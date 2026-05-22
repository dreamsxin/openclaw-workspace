const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const [unpackDir, sourceDir, outDir] = process.argv.slice(2);
if (!unpackDir || !sourceDir || !outDir) {
  console.error("Usage: node analyze-unpack-cache.js <UnpackBundleFiles> <sourceBundleDir> <outDir>");
  process.exit(2);
}

fs.mkdirSync(outDir, { recursive: true });

function walk(dir, acc = []) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) walk(p, acc);
    else acc.push(p);
  }
  return acc;
}
function md5(file) {
  return crypto.createHash("md5").update(fs.readFileSync(file)).digest("hex");
}
function headHex(file, n = 8) {
  return fs.readFileSync(file).subarray(0, n).toString("hex").match(/../g).join(" ");
}
function csvEscape(v) {
  const s = String(v ?? "");
  return /[",\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}
function writeCsv(file, rows, headers) {
  fs.writeFileSync(path.join(outDir, file), [headers.join(","), ...rows.map((r) => headers.map((h) => csvEscape(r[h])).join(","))].join("\n"), "utf8");
}

const dataFiles = walk(unpackDir).filter((p) => path.basename(p) === "__data");
const rows = dataFiles.map((p) => {
  const hash = path.basename(path.dirname(p));
  const source = path.join(sourceDir, `${hash}.bundle`);
  const info = path.join(path.dirname(p), "__info");
  const sourceExists = fs.existsSync(source);
  const dataHash = md5(p);
  const sourceHash = sourceExists ? md5(source) : "";
  return {
    hash,
    dataPath: p,
    infoPath: fs.existsSync(info) ? info : "",
    length: fs.statSync(p).size,
    head: headHex(p),
    dataMd5: dataHash,
    sourceExists,
    sourceMd5: sourceHash,
    sameAsSource: sourceExists && dataHash.toLowerCase() === sourceHash.toLowerCase(),
  };
}).sort((a, b) => Number(b.length) - Number(a.length));

const sourceHashes = new Set(fs.readdirSync(sourceDir).filter((f) => f.endsWith(".bundle")).map((f) => path.basename(f, ".bundle")));
const unpackHashes = new Set(rows.map((r) => r.hash));
const missingInUnpack = [...sourceHashes].filter((h) => !unpackHashes.has(h)).sort().map((hash) => ({
  hash,
  sourcePath: path.join(sourceDir, `${hash}.bundle`),
  length: fs.statSync(path.join(sourceDir, `${hash}.bundle`)).size,
}));

writeCsv("unpack-cache-bundles.csv", rows, ["hash", "length", "head", "dataMd5", "sourceExists", "sourceMd5", "sameAsSource", "dataPath", "infoPath"]);
writeCsv("unpack-missing-source-bundles.csv", missingInUnpack, ["hash", "length", "sourcePath"]);

console.log(`unpackData=${rows.length}`);
console.log(`sourceBundles=${sourceHashes.size}`);
console.log(`missingInUnpack=${missingInUnpack.length}`);
console.log(`sameAsSource=${rows.filter((r) => r.sameAsSource).length}`);
