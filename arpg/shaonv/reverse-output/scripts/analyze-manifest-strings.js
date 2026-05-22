const fs = require("fs");
const path = require("path");

const [stringsPath, outDir] = process.argv.slice(2);
if (!stringsPath || !outDir) {
  console.error("Usage: node analyze-manifest-strings.js <strings.txt> <outDir>");
  process.exit(2);
}

fs.mkdirSync(outDir, { recursive: true });

const lines = fs.readFileSync(stringsPath, "utf8").split(/\r?\n/).filter(Boolean);
const assets = [...new Set(lines.filter((line) => line.startsWith("Assets/")))];

function csvEscape(v) {
  const s = String(v ?? "");
  return /[",\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

function writeCsv(file, rows, headers) {
  const body = [headers.join(",")];
  for (const row of rows) {
    body.push(headers.map((h) => csvEscape(row[h])).join(","));
  }
  fs.writeFileSync(path.join(outDir, file), body.join("\n"), "utf8");
}

function extOf(p) {
  return path.posix.extname(p).toLowerCase() || "(none)";
}

function topDir(p, depth = 4) {
  return p.split("/").slice(0, depth).join("/");
}

const extensionStats = [...assets.reduce((m, p) => {
  const ext = extOf(p);
  m.set(ext, (m.get(ext) || 0) + 1);
  return m;
}, new Map()).entries()]
  .sort((a, b) => b[1] - a[1])
  .map(([extension, count]) => ({ extension, count }));

const dirStats = [...assets.reduce((m, p) => {
  const dir = topDir(p, 4);
  m.set(dir, (m.get(dir) || 0) + 1);
  return m;
}, new Map()).entries()]
  .sort((a, b) => b[1] - a[1])
  .map(([directory, count]) => ({ directory, count }));

const uiRe = /(^|\/)(ui|UI|Ui)(\/|_|[A-Z])|UIPopup|UITutorial|UILobby|View|Panel|Popup|Dialog|HUD|Window|Btn|Button|Icon|Common|Reward|Shop|Mail|Task|Battle/i;
const guideRe = /Guide|Novice|Dialogue|Tutorial/i;
const sceneRe = /\.unity$/i;
const dllRe = /\.(dll|bytes)$/i;
const configRe = /Config|Cfg|Setting|Table|Json|Lang|I18N|GuideGraph/i;

const rows = assets.map((p) => ({
  path: p,
  extension: extOf(p),
  directory: topDir(p, 5),
  category: sceneRe.test(p) ? "scene"
    : /\.prefab$/i.test(p) && uiRe.test(p) ? "ui_prefab_candidate"
    : uiRe.test(p) ? "ui_asset_candidate"
    : guideRe.test(p) ? "guide"
    : dllRe.test(p) ? "dll_or_bytes"
    : configRe.test(p) ? "config"
    : /\.prefab$/i.test(p) ? "prefab"
    : "asset",
}));

writeCsv("manifest-assets.csv", rows, ["path", "extension", "directory", "category"]);
writeCsv("manifest-extension-stats.csv", extensionStats, ["extension", "count"]);
writeCsv("manifest-directory-stats.csv", dirStats, ["directory", "count"]);
writeCsv("manifest-ui-candidates.csv", rows.filter((r) => r.category.includes("ui_")), ["path", "extension", "directory", "category"]);
writeCsv("manifest-scenes.csv", rows.filter((r) => r.category === "scene"), ["path", "extension", "directory", "category"]);
writeCsv("manifest-dll-bytes.csv", rows.filter((r) => r.category === "dll_or_bytes" || /HotFix|PatchAOT|Assembly-CSharp|WorldMap/i.test(r.path)), ["path", "extension", "directory", "category"]);
writeCsv("manifest-guide-assets.csv", rows.filter((r) => r.category === "guide" || /Guide|Tutorial|Novice|Dialogue/i.test(r.path)), ["path", "extension", "directory", "category"]);

console.log(`assets=${assets.length}`);
console.log(`ui_candidates=${rows.filter((r) => r.category.includes("ui_")).length}`);
console.log(`scenes=${rows.filter((r) => r.category === "scene").length}`);
console.log(`dll_or_bytes=${rows.filter((r) => r.category === "dll_or_bytes" || /HotFix|PatchAOT|Assembly-CSharp|WorldMap/i.test(r.path)).length}`);
