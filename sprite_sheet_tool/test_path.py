from pathlib import Path
p = Path('D:/work/workbuddy/arpg/assets/character')
print(p.exists(), p.is_dir())
files = list(p.iterdir())[:3]
print(files)
