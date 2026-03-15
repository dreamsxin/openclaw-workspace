import os
s = os.path.getsize('character_animations.html')
print(str(round(s/1024/1024, 1)) + ' MB')
