#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Export Unity effect prefab internals for human reconstruction.

This is aimed at UI/effect prefabs such as ``fx_capsule_open_blue`` where the
important facts are ParticleSystem modules, UiParticles bindings, external
materials, and texture slots rather than only UGUI layout.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from collections import Counter, deque
from pathlib import Path
from typing import Any

import UnityPy


INTERESTING_TYPES = {
    "AssetBundle",
    "CanvasRenderer",
    "GameObject",
    "Material",
    "MonoBehaviour",
    "MonoScript",
    "ParticleSystem",
    "ParticleSystemRenderer",
    "RectTransform",
    "Shader",
    "Sprite",
    "Texture2D",
    "Transform",
}


def parse_int(value: str) -> int:
    return int(value, 0)


def safe_name(value: str, fallback: str = "unnamed") -> str:
    text = re.sub(r"[<>:\"/\\|?*\x00-\x1f]", "_", str(value or "")).strip(" .")
    return text or fallback


def pptr_id(value: Any) -> int:
    return int(getattr(value, "path_id", getattr(value, "m_PathID", 0)) or 0)


def pptr_file_id(value: Any) -> int:
    return int(getattr(value, "file_id", getattr(value, "m_FileID", 0)) or 0)


def load_source(path: Path, xor_prefix: int, xor_key: int) -> Any:
    data = bytearray(path.read_bytes())
    for index in range(min(xor_prefix, len(data))):
        data[index] ^= xor_key
    return UnityPy.load(bytes(data))


