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
const spineDir = path.join(root, "godot-project/assets/spine/loading/kokomi_Loading");
const atlasPath = path.join(spineDir, "kokomi_Loading.atlas.txt");
const skelPath = path.join(spineDir, "kokomi_Loading.skel.bytes");
const outPath = path.join(spineDir, "kokomi_Loading.baked.json");
const manifestPath = path.join(root, "reverse-output/assets/derived/kokomi_loading_spine_bake_manifest.json");

const preferredAnimations = ["idle", "loading", "Loading", "animation", "Ani"];
const fps = 30;
const maxDuration = 6.0;

function round(value, digits = 3) {
  const scale = 10 ** digits;
  return Math.round(value * scale) / scale;
}

function loadSkeleton() {
  const atlas = new TextureAtlas(fs.readFileSync(atlasPath, "utf8"));
  const loader = new AtlasAttachmentLoader(atlas);
  const binary = new SkeletonBinary(loader);
  const skeletonData = binary.readSkeletonData(new Uint8Array(fs.readFileSync(skelPath)));
  const skeleton = new Skeleton(skeletonData);
  skeleton.setToSetupPose();
  skeleton.updateWorldTransform(Physics.update);
  return { atlas, skeletonData, skeleton };
}

function chooseAnimation(skeletonData) {
  const names = skeletonData.animations.map((animation) => animation.name);
  for (const candidate of preferredAnimations) {
    if (names.includes(candidate)) return candidate;
  }
  return names[0] ?? "";
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
  return {
    time: round(time, 4),
    attachments,
  };
}

function compactFrames(rawFrames) {
  const attachments = [];
  const attachmentIndex = new Map();
  const frames = [];
  for (const rawFrame of rawFrames) {
    const frameItems = [];
    for (const item of rawFrame.attachments) {
      const key = `${item.slot}\u0000${item.attachment}\u0000${item.path}\u0000${item.page}`;
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
    frames.push({
      time: rawFrame.time,
      items: frameItems,
    });
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
  return {
    minX: round(minX),
    minY: round(minY),
    maxX: round(maxX),
    maxY: round(maxY),
    width: round(maxX - minX),
    height: round(maxY - minY),
  };
}

function bake() {
  const { skeletonData, skeleton } = loadSkeleton();
  const animationName = chooseAnimation(skeletonData);
  const animation = animationName ? skeletonData.findAnimation(animationName) : null;
  const duration = animation ? Math.min(animation.duration, maxDuration) : 0;
  const frameCount = Math.max(1, Math.ceil((duration || 1 / fps) * fps));
  const rawFrames = [];

  if (animation) {
    const stateData = new AnimationStateData(skeletonData);
    const state = new AnimationState(stateData);
    state.setAnimation(0, animationName, true);
    for (let frameIndex = 0; frameIndex < frameCount; frameIndex++) {
      const time = frameIndex / fps;
      skeleton.setToSetupPose();
      state.update(frameIndex == 0 ? 0 : 1 / fps);
      state.apply(skeleton);
      rawFrames.push(captureFrame(skeleton, time));
    }
  } else {
    skeleton.setToSetupPose();
    rawFrames.push(captureFrame(skeleton, 0));
  }
  const compact = compactFrames(rawFrames);
  const bakedBounds = computeBounds(compact.frames);

  const output = {
    schema: "openclaw-spine-baked-v1",
    source: {
      atlas: path.relative(root, atlasPath).replaceAll("\\", "/"),
      skeleton: path.relative(root, skelPath).replaceAll("\\", "/"),
      runtime: "@esotericsoftware/spine-core@4.2.43",
    },
    skeleton: {
      version: skeletonData.version,
      hash: skeletonData.hash,
      width: round(skeletonData.width),
      height: round(skeletonData.height),
      bones: skeletonData.bones.map((bone) => ({
        name: bone.name,
        parent: bone.parent?.name ?? "",
        x: round(bone.x),
        y: round(bone.y),
        rotation: round(bone.rotation),
        scaleX: round(bone.scaleX),
        scaleY: round(bone.scaleY),
      })),
      slots: skeletonData.slots.map((slot) => ({
        name: slot.name,
        bone: slot.boneData.name,
        attachment: slot.attachmentName ?? "",
      })),
      skins: skeletonData.skins.map((skin) => skin.name),
      animations: skeletonData.animations.map((item) => ({
        name: item.name,
        duration: round(item.duration, 4),
        timelines: item.timelines.length,
      })),
    },
    bake: {
      animation: animationName,
      fps,
      duration: round(duration, 4),
      frameCount,
      coordinateSystem: "Spine world coordinates; Godot flips Y at render time.",
      bounds: bakedBounds,
    },
    attachments: compact.attachments,
    frames: compact.frames,
  };

  fs.writeFileSync(outPath, JSON.stringify(output) + "\n", "utf8");
  fs.mkdirSync(path.dirname(manifestPath), { recursive: true });
  fs.writeFileSync(
    manifestPath,
    JSON.stringify(
      {
        generated: path.relative(root, outPath).replaceAll("\\", "/"),
        runtime: "@esotericsoftware/spine-core@4.2.43",
        skeletonVersion: skeletonData.version,
        animations: output.skeleton.animations,
        bakedAnimation: animationName,
        frames: frameCount,
      },
      null,
      2,
    ) + "\n",
    "utf8",
  );

  console.log(`Baked ${frameCount} frames from ${animationName || "setup pose"} to ${outPath}`);
  console.log(`Skeleton version: ${skeletonData.version}`);
  console.log(`Bones: ${skeletonData.bones.length}, slots: ${skeletonData.slots.length}, animations: ${skeletonData.animations.length}`);
  console.log(`Animations: ${skeletonData.animations.map((item) => `${item.name}:${round(item.duration, 3)}s`).join(", ")}`);
}

bake();
