import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  AnimationState,
  AnimationStateData,
  AtlasAttachmentLoader,
  MeshAttachment,
  Physics,
  RegionAttachment,
  Skeleton,
  SkeletonBinary,
  TextureAtlas,
} from "../../tools/spine-baker-js/node_modules/@esotericsoftware/spine-core/dist/index.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "../..");
const characterRoot = path.join(root, "godot-project/assets/characters");
const sourceTextRoot = path.join(root, "reverse-output/assets/assetripper-primary/Assets/TextAsset");
const manifestPath = path.join(root, "godot-project/data/character_spine_browser.json");
const auditPath = path.join(root, "reverse-output/assets/derived/character_spine_preview_bake_manifest.json");

const preferredClipNames = [
  "01 Idle",
  "Idle",
  "idle",
  "02 Ready",
  "02 Ready_ef",
  "03 Interaction",
  "Interaction",
  "05 Interaction2",
  "04 Complete_Ready",
];
const fps = numberArg("--fps=", 10);
const maxDuration = numberArg("--max-duration=", 1.2);
const maxClips = numberArg("--max-clips=", 2);

function numberArg(prefix, fallback) {
  const arg = process.argv.find((item) => item.startsWith(prefix));
  if (!arg) return fallback;
  const value = Number(arg.slice(prefix.length));
  return Number.isFinite(value) && value > 0 ? value : fallback;
}

function round(value, digits = 3) {
  const scale = 10 ** digits;
  return Math.round(value * scale) / scale;
}

function walkFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...walkFiles(fullPath));
    } else {
      results.push(fullPath);
    }
  }
  return results;
}

function relProjectPath(absPath) {
  return path.relative(root, absPath).replaceAll("\\", "/");
}

function resPath(absPath) {
  const projectRelative = path.relative(path.join(root, "godot-project"), absPath).replaceAll("\\", "/");
  return `res://${projectRelative}`;
}

function extractAtlasPages(atlasText) {
  const pages = [];
  for (const rawLine of atlasText.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (/^[^:]+\.(png|jpg|jpeg|webp|tga)$/i.test(line)) {
      pages.push(line);
    }
  }
  return [...new Set(pages)];
}

function collectCandidates() {
  const byBase = new Map();
  for (const filePath of walkFiles(characterRoot)) {
    if (!filePath.toLowerCase().endsWith(".png")) continue;
    const base = path.basename(filePath, ".png");
    if (!byBase.has(base)) byBase.set(base, []);
    byBase.get(base).push(filePath);
  }

  const candidates = [];
  for (const [base, pngPaths] of byBase) {
    const skelPath = path.join(sourceTextRoot, `${base}.skel.bytes`);
    const atlasPath = path.join(sourceTextRoot, `${base}.atlas.bytes`);
    if (!fs.existsSync(skelPath) || !fs.existsSync(atlasPath)) continue;
    const primaryPng = pngPaths[0];
    const categoryDir = path.dirname(primaryPng);
    candidates.push({
      base,
      category: path.relative(characterRoot, categoryDir).replaceAll("\\", "/"),
      categoryDir,
      skelPath,
      atlasPath,
      primaryPng,
    });
  }
  return candidates.sort((a, b) => `${a.category}/${a.base}`.localeCompare(`${b.category}/${b.base}`));
}

function resolveAtlasPagePaths(candidate, atlasPages) {
  const pages = {};
  for (const pageName of atlasPages) {
    const directPath = path.join(candidate.categoryDir, pageName);
    if (fs.existsSync(directPath)) {
      pages[pageName] = resPath(directPath);
      continue;
    }
    const fallbackPath = path.join(candidate.categoryDir, `${candidate.base}.png`);
    if (fs.existsSync(fallbackPath) && atlasPages.length === 1) {
      pages[pageName] = resPath(fallbackPath);
      continue;
    }
    return { ok: false, missing: pageName };
  }
  return { ok: true, pages };
}

function loadSkeleton(candidate, atlasText) {
  const atlas = new TextureAtlas(atlasText);
  const loader = new AtlasAttachmentLoader(atlas);
  const binary = new SkeletonBinary(loader);
  const skeletonData = binary.readSkeletonData(new Uint8Array(fs.readFileSync(candidate.skelPath)));
  const skeleton = new Skeleton(skeletonData);
  skeleton.setToSetupPose();
  skeleton.updateWorldTransform(Physics.update);
  return { skeletonData, skeleton };
}

