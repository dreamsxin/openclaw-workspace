@echo off
setlocal

set "ROOT=%~dp0"
set "GODOT=%ROOT%Godot\Godot.exe"
set "PROJECT=%ROOT%standalone\godot-mvp"

if not exist "%GODOT%" (
  echo Godot executable not found: "%GODOT%"
  echo Expected tool directory: "%ROOT%Godot"
  pause
  exit /b 1
)

if not exist "%PROJECT%\project.godot" (
  echo Godot MVP project not found: "%PROJECT%\project.godot"
  pause
  exit /b 1
)

start "" "%GODOT%" --path "%PROJECT%" --scene res://scenes/main.tscn --rendering-method mobile --windowed --resolution 1670x750
