param(
    [string]$RepoRoot = "."
)

$ErrorActionPreference = "Stop"

$repo = (Resolve-Path $RepoRoot).Path
$unityRoot = Join-Path $repo "standalone\unity-mvp\Assets\Resources\UI"
$godotRoot = Join-Path $repo "standalone\godot-mvp\assets\ui"
$conflictRoot = Join-Path $godotRoot "unity_conflicts"
$reportDir = Join-Path $repo "reverse-output\godot-resource-export"
$reportPath = Join-Path $reportDir "unity-ui-merge-report.json"

if (-not (Test-Path $unityRoot)) {
    throw "Unity UI root not found: $unityRoot"
}

function Get-TargetRelativePath {
    param(
        [string]$SourceDir,
        [string]$FileName
    )

    switch ($SourceDir) {
        "BackGround" {
            if ($FileName -like "gal_gallery_pic_*.png") { return Join-Path "gallery" $FileName }
            return Join-Path "background" $FileName
        }
        "Battle" { return Join-Path "battle" $FileName }
        "Common" { return Join-Path "common" $FileName }
        "Hero" {
            if ($FileName -like "zhero_*.png") { return Join-Path "hero\recruit" $FileName }
            if ($FileName -like "phero_*.png") { return Join-Path "hero\half" $FileName }
            if ($FileName -like "yhero_*.png") { return Join-Path "hero\round" $FileName }
            if ($FileName -like "thero_*.png") { return Join-Path "hero\square" $FileName }
            return Join-Path "hero" $FileName
        }
        "Item" {
            if ($FileName -like "thero_*.png") { return Join-Path "hero\square" $FileName }
            return Join-Path "item" $FileName
        }
        "Loading" { return Join-Path "loading" $FileName }
        "Login" { return Join-Path "login" $FileName }
        "LotteryDraw" { return Join-Path "lottery" $FileName }
        "Mail" { return Join-Path "mail" $FileName }
        "MainUI" { return Join-Path "mainui" $FileName }
        "Task" { return Join-Path "task" $FileName }
        "Welfare" { return Join-Path "welfare" $FileName }
        default { throw "Unhandled Unity UI source directory: $SourceDir" }
    }
}

function New-ConflictPath {
    param(
        [string]$MappedRelativePath,
        [string]$SourceDir,
        [string]$FileName
    )

    $mappedDir = Split-Path $MappedRelativePath -Parent
    $safeSourceDir = $SourceDir.ToLowerInvariant()
    return Join-Path (Join-Path $conflictRoot $mappedDir) "$safeSourceDir`__$FileName"
}

function Remove-EmptyDirectories {
    param([string]$RootPath)

    Get-ChildItem $RootPath -Directory -Recurse |
        Sort-Object FullName -Descending |
        ForEach-Object {
            if (-not (Get-ChildItem $_.FullName -Force | Select-Object -First 1)) {
                Remove-Item $_.FullName -Force
            }
        }

    if (-not (Get-ChildItem $RootPath -Force | Select-Object -First 1)) {
        Remove-Item $RootPath -Force
    }
}

$stats = [ordered]@{
    moved_unique = 0
    removed_duplicate = 0
    moved_conflict = 0
}

$report = New-Object System.Collections.ArrayList
$files = Get-ChildItem $unityRoot -Recurse -File -Filter *.png | Sort-Object FullName

foreach ($file in $files) {
    $sourceDir = $file.Directory.Name
    $targetRelative = Get-TargetRelativePath -SourceDir $sourceDir -FileName $file.Name
    $targetPath = Join-Path $godotRoot $targetRelative
    $targetDir = Split-Path $targetPath -Parent

    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    if (-not (Test-Path $targetPath)) {
        Move-Item -LiteralPath $file.FullName -Destination $targetPath
        $stats.moved_unique++
        [void]$report.Add([ordered]@{
            action = "move_unique"
            source = $file.FullName.Replace($repo + "\", "")
            destination = $targetPath.Replace($repo + "\", "")
        })
        continue
    }

    $sourceHash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    $targetHash = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash

    if ($sourceHash -eq $targetHash) {
        Remove-Item -LiteralPath $file.FullName -Force
        $stats.removed_duplicate++
        [void]$report.Add([ordered]@{
            action = "remove_duplicate"
            source = $file.FullName.Replace($repo + "\", "")
            destination = $targetPath.Replace($repo + "\", "")
        })
        continue
    }

    $conflictPath = New-ConflictPath -MappedRelativePath $targetRelative -SourceDir $sourceDir -FileName $file.Name
    $conflictDir = Split-Path $conflictPath -Parent
    New-Item -ItemType Directory -Force -Path $conflictDir | Out-Null
    Move-Item -LiteralPath $file.FullName -Destination $conflictPath
    $stats.moved_conflict++
    [void]$report.Add([ordered]@{
        action = "move_conflict"
        source = $file.FullName.Replace($repo + "\", "")
        destination = $conflictPath.Replace($repo + "\", "")
        existing = $targetPath.Replace($repo + "\", "")
    })
}

Remove-EmptyDirectories -RootPath (Join-Path $repo "standalone\unity-mvp")

New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
$reportObject = [ordered]@{
    stats = $stats
    generatedAt = (Get-Date).ToString("s")
    entries = $report
}
$reportObject | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $reportPath

Write-Output "moved_unique=$($stats.moved_unique)"
Write-Output "removed_duplicate=$($stats.removed_duplicate)"
Write-Output "moved_conflict=$($stats.moved_conflict)"
Write-Output "report=$($reportPath.Replace($repo + '\', ''))"
