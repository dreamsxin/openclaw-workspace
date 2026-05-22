@echo off
setlocal

set "ROOT=%~dp0"
set "GODOT=%ROOT%Godot\Godot_console.exe"
set "PROJECT=%ROOT%standalone\godot-mvp"

if not exist "%GODOT%" (
  echo Godot console executable not found: "%GODOT%"
  echo Expected tool directory: "%ROOT%Godot"
  pause
  exit /b 1
)

if not exist "%PROJECT%\project.godot" (
  echo Godot MVP project not found: "%PROJECT%\project.godot"
  pause
  exit /b 1
)

"%GODOT%" --path "%PROJECT%" --scene res://scenes/main.tscn --rendering-method mobile --windowed --resolution 1280x720
pause
