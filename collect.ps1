[CmdletBinding()]
param(
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$repoClaude = Join-Path $repo 'claude'
$liveClaude = Join-Path $HOME '.claude'

if (-not (Test-Path -LiteralPath $repoClaude -PathType Container)) {
  throw "Portable source folder not found: $repoClaude"
}

$files = Get-ChildItem -LiteralPath $repoClaude -Recurse -File |
  Where-Object { $_.Name -notmatch '^\.credentials' -and $_.Name -ne 'settings.local.json' } |
  Sort-Object FullName

Write-Host "Collecting declared portable files from $liveClaude" -ForegroundColor Cyan
Write-Host "Only files already present under repo/claude are eligible." -ForegroundColor DarkGray

$copied = 0
$missing = 0
foreach ($file in $files) {
  $relative = $file.FullName.Substring($repoClaude.Length + 1)
  $source = Join-Path $liveClaude $relative
  $destination = $file.FullName

  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    Write-Warning "Missing on this machine: $relative"
    $missing++
    continue
  }

  if ($DryRun) {
    Write-Host "  would copy  $relative"
    continue
  }

  Copy-Item -LiteralPath $source -Destination $destination -Force
  Write-Host "  copied      $relative"
  $copied++
}

Write-Host ""
if ($DryRun) {
  Write-Host "Dry run complete; no files changed." -ForegroundColor Green
} else {
  Write-Host "Collected $copied file(s); $missing missing." -ForegroundColor Green
  Write-Host ""
  Write-Host "Repo status:" -ForegroundColor Cyan
  git -C $repo status --short
  Write-Host ""
  Write-Host "Review the diff before committing or pushing." -ForegroundColor Green
}
