@echo off
setlocal

set "ROOT=%~dp0"
set "GODOT=%ROOT%tools\Godot\Godot.exe"
set "PROJECT=%ROOT%godot-project"

if not exist "%GODOT%" (
  echo Godot executable not found:
  echo   %GODOT%
  exit /b 1
)

if not exist "%PROJECT%\project.godot" (
  echo Godot project not found:
  echo   %PROJECT%\project.godot
  exit /b 1
)

pushd "%ROOT%" >nul
"%GODOT%" --path "%PROJECT%" %*
set "EXIT_CODE=%ERRORLEVEL%"
popd >nul

exit /b %EXIT_CODE%
