# =============================================================================
#  Collect - pull the LIVE ~/.claude files back into this repo.
#  Run this after editing CLAUDE.md or a skill on this machine, then commit and
#  push so other machines can "git pull" + run.bat to pick up the change.
# =============================================================================

$ErrorActionPreference = 'Stop'
$repo   = $PSScriptRoot
$claude = Join-Path $HOME '.claude'

$files = @(
  'CLAUDE.md',
  'skills\codex-review\SKILL.md',
  'skills\codex-implementation\SKILL.md',
  'skills\codex-computer-use\SKILL.md',
  'skills\close-out\SKILL.md'
)

Write-Host ""
Write-Host "Collecting live files from $claude into $repo" -ForegroundColor Cyan
foreach ($f in $files) {
  $src  = Join-Path $claude $f
  $dest = Join-Path $repo (Join-Path 'claude' $f)
  if (Test-Path $src) {
    $dir = Split-Path $dest -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Copy-Item $src $dest -Force
    Write-Host "  copied $f"
  } else {
    Write-Host "  WARN   missing on this machine: $src" -ForegroundColor Yellow
  }
}

Write-Host ""
Write-Host "Repo status:" -ForegroundColor Cyan
git -C $repo status --short
Write-Host ""
Write-Host "If that looks right: commit and push (or tell Claude to 'push to git')." -ForegroundColor Green
