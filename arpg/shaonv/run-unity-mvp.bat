@echo off
REM Run Unity MVP project
REM Requires Unity 2022.3.62f2 installed at default location

set UNITY_EXE=D:\Program Files\tuanjie_hub\Editor\2022.3.62t8\Editor\Tuanjie.exe

if not exist "%UNITY_EXE%" (
    echo ERROR: Unity not found at %UNITY_EXE%
    pause
    exit /b 1
)

echo Starting Unity MVP...
"%UNITY_EXE%" -projectPath "%~dp0standalone\unity-mvp" -logFile "%~dp0tmp\unity-mvp.log"
