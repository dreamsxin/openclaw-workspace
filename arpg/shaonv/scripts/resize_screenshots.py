"""Resize screenshots to 1/4 of original size.

Usage: python tmp/resize_screenshots.py
Input:  screenshot/*.jpg
Output: tmp/screenshots_resized/*.jpg (half width, half height)
"""
import os
from PIL import Image

SRC = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "screenshot")
DST = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "tmp", "screenshots_resized")

os.makedirs(DST, exist_ok=True)

count = 0
for name in os.listdir(SRC):
    if not name.lower().endswith((".jpg", ".jpeg", ".png")):
        continue
    src_path = os.path.join(SRC, name)
    dst_path = os.path.join(DST, name)
    with Image.open(src_path) as img:
        w, h = img.size
        img = img.resize((w // 2, h // 2), Image.LANCZOS)
        img.save(dst_path, quality=85)
    count += 1
    print(f"  {name}: {w}x{h} -> {w//2}x{h//2}")

print(f"\nDone. {count} images resized -> {DST}")
