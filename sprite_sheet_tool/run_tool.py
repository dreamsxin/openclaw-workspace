import sys, traceback
sys.argv = [
    'sprite_preview',
    'D:/work/workbuddy/arpg/assets/character',
    '-o', 'character_animations.html'
]
try:
    import sprite_preview
    sprite_preview.main()
except SystemExit as e:
    print(f"SystemExit: {e.code}")
except Exception as e:
    traceback.print_exc()
