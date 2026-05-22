const fs = require("fs");
const path = require("path");

const [inputDir, outputDir] = process.argv.slice(2);
if (!inputDir || !outputDir) {
  console.error("Usage: node extract-textasset-dll.js <assetstudio TextAsset dir> <output dir>");
  process.exit(2);
}

function align4(n) {
  return (n + 3) & ~3;
}

function readTextAssetRaw(filePath) {
  const data = fs.readFileSync(filePath);
  if (data.length < 8) throw new Error("too short");
  const nameLen = data.readInt32LE(0);
  if (nameLen < 0 || nameLen > data.length - 4) throw new Error(`bad name length ${nameLen}`);
  const nameStart = 4;
  const nameEnd = nameStart + nameLen;
  const name = data.slice(nameStart, nameEnd).toString("utf8").replace(/\0+$/g, "");
  const scriptLenOffset = align4(nameEnd);
  if (scriptLenOffset + 4 > data.length) throw new Error("missing script length");
  const scriptLen = data.readInt32LE(scriptLenOffset);
  const scriptStart = scriptLenOffset + 4;
  const scriptEnd = scriptStart + scriptLen;
  if (scriptLen < 0 || scriptEnd > data.length) {
    throw new Error(`bad script length ${scriptLen} at ${scriptLenOffset}, file length ${data.length}`);
  }
  return { name, script: data.slice(scriptStart, scriptEnd), scriptStart, scriptLen };
}

fs.mkdirSync(outputDir, { recursive: true });
const rows = [];
for (const entry of fs.readdirSync(inputDir, { withFileTypes: true })) {
  if (!entry.isFile() || !entry.name.toLowerCase().endsWith(".dat")) continue;
  const inputPath = path.join(inputDir, entry.name);
  try {
    const parsed = readTextAssetRaw(inputPath);
    const safeName = (parsed.name || path.basename(entry.name, ".dat")).replace(/[<>:"/\\|?*\x00-\x1f]/g, "_");
    const ext = parsed.script.slice(0, 2).toString("ascii") === "MZ" ? ".dll" : ".bytes";
    const outPath = path.join(outputDir, `${safeName}${ext}`);
    fs.writeFileSync(outPath, parsed.script);
    rows.push({ input: inputPath, name: parsed.name, output: outPath, scriptStart: parsed.scriptStart, scriptLen: parsed.scriptLen, magic: parsed.script.slice(0, 8).toString("hex") });
    console.log(`extracted ${parsed.name} len=${parsed.scriptLen} -> ${outPath}`);
  } catch (error) {
    console.error(`skip ${inputPath}: ${error.message}`);
  }
}
fs.writeFileSync(path.join(outputDir, "extract-summary.json"), JSON.stringify(rows, null, 2), "utf8");
