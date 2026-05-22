const fs = require("fs");
const path = require("path");

const [inputPath, outputDir] = process.argv.slice(2);
if (!inputPath || !outputDir) {
  console.error("Usage: node carve-pe-from-bundle.js <bundle-or-data-file> <output dir>");
  process.exit(2);
}

function u16(buf, off) { return buf.readUInt16LE(off); }
function u32(buf, off) { return buf.readUInt32LE(off); }

function tryParsePe(buf, mz) {
  if (mz + 0x40 > buf.length || buf[mz] !== 0x4d || buf[mz + 1] !== 0x5a) return null;
  const peOff = u32(buf, mz + 0x3c);
  const pe = mz + peOff;
  if (peOff < 0x40 || pe + 0x18 > buf.length) return null;
  if (buf[pe] !== 0x50 || buf[pe + 1] !== 0x45 || buf[pe + 2] !== 0 || buf[pe + 3] !== 0) return null;
  const numberOfSections = u16(buf, pe + 6);
  const sizeOfOptionalHeader = u16(buf, pe + 20);
  const opt = pe + 24;
  const sectionTable = opt + sizeOfOptionalHeader;
  if (numberOfSections <= 0 || numberOfSections > 96 || sectionTable + numberOfSections * 40 > buf.length) return null;
  const magic = u16(buf, opt);
  if (magic !== 0x10b && magic !== 0x20b) return null;
  const sizeOfImage = u32(buf, opt + 56);
  let rawEnd = 0;
  const sections = [];
  for (let i = 0; i < numberOfSections; i++) {
    const off = sectionTable + i * 40;
    const name = buf.slice(off, off + 8).toString("ascii").replace(/\0+$/g, "");
    const sizeOfRawData = u32(buf, off + 16);
    const pointerToRawData = u32(buf, off + 20);
    if (pointerToRawData > 0 && sizeOfRawData > 0) {
      rawEnd = Math.max(rawEnd, pointerToRawData + sizeOfRawData);
    }
    sections.push({ name, sizeOfRawData, pointerToRawData });
  }
  if (rawEnd <= 0 || mz + rawEnd > buf.length) return null;
  const bytes = buf.slice(mz, mz + rawEnd);
  const ascii = bytes.toString("latin1");
  let name = "unknown";
  const versionInfo = ascii.match(/I\x00n\x00t\x00e\x00r\x00n\x00a\x00l\x00N\x00a\x00m\x00e\x00\x00\x00([\s\S]{0,160}?\.dll)\x00/i);
  if (versionInfo) {
    name = Buffer.from(versionInfo[1], "latin1").toString("utf16le").replace(/\0/g, "");
  } else {
    const simple = ascii.match(/([A-Za-z0-9_.-]{2,80})\.dll/);
    if (simple) name = `${simple[1]}.dll`;
  }
  return { offset: mz, rawEnd, sizeOfImage, numberOfSections, sections, bytes, name };
}

fs.mkdirSync(outputDir, { recursive: true });
const data = fs.readFileSync(inputPath);
const rows = [];
for (let i = 0; i < data.length - 1; i++) {
  if (data[i] !== 0x4d || data[i + 1] !== 0x5a) continue;
  const pe = tryParsePe(data, i);
  if (!pe) continue;
  let fileName = pe.name || `pe_${pe.offset}.dll`;
  fileName = fileName.replace(/[<>:"/\\|?*\x00-\x1f]/g, "_");
  if (!fileName.toLowerCase().endsWith(".dll")) fileName += ".dll";
  const outPath = path.join(outputDir, `${String(pe.offset).padStart(8, "0")}_${fileName}`);
  fs.writeFileSync(outPath, pe.bytes);
  rows.push({
    offset: pe.offset,
    output: outPath,
    name: pe.name,
    length: pe.rawEnd,
    sizeOfImage: pe.sizeOfImage,
    numberOfSections: pe.numberOfSections,
    sections: pe.sections,
  });
  console.log(`carved offset=${pe.offset} len=${pe.rawEnd} name=${pe.name} -> ${outPath}`);
}
fs.writeFileSync(path.join(outputDir, "carve-summary.json"), JSON.stringify(rows, null, 2), "utf8");
console.log(`done count=${rows.length}`);
