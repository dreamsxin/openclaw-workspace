@echo off
setlocal
REM Strip all unnecessary env vars to avoid "env block too big" in bee_backend
REM Keep only essential paths

set "PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0"
set "SystemRoot=C:\Windows"
set "TEMP=%LOCALAPPDATA%\Temp"
set "TMP=%LOCALAPPDATA%\Temp"
set "USERPROFILE=%USERPROFILE%"
set "APPDATA=%APPDATA%"
set "LOCALAPPDATA=%LOCALAPPDATA%"

REM Clear all other env vars that might bloat the environment block
for /f "tokens=1,* delims==" %%a in ('set') do (
    if not "%%a"=="PATH" if not "%%a"=="SystemRoot" if not "%%a"=="TEMP" if not "%%a"=="TMP" if not "%%a"=="USERPROFILE" if not "%%a"=="APPDATA" if not "%%a"=="LOCALAPPDATA" if not "%%a"=="PROMPT" if not "%%a"=="COMSPEC" if not "%%a"=="PATHEXT" if not "%%a"=="HOMEDRIVE" if not "%%a"=="HOMEPATH" (
        set "%%a="
    )
)

echo Environment trimmed. Launching Unity batch mode...
"D:\Program Files\tuanjie_hub\2022.3.62f3c1\Editor\Unity.exe" -projectPath "D:/work/openclaw-workspace/arpg/shaonv/standalone/unity-mvp" -batchmode -quit -noUpm -logFile "D:/work/openclaw-workspace/arpg/shaonv/tmp/unity-clean.log"
echo Exit code: %ERRORLEVEL%
endlocal
