@echo off
setlocal

set "ROOT=%~dp0"
set "GODOT=%ROOT%tools\Godot\Godot_console.exe"
set "PROJECT=%ROOT%godot-project"
set "CAPTURE_DIR=%ROOT%reverse-output\startup-captures"

if not exist "%GODOT%" (
  echo Godot console executable not found:
  echo   %GODOT%
  exit /b 1
)

if not exist "%PROJECT%\project.godot" (
  echo Godot project not found:
  echo   %PROJECT%\project.godot
  exit /b 1
)

if exist "%CAPTURE_DIR%" (
  rmdir /s /q "%CAPTURE_DIR%"
)

pushd "%ROOT%" >nul
"%GODOT%" --path "%PROJECT%" --resolution 540x960 --quit-after 480 %* -- --restored-startup --startup-capture-dir="%CAPTURE_DIR%"
set "EXIT_CODE=%ERRORLEVEL%"
popd >nul

if %EXIT_CODE% neq 0 (
  exit /b %EXIT_CODE%
)

echo.
echo Startup captures written to:
echo   %CAPTURE_DIR%
dir /b "%CAPTURE_DIR%"

exit /b 0
