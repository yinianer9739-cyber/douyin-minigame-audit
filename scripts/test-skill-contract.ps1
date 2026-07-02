param()

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillDir = Split-Path -Parent $scriptDir

function Read-Text {
    param([string]$Path)
    return Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $skillDir $Path)
}

function Assert-Contains {
    param(
        [string]$Name,
        [string]$Haystack,
        [string]$Needle
    )
    if ($Haystack -notlike "*$Needle*") {
        throw "Missing contract marker: $Name -> $Needle"
    }
}

function Assert-NotContains {
    param(
        [string]$Name,
        [string]$Haystack,
        [string]$Needle
    )
    if ($Haystack -like "*$Needle*") {
        throw "Forbidden contract marker present: $Name -> $Needle"
    }
}

$skill = Read-Text "SKILL.md"
$readme = Read-Text "README.md"
$yaml = Read-Text "assets/audit-input.zh.yaml"
$saveScript = Read-Text "scripts/save-audit-input.ps1"
$checkUpdateScript = Read-Text "scripts/check-update.ps1"
$version = (Read-Text "VERSION").Trim()

Assert-Contains "version" $version "0.3.2"
Assert-Contains "first touch gate" $skill "First Touch Gate"
Assert-Contains "new-or-existing question" $skill "new project or existing project"
Assert-Contains "no empty report" $skill "bare trigger phrase"
Assert-Contains "project scoped save" $skill ".douyin-minigame-audit/projects/<project-slug>"
Assert-Contains "fuzzy old project" $skill "project nickname"
Assert-Contains "provided content scope" $skill "provided content appears compliant"
Assert-Contains "unknown legal materials" $skill "outside the user's role"
Assert-Contains "missing materials section" $skill "Missing Materials And Owners"
Assert-Contains "README first run" $readme "will not immediately produce an audit"
Assert-Contains "YAML project alias" $yaml "AppID"
Assert-Contains "save project name parameter" $saveScript "ProjectName"
Assert-Contains "sidebar revisit skill rule" $skill "Sidebar Revisit Required Ability"
Assert-Contains "sidebar revisit api signal" $skill "tt.navigateToScene"
Assert-Contains "sidebar revisit high risk" $skill "sidebar revisit is missing"
Assert-Contains "YAML sidebar field" $yaml "sidebar_revisit_required"
Assert-Contains "official essential skills doc" (Read-Text "references/official-norms.md") "essential-skills"
Assert-Contains "official sidebar doc" (Read-Text "references/official-norms.md") "sidebar"
Assert-Contains "every trigger update check skill doc" $skill "Every Trigger Update Check"
Assert-Contains "every trigger update check README" $readme "Every trigger update check"
Assert-NotContains "no skipped_today status in update script" $checkUpdateScript "skipped_today"
Assert-NotContains "no daily update check heading" $skill "Daily Update Check"
Assert-NotContains "no daily update check README heading" $readme "Daily Update Check"

Write-Output "skill contract ok"
