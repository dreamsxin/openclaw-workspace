@echo off
setlocal

set "ROOT=%~dp0"
set "GODOT=%ROOT%Godot\Godot_console.exe"
set "PROJECT=%ROOT%standalone\godot-mvp"
set "SHOT=%ROOT%tmp\screenshots\godot-mvp-internal.png"

if not exist "%GODOT%" (
  echo Godot console executable not found: "%GODOT%"
  pause
  exit /b 1
)

if not exist "%PROJECT%\project.godot" (
  echo Godot MVP project not found: "%PROJECT%\project.godot"
  pause
  exit /b 1
)

if not exist "%ROOT%tmp\screenshots" mkdir "%ROOT%tmp\screenshots"
set "SHAONV_MVP_CAPTURE=%SHOT%"
"%GODOT%" --path "%PROJECT%" --scene res://scenes/main.tscn --rendering-method mobile --quit-after 3
echo Screenshot saved to: "%SHOT%"
pause