function chooseClipNames(skeletonData) {
  const available = skeletonData.animations.map((animation) => animation.name);
  const selected = [];
  for (const preferred of preferredClipNames) {
    if (available.includes(preferred) && !selected.includes(preferred)) selected.push(preferred);
    if (selected.length >= maxClips) break;
  }
  for (const name of available) {
    if (!selected.includes(name)) selected.push(name);
    if (selected.length >= maxClips) break;
  }
  return selected;
}

function attachmentFrame(slot) {
  const attachment = slot.getAttachment();
  if (!attachment) return null;

  if (attachment instanceof RegionAttachment) {
    attachment.updateRegion();
    const vertices = new Array(8).fill(0);
    attachment.computeWorldVertices(slot, vertices, 0, 2);
    const region = attachment.region;
    return {
      kind: "region",
      slot: slot.data.name,
      bone: slot.bone.data.name,
      attachment: attachment.name,
      path: attachment.path,
      page: region?.page?.name ?? "",
      vertices: vertices.map((value) => round(value)),
      uvs: Array.from(attachment.uvs).map((value) => round(value, 6)),
      triangles: [0, 1, 2, 0, 2, 3],
      color: [slot.color.r, slot.color.g, slot.color.b, slot.color.a].map((value) => round(value, 4)),
    };
  }

  if (attachment instanceof MeshAttachment) {
    attachment.updateRegion();
    const count = attachment.worldVerticesLength;
    const vertices = new Array(count).fill(0);
    attachment.computeWorldVertices(slot, 0, count, vertices, 0, 2);
    const region = attachment.region;
    return {
      kind: "mesh",
      slot: slot.data.name,
      bone: slot.bone.data.name,
      attachment: attachment.name,
      path: attachment.path,
      page: region?.page?.name ?? "",
      vertices: vertices.map((value) => round(value)),
      uvs: Array.from(attachment.uvs).map((value) => round(value, 6)),
      triangles: Array.from(attachment.triangles),
      color: [slot.color.r, slot.color.g, slot.color.b, slot.color.a].map((value) => round(value, 4)),
    };
  }

  return null;
}

function captureFrame(skeleton, time) {
  skeleton.updateWorldTransform(Physics.update);
  const attachments = [];
  for (const slot of skeleton.drawOrder) {
    const frame = attachmentFrame(slot);
    if (frame) attachments.push(frame);
  }
  return { time: round(time, 4), attachments };
}

function compactFrames(rawFrames) {
  const attachments = [];
  const attachmentIndex = new Map();
  const frames = [];
  for (const rawFrame of rawFrames) {
    const frameItems = [];
    for (const item of rawFrame.attachments) {
      const key = `${item.kind}\u0000${item.slot}\u0000${item.attachment}\u0000${item.path}\u0000${item.page}`;
      let index = attachmentIndex.get(key);
      if (index === undefined) {
        index = attachments.length;
        attachmentIndex.set(key, index);
        attachments.push({
          kind: item.kind,
          slot: item.slot,
          bone: item.bone,
          attachment: item.attachment,
          path: item.path,
          page: item.page,
          uvs: item.uvs,
          triangles: item.triangles,
          color: item.color,
        });
      }
      frameItems.push([index, item.vertices]);
    }
    frames.push({ time: rawFrame.time, items: frameItems });
  }
  return { attachments, frames };
}

function computeBounds(frames) {
  let minX = Number.POSITIVE_INFINITY;
  let minY = Number.POSITIVE_INFINITY;
  let maxX = Number.NEGATIVE_INFINITY;
  let maxY = Number.NEGATIVE_INFINITY;
  for (const frame of frames) {
    for (const [, vertices] of frame.items) {
      for (let i = 0; i + 1 < vertices.length; i += 2) {
        const x = vertices[i];
        const y = vertices[i + 1];
        minX = Math.min(minX, x);
        minY = Math.min(minY, y);
        maxX = Math.max(maxX, x);
        maxY = Math.max(maxY, y);
      }
    }
  }
  if (!Number.isFinite(minX) || !Number.isFinite(minY) || !Number.isFinite(maxX) || !Number.isFinite(maxY)) {
    return { minX: 0, minY: 0, maxX: 0, maxY: 0, width: 0, height: 0 };
  }
  return {
    minX: round(minX),
    minY: round(minY),
    maxX: round(maxX),
    maxY: round(maxY),
    width: round(maxX - minX),
    height: round(maxY - minY),
  };
}

