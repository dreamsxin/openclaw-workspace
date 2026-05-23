' VBScript launcher for Unity batch mode
' Runs Unity in a completely isolated process with minimal environment
Set WshShell = CreateObject("WScript.Shell")
Set WshEnv = WshShell.Environment("Process")

' Set minimal environment
WshEnv("PATH") = "C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem"
WshEnv("SystemRoot") = "C:\Windows"

Set objArgs = WScript.Arguments
projectPath = objArgs(0)
logFile = objArgs(1)

unityExe = "D:\Program Files\tuanjie_hub\2022.3.62f3c1\Editor\Unity.exe"

cmd = """" & unityExe & """ -projectPath """ & projectPath & """ -batchmode -quit -noUpm -logFile """ & logFile & """"

WshShell.Run cmd, 1, True
WScript.Quit 0
