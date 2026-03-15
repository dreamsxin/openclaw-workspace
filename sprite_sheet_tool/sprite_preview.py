#!/usr/bin/env python3
"""
sprite_preview.py — Sprite Sheet 动画演示生成工具
用法见 README.md，或运行 python sprite_preview.py --help
"""
from __future__ import annotations

import argparse
import os
import sys
import time
import traceback
from pathlib import Path

# Windows 下强制 stdout/stderr 使用 UTF-8，避免中文/特殊字符乱码
if sys.platform == "win32":
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")


# ── 依赖检查 ──────────────────────────────────────────────────────────────────

def _check_deps():
    missing = []
    try:
        import PIL  # noqa: F401
    except ImportError:
        missing.append("Pillow")
    try:
        import numpy  # noqa: F401
    except ImportError:
        missing.append("numpy")
    if missing:
        print(f"[错误] 缺少依赖库: {', '.join(missing)}")
        print(f"       请运行: pip install {' '.join(missing)}")
        sys.exit(1)

_check_deps()

from sprite_sheet_tool.analyzer import analyze_sprite  # noqa: E402
from sprite_sheet_tool.builder import build_html       # noqa: E402


# ── 辅助 ─────────────────────────────────────────────────────────────────────

_IMG_EXTS = {".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp"}


def _collect_images(inputs: list[str]) -> list[str]:
    """
    将输入路径列表展开为图片文件路径列表。
    - 若是目录，收集其下所有图片（非递归）
    - 若是文件，直接使用
    """
    result: list[str] = []
    for p in inputs:
        path = Path(p)
        if path.is_dir():
            found = sorted(
                str(f) for f in path.iterdir()
                if f.is_file() and f.suffix.lower() in _IMG_EXTS
            )
            if not found:
                print(f"[警告] 目录 {p} 下未找到图片文件，已跳过")
            result.extend(found)
        elif path.is_file():
            if path.suffix.lower() not in _IMG_EXTS:
                print(f"[警告] {p} 不是支持的图片格式，已跳过")
            else:
                result.append(str(path))
        else:
            print(f"[警告] 路径不存在: {p}，已跳过")
    return result


def _default_output(inputs: list[str], out_arg: str | None) -> str:
    """推断输出 HTML 路径。"""
    if out_arg:
        return out_arg
    # 取第一个输入的父目录
    first = Path(inputs[0])
    base = first.parent if first.is_file() else first
    return str(base / "sprite_preview.html")


# ── CLI ───────────────────────────────────────────────────────────────────────

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="sprite_preview",
        description="标准 Sprite Sheet → 自包含 HTML 动画演示",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 单张图片
  python sprite_preview.py hero.png

  # 多张图片，指定输出路径
  python sprite_preview.py hero.png enemy.png -o demo.html

  # 整个目录
  python sprite_preview.py assets/characters/ -o preview.html

  # 自定义行数和行标签（逗号分隔）
  python sprite_preview.py sheet.png --rows 4 --labels "下,左,右,上"

  # 调整默认帧率
  python sprite_preview.py sheet.png --fps 12
""",
    )
    p.add_argument(
        "inputs", nargs="+", metavar="图片/目录",
        help="一个或多个 Sprite Sheet 图片路径，或包含图片的目录",
    )
    p.add_argument(
        "-o", "--output", metavar="OUTPUT",
        help="输出 HTML 文件路径（默认与第一个输入同目录，文件名 sprite_preview.html）",
    )
    p.add_argument(
        "--rows", type=int, default=4, metavar="N",
        help="每张图的动画行数（默认 4）",
    )
    p.add_argument(
        "--labels", default=None, metavar="LABELS",
        help="行标签，英文逗号分隔（默认: 向下,向左,向右,向上）。"
             "数量须与 --rows 一致",
    )
    p.add_argument(
        "--fps", type=int, default=8, metavar="FPS",
        help="默认播放帧率，可在页面内实时调整（默认 8）",
    )
    p.add_argument(
        "--title", default="Sprite Sheet 动画演示", metavar="TITLE",
        help="HTML 页面标题",
    )
    p.add_argument(
        "--max-sheet-width", type=int, default=1200, metavar="PX",
        help="原图缩略图最大宽度（控制 HTML 体积，默认 1200px）",
    )
    p.add_argument(
        "-v", "--verbose", action="store_true",
        help="输出详细检测信息",
    )
    return p


def main():
    parser = build_parser()
    args = parser.parse_args()

    # 解析 row labels
    row_labels = None
    if args.labels:
        row_labels = [s.strip() for s in args.labels.split(",")]
        if len(row_labels) != args.rows:
            parser.error(
                f"--labels 提供了 {len(row_labels)} 个标签，"
                f"但 --rows={args.rows}，数量须一致"
            )

    # 收集图片
    images = _collect_images(args.inputs)
    if not images:
        print("[错误] 没有找到任何可处理的图片文件")
        sys.exit(1)

    output = _default_output(args.inputs, args.output)

    print(f"找到 {len(images)} 张图片，开始分析...\n")
    t0 = time.time()

    sheets = []
    ok = err = 0
    for img_path in images:
        name = os.path.basename(img_path)
        try:
            info = analyze_sprite(
                img_path,
                num_rows=args.rows,
                row_labels=row_labels,
                verbose=args.verbose,
            )
            total_frames = sum(len(r.frames) for r in info.rows)
            print(
                f"  [OK]  {name:<36}  {info.width}x{info.height}  "
                f"{info.num_cols} cols  {total_frames} frames"
            )
            sheets.append(info)
            ok += 1
        except Exception as e:
            print(f"  [FAIL] {name}  -> {e}")
            if args.verbose:
                traceback.print_exc()
            err += 1

    if not sheets:
        print("\n[错误] 所有图片均处理失败，未生成 HTML")
        sys.exit(1)

    print(f"\n生成 HTML: {output}")
    build_html(
        sheets,
        output_path=output,
        title=args.title,
        sheet_preview_max_w=args.max_sheet_width,
        default_fps=args.fps,
    )

    size_mb = os.path.getsize(output) / 1024 / 1024
    elapsed = time.time() - t0
    print(
        f"完成！  成功 {ok} 张  失败 {err} 张  "
        f"文件大小 {size_mb:.1f} MB  耗时 {elapsed:.1f}s\n"
        f"用浏览器打开: {output}"
    )


if __name__ == "__main__":
    main()
