#!/usr/bin/env python3
"""Bulk export all hero Spine resources."""
import csv, os, shutil, UnityPy
from pathlib import Path

REPO = Path(r"D:\work\openclaw-workspace\arpg\shaonv")
GD_SPINE = REPO / "standalone/godot-mvp/assets/spine"

# Load physical map
pmap = {}
with open(REPO / "reverse-output/assets/yoo-physical-map/physical-asset-map.csv", 'r', encoding='utf-8-sig') as f:
    for row in csv.DictReader(f):
        a = row.get('address', '').lower()
        if a: pmap[a] = row['physicalPath']

# Find all hero asset paths from manifest
manifest_paths = set()
with open(REPO / "reverse-output/assets/manifest/manifest-assets.csv", 'r', encoding='utf-8') as f:
    for row in csv.reader(f):
        if row and '/Spine/Hero/' in row[0]:
            manifest_paths.add(row[0])

# Group by hero key
from collections import defaultdict
heroes = defaultdict(lambda: {'skel': '', 'atlas': '', 'png': ''})
for path in sorted(manifest_paths):
    rel = path.split('/Spine/Hero/')[-1]
    parts = rel.split('/')
    if len(parts) != 2: continue
    key, fname = parts
    if fname.endswith('.skel.bytes'):
        heroes[key]['skel'] = path
    elif fname.endswith('.atlas.txt') and '_silhouette' not in fname and '_bg' not in fname and '_fg' not in fname:
        heroes[key]['atlas'] = path
    elif fname.endswith('.png') and not any(x in fname for x in ['silhouette', '_bg', '_fg', '_2.']):
        if not heroes[key]['png']:
            heroes[key]['png'] = path

# Process each hero
total, ok, skip, fail = 0, 0, 0, 0
for key, info in sorted(heroes.items()):
    if not info['skel'] or not info['atlas'] or not info['png']:
        continue
    total += 1
    
    hero_dir = GD_SPINE / key
    hero_dir.mkdir(parents=True, exist_ok=True)
    
    # Check if already complete
    if all((hero_dir / f"{key}{s}").exists() for s in ['.skel.bytes', '.atlas.txt', '.png']):
        skip += 1
        continue
    
    # Collect unique bundles
    bundles_needed = set()
    for ftype in ['skel', 'atlas', 'png']:
        pp = pmap.get(info[ftype].lower(), '')
        if pp:
            bundles_needed.add(str(REPO / pp))
    
    # Extract from each bundle
    for bp_str in bundles_needed:
        bp = Path(bp_str)
        if not bp.exists():
            continue
        
        # XOR decrypt
        data = bytearray(bp.read_bytes())
        for i in range(min(222, len(data))):
            data[i] ^= 0x16
        
        try:
            env = UnityPy.load(bytes(data))
        except:
            continue
        
        for cpath, obj in env.container.items():
            cfname = os.path.basename(cpath)
            # Only extract files for this hero
            if not cfname.startswith(key):
                continue
            
            target = hero_dir / cfname
            if target.exists():
                continue
            
            try:
                od = obj.read()
                if obj.type.name == 'TextAsset':
                    raw = od.m_Script
                    if isinstance(raw, bytes):
                        target.write_bytes(raw)
                    else:
                        target.write_bytes(raw.encode('utf-8', errors='surrogateescape'))
                elif obj.type.name == 'Texture2D':
                    od.image.save(str(target))
            except:
                pass
    
    if all((hero_dir / f"{key}{s}").exists() for s in ['.skel.bytes', '.atlas.txt', '.png']):
        ok += 1
    else:
        fail += 1

print(f"Total: {total}, OK: {ok}, Skipped: {skip}, Failed: {fail}")
