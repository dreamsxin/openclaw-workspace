const fs = require("fs");
const path = require("path");

const [catalogPath, sourceDir, outputDir, keyArg] = process.argv.slice(2);
if (!catalogPath || !sourceDir || !outputDir) {
  console.error("Usage: node decrypt-yoo-xor16.js <catalog.json> <sourceDir> <outputDir> [keyHex]");
  process.exit(2);
}

const key = keyArg ? Number.parseInt(keyArg, 16) : 0x16;
fs.mkdirSync(outputDir, { recursive: true });

const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
let decoded = 0;
let skipped = 0;

for (const wrapper of catalog.Wrappers || []) {
  const fileName = wrapper.FileName;
  if (!fileName) {
    skipped++;
    continue;
  }

  const src = path.join(sourceDir, fileName);
  const dst = path.join(outputDir, fileName);
  if (!fs.existsSync(src)) {
    console.error(`missing: ${src}`);
    skipped++;
    continue;
  }

  const data = fs.readFileSync(src);
  for (let i = 0; i < data.length; i++) {
    data[i] ^= key;
  }
  fs.writeFileSync(dst, data);
  decoded++;

  if (decoded % 50 === 0) {
    console.log(`decoded ${decoded} files...`);
  }
}

fs.copyFileSync(catalogPath, path.join(outputDir, "BuildinCatalog.json"));
const versionPath = path.join(sourceDir, "Default.version");
if (fs.existsSync(versionPath)) {
  fs.copyFileSync(versionPath, path.join(outputDir, "Default.version"));
}

console.log(`done decoded=${decoded} skipped=${skipped} output=${path.resolve(outputDir)} key=0x${key.toString(16)}`);
