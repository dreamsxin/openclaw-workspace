import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "../..");
const characterRoot = path.join(root, "godot-project/assets/characters");
const sourceTextRoot = path.join(root, "reverse-output/assets/assetripper-primary/Assets/TextAsset");
const sourceTextureRoot = path.join(root, "reverse-output/assets/assetripper-primary/Assets/Texture2D");
const auditPath = path.join(root, "reverse-output/assets/derived/character_atlas_page_sync_manifest.json");

function walkFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) results.push(...walkFiles(fullPath));
    else results.push(fullPath);
  }
  return results;
}

function rel(absPath) {
  return path.relative(root, absPath).replaceAll("\\", "/");
}

function pngSize(filePath) {
  const data = fs.readFileSync(filePath);
  if (data.length < 24 || data.toString("ascii", 1, 4) !== "PNG") return null;
  return { width: data.readUInt32BE(16), height: data.readUInt32BE(20) };
}

function atlasSize(atlasText) {
  const match = atlasText.match(/^size:(\d+),(\d+)$/m);
  if (!match) return null;
  return { width: Number(match[1]), height: Number(match[2]) };
}

function extractAtlasPages(atlasText) {
  const pages = [];
  for (const rawLine of atlasText.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (/^[^:]+\.(png|jpg|jpeg|webp|tga)$/i.test(line)) pages.push(line);
  }
  return [...new Set(pages)];
}

function sameSize(left, right) {
  return left && right && left.width === right.width && left.height === right.height;
}

function sync() {
  const synced = [];
  const skipped = [];
  const pngs = walkFiles(characterRoot).filter((item) => item.toLowerCase().endsWith(".png"));
  for (const targetPath of pngs) {
    const baseName = path.basename(targetPath, ".png");
    const atlasPath = path.join(sourceTextRoot, `${baseName}.atlas.bytes`);
    if (!fs.existsSync(atlasPath)) continue;

    const atlasText = fs.readFileSync(atlasPath, "utf8");
    const expectedSize = atlasSize(atlasText);
    const pages = extractAtlasPages(atlasText);
    if (pages.length !== 1 || pages[0] !== path.basename(targetPath)) {
      skipped.push({
        target: rel(targetPath),
        reason: "atlas page list does not match target filename",
        pages,
      });
      continue;
    }

    const currentSize = pngSize(targetPath);
    if (sameSize(currentSize, expectedSize)) {
      skipped.push({
        target: rel(targetPath),
        reason: "already matches atlas size",
        size: currentSize,
      });
      continue;
    }

    const sourcePath = path.join(sourceTextureRoot, path.basename(targetPath));
    if (!fs.existsSync(sourcePath)) {
      skipped.push({
        target: rel(targetPath),
        reason: "missing AssetRipper Texture2D source",
        expectedSize,
      });
      continue;
    }
    const sourceSize = pngSize(sourcePath);
    if (!sameSize(sourceSize, expectedSize)) {
      skipped.push({
        target: rel(targetPath),
        source: rel(sourcePath),
        reason: "AssetRipper Texture2D size does not match atlas size",
        expectedSize,
        sourceSize,
      });
      continue;
    }

    fs.copyFileSync(sourcePath, targetPath);
    synced.push({
      target: rel(targetPath),
      source: rel(sourcePath),
      previousSize: currentSize,
      atlasSize: expectedSize,
    });
  }

  fs.mkdirSync(path.dirname(auditPath), { recursive: true });
  fs.writeFileSync(
    auditPath,
    JSON.stringify(
      {
        schema: "openclaw-character-atlas-page-sync-v1",
        generated_by: "scripts/reverse/sync_character_atlas_pages.mjs",
        sourceTextureRoot: rel(sourceTextureRoot),
        totals: {
          synced: synced.length,
          skipped: skipped.length,
        },
        synced,
        skipped,
      },
      null,
      2,
    ) + "\n",
    "utf8",
  );

  console.log(`synced ${synced.length} atlas pages; skipped ${skipped.length}`);
  for (const item of synced) {
    console.log(`${item.target}: ${item.previousSize.width}x${item.previousSize.height} -> ${item.atlasSize.width}x${item.atlasSize.height}`);
  }
}

sync();
