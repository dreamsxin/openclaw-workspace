param(
    [string]$RepoRoot = ".",
    [string]$SourceDir = "reverse-output\media-export\Assets\Game\RawAssets\Video",
    [string]$OutDir = "standalone\godot-mvp\assets\video\recruit"
)

$ErrorActionPreference = "Stop"

$repo = Resolve-Path $RepoRoot
$source = Join-Path $repo $SourceDir
$out = Join-Path $repo $OutDir
New-Item -ItemType Directory -Force -Path $out | Out-Null

$ids = @(
    "009", "010", "012", "013", "014", "016", "018", "027", "046", "050",
    "051", "052", "053", "054", "056", "061", "062", "064", "065"
)

foreach ($id in $ids) {
    $src = Join-Path $source "recruit_${id}_1.mp4"
    if (-not (Test-Path $src)) {
        $src = Join-Path $source "recruit_${id}.mp4"
    }
    if (-not (Test-Path $src)) {
        Write-Warning "missing source recruit_${id}"
        continue
    }

    $dst = Join-Path $out "recruit_${id}.ogv"
    Write-Host "transcode recruit_${id}"
    ffmpeg -hide_banner -loglevel error -y -i $src -vf "scale='min(1280,iw)':-2" -c:v libtheora -q:v 6 -an $dst
}

Get-ChildItem $out -Filter *.ogv | Sort-Object Name | Select-Object Name,Length
