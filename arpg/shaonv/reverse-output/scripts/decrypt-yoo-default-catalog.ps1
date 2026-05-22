param(
    [string]$CatalogPath = "resources\assets\yoo\Default\BuildinCatalog.json",
    [string]$SourceDir = "resources\assets\yoo\Default",
    [string]$OutputDir = "reverse-output\assets\yoo-default-xor16-decoded",
    [byte]$Key = 0x16
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $CatalogPath)) {
    throw "Catalog not found: $CatalogPath"
}
if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "Source dir not found: $SourceDir"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $CatalogPath | ConvertFrom-Json
$count = 0
$skipped = 0

foreach ($wrapper in $catalog.Wrappers) {
    $fileName = [string]$wrapper.FileName
    $src = Join-Path $SourceDir $fileName
    $dst = Join-Path $OutputDir $fileName
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "Missing source: $src"
        $skipped++
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $src))
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        $bytes[$i] = $bytes[$i] -bxor $Key
    }
    [System.IO.File]::WriteAllBytes($dst, $bytes)
    $count++

    if (($count % 25) -eq 0) {
        Write-Output "decoded $count files..."
    }
}

Copy-Item -LiteralPath $CatalogPath -Destination (Join-Path $OutputDir "BuildinCatalog.json") -Force
$versionPath = Join-Path $SourceDir "Default.version"
if (Test-Path -LiteralPath $versionPath) {
    Copy-Item -LiteralPath $versionPath -Destination (Join-Path $OutputDir "Default.version") -Force
}

Write-Output ("done decoded={0} skipped={1} output={2}" -f $count, $skipped, (Resolve-Path -LiteralPath $OutputDir))
