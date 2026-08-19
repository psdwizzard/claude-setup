[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$NoBackup
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$sourceClaude = Join-Path $repo 'claude'
$liveClaude = Join-Path $HOME '.claude'
$liveCodex = Join-Path $HOME '.codex'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $HOME (Join-Path '.claude-setup-backups' $timestamp)
$backupCreated = $false

function Backup-ExistingFile {
  param(
    [Parameter(Mandatory)] [string]$Path,
    [Parameter(Mandatory)] [string]$RelativeBackupPath
  )

  if ($NoBackup -or -not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }

  $backupPath = Join-Path $backupRoot $RelativeBackupPath
  if ($DryRun) {
    Write-Host "  would backup $Path -> $backupPath"
    return
  }

  $backupDir = Split-Path $backupPath -Parent
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
  Copy-Item -LiteralPath $Path -Destination $backupPath -Force
  $script:backupCreated = $true
}

if (-not (Test-Path -LiteralPath $sourceClaude -PathType Container)) {
  throw "Portable source folder not found: $sourceClaude"
}

Write-Host "Installing Claude Code + Codex setup from $repo" -ForegroundColor Cyan
if ($DryRun) { Write-Host "DRY RUN: no files will change." -ForegroundColor Yellow }

Get-ChildItem -LiteralPath $sourceClaude -Recurse -File | Sort-Object FullName | ForEach-Object {
  $relative = $_.FullName.Substring($sourceClaude.Length + 1)
  $destination = Join-Path $liveClaude $relative
  $unchanged = (Test-Path -LiteralPath $destination -PathType Leaf) -and
    ((Get-FileHash -LiteralPath $_.FullName).Hash -eq (Get-FileHash -LiteralPath $destination).Hash)

  if ($unchanged) {
    Write-Host "  ok           $destination"
  } else {
    Backup-ExistingFile -Path $destination -RelativeBackupPath (Join-Path 'claude' $relative)
    if ($DryRun) {
      Write-Host "  would write  $destination"
    } else {
      $destinationDir = Split-Path $destination -Parent
      New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
      Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
      Write-Host "  wrote        $destination"
    }
  }
}

$wantedCodexSettings = [ordered]@{
  'model' = 'gpt-5.6-sol'
  'model_reasoning_effort' = 'medium'
  'approval_policy' = 'never'
}

$configPath = Join-Path $liveCodex 'config.toml'
$originalConfig = if (Test-Path -LiteralPath $configPath -PathType Leaf) {
  Get-Content -LiteralPath $configPath -Raw
} else {
  ''
}
$config = $originalConfig

foreach ($key in $wantedCodexSettings.Keys) {
  $wantedLine = "$key = `"$($wantedCodexSettings[$key])`""
  $pattern = "(?m)^\s*$([regex]::Escape($key))\s*=.*$"
  if ($config -match $pattern) {
    $config = [regex]::Replace($config, $pattern, $wantedLine, 1)
  } else {
    $config = "$wantedLine`r`n$config"
  }
}

if ($config -ceq $originalConfig) {
  Write-Host "  ok           $configPath"
} else {
  Backup-ExistingFile -Path $configPath -RelativeBackupPath 'codex\config.toml'
  if ($DryRun) {
    Write-Host "  would update $configPath"
  } else {
    New-Item -ItemType Directory -Force -Path $liveCodex | Out-Null
    [System.IO.File]::WriteAllText(
      $configPath,
      $config,
      [System.Text.UTF8Encoding]::new($false)
    )
    Write-Host "  updated      $configPath"
  }
}

Write-Host ""
if ($DryRun) {
  Write-Host "Dry run complete; no files changed." -ForegroundColor Green
} else {
  if ($backupCreated) {
    Write-Host "Backup saved to $backupRoot" -ForegroundColor Green
  } elseif (-not $NoBackup) {
    Write-Host "No existing files needed backup." -ForegroundColor DarkGray
  }
  Write-Host "Done. Start a new Claude Code session to load the updated files." -ForegroundColor Green
}
