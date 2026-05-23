@echo off
setlocal EnableDelayedExpansion

set UNITY=D:\Program Files\tuanjie_hub\Editor\2022.3.62t8\Editor\Tuanjie.exe
set PROJ=D:\work\openclaw-workspace\arpg\shaonv\standalone\unity-mvp
set LOG=D:\work\openclaw-workspace\arpg\shaonv\tmp\unity-init-manual.log
set PROJNAME=unity-mvp

if not exist "%UNITY%" (
    echo [ERROR] Unity.exe not found: %UNITY%
    pause
    exit /b 1
)

echo ============================================
echo   Unity MVP - Project Init (Batch Mode)
echo ============================================
echo.
echo This script will:
echo   1. Clean old Library/Temp cache
echo   2. Launch Unity in batch mode
echo   3. Compile all C# scripts  (UGUI + TMP pkgs)
echo   4. Auto-quit when done
echo.
echo Estimated time: 1-3 min
echo ============================================
echo.

echo [1/3] Cleaning old cache...
if exist "%PROJ%\Library" (
    rmdir /s /q "%PROJ%\Library" 2>nul
    echo   Library/ deleted
)
if exist "%PROJ%\Temp" (
    rmdir /s /q "%PROJ%\Temp" 2>nul
    echo   Temp/ deleted
)

echo.
echo [2/3] Launching Unity batch mode...
echo   Unity:  %UNITY%
echo   Project: %PROJ%
echo   Log:     %LOG%
echo.

"%UNITY%" -projectPath "%PROJ%" -batchmode -quit -logFile "%LOG%"
set EC=%ERRORLEVEL%

echo.
echo [3/3] Done! Exit code: %EC%
echo.

REM Check results
set OK=0
if exist "%PROJ%\Library\ScriptAssemblies\Assembly-CSharp.dll" (
    echo [OK] Script compilation succeeded
    set OK=1
)
if exist "%PROJ%\Library\ScriptAssemblies" (
    dir /b "%PROJ%\Library\ScriptAssemblies\*.dll" 2>nul
)

if exist "%PROJ%\ProjectSettings\ProjectSettings.asset" (
    echo [OK] ProjectSettings generated
)

if "%EC%"=="0" (
    echo.
    echo ============================================
    echo   SUCCESS - Project initialized
    echo ============================================
) else (
    echo.
    echo ============================================
    echo   Exit code: %EC% (non-zero)
    echo   Check log: %LOG%
    echo ============================================
)

echo.
echo Log file: %LOG%
echo.
pause
endlocal