def read_bundle_map(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return [row for row in csv.DictReader(handle) if row.get("physicalExists") == "True"]


def env_asset_names(env: Any) -> list[str]:
    return [str(getattr(asset, "name", "") or "") for asset in getattr(env, "assets", [])]


def external_cabs(env: Any) -> dict[int, str]:
    result: dict[int, str] = {}
    for asset in getattr(env, "assets", []):
        for index, ext in enumerate(getattr(asset, "externals", []) or [], 1):
            name = str(getattr(ext, "name", "") or "")
            if name:
                result[index] = name
    return result


def canonical_cab(value: str) -> str:
    match = re.search(r"cab-([0-9a-fA-F]{32})", value or "", re.IGNORECASE)
    if match:
        return f"CAB-{match.group(1).lower()}"
    return value


def locate_bundle_for_cab(
    repo_root: Path,
    bundle_rows: list[dict[str, str]],
    cab: str,
    xor_prefix: int,
    xor_key: int,
    scanned: dict[str, list[str]],
) -> dict[str, str] | None:
    target = canonical_cab(cab).lower()
    for row in bundle_rows:
        physical = row.get("physicalPath", "")
        if not physical:
            continue
        if physical not in scanned:
            try:
                env = load_source(repo_root / physical, xor_prefix, xor_key)
                scanned[physical] = [name.lower() for name in env_asset_names(env)]
            except Exception:
                scanned[physical] = []
        if target in scanned[physical]:
            return row
    return None


def json_safe(value: Any) -> Any:
    if isinstance(value, (bytes, bytearray)):
        return {
            "__bytes__": len(value),
            "hexPreview": bytes(value[:32]).hex(),
        }
    if isinstance(value, dict):
        return {str(key): json_safe(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [json_safe(item) for item in value]
    if hasattr(value, "m_PathID") or hasattr(value, "path_id"):
        return {"m_FileID": pptr_file_id(value), "m_PathID": pptr_id(value)}
    if hasattr(value, "__dict__") and value.__class__.__module__.startswith("UnityPy"):
        return str(value)
    return value


def object_typetree(obj: Any) -> dict[str, Any]:
    return json_safe(obj.read_typetree())


def object_name(obj: Any, tree: dict[str, Any] | None = None) -> str:
    if tree:
        name = tree.get("m_Name") or tree.get("name")
        if name:
            return str(name)
    try:
        data = obj.read()
        name = getattr(data, "m_Name", "") or getattr(data, "name", "")
        if name:
            return str(name)
    except Exception:
        pass
    return f"{obj.type.name}_{obj.path_id}"


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def write_raw(obj: Any, path: Path) -> bool:
    try:
        data = obj.get_raw_data()
    except Exception:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return True


def collect_bundle_graph(
    repo_root: Path,
    source: Path,
    bundle_rows: list[dict[str, str]],
    xor_prefix: int,
    xor_key: int,
    include_dependencies: bool,
) -> dict[int, dict[str, Any]]:
    root_env = load_source(source, xor_prefix, xor_key)
    bundles: dict[int, dict[str, Any]] = {
        0: {
            "fileId": 0,
            "cab": env_asset_names(root_env)[0] if env_asset_names(root_env) else "",
            "source": str(source),
            "row": None,
            "env": root_env,
        }
    }
    if not include_dependencies:
        return bundles

    scanned: dict[str, list[str]] = {}
    queue: deque[tuple[int, str, Any]] = deque((fid, cab, root_env) for fid, cab in external_cabs(root_env).items())
    seen_cabs = {canonical_cab(env_asset_names(root_env)[0]).lower()} if env_asset_names(root_env) else set()

    while queue:
        file_id, cab, parent_env = queue.popleft()
        key = canonical_cab(cab).lower()
        if key in seen_cabs:
            continue
        row = locate_bundle_for_cab(repo_root, bundle_rows, cab, xor_prefix, xor_key, scanned)
        if not row:
            bundle_key = file_id if file_id not in bundles else max(bundles) + 1
            bundles[bundle_key] = {
                "fileId": bundle_key,
                "localFileId": file_id,
                "cab": canonical_cab(cab),
                "source": "",
                "row": None,
                "env": None,
                "missing": True,
            }
            seen_cabs.add(key)
            continue
        dep_source = repo_root / row.get("physicalPath", "")
        env = load_source(dep_source, xor_prefix, xor_key)
        bundle_key = file_id if file_id not in bundles else max(bundles) + 1
        bundles[bundle_key] = {
            "fileId": bundle_key,
            "localFileId": file_id,
            "cab": canonical_cab(cab),
            "source": str(dep_source),
            "row": row,
            "env": env,
        }
        seen_cabs.add(key)
        for nested_file_id, nested_cab in external_cabs(env).items():
            # Keep Unity file IDs local to each bundle in object refs, but add
            # the nested bundle so texture references can be resolved by CAB.
            if canonical_cab(nested_cab).lower() not in seen_cabs:
                queue.append((nested_file_id, nested_cab, env))
    return bundles


def build_object_index(bundles: dict[int, dict[str, Any]]) -> dict[str, Any]:
    by_file_and_path: dict[tuple[int, int], Any] = {}
    by_cab_and_path: dict[tuple[str, int], Any] = {}
    for file_id, bundle in bundles.items():
        env = bundle.get("env")
        if env is None:
            continue
        cab = canonical_cab(str(bundle.get("cab", ""))).lower()
        for obj in env.objects:
            by_file_and_path[(file_id, int(obj.path_id))] = obj
            by_cab_and_path[(cab, int(obj.path_id))] = obj
    return {"byFilePath": by_file_and_path, "byCabPath": by_cab_and_path}


def component_context(env: Any) -> tuple[dict[int, int], dict[int, dict[str, Any]], dict[int, dict[str, Any]]]:
    component_to_go: dict[int, int] = {}
    gameobjects: dict[int, dict[str, Any]] = {}
    transforms_by_go: dict[int, dict[str, Any]] = {}
    component_types = {int(obj.path_id): obj.type.name for obj in env.objects}

    for obj in env.objects:
        if obj.type.name != "GameObject":
            continue
        tree = object_typetree(obj)
        components = []
        for pair in tree.get("m_Component", []) or []:
            ref = pair.get("component", {}) or {}
            cid = int(ref.get("m_PathID", 0) or 0)
            if not cid:
                continue
            component_to_go[cid] = int(obj.path_id)
            components.append({"pathId": cid, "type": component_types.get(cid, "Unknown")})
        gameobjects[int(obj.path_id)] = {
            "pathId": int(obj.path_id),
            "name": object_name(obj, tree),
            "active": bool(tree.get("m_IsActive", True)),
            "layer": int(tree.get("m_Layer", 0) or 0),
            "components": components,
        }

    for obj in env.objects:
        if obj.type.name not in {"RectTransform", "Transform"}:
            continue
        tree = object_typetree(obj)
        go_id = int((tree.get("m_GameObject") or {}).get("m_PathID", 0) or 0)
        father_id = int((tree.get("m_Father") or {}).get("m_PathID", 0) or 0)
        entry = {
            "transformPathId": int(obj.path_id),
            "type": obj.type.name,
            "gameObjectPathId": go_id,
            "fatherTransformPathId": father_id,
            "childrenTransformPathIds": [int((child or {}).get("m_PathID", 0) or 0) for child in tree.get("m_Children", []) or []],
            "localRotation": tree.get("m_LocalRotation"),
            "localPosition": tree.get("m_LocalPosition"),
            "localScale": tree.get("m_LocalScale"),
            "anchorMin": tree.get("m_AnchorMin"),
            "anchorMax": tree.get("m_AnchorMax"),
            "anchoredPosition": tree.get("m_AnchoredPosition"),
            "sizeDelta": tree.get("m_SizeDelta"),
            "pivot": tree.get("m_Pivot"),
        }
        if go_id:
            transforms_by_go[go_id] = entry
    return component_to_go, gameobjects, transforms_by_go


def build_hierarchy(env: Any) -> dict[str, Any]:
    _component_to_go, gameobjects, transforms_by_go = component_context(env)
    transforms_by_path = {item["transformPathId"]: item for item in transforms_by_go.values()}
    children_by_parent: dict[int, list[int]] = {}
    parent_by_go: dict[int, int] = {}

    for go_id, transform in transforms_by_go.items():
        father_transform = int(transform.get("fatherTransformPathId", 0) or 0)
        parent_go = int(transforms_by_path.get(father_transform, {}).get("gameObjectPathId", 0) or 0)
        parent_by_go[go_id] = parent_go
        children_by_parent.setdefault(parent_go, []).append(go_id)

    def sibling_index(go_id: int) -> int:
        transform = transforms_by_go.get(go_id, {})
        parent_transform = int(transform.get("fatherTransformPathId", 0) or 0)
        siblings = transforms_by_path.get(parent_transform, {}).get("childrenTransformPathIds", []) or []
        try:
            return siblings.index(transform.get("transformPathId"))
        except ValueError:
            return 9999

    for children in children_by_parent.values():
        children.sort(key=lambda go_id: (sibling_index(go_id), gameobjects.get(go_id, {}).get("name", "")))

    def node(go_id: int, parent_path: str = "") -> dict[str, Any]:
        go = gameobjects[go_id]
        path = f"{parent_path}/{go['name']}" if parent_path else go["name"]
        return {
            **go,
            "path": path,
            "parentPathId": parent_by_go.get(go_id, 0),
            "transform": transforms_by_go.get(go_id),
            "children": [node(child_id, path) for child_id in children_by_parent.get(go_id, [])],
        }

    roots = [go_id for go_id in gameobjects if parent_by_go.get(go_id, 0) not in gameobjects]
    roots.sort(key=lambda go_id: (sibling_index(go_id), gameobjects.get(go_id, {}).get("name", "")))
    return {"roots": [node(go_id) for go_id in roots], "nodeCount": len(gameobjects)}


def scalar_curve(value: Any) -> Any:
    if not isinstance(value, dict):
        return value
    return {
        "minMaxState": value.get("minMaxState"),
        "scalar": value.get("scalar"),
        "minScalar": value.get("minScalar"),
        "maxScalar": value.get("maxScalar"),
        "maxCurveKeys": len(((value.get("maxCurve") or {}).get("m_Curve") or [])),
        "minCurveKeys": len(((value.get("minCurve") or {}).get("m_Curve") or [])),
    }


def color_curve(value: Any) -> Any:
    if not isinstance(value, dict):
        return value
    return {
        "minMaxState": value.get("minMaxState"),
        "minColor": value.get("minColor"),
        "maxColor": value.get("maxColor"),
    }


def summarize_particle_system(obj: Any, go_name_by_component: dict[int, str]) -> dict[str, Any]:
    tree = object_typetree(obj)
    initial = tree.get("InitialModule", {}) or {}
    emission = tree.get("EmissionModule", {}) or {}
    shape = tree.get("ShapeModule", {}) or {}
    size = tree.get("SizeModule", {}) or {}
    rotation = tree.get("RotationModule", {}) or {}
    color = tree.get("ColorModule", {}) or {}
    uv = tree.get("UVModule", {}) or {}
    return {
        "pathId": int(obj.path_id),
        "gameObject": go_name_by_component.get(int(obj.path_id), ""),
        "lengthInSec": tree.get("lengthInSec"),
        "simulationSpeed": tree.get("simulationSpeed"),
        "looping": tree.get("looping"),
        "playOnAwake": tree.get("playOnAwake"),
        "autoRandomSeed": tree.get("autoRandomSeed"),
        "startDelay": scalar_curve(tree.get("startDelay")),
        "scalingMode": tree.get("scalingMode"),
        "initial": {
            "enabled": initial.get("enabled"),
            "startLifetime": scalar_curve(initial.get("startLifetime")),
            "startSpeed": scalar_curve(initial.get("startSpeed")),
            "startSize": scalar_curve(initial.get("startSize")),
            "startSizeY": scalar_curve(initial.get("startSizeY")),
            "startSizeZ": scalar_curve(initial.get("startSizeZ")),
            "startRotation": scalar_curve(initial.get("startRotation")),
            "startColor": color_curve(initial.get("startColor")),
            "maxNumParticles": initial.get("maxNumParticles"),
            "gravityModifier": scalar_curve(initial.get("gravityModifier")),
        },
        "emission": {
            "enabled": emission.get("enabled"),
            "rateOverTime": scalar_curve(emission.get("rateOverTime")),
            "rateOverDistance": scalar_curve(emission.get("rateOverDistance")),
            "bursts": emission.get("m_Bursts") or emission.get("bursts") or [],
        },
        "shape": {
            "enabled": shape.get("enabled"),
            "type": shape.get("type"),
            "angle": shape.get("angle"),
            "radius": shape.get("radius"),
            "boxX": shape.get("boxX"),
            "boxY": shape.get("boxY"),
            "boxZ": shape.get("boxZ"),
            "arc": shape.get("arc"),
            "position": shape.get("position"),
            "rotation": shape.get("rotation"),
            "scale": shape.get("scale"),
        },
        "sizeOverLifetime": {
            "enabled": size.get("enabled"),
            "curve": scalar_curve(size.get("curve")),
        },
        "rotationOverLifetime": {
            "enabled": rotation.get("enabled"),
            "x": scalar_curve(rotation.get("x")),
            "y": scalar_curve(rotation.get("y")),
            "curve": scalar_curve(rotation.get("curve")),
        },
        "colorOverLifetime": {
            "enabled": color.get("enabled"),
            "gradient": color_curve(color.get("gradient")),
        },
        "textureSheetAnimation": {
            "enabled": uv.get("enabled"),
            "tilesX": uv.get("tilesX"),
            "tilesY": uv.get("tilesY"),
            "animationType": uv.get("animationType"),
            "rowIndex": uv.get("rowIndex"),
            "cycles": uv.get("cycles"),
            "frameOverTime": scalar_curve(uv.get("frameOverTime")),
        },
    }


def summarize_renderer(obj: Any, go_name_by_component: dict[int, str]) -> dict[str, Any]:
    tree = object_typetree(obj)
    return {
        "pathId": int(obj.path_id),
        "gameObject": go_name_by_component.get(int(obj.path_id), ""),
        "enabled": tree.get("m_Enabled"),
        "materials": tree.get("m_Materials", []),
        "sortingLayer": tree.get("m_SortingLayer"),
        "sortingOrder": tree.get("m_SortingOrder"),
        "renderMode": tree.get("m_RenderMode"),
        "renderAlignment": tree.get("m_RenderAlignment"),
        "minParticleSize": tree.get("m_MinParticleSize"),
        "maxParticleSize": tree.get("m_MaxParticleSize"),
        "lengthScale": tree.get("m_LengthScale"),
        "normalDirection": tree.get("m_NormalDirection"),
        "pivot": tree.get("m_Pivot"),
        "vertexStreams": tree.get("m_VertexStreams"),
    }


def summarize_uiparticles(obj: Any, go_name_by_component: dict[int, str]) -> dict[str, Any]:
    tree = object_typetree(obj)
    script = tree.get("m_Script", {}) or {}
    return {
        "pathId": int(obj.path_id),
        "gameObject": go_name_by_component.get(int(obj.path_id), ""),
        "enabled": tree.get("m_Enabled"),
        "script": script,
        "material": tree.get("m_Material"),
        "color": tree.get("m_Color"),
        "raycastTarget": tree.get("m_RaycastTarget"),
        "maskable": tree.get("m_Maskable"),
        "particleSystem": tree.get("m_ParticleSystem"),
        "renderMode": tree.get("m_RenderMode"),
        "stretchedSpeedScale": tree.get("m_StretchedSpeedScale"),
        "stretchedLengthScale": tree.get("m_StretchedLenghScale"),
        "ignoreTimescale": tree.get("m_IgnoreTimescale"),
    }


def tex_env_refs(material_tree: dict[str, Any]) -> list[dict[str, Any]]:
    saved = material_tree.get("m_SavedProperties", {}) or {}
    refs = []
    for item in saved.get("m_TexEnvs", []) or []:
        if not isinstance(item, list) or len(item) != 2:
            continue
        slot, payload = item
        texture = ((payload or {}).get("m_Texture") or {})
        fid = int(texture.get("m_FileID", 0) or 0)
        pid = int(texture.get("m_PathID", 0) or 0)
        refs.append({
            "slot": slot,
            "texture": {"m_FileID": fid, "m_PathID": pid},
            "scale": (payload or {}).get("m_Scale"),
            "offset": (payload or {}).get("m_Offset"),
        })
    return refs


def floats_and_colors(material_tree: dict[str, Any]) -> dict[str, Any]:
    saved = material_tree.get("m_SavedProperties", {}) or {}
    return {
        "keywords": material_tree.get("m_ValidKeywords", []),
        "floats": {str(key): value for key, value in saved.get("m_Floats", []) or []},
        "colors": {str(key): value for key, value in saved.get("m_Colors", []) or []},
    }


def export_texture(obj: Any, out_dir: Path, name_hint: str) -> str:
    data = obj.read()
    image = getattr(data, "image", None)
    if image is None:
        return ""
    name = safe_name(object_name(obj), name_hint)
    path = out_dir / f"{name}_{obj.path_id}.png"
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)
    return str(path)


def export_referenced_textures(
    bundles: dict[int, dict[str, Any]],
    out_dir: Path,
    repo_root: Path,
    exported_paths: set[str],
) -> list[dict[str, Any]]:
    exported = []
    for bundle in bundles.values():
        env = bundle.get("env")
        if env is None:
            continue
        for obj in env.objects:
            if obj.type.name != "Texture2D":
                continue
            name = object_name(obj)
            try:
                png = export_texture(obj, out_dir, name)
            except Exception:
                continue
            if not png:
                continue
            rel_png = str(Path(png).resolve().relative_to(repo_root))
            if rel_png in exported_paths:
                continue
            exported_paths.add(rel_png)
            exported.append({
                "texture": name,
                "pathId": int(obj.path_id),
                "cab": bundle.get("cab", ""),
                "source": bundle.get("source", ""),
                "png": rel_png,
                "referencedByMaterial": False,
            })
    return exported


def find_object_for_ref(
    ref: dict[str, Any],
    owner_bundle: dict[str, Any],
    bundles: dict[int, dict[str, Any]],
    index: dict[str, Any],
) -> Any | None:
    fid = int(ref.get("m_FileID", 0) or 0)
    pid = int(ref.get("m_PathID", 0) or 0)
    if not pid:
        return None
    if fid == 0:
        owner_file_id = int(owner_bundle.get("fileId", 0) or 0)
        return index["byFilePath"].get((owner_file_id, pid))
    cab = external_cabs(owner_bundle["env"]).get(fid)
    if not cab:
        return index["byFilePath"].get((fid, pid))
    return index["byCabPath"].get((canonical_cab(cab).lower(), pid))


def find_owner_bundle(obj: Any, bundles: dict[int, dict[str, Any]]) -> dict[str, Any] | None:
    for bundle in bundles.values():
        env = bundle.get("env")
        if env is not None and obj in env.objects:
            return bundle
    return None


def export_effect(args: argparse.Namespace) -> int:
    repo_root = Path(args.repo_root).resolve()
    source = (repo_root / args.source).resolve()
    out_dir = (repo_root / args.out).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    errors_path = out_dir / "unitypy-effect-export-errors.log"
    if errors_path.exists():
        errors_path.unlink()
    bundle_rows = read_bundle_map(repo_root / args.bundle_map)
    bundles = collect_bundle_graph(repo_root, source, bundle_rows, args.xor_prefix, args.xor_key, args.include_dependencies)
    root_env = bundles[0]["env"]
    index = build_object_index(bundles)
    component_to_go, gameobjects, _transforms_by_go = component_context(root_env)
    go_name_by_component = {component_id: gameobjects.get(go_id, {}).get("name", "") for component_id, go_id in component_to_go.items()}

    manifest_rows: list[dict[str, Any]] = []
    errors: list[str] = []
    all_type_counts: dict[str, dict[str, int]] = {}

    for file_id, bundle in sorted(bundles.items()):
        env = bundle.get("env")
        if env is None:
            continue
        source_label = str(bundle.get("source", ""))
        rel_source = str(Path(source_label).resolve().relative_to(repo_root)) if source_label else ""
        all_type_counts[str(file_id)] = dict(sorted(Counter(obj.type.name for obj in env.objects).items()))
        for obj in env.objects:
            if args.only_interesting and obj.type.name not in INTERESTING_TYPES:
                continue
            try:
                tree = object_typetree(obj)
                name = object_name(obj, tree)
                base = f"{safe_name(name, obj.type.name)}_{obj.path_id}"
                json_path = out_dir / "by_type" / obj.type.name / f"{base}.typetree.json"
                write_json(json_path, {
                    "source": rel_source,
                    "fileId": file_id,
                    "cab": bundle.get("cab", ""),
                    "type": obj.type.name,
                    "name": name,
                    "pathId": int(obj.path_id),
                    "typetree": tree,
                })
                raw_path = out_dir / "by_type" / obj.type.name / f"{base}.bin"
                raw_ok = write_raw(obj, raw_path)
                manifest_rows.append({
                    "source": rel_source,
                    "fileId": file_id,
                    "cab": bundle.get("cab", ""),
                    "type": obj.type.name,
                    "name": name,
                    "pathId": int(obj.path_id),
                    "typetree": str(json_path.relative_to(repo_root)),
                    "raw": str(raw_path.relative_to(repo_root)) if raw_ok else "",
                })
            except Exception as exc:
                errors.append(f"{rel_source} {obj.type.name} {obj.path_id}: {exc}")

    hierarchy = build_hierarchy(root_env)
    write_json(out_dir / "prefab-hierarchy.json", hierarchy)

    particles = [
        summarize_particle_system(obj, go_name_by_component)
        for obj in root_env.objects
        if obj.type.name == "ParticleSystem"
    ]
    renderers = [
        summarize_renderer(obj, go_name_by_component)
        for obj in root_env.objects
        if obj.type.name == "ParticleSystemRenderer"
    ]
    ui_particles = [
        summarize_uiparticles(obj, go_name_by_component)
        for obj in root_env.objects
        if obj.type.name == "MonoBehaviour" and "m_ParticleSystem" in object_typetree(obj)
    ]
    write_json(out_dir / "particles" / "particle-systems.json", particles)
    write_json(out_dir / "particles" / "particle-renderers.json", renderers)
    write_json(out_dir / "particles" / "ui-particles.json", ui_particles)

    material_refs: dict[tuple[str, int], dict[str, Any]] = {}
    for renderer in renderers:
        for ref in renderer.get("materials", []) or []:
            material_refs[(canonical_cab(external_cabs(root_env).get(int(ref.get("m_FileID", 0) or 0), "")).lower(), int(ref.get("m_PathID", 0) or 0))] = ref
    for ui_particle in ui_particles:
        ref = ui_particle.get("material") or {}
        material_refs[(canonical_cab(external_cabs(root_env).get(int(ref.get("m_FileID", 0) or 0), "")).lower(), int(ref.get("m_PathID", 0) or 0))] = ref

    materials = []
    texture_exports = []
    for key, ref in sorted(material_refs.items(), key=lambda item: item[0]):
        mat = find_object_for_ref(ref, bundles[0], bundles, index)
        if mat is None:
            materials.append({"ref": ref, "missing": True})
            continue
        owner_bundle = find_owner_bundle(mat, bundles)
        if owner_bundle is None:
            owner_bundle = bundles[0]
        tree = object_typetree(mat)
        entry = {
            "pathId": int(mat.path_id),
            "name": object_name(mat, tree),
            "cab": owner_bundle.get("cab", ""),
            "source": owner_bundle.get("source", ""),
            "shader": tree.get("m_Shader"),
            "textureSlots": tex_env_refs(tree),
            **floats_and_colors(tree),
        }
        for slot in entry["textureSlots"]:
            tex_ref = slot.get("texture", {})
            tex_obj = find_object_for_ref(tex_ref, owner_bundle, bundles, index)
            if tex_obj is None:
                continue
            tex_owner = find_owner_bundle(tex_obj, bundles)
            texture_name = object_name(tex_obj)
            slot["resolvedTextureName"] = texture_name
            slot["resolvedTextureType"] = tex_obj.type.name
            if tex_owner is not None:
                slot["resolvedTextureCab"] = tex_owner.get("cab", "")
                slot["resolvedTextureSource"] = tex_owner.get("source", "")
            if tex_obj.type.name == "Texture2D":
                png = export_texture(tex_obj, out_dir / "textures", texture_name)
                if png:
                    rel_png = str(Path(png).resolve().relative_to(repo_root))
                    slot["exportedPng"] = rel_png
                    texture_exports.append({
                        "material": entry["name"],
                        "slot": slot.get("slot"),
                        "texture": texture_name,
                        "pathId": int(tex_obj.path_id),
                        "png": rel_png,
                    })
        materials.append(entry)
    write_json(out_dir / "materials" / "materials.json", materials)
    if args.export_all_dependency_textures:
        texture_exports.extend(export_referenced_textures(bundles, out_dir / "textures", repo_root, {str(item.get("png", "")) for item in texture_exports}))
    write_json(out_dir / "textures" / "texture-exports.json", texture_exports)

    bundle_summary = {
        "source": str(source),
        "rootAssetNames": env_asset_names(root_env),
        "bundles": [
            {
                "fileId": file_id,
                "localFileId": bundle.get("localFileId", file_id),
                "cab": bundle.get("cab", ""),
                "source": bundle.get("source", ""),
                "bundleName": (bundle.get("row") or {}).get("bundleName", ""),
                "missing": bool(bundle.get("missing", False)),
                "typeCounts": all_type_counts.get(str(file_id), {}),
                "externals": external_cabs(bundle["env"]) if bundle.get("env") is not None else {},
            }
            for file_id, bundle in sorted(bundles.items())
        ],
        "rootTypeCounts": all_type_counts.get("0", {}),
        "prefabNodeCount": hierarchy["nodeCount"],
        "particleSystemCount": len(particles),
        "uiParticlesCount": len(ui_particles),
        "materialCount": len(materials),
        "textureExportCount": len(texture_exports),
    }
    write_json(out_dir / "bundle-summary.json", bundle_summary)

    manifest_path = out_dir / "unitypy-effect-export-manifest.csv"
    with manifest_path.open("w", encoding="utf-8-sig", newline="") as handle:
        fieldnames = ["source", "fileId", "cab", "type", "name", "pathId", "typetree", "raw"]
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(manifest_rows)

    if errors:
        errors_path.write_text("\n".join(errors) + "\n", encoding="utf-8")

    print(f"summary: {out_dir / 'bundle-summary.json'}")
    print(f"hierarchy: {out_dir / 'prefab-hierarchy.json'}")
    print(f"particles: {out_dir / 'particles' / 'particle-systems.json'}")
    print(f"materials: {out_dir / 'materials' / 'materials.json'}")
    print(f"textures exported: {len(texture_exports)}")
    print(f"objects exported: {len(manifest_rows)}, errors: {len(errors)}")
    return 1 if errors else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Export Unity effect prefab typetrees, particles, materials, and textures.")
    parser.add_argument("source", help="Unity bundle or __data file.")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--out", default="tmp/unity-effect-prefab-export")
    parser.add_argument("--bundle-map", default="reverse-output/assets/yoo-physical-map/physical-bundle-map.csv")
    parser.add_argument("--xor-prefix", type=parse_int, default=222)
    parser.add_argument("--xor-key", type=parse_int, default=0x16)
    parser.add_argument("--include-dependencies", action="store_true", default=True)
    parser.add_argument("--no-dependencies", dest="include_dependencies", action="store_false")
    parser.add_argument("--only-interesting", action="store_true", default=True)
    parser.add_argument("--all-types", dest="only_interesting", action="store_false")
    parser.add_argument("--export-all-dependency-textures", action="store_true")
    args = parser.parse_args()
    return export_effect(args)


if __name__ == "__main__":
    sys.exit(main())
