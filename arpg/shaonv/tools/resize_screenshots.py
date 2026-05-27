"""Resize screenshots to 1/4 area (half width, half height), overwriting originals.

Usage: python tools/resize_screenshots.py
Input:  screenshot/*.jpg (overwritten in-place)
Effect: 2400x1080 -> 1200x540 (1/4 pixel count)

WARNING: This overwrites the original files. Back up first if needed.
"""
import os
import sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "screenshot")

if not os.path.isdir(SRC):
    print(f"Source directory not found: {SRC}")
    sys.exit(1)

images = [n for n in os.listdir(SRC) if n.lower().endswith((".jpg", ".jpeg", ".png"))]
if not images:
    print("No images found.")
    sys.exit(0)

print(f"Will resize {len(images)} images IN-PLACE (overwriting originals).")
print(f"Directory: {SRC}")
response = input("Continue? [y/N]: ").strip().lower()
if response not in ("y", "yes"):
    print("Aborted.")
    sys.exit(0)

count = 0
for name in images:
    src_path = os.path.join(SRC, name)
    with Image.open(src_path) as img:
        w, h = img.size
        resized = img.resize((w // 2, h // 2), Image.LANCZOS)
        resized.save(src_path, quality=85)
    count += 1
    print(f"  {name}: {w}x{h} -> {w//2}x{h//2}")

print(f"\nDone. {count} images resized in-place.")
