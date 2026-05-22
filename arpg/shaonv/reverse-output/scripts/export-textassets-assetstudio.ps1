param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,

    [Parameter(Mandatory=$true)]
    [string]$OutputDir,

    [Parameter(Mandatory=$true)]
    [string]$AssetStudioDir
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Get-ChildItem -LiteralPath $AssetStudioDir -Filter *.dll | ForEach-Object { Unblock-File -LiteralPath $_.FullName }
Add-Type -Path (Join-Path $AssetStudioDir "AssetStudio.dll")

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$manager = New-Object AssetStudio.AssetsManager
if ([System.IO.Directory]::Exists($InputPath)) {
    $manager.LoadFolder($InputPath)
} else {
    $manager.LoadFiles($InputPath)
}
$count = 0
$rows = @()
Write-Output "assetsFileList count=$($manager.assetsFileList.Count)"
foreach ($asset in $manager.assetsFileList) {
    Write-Output "asset file=$($asset.fileName) objects=$($asset.Objects.Count)"
    foreach ($obj in $asset.Objects) {
        if ($obj.type -ne [AssetStudio.ClassIDType]::TextAsset) {
            continue
        }
        try {
            $textAsset = New-Object AssetStudio.TextAsset($obj)
            $name = $textAsset.m_Name
            if ([string]::IsNullOrWhiteSpace($name)) {
                $name = "TextAsset_$($obj.m_PathID)"
            }
            $safeName = [Regex]::Replace($name, '[<>:"/\\|?*\x00-\x1f]', '_')
            $bytes = $textAsset.m_Script
            $ext = ".bytes"
            if ($bytes.Length -ge 2 -and $bytes[0] -eq 0x4d -and $bytes[1] -eq 0x5a) {
                $ext = ".dll"
            }
            $out = Join-Path $OutputDir "$safeName$ext"
            [System.IO.File]::WriteAllBytes($out, $bytes)
            $count++
            $rows += [PSCustomObject]@{
                name = $name
                length = $bytes.Length
                output = $out
                pathId = $obj.m_PathID
                source = $asset.fileName
            }
            Write-Output "exported $name len=$($bytes.Length) -> $out"
        } catch {
            Write-Output "failed pathId=$($obj.m_PathID): $($_.Exception.Message)"
        }
    }
}

$rows | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $OutputDir "assetstudio-textasset-summary.json")
Write-Output "done count=$count"
