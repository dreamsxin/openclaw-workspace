param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [byte]$Key = 0x16
)

$ErrorActionPreference = "Stop"

$resolvedInput = Resolve-Path -LiteralPath $InputPath
$outputDir = Split-Path -Parent $OutputPath
if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

$bytes = [System.IO.File]::ReadAllBytes($resolvedInput)
for ($i = 0; $i -lt $bytes.Length; $i++) {
    $bytes[$i] = $bytes[$i] -bxor $Key
}

[System.IO.File]::WriteAllBytes($OutputPath, $bytes)
Write-Output ("decoded {0} -> {1} ({2} bytes, key=0x{3:X2})" -f $resolvedInput, (Resolve-Path -LiteralPath $OutputPath), $bytes.Length, $Key)
