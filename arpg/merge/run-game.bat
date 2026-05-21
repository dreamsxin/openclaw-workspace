@echo off
setlocal

set "ROOT=%~dp0"
set "GODOT=%ROOT%tools\Godot\Godot.exe"
set "GODOT_CONSOLE=%ROOT%tools\Godot\Godot_console.exe"
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

if exist "%GODOT_CONSOLE%" (
  echo Importing Godot assets...
  "%GODOT_CONSOLE%" --headless --import --path "%PROJECT%"
  if errorlevel 1 (
    set "EXIT_CODE=%ERRORLEVEL%"
    popd >nul
    exit /b %EXIT_CODE%
  )
) else (
  echo Godot console executable not found, importing with GUI executable:
  echo   %GODOT_CONSOLE%
  "%GODOT%" --headless --import --path "%PROJECT%"
  if errorlevel 1 (
    set "EXIT_CODE=%ERRORLEVEL%"
    popd >nul
    exit /b %EXIT_CODE%
  )
)

"%GODOT%" --path "%PROJECT%" --resolution 540x960 %* -- --restored-startup
set "EXIT_CODE=%ERRORLEVEL%"
popd >nul

exit /b %EXIT_CODE%
