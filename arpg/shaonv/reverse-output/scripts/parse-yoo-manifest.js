const fs = require("fs");
const path = require("path");

const [manifestPath, outDir] = process.argv.slice(2);
if (!manifestPath || !outDir) {
  console.error("Usage: node parse-yoo-manifest.js <manifest.bytes> <outDir>");
  process.exit(2);
}

const data = fs.readFileSync(manifestPath);
let off = 0;

function u8() { return data[off++]; }
function bool() { return u8() === 1; }
function i32() { const v = data.readInt32LE(off); off += 4; return v; }
function u32() { const v = data.readUInt32LE(off); off += 4; return v; }
function i64() { const v = Number(data.readBigInt64LE(off)); off += 8; return v; }
function str() {
  const n = i32();
  if (n === 0) return "";
  const v = data.toString("utf8", off, off + n);
  off += n;
  return v;
}
function strArray() {
  const n = i32();
  const a = [];
  for (let i = 0; i < n; i++) a.push(str());
  return a;
}
function i32Array() {
  const n = i32();
  const a = [];
  for (let i = 0; i < n; i++) a.push(i32());
  return a;
}
function remoteFileName(outputNameStyle, bundleName, fileHash) {
  const ext = path.posix.extname(bundleName);
  if (outputNameStyle === 1) return `${fileHash}${ext}`;
  if (outputNameStyle === 2) return bundleName;
  if (outputNameStyle === 3) {
    if (!ext) return `${bundleName}_${fileHash}`;
    return `${bundleName.slice(0, -ext.length)}_${fileHash}${ext}`;
  }
  return `${fileHash}${ext}`;
}
function csvEscape(v) {
  const s = String(v ?? "");
  return /[",\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}
function writeCsv(file, rows, headers) {
  fs.writeFileSync(
    path.join(outDir, file),
    [headers.join(","), ...rows.map((r) => headers.map((h) => csvEscape(r[h])).join(","))].join("\n"),
    "utf8"
  );
}

fs.mkdirSync(outDir, { recursive: true });

const sign = u32();
if (sign !== 0x00594f4f) {
  throw new Error(`Invalid manifest sign 0x${sign.toString(16)} at ${manifestPath}`);
}

const manifest = {
  fileVersion: str(),
  enableAddressable: bool(),
  supportExtensionless: bool(),
  locationToLower: bool(),
  includeAssetGUID: bool(),
  replaceAssetPathWithAddress: bool(),
  outputNameStyle: i32(),
  buildBundleType: i32(),
  buildPipeline: str(),
  packageName: str(),
  packageVersion: str(),
  packageNote: str(),
};

const assetCount = i32();
const assets = [];
for (let i = 0; i < assetCount; i++) {
  assets.push({
    id: i,
    address: str(),
    assetPath: str(),
    assetGUID: str(),
    assetTags: strArray().join("|"),
    bundleID: i32(),
    dependBundleIDs: i32Array().join("|"),
  });
}

const bundleCount = i32();
const bundles = [];
for (let i = 0; i < bundleCount; i++) {
  const bundleName = str();
  const unityCRC = u32();
  const fileHash = str();
  const fileCRC = u32();
  const fileSize = i64();
  const encrypted = bool();
  const tags = strArray();
  const dependBundleIDs = i32Array();
  bundles.push({
    id: i,
    bundleName,
    unityCRC,
    fileHash,
    fileCRC,
    fileSize,
    encrypted,
    tags: tags.join("|"),
    dependBundleIDs: dependBundleIDs.join("|"),
    fileName: remoteFileName(manifest.outputNameStyle, bundleName, fileHash),
  });
}

const rows = assets.map((a) => {
  const b = bundles[a.bundleID] || {};
  return {
    assetPath: a.assetPath,
    address: a.address,
    assetTags: a.assetTags,
    bundleID: a.bundleID,
    bundleName: b.bundleName || "",
    fileName: b.fileName || "",
    fileHash: b.fileHash || "",
    fileSize: b.fileSize || "",
    encrypted: b.encrypted ?? "",
    dependBundleIDs: a.dependBundleIDs,
  };
});

writeCsv("manifest-parsed-assets.csv", rows, ["assetPath", "address", "assetTags", "bundleID", "bundleName", "fileName", "fileHash", "fileSize", "encrypted", "dependBundleIDs"]);
writeCsv("manifest-parsed-bundles.csv", bundles, ["id", "bundleName", "fileName", "fileHash", "fileSize", "encrypted", "tags", "dependBundleIDs", "unityCRC", "fileCRC"]);
fs.writeFileSync(path.join(outDir, "manifest-parsed-summary.json"), JSON.stringify({ ...manifest, assetCount, bundleCount, endOffset: off, fileSize: data.length }, null, 2), "utf8");

console.log(JSON.stringify({ ...manifest, assetCount, bundleCount, endOffset: off, fileSize: data.length }, null, 2));
