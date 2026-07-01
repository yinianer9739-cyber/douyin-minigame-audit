param(
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillDir = Split-Path -Parent $scriptDir
$version = (Get-Content -LiteralPath (Join-Path $skillDir "VERSION") -Raw).Trim()

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $skillDir "release"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$zipPath = Join-Path $OutputDir ("douyin-minigame-audit-v$version.zip")
$stageRoot = Join-Path $env:TEMP ("douyin-minigame-audit-package-" + [guid]::NewGuid().ToString("N"))
$stageSkill = Join-Path $stageRoot "douyin-minigame-audit"

New-Item -ItemType Directory -Force -Path $stageSkill | Out-Null

$excludeNames = @(".git", ".github", "release")
Get-ChildItem -LiteralPath $skillDir -Force | ForEach-Object {
    if ($_.Name -in $excludeNames) {
        return
    }
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $stageSkill $_.Name) -Recurse -Force
}

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
Compress-Archive -LiteralPath $stageSkill -DestinationPath $zipPath -Force
Remove-Item -LiteralPath $stageRoot -Recurse -Force

Write-Output $zipPath
