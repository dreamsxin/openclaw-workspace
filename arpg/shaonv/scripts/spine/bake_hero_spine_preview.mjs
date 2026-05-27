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
const projectRoot = path.join(root, "standalone/godot-mvp");
const heroName = stringArg("--hero=", "hero_016");
const spineDirArg = stringArg("--dir=", "");
const sourceKey = stringArg("--key=", heroName);
const fps = numberArg("--fps=", 8);
const maxDuration = numberArg("--max-duration=", 1.2);
const maxClips = numberArg("--max-clips=", 2);
const explicitClips = listArg("--clips=");
const heroDir = spineDirArg
  ? path.resolve(projectRoot, spineDirArg.replace(/^res:\/\//, ""))
  : path.join(projectRoot, "assets/spine", heroName);

const preferredClipNames = [
  "Idle",
  "idle",
  "01 Idle",
  "wait",
  "Wait",
  "wait1",
  "stand",
  "Stand",
  "show",
  "Show",
  "animation",
  "Animation",
];

function stringArg(prefix, fallback) {
  const arg = process.argv.find((item) => item.startsWith(prefix));
  return arg ? arg.slice(prefix.length) : fallback;
}

function numberArg(prefix, fallback) {
  const arg = process.argv.find((item) => item.startsWith(prefix));
  if (!arg) return fallback;
  const value = Number(arg.slice(prefix.length));
  return Number.isFinite(value) && value > 0 ? value : fallback;
}

function listArg(prefix) {
  const arg = process.argv.find((item) => item.startsWith(prefix));
  if (!arg) return [];
  return arg
    .slice(prefix.length)
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

function round(value, digits = 3) {
  const scale = 10 ** digits;
  return Math.round(value * scale) / scale;
}

function resPath(absPath) {
  return `res://${path.relative(projectRoot, absPath).replaceAll("\\", "/")}`;
}

function extractAtlasPages(atlasText) {
  const pages = [];
  const lines = atlasText.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!/^[^:]+\.(png|jpg|jpeg|webp|tga)$/i.test(line)) continue;
    const next = lines.slice(i + 1).map((item) => item.trim()).find((item) => item.length > 0) ?? "";
    if (next.toLowerCase().startsWith("size:")) pages.push(line);
  }
  return [...new Set(pages)];
}

function loadSkeleton(skelPath, atlasText) {
  const atlas = new TextureAtlas(atlasText);
  const loader = new AtlasAttachmentLoader(atlas);
  const binary = new SkeletonBinary(loader);
  const skeletonData = binary.readSkeletonData(new Uint8Array(fs.readFileSync(skelPath)));
  return skeletonData;
}

function chooseClipNames(skeletonData) {
  const available = skeletonData.animations.map((animation) => animation.name);
  const selected = [];
  const targetCount = explicitClips.length > 0 ? Math.max(maxClips, explicitClips.length) : maxClips;
  for (const explicit of explicitClips) {
    if (available.includes(explicit) && !selected.includes(explicit)) selected.push(explicit);
    if (selected.length >= targetCount) return selected;
  }
  for (const preferred of preferredClipNames) {
    if (available.includes(preferred) && !selected.includes(preferred)) selected.push(preferred);
    if (selected.length >= targetCount) break;
  }
  for (const name of available) {
    if (!selected.includes(name)) selected.push(name);
    if (selected.length >= targetCount) break;
  }
  return selected;
}

function normalizedName(value) {
  return String(value).toLowerCase().replace(/^[0-9]+[\s_-]*/, "").replace(/[^a-z0-9]+/g, "");
}

function skinNameForClip(skeletonData, animationName) {
  const skins = skeletonData.skins.map((skin) => skin.name);
  if (skins.includes(animationName)) return animationName;
  const normalizedAnimation = normalizedName(animationName);
  const aliases = [];
  if (normalizedAnimation.includes("idle")) aliases.push("idle");
  if (normalizedAnimation.includes("show")) aliases.push("show");
  if (normalizedAnimation.includes("stand")) aliases.push("stand");
  for (const alias of aliases) {
    const exact = skins.find((skin) => normalizedName(skin) === alias);
    if (exact) return exact;
  }
  for (const alias of aliases) {
    const partial = skins.find((skin) => normalizedName(skin).includes(alias));
    if (partial) return partial;
  }
  return skins.includes("default") ? "default" : (skins[0] ?? "");
}

function attachmentFrame(slot) {
  const attachment = slot.getAttachment();
  if (!attachment) return null;

  if (attachment instanceof RegionAttachment) {
    try {
      attachment.updateRegion();
    } catch {
      return null;
    }
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
    try {
      attachment.updateRegion();
    } catch {
      return null;
    }
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
  return { minX: round(minX), minY: round(minY), maxX: round(maxX), maxY: round(maxY), width: round(maxX - minX), height: round(maxY - minY) };
}

function bakeAnimationClip(skeletonData, animationName) {
  const animation = skeletonData.findAnimation(animationName);
  const duration = Math.min(animation?.duration ?? 0, maxDuration);
  const frameCount = Math.max(1, Math.ceil((duration || 1 / fps) * fps));
  const stateData = new AnimationStateData(skeletonData);
  const state = new AnimationState(stateData);
  const skeleton = new Skeleton(skeletonData);
  const skinName = skinNameForClip(skeletonData, animationName);
  if (skinName) skeleton.setSkinByName(skinName);
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
    skin: skinName,
    fps,
    duration: round(duration, 4),
    frameCount,
    bounds: computeBounds(compact.frames),
    attachments: compact.attachments,
    frames: compact.frames,
  };
}

function main() {
  const skelPath = path.join(heroDir, `${sourceKey}.skel.bytes`);
  const atlasPath = path.join(heroDir, `${sourceKey}.atlas.txt`);
  const atlasText = fs.readFileSync(atlasPath, "utf8");
  const atlasPages = extractAtlasPages(atlasText);
  const pages = {};
  for (const pageName of atlasPages) {
    const pagePath = path.join(heroDir, pageName);
    if (!fs.existsSync(pagePath)) throw new Error(`missing atlas page ${pageName}`);
    pages[pageName] = resPath(pagePath);
  }
  const skeletonData = loadSkeleton(skelPath, atlasText);
  const clipNames = chooseClipNames(skeletonData);
  if (clipNames.length === 0) throw new Error("skeleton has no animations");
  const clips = {};
  for (const clipName of clipNames) clips[clipName] = bakeAnimationClip(skeletonData, clipName);
  const output = {
    schema: "shaonv-spine-baked-v1",
    source: {
      atlas: resPath(atlasPath),
      skeleton: resPath(skelPath),
      runtime: "@esotericsoftware/spine-core@4.2.43",
    },
    character: { name: sourceKey, pages },
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
      defaultClip: clipNames[0],
      bakedClips: clipNames,
      coordinateSystem: "Spine world coordinates; Godot flips Y at render time.",
    },
    clips,
  };
  const outPath = path.join(heroDir, `${sourceKey}.baked.json`);
  fs.writeFileSync(outPath, JSON.stringify(output) + "\n", "utf8");
  console.log(`baked ${sourceKey}: ${clipNames.join(", ")} -> ${path.relative(root, outPath)}`);
  console.log(JSON.stringify(output.skeleton, null, 2));
}

main();
