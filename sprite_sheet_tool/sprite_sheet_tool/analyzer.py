"""
analyzer.py — Sprite Sheet 分析核心
职责：
  - 自动检测列数（等宽均分）
  - 自动检测行分割（透明行间隙）
  - 按等宽裁切每帧，返回 PIL Image 列表
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import numpy as np
from PIL import Image


# ── 数据结构 ──────────────────────────────────────────────────────────────────

@dataclass
class FrameData:
    col: int
    x: int
    y: int
    w: int
    h: int
    img: Image.Image


@dataclass
class RowData:
    row_idx: int
    label: str
    y0: int
    y1: int
    frames: List[FrameData] = field(default_factory=list)


@dataclass
class SpriteSheetInfo:
    path: str
    name: str
    width: int
    height: int
    num_cols: int
    rows: List[RowData] = field(default_factory=list)


# ── 内部辅助 ─────────────────────────────────────────────────────────────────

def _group_consecutive(indices: np.ndarray) -> List[Tuple[int, int]]:
    """将连续整数索引数组分组为 [(start, end), ...] 区间列表。"""
    if len(indices) == 0:
        return []
    groups: List[Tuple[int, int]] = []
    start = prev = int(indices[0])
    for v in indices[1:]:
        v = int(v)
        if v == prev + 1:
            prev = v
        else:
            groups.append((start, prev))
            start = prev = v
    groups.append((start, prev))
    return groups


def _detect_num_cols(
    content_mask: np.ndarray,
    width: int,
    min_gap_width: int = 1,
) -> int:
    """
    从全图内容掩码（alpha > threshold）估算帧列数。

    策略：
      1. 以递增透明度阈值（2 → 5 → 10 → 20）搜索列间隙。
      2. 取相邻间隙中心距离的中位数作为估算帧宽。
      3. 用 round(width / 帧宽) 得到列数，并做 ±1 微调。
      4. 若估算帧宽 < width/60（噪声过多），提升阈值重试。
    """
    def _gaps_for_threshold(thresh: int) -> List[Tuple[int, int]]:
        col_density = content_mask.sum(axis=0).astype(float)
        low_cols = np.where(col_density <= thresh)[0]
        raw = _group_consecutive(low_cols)
        return [
            (s, e) for s, e in raw
            if s > 2 and e < width - 3 and (e - s + 1) >= min_gap_width
        ]

    for threshold in (2, 5, 10, 20):
        gaps = _gaps_for_threshold(threshold)
        if not gaps:
            continue

        centers = sorted((s + e) // 2 for s, e in gaps)
        diffs = [centers[i + 1] - centers[i] for i in range(len(centers) - 1)]

        if not diffs:
            est_w = float(centers[0])
        else:
            arr = np.array(diffs, dtype=float)
            median = float(np.median(arr))
            valid = arr[arr >= median * 0.4]
            est_w = float(np.median(valid if len(valid) else arr))

        if est_w < width / 60:          # 仍有噪声 → 提升阈值
            continue

        n = max(1, round(width / est_w))
        # 微调 ±1
        best, best_err = n, abs(width / n - est_w)
        for cand in (n - 1, n + 1):
            if cand > 0:
                err = abs(width / cand - est_w)
                if err < best_err:
                    best, best_err = cand, err
        return best

    return 1  # 兜底：整张图当作 1 帧


def _detect_row_bands(
    alpha: np.ndarray,
    height: int,
    num_rows: int,
) -> List[Tuple[int, int]]:
    """
    检测水平方向的行分割，返回 num_rows 个 (y0, y1) 区间。
    优先利用透明行间隙定位；不够时退回均分。
    """
    row_density = (alpha > 10).sum(axis=1).astype(float)
    transparent = np.where(row_density <= 2)[0]
    h_gaps = [
        (s, e) for s, e in _group_consecutive(transparent)
        if s > 2 and e < height - 3
    ]

    if len(h_gaps) >= num_rows - 1:
        split_ys = sorted((s + e) // 2 for s, e in h_gaps[: num_rows - 1])
        ranges: List[Tuple[int, int]] = []
        prev = 0
        for sy in split_ys:
            ranges.append((prev, sy))
            prev = sy + 1
        ranges.append((prev, height - 1))
        return ranges

    # 回退：均分
    rh = height // num_rows
    return [(i * rh, (i + 1) * rh - 1) for i in range(num_rows)]


# ── 公开接口 ──────────────────────────────────────────────────────────────────

DEFAULT_ROW_LABELS = ["向下", "向左", "向右", "向上"]


def analyze_sprite(
    img_path: str,
    num_rows: int = 4,
    row_labels: Optional[List[str]] = None,
    verbose: bool = False,
) -> SpriteSheetInfo:
    """
    分析一张标准 Sprite Sheet，返回 SpriteSheetInfo。

    参数
    ----
    img_path   : 图片路径（支持 PNG / JPEG 等 Pillow 可读格式）
    num_rows   : 动画行数，默认 4（下/左/右/上）
    row_labels : 每行的名称列表，长度须 == num_rows；None 时使用默认值
    verbose    : 打印检测细节

    返回
    ----
    SpriteSheetInfo，其中 rows[i].frames 已包含裁切后的 PIL Image。
    """
    if row_labels is None:
        row_labels = (DEFAULT_ROW_LABELS * num_rows)[:num_rows]
    if len(row_labels) < num_rows:
        row_labels = list(row_labels) + [f"行{i}" for i in range(len(row_labels), num_rows)]

    import os
    img = Image.open(img_path).convert("RGBA")
    width, height = img.size
    alpha = np.array(img)[:, :, 3]
    content_mask = (alpha > 10).astype(np.uint8)

    num_cols = _detect_num_cols(content_mask, width)
    row_bands = _detect_row_bands(alpha, height, num_rows)

    if verbose:
        print(f"  {os.path.basename(img_path)}  {width}×{height}")
        print(f"  列数: {num_cols}  帧宽: {width / num_cols:.1f}px")
        print(f"  行分割: {row_bands}")

    frame_w = width / num_cols
    rows: List[RowData] = []

    for ri, (ry0, ry1) in enumerate(row_bands):
        label = row_labels[ri] if ri < len(row_labels) else f"行{ri}"
        frames: List[FrameData] = []
        frame_h = ry1 - ry0 + 1

        for ci in range(num_cols):
            cx0 = round(ci * frame_w)
            cx1 = round((ci + 1) * frame_w)
            cell_w = cx1 - cx0
            cropped = img.crop((cx0, ry0, cx1, ry1 + 1))
            frames.append(FrameData(
                col=ci, x=cx0, y=ry0,
                w=cell_w, h=frame_h,
                img=cropped,
            ))

        if verbose:
            print(f"  行{ri} {label}: {len(frames)} 帧")

        rows.append(RowData(
            row_idx=ri, label=label,
            y0=ry0, y1=ry1,
            frames=frames,
        ))

    return SpriteSheetInfo(
        path=img_path,
        name=os.path.basename(img_path),
        width=width,
        height=height,
        num_cols=num_cols,
        rows=rows,
    )
