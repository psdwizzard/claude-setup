[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$Message) {
  $failures.Add($Message)
  Write-Host "FAIL: $Message" -ForegroundColor Red
}

$required = @(
  'LICENSE',
  '.gitignore',
  'README.md',
  'install.ps1',
  'install.sh',
  'collect.ps1',
  'collect.sh',
  'claude/CLAUDE.md'
)

foreach ($relative in $required) {
  if (-not (Test-Path -LiteralPath (Join-Path $repo $relative))) {
    Add-Failure "Missing required file: $relative"
  }
}

foreach ($script in @('install.ps1', 'collect.ps1', 'tests/validate.ps1')) {
  $path = Join-Path $repo $script
  $tokens = $null
  $parseErrors = $null
  [System.Management.Automation.Language.Parser]::ParseFile(
    $path,
    [ref]$tokens,
    [ref]$parseErrors
  ) | Out-Null
  foreach ($parseError in $parseErrors) {
    Add-Failure "$script parse error: $($parseError.Message)"
  }
}

$skillFiles = Get-ChildItem -LiteralPath (Join-Path $repo 'claude/skills') -Filter 'SKILL.md' -Recurse
if ($skillFiles.Count -eq 0) {
  Add-Failure 'No skills found under claude/skills.'
}
foreach ($skill in $skillFiles) {
  $content = Get-Content -LiteralPath $skill.FullName -Raw
  if ($content -notmatch '(?ms)^---\s*.*?^name:\s*\S+.*?^description:\s*.+?^---\s*$') {
    Add-Failure "Invalid skill frontmatter: $($skill.FullName.Substring($repo.Length + 1))"
  }
}

$sensitivePatterns = [ordered]@{
  'email address' = '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
  'Windows home path' = '[A-Za-z]:\\Users\\[^\\\s"'']+'
  'macOS/Linux home path' = '/(Users|home)/[^/\s"'']+'
  'private key' = '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'GitHub token' = 'gh[pousr]_[A-Za-z0-9_]{20,}'
  'common provider key' = '(sk-[A-Za-z0-9_-]{16,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{30,})'
}

$scanFiles = Get-ChildItem -LiteralPath $repo -File -Recurse | Where-Object {
  $_.FullName -notlike (Join-Path $repo '.git\*')
}
foreach ($file in $scanFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
  foreach ($entry in $sensitivePatterns.GetEnumerator()) {
    if ($content -match $entry.Value) {
      Add-Failure "$($entry.Key) pattern found in $($file.FullName.Substring($repo.Length + 1))"
    }
  }
}

if ($failures.Count -gt 0) {
  throw "Validation failed with $($failures.Count) issue(s)."
}

Write-Host "Validation passed: $($skillFiles.Count) skills and $($scanFiles.Count) repository files checked." -ForegroundColor Green
