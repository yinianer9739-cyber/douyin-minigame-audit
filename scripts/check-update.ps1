param(
    [switch]$Install,
    [switch]$Force,
    [string]$Owner = "yinianer9739-cyber",
    [string]$Repo = "douyin-minigame-audit",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

function Write-Result {
    param(
        [string]$Status,
        [hashtable]$Extra = @{}
    )
    $data = [ordered]@{ status = $Status }
    foreach ($key in $Extra.Keys) {
        $data[$key] = $Extra[$key]
    }
    $data | ConvertTo-Json -Depth 6
}

function ConvertTo-Version {
    param([string]$Text)
    $clean = ($Text -replace '^v', '').Trim()
    return [version]$clean
}

function Copy-DirectoryContents {
    param(
        [string]$Source,
        [string]$Destination
    )
    Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
        if ($_.Name -in @(".git", ".github")) {
            return
        }
        $target = Join-Path $Destination $_.Name
        if ($_.PSIsContainer) {
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Recurse -Force
            }
            Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
        }
        else {
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillDir = Split-Path -Parent $scriptDir
$versionFile = Join-Path $skillDir "VERSION"
$localVersionText = if (Test-Path -LiteralPath $versionFile) { Get-Content -LiteralPath $versionFile -Raw } else { "0.0.0" }
$localVersion = ConvertTo-Version $localVersionText

$stateRoot = Join-Path $env:LOCALAPPDATA "douyin-minigame-audit"
$stateFile = Join-Path $stateRoot "update-check.json"
New-Item -ItemType Directory -Force -Path $stateRoot | Out-Null

$remoteVersionUrl = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/VERSION"
$archiveUrl = "https://github.com/$Owner/$Repo/archive/refs/heads/$Branch.zip"

try {
    try {
        $remoteVersionText = (Invoke-WebRequest -Uri $remoteVersionUrl -UseBasicParsing -TimeoutSec 20).Content
    }
    catch {
        if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 404) {
            $stateData = [ordered]@{
                last_check_date = (Get-Date).ToString("yyyy-MM-dd")
                local_version = $localVersion.ToString()
                remote_version = $null
                checked_at = (Get-Date).ToString("s")
                note = "Remote VERSION file was not found."
            }
            $stateData | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $stateFile -Encoding UTF8
            Write-Result "remote_version_missing" @{
                local_version = $localVersion.ToString()
                remote_version_url = $remoteVersionUrl
                message = "Remote VERSION is not published yet. Continue with the local skill version."
            }
            exit 0
        }
        throw
    }

    $remoteVersion = ConvertTo-Version $remoteVersionText

    $stateData = [ordered]@{
        last_check_date = (Get-Date).ToString("yyyy-MM-dd")
        local_version = $localVersion.ToString()
        remote_version = $remoteVersion.ToString()
        checked_at = (Get-Date).ToString("s")
    }
    $stateData | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $stateFile -Encoding UTF8

    if ($remoteVersion -le $localVersion) {
        Write-Result "up_to_date" @{
            local_version = $localVersion.ToString()
            remote_version = $remoteVersion.ToString()
        }
        exit 0
    }

    if (-not $Install) {
        Write-Result "update_available" @{
            local_version = $localVersion.ToString()
            remote_version = $remoteVersion.ToString()
            archive_url = $archiveUrl
        }
        exit 0
    }

    $tmpRoot = Join-Path $env:TEMP ("douyin-minigame-audit-update-" + [guid]::NewGuid().ToString("N"))
    $zipPath = Join-Path $tmpRoot "source.zip"
    $extractDir = Join-Path $tmpRoot "extract"
    New-Item -ItemType Directory -Force -Path $tmpRoot, $extractDir | Out-Null

    Invoke-WebRequest -Uri $archiveUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 60
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

    $sourceRoot = Get-ChildItem -LiteralPath $extractDir -Directory | Select-Object -First 1
    if ($null -eq $sourceRoot) {
        throw "Downloaded archive did not contain a source directory."
    }

    $backupRoot = Join-Path $stateRoot "backups"
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    $backupPath = Join-Path $backupRoot ("douyin-minigame-audit-" + (Get-Date).ToString("yyyyMMdd-HHmmss"))
    Copy-Item -LiteralPath $skillDir -Destination $backupPath -Recurse -Force

    Copy-DirectoryContents -Source $sourceRoot.FullName -Destination $skillDir

    Write-Result "installed" @{
        previous_version = $localVersion.ToString()
        installed_version = $remoteVersion.ToString()
        backup_path = $backupPath
        message = "Restart Codex or the current AI client. After restart, return to this conversation and say '继续' to resume the unfinished audit flow."
    }
    exit 0
}
catch {
    Write-Result "failed" @{
        local_version = $localVersion.ToString()
        error = $_.Exception.Message
    }
    exit 1
}