function bakeAnimationClip(skeletonData, animationName) {
  const animation = skeletonData.findAnimation(animationName);
  const duration = Math.min(animation?.duration ?? 0, maxDuration);
  const frameCount = Math.max(1, Math.ceil((duration || 1 / fps) * fps));
  const stateData = new AnimationStateData(skeletonData);
  const state = new AnimationState(stateData);
  const skeleton = new Skeleton(skeletonData);
  state.setAnimation(0, animationName, true);
  const rawFrames = [];
  for (let frameIndex = 0; frameIndex < frameCount; frameIndex++) {
    const time = frameIndex / fps;
    skeleton.setToSetupPose();
    state.update(frameIndex === 0 ? 0 : 1 / fps);
    state.apply(skeleton);
    rawFrames.push(captureFrame(skeleton, time));
  }
  const compact = compactFrames(rawFrames);
  return {
    name: animationName,
    fps,
    duration: round(duration, 4),
    frameCount,
    bounds: computeBounds(compact.frames),
    attachments: compact.attachments,
    frames: compact.frames,
  };
}

function bakeCandidate(candidate) {
  const atlasText = fs.readFileSync(candidate.atlasPath, "utf8");
  const atlasPages = extractAtlasPages(atlasText);
  const resolvedPages = resolveAtlasPagePaths(candidate, atlasPages);
  if (!resolvedPages.ok) {
    throw new Error(`missing committed atlas page ${resolvedPages.missing}`);
  }
  const { skeletonData } = loadSkeleton(candidate, atlasText);
  const clipNames = chooseClipNames(skeletonData);
  if (clipNames.length === 0) {
    throw new Error("skeleton has no animations");
  }

  const clips = {};
  for (const clipName of clipNames) {
    clips[clipName] = bakeAnimationClip(skeletonData, clipName);
  }
  const defaultClipName = clipNames[0];
  const outPath = path.join(candidate.categoryDir, `${candidate.base}.baked.json`);
  const output = {
    schema: "openclaw-character-spine-preview-v1",
    source: {
      atlas: relProjectPath(candidate.atlasPath),
      skeleton: relProjectPath(candidate.skelPath),
      runtime: "@esotericsoftware/spine-core@4.2.43",
    },
    character: {
      name: candidate.base,
      category: candidate.category,
      pages: resolvedPages.pages,
    },
    skeleton: {
      version: skeletonData.version,
      hash: skeletonData.hash,
      width: round(skeletonData.width),
      height: round(skeletonData.height),
      bones: skeletonData.bones.length,
      slots: skeletonData.slots.length,
      skins: skeletonData.skins.map((skin) => skin.name),
      animations: skeletonData.animations.map((animation) => ({
        name: animation.name,
        duration: round(animation.duration, 4),
        timelines: animation.timelines.length,
      })),
    },
    bake: {
      fps,
      maxDuration,
      maxClips,
      defaultClip: defaultClipName,
      bakedClips: clipNames,
      coordinateSystem: "Spine world coordinates; Godot flips Y at render time.",
    },
    clips,
  };
  fs.writeFileSync(outPath, JSON.stringify(output) + "\n", "utf8");
  return {
    name: candidate.base,
    category: candidate.category,
    baked_path: resPath(outPath),
    page_paths: resolvedPages.pages,
    skeleton: output.skeleton,
    default_clip: defaultClipName,
    baked_clips: clipNames,
    source_skel: relProjectPath(candidate.skelPath),
    source_atlas: relProjectPath(candidate.atlasPath),
    output: relProjectPath(outPath),
  };
}

function main() {
  const candidates = collectCandidates();
  const characters = [];
  const failures = [];
  fs.mkdirSync(path.dirname(auditPath), { recursive: true });

  for (const candidate of candidates) {
    try {
      const entry = bakeCandidate(candidate);
      characters.push(entry);
      console.log(`baked ${entry.category}/${entry.name}: ${entry.baked_clips.join(", ")}`);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      failures.push({
        name: candidate.base,
        category: candidate.category,
        atlas: relProjectPath(candidate.atlasPath),
        skeleton: relProjectPath(candidate.skelPath),
        error: message,
      });
      console.warn(`failed ${candidate.category}/${candidate.base}: ${message}`);
    }
  }

  const manifest = {
    schema: "openclaw-character-spine-browser-v1",
    generated_by: "scripts/reverse/bake_character_spine_previews.mjs",
    runtime: "@esotericsoftware/spine-core@4.2.43",
    bake: {
      fps,
      maxDuration,
      maxClips,
      sourceTextRoot: relProjectPath(sourceTextRoot),
    },
    totals: {
      candidates: candidates.length,
      baked: characters.length,
      failed: failures.length,
    },
    characters,
    failures,
  };
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + "\n", "utf8");
  fs.writeFileSync(auditPath, JSON.stringify(manifest, null, 2) + "\n", "utf8");
  console.log(`wrote ${relProjectPath(manifestPath)} with ${characters.length}/${candidates.length} baked characters`);
}

main();
