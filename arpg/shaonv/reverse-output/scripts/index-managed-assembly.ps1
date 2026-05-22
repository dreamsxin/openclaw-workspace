param(
    [Parameter(Mandatory=$true)]
    [string]$AssemblyPath,

    [Parameter(Mandatory=$true)]
    [string]$CecilPath,

    [Parameter(Mandatory=$true)]
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Unblock-File -LiteralPath $CecilPath
Add-Type -Path $CecilPath
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($AssemblyPath)
$types = New-Object System.Collections.Generic.List[object]
$methods = New-Object System.Collections.Generic.List[object]

function Add-TypeRecursive {
    param($type)
    $baseType = ""
    if ($null -ne $type.BaseType) { $baseType = $type.BaseType.FullName }
    $types.Add([PSCustomObject]@{
        FullName = $type.FullName
        Namespace = $type.Namespace
        Name = $type.Name
        BaseType = $baseType
        MethodCount = $type.Methods.Count
        FieldCount = $type.Fields.Count
    })
    foreach ($method in $type.Methods) {
        $params = ($method.Parameters | ForEach-Object { $_.ParameterType.FullName }) -join "|"
        $methods.Add([PSCustomObject]@{
            Type = $type.FullName
            Name = $method.Name
            ReturnType = $method.ReturnType.FullName
            Parameters = $params
            HasBody = $method.HasBody
        })
    }
    foreach ($nested in $type.NestedTypes) {
        Add-TypeRecursive $nested
    }
}

foreach ($module in $asm.Modules) {
    foreach ($type in $module.Types) {
        Add-TypeRecursive $type
    }
}

$types | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "types.csv")
$methods | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "methods.csv")

$uiPattern = '(^|\.|/|_)(UI|Ui|Popup|Panel|View|Window|Lobby|Login|Loading|Tutorial|Guide|Hud|HUD|Dialog|RedDot|MainView|Grid|Item)'
$types |
    Where-Object { $_.FullName -match $uiPattern -or $_.BaseType -match $uiPattern } |
    Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "ui-types.csv")

$methods |
    Where-Object { $_.Name -match 'Open|Close|Show|Hide|Init|Start|Awake|OnEnable|Load|Scene|Login|Lobby|Guide|Tutorial|Create|Destroy|Push|Pop' -or $_.Type -match $uiPattern } |
    Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutputDir "ui-methods.csv")

Write-Output "types=$($types.Count)"
Write-Output "methods=$($methods.Count)"
Write-Output "uiTypes=$(($types | Where-Object { $_.FullName -match $uiPattern -or $_.BaseType -match $uiPattern }).Count)"
