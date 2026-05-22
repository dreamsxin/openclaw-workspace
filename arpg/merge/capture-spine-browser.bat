@echo off
setlocal

set "ROOT=%~dp0"
set "GODOT=%ROOT%tools\Godot\Godot_console.exe"
set "PROJECT=%ROOT%godot-project"
set "CAPTURE_DIR=%ROOT%reverse-output\spine-browser-captures"

if not exist "%GODOT%" (
  echo Godot console executable not found:
  echo   %GODOT%
  exit /b 1
)

pushd "%ROOT%" >nul

if exist "%CAPTURE_DIR%" (
  rmdir /s /q "%CAPTURE_DIR%"
)

"%GODOT%" --path "%PROJECT%" --resolution 1280x720 --quit-after 180 %* -- --spine-browser --startup-capture-dir="%CAPTURE_DIR%"
set "EXIT_CODE=%ERRORLEVEL%"
popd >nul

if %EXIT_CODE% neq 0 (
  exit /b %EXIT_CODE%
)

echo.
echo Spine browser captures written to:
echo   %CAPTURE_DIR%
dir /b "%CAPTURE_DIR%"

exit /b 0
