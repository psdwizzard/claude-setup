# =============================================================================
#  Claude Code + Codex - machine setup installer
#  Usage: run.bat   (or: powershell -ExecutionPolicy Bypass -File install.ps1)
#
#  1. Copies the files under claude\ into ~/.claude (global CLAUDE.md + skills).
#  2. Sets three keys in ~/.codex/config.toml to this repo's standard values
#     (model = gpt-5.6-sol, model_reasoning_effort = medium, approval_policy =
#     never - the same values setup-claude-codex.ps1 has always applied). Only
#     those three lines are touched; the [projects] trust list and everything
#     else Codex wrote is preserved. Safe to re-run; after "git pull", re-run
#     to apply updates to this machine.
# =============================================================================

$ErrorActionPreference = 'Stop'
$repo   = $PSScriptRoot
$claude = Join-Path $HOME '.claude'
$codex  = Join-Path $HOME '.codex'

Write-Host ""
Write-Host "Installing Claude Code + Codex setup from $repo" -ForegroundColor Cyan
Write-Host "Home: $HOME"
Write-Host ""

# ---- ~/.claude files (CLAUDE.md + skills) -----------------------------------
$src = Join-Path $repo 'claude'
Get-ChildItem $src -Recurse -File | ForEach-Object {
  $rel  = $_.FullName.Substring($src.Length + 1)
  $dest = Join-Path $claude $rel
  $dir  = Split-Path $dest -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  Copy-Item $_.FullName $dest -Force
  Write-Host "  wrote  $dest"
}

# ---- Codex config -----------------------------------------------------------
$want = [ordered]@{
  'model'                  = 'gpt-5.6-sol'
  'model_reasoning_effort' = 'medium'
  'approval_policy'        = 'never'
}

$cfgPath = Join-Path $codex 'config.toml'
if (Test-Path $cfgPath) {
  $cfg = Get-Content $cfgPath -Raw
  foreach ($k in $want.Keys) {
    $line    = "$k = `"$($want[$k])`""
    $pattern = "(?m)^\s*$([regex]::Escape($k))\s*=.*$"
    if ($cfg -match $pattern) {
      $current = [regex]::Match($cfg, $pattern).Value.Trim()
      if ($current -eq $line) {
        Write-Host "  ok     $line"
      } else {
        $cfg = [regex]::Replace($cfg, $pattern, $line, 1)
        Write-Host "  patch  $current  ->  $line"
      }
    } else {
      # prepend: top of file = top-level TOML, before any [table] section
      $cfg = "$line`r`n" + $cfg
      Write-Host "  add    $line"
    }
  }
  [System.IO.File]::WriteAllText($cfgPath, $cfg, (New-Object System.Text.UTF8Encoding($false)))
} else {
  $lines = foreach ($k in $want.Keys) { "$k = `"$($want[$k])`"" }
  $seed  = ($lines -join "`r`n") + "`r`n"
  if (-not (Test-Path $codex)) { New-Item -ItemType Directory -Force -Path $codex | Out-Null }
  [System.IO.File]::WriteAllText($cfgPath, $seed, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host "  wrote  $cfgPath (fresh; Codex adds its own [projects] entries as you use it)"
}

# ---- sanity checks ----------------------------------------------------------
Write-Host ""
Write-Host "Checking CLIs..." -ForegroundColor Cyan
$codexCmd = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd) {
  Write-Host "  ok     codex found: $($codexCmd.Source)"
} else {
  Write-Host "  WARN   codex not on PATH. Install it with:  npm install -g @openai/codex" -ForegroundColor Yellow
}
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
  Write-Host "  WARN   claude not on PATH. Install Claude Code first." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Start a NEW Claude Code session for CLAUDE.md + skills to load." -ForegroundColor Green
