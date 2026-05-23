@echo off
set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem
set SystemRoot=C:\Windows

"D:\Program Files\tuanjie_hub\2022.3.62f3c1\Editor\Unity.exe" -projectPath "D:/work/openclaw-workspace/arpg/shaonv/standalone/unity-mvp" -batchmode -quit -noUpm -logFile "D:/work/openclaw-workspace/arpg/shaonv/tmp/unity-clean3.log"
echo EXIT_CODE=%ERRORLEVEL% >> "D:/work/openclaw-workspace/arpg/shaonv/tmp/unity-clean3.log"
