#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import re
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
DATA_DIR = ROOT / "data"
PREFABS_CSV = DATA_DIR / "prefabs.csv"
INDEX_JS = ROOT / "assets" / "main" / "index.js"
OUT_JSON = DATA_DIR / "prefab_source_inventory.json"
OUT_CSV = DATA_DIR / "prefab_source_inventory.csv"
OUT_MD = DATA_DIR / "prefab_source_inventory.md"

PREFAB_RE = re.compile(r"Prefab/[A-Za-z0-9_\-/]+")
SOURCE_RE = re.compile(r"""(?P<key>preUrl|url)\s*(?:=|:)\s*["'](?P<path>Prefab/[A-Za-z0-9_\-/]+)["']""")
MODULE_RE = re.compile(r"^\s*([A-Za-z0-9_$]+):\s*\[\s*function\b")


def read_prefabs() -> dict[str, dict]:
    prefabs: dict[str, dict] = {}
    with PREFABS_CSV.open("r", encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            path = row["path"]
            prefabs[path] = {
                "bundle": row.get("bundle", ""),
                "path": path,
                "category": category_for(path),
                "uuid": row.get("uuid", ""),
                "import": row.get("import", ""),
                "native": row.get("native", ""),
                "source_refs": [],
                "doc_refs": [],
            }
    return prefabs


def category_for(path: str) -> str:
    parts = path.split("/")
    return parts[1] if len(parts) > 2 else "(root)"


def scan_source() -> dict[str, list[dict]]:
    refs: dict[str, list[dict]] = defaultdict(list)
    if not INDEX_JS.exists():
        return refs
    module = ""
    with INDEX_JS.open("r", encoding="utf-8", errors="ignore") as handle:
        for line_no, line in enumerate(handle, start=1):
            match = MODULE_RE.search(line)
            if match:
                module = match.group(1)
            for hit in SOURCE_RE.finditer(line):
                refs[hit.group("path")].append({
                    "line": line_no,
                    "key": hit.group("key"),
                    "module": module,
                })
    return refs


def scan_docs() -> dict[str, list[dict]]:
    refs: dict[str, list[dict]] = defaultdict(list)
    doc_paths = list(ROOT.glob("*.md")) + list(DATA_DIR.glob("*.md"))
    for doc in sorted(set(doc_paths)):
        try:
            lines = doc.read_text(encoding="utf-8", errors="ignore").splitlines()
        except OSError:
            continue
        for line_no, line in enumerate(lines, start=1):
            for hit in PREFAB_RE.finditer(line):
                refs[hit.group(0)].append({
                    "file": rel(doc),
                    "line": line_no,
                })
    return refs


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def compact_refs(refs: list[dict], limit: int = 8) -> list[dict]:
    seen = set()
    compact = []
    for ref in refs:
        key = tuple(sorted(ref.items()))
        if key in seen:
            continue
        seen.add(key)
        compact.append(ref)
        if len(compact) >= limit:
            break
    return compact


def write_csv(rows: list[dict]) -> None:
    fields = [
        "category",
        "path",
        "bundle",
        "uuid",
        "import",
        "source_ref_count",
        "source_modules",
        "doc_ref_count",
    ]
    with OUT_CSV.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({
                "category": row["category"],
                "path": row["path"],
                "bundle": row["bundle"],
                "uuid": row["uuid"],
                "import": row["import"],
                "source_ref_count": row["source_ref_count"],
                "source_modules": ";".join(row["source_modules"]),
                "doc_ref_count": row["doc_ref_count"],
            })


def write_markdown(rows: list[dict], source_only: list[dict]) -> None:
    category_counts = Counter(row["category"] for row in rows)
    source_rows = [row for row in rows if row["source_ref_count"]]
    doc_rows = [row for row in rows if row["doc_ref_count"]]
    hot_rows = sorted(source_rows, key=lambda r: (-r["source_ref_count"], r["category"], r["path"]))[:80]
    known_rows = sorted(
        [row for row in rows if row["source_ref_count"] or row["doc_ref_count"]],
        key=lambda r: (-r["source_ref_count"], -r["doc_ref_count"], r["category"], r["path"]),
    )[:160]

    lines: list[str] = []
    lines.append("# Prefab Source Inventory")
    lines.append("")
    lines.append("该文件由 `tools/export_prefab_source_inventory.py` 生成，用于手工还原界面前确认 prefab 资源、源码入口和文档线索。")
    lines.append("")
    lines.append("## 统计")
    lines.append("")
    lines.append(f"- `prefabs.csv` 中 prefab 总数：{len(rows)}")
    lines.append(f"- 源码 `assets/main/index.js` 直接引用的 prefab：{len(source_rows)}")
    lines.append(f"- 现有文档已提到的 prefab：{len(doc_rows)}")
    lines.append(f"- 源码引用但 `prefabs.csv` 未收录的 prefab：{len(source_only)}")
    lines.append("")
    lines.append("## 分类数量")
    lines.append("")
    for category, count in sorted(category_counts.items(), key=lambda item: (-item[1], item[0])):
        lines.append(f"- `{category}`：{count}")
    lines.append("")
    lines.append("## 源码高频入口")
    lines.append("")
    lines.append("| 次数 | 分类 | Prefab | 源码模块 | Import |")
    lines.append("| ---: | --- | --- | --- | --- |")
    for row in hot_rows:
        modules = ", ".join(row["source_modules"][:4])
        lines.append(f"| {row['source_ref_count']} | `{row['category']}` | `{row['path']}` | `{modules}` | `{row['import']}` |")
    lines.append("")
    lines.append("## 已知还原候选")
    lines.append("")
    lines.append("| 源码 | 文档 | 分类 | Prefab | 入口模块 |")
    lines.append("| ---: | ---: | --- | --- | --- |")
    for row in known_rows:
        modules = ", ".join(row["source_modules"][:4])
        lines.append(f"| {row['source_ref_count']} | {row['doc_ref_count']} | `{row['category']}` | `{row['path']}` | `{modules}` |")
    if source_only:
        lines.append("")
        lines.append("## 源码引用但未在 prefabs.csv 找到")
        lines.append("")
        lines.append("| 次数 | Prefab | 源码模块 |")
        lines.append("| ---: | --- | --- |")
        for row in source_only[:80]:
            modules = ", ".join(row["source_modules"][:4])
            lines.append(f"| {row['source_ref_count']} | `{row['path']}` | `{modules}` |")
    lines.append("")
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    prefabs = read_prefabs()
    source_refs = scan_source()
    doc_refs = scan_docs()

    for path, refs in source_refs.items():
        prefabs.setdefault(path, {
            "bundle": "",
            "path": path,
            "category": category_for(path),
            "uuid": "",
            "import": "",
            "native": "",
            "source_refs": [],
            "doc_refs": [],
        })["source_refs"].extend(refs)
    for path, refs in doc_refs.items():
        prefabs.setdefault(path, {
            "bundle": "",
            "path": path,
            "category": category_for(path),
            "uuid": "",
            "import": "",
            "native": "",
            "source_refs": [],
            "doc_refs": [],
        })["doc_refs"].extend(refs)

    rows = []
    source_only = []
    for row in prefabs.values():
        modules = sorted({ref.get("module", "") for ref in row["source_refs"] if ref.get("module")})
        item = {
            **row,
            "source_ref_count": len(row["source_refs"]),
            "doc_ref_count": len(row["doc_refs"]),
            "source_modules": modules,
            "source_refs": compact_refs(row["source_refs"]),
            "doc_refs": compact_refs(row["doc_refs"]),
        }
        rows.append(item)
        if item["source_ref_count"] and not item["import"]:
            source_only.append(item)

    rows.sort(key=lambda r: (r["category"], r["path"]))
    source_only.sort(key=lambda r: (-r["source_ref_count"], r["path"]))
    OUT_JSON.write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8")
    write_csv(rows)
    write_markdown(rows, source_only)
    print(f"prefabs={len(rows)} source_refs={sum(1 for r in rows if r['source_ref_count'])} docs={sum(1 for r in rows if r['doc_ref_count'])}")
    print(rel(OUT_JSON))
    print(rel(OUT_CSV))
    print(rel(OUT_MD))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
