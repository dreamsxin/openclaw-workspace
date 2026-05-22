#!/usr/bin/env python3
from pathlib import Path

data = Path("resources/assets/yoo/Default/Default_1001.1774870195.cht.bytes").read_bytes()
print(len(data), data[:64], data[:16].hex())
for s in [
    b"YooAsset",
    b"Default",
    b"ScriptableBuildPipeline",
    b"Assets/Game/RawAssets/Spine/Hero/hero_003",
    b"assets_game_rawassets_spine_hero_hero_003",
]:
    print(s, data.find(s))
for i in range(0, 384, 16):
    chunk = data[i : i + 16]
    asc = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
    print(f"{i:04x}: {chunk.hex(' ')} {asc}")
