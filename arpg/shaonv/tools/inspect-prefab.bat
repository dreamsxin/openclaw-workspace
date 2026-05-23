@echo off
setlocal
set ROOT=%~dp0..
python "%ROOT%\tools\inspect_unity_prefab_layout.py" %* --repo-root "%ROOT%"
