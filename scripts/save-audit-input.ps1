param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,

    [string]$PackageDir,
    [string]$ProjectDir,
    [string]$OutputDir,
    [string]$ProjectName,
    [string]$ProjectAliases
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $InputFile -PathType Leaf)) {
    throw "Input file not found: $InputFile"
}

$ext = [System.IO.Path]::GetExtension($InputFile).ToLowerInvariant()
if ($ext -notin @(".yaml", ".yml", ".md", ".markdown")) {
    throw "Unsupported input extension '$ext'. Use YAML or Markdown."
}

function Resolve-ExistingDirectory {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }
    if (Test-Path -LiteralPath $Path -PathType Container) {
        return (Resolve-Path -LiteralPath $Path).Path
    }
    return $null
}

function ConvertTo-Slug {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $normalized = $Value.Trim().ToLowerInvariant()
    $normalized = $normalized -replace "[\\/:*?`"<>|]", "-"
    $normalized = $normalized -replace "\s+", "-"
    $normalized = $normalized -replace "-+", "-"
    $normalized = $normalized.Trim("-")

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        return "unnamed-project"
    }
    return $normalized
}

$base = Resolve-ExistingDirectory $OutputDir
if ($null -eq $base) {
    $base = Resolve-ExistingDirectory $PackageDir
}
if ($null -eq $base) {
    $base = Resolve-ExistingDirectory $ProjectDir
}
if ($null -eq $base) {
    $base = (Get-Location).Path
}

$rootStateDir = Join-Path $base ".douyin-minigame-audit"
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $stateDir = $rootStateDir
} else {
    $projectSlug = ConvertTo-Slug $ProjectName
    $stateDir = Join-Path (Join-Path $rootStateDir "projects") $projectSlug
}
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null

$targetName = if ($ext -in @(".md", ".markdown")) { "audit-input.md" } else { "audit-input.yaml" }
$target = Join-Path $stateDir $targetName
Copy-Item -LiteralPath $InputFile -Destination $target -Force

$meta = [ordered]@{
    saved_at = (Get-Date).ToString("s")
    input_file = (Resolve-Path -LiteralPath $InputFile).Path
    saved_file = $target
    project_name = $ProjectName
    project_aliases = @(
        if (-not [string]::IsNullOrWhiteSpace($ProjectAliases)) {
            $ProjectAliases -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }
    )
    package_dir = $PackageDir
    project_dir = $ProjectDir
}

$metaPath = Join-Path $stateDir "last-save.json"
($meta | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $metaPath -Encoding UTF8

Write-Output $target
