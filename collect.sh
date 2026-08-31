#!/usr/bin/env bash
set -euo pipefail

dry_run=0
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=1
elif [[ "$#" -gt 0 ]]; then
  echo "Usage: $0 [--dry-run]" >&2
  exit 2
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_claude="$repo_dir/claude"
live_claude="$HOME/.claude"
copied=0
missing=0

echo "Collecting declared portable files from $live_claude"
echo "Only files already present under repo/claude are eligible."

while IFS= read -r -d '' destination; do
  relative="${destination#"$repo_claude/"}"
  source="$live_claude/$relative"
  if [[ ! -f "$source" ]]; then
    echo "  WARN missing $relative" >&2
    missing=$((missing + 1))
    continue
  fi
  if [[ "$dry_run" -eq 1 ]]; then
    echo "  would copy  $relative"
  else
    cp -p "$source" "$destination"
    echo "  copied      $relative"
    copied=$((copied + 1))
  fi
done < <(find "$repo_claude" -type f -print0)

strip_work_import() {
  # The live CLAUDE.md on work machines ends with a "## Work import" section that
  # imports CLAUDE.work.md (employer-specific). That section must never ship in the
  # public payload. Idempotent: a no-op when the section is absent.
  # \r?-tolerant: the live file may be CRLF (installed from this repo's working tree).
  local file="$1"
  awk '
    /^## Work import\r?$/ { skipping = 1; next }
    skipping && /^@CLAUDE\.work\.md\r?$/ { skipping = 0; next }
    !skipping { print }
  ' "$file" > "$file.tmp"
  # Trim trailing blank lines left behind by the removal.
  awk '/[^[:space:]]/ { blanks = 0 } !/[^[:space:]]/ { blanks++; next } { for (i = 0; i < blanks; i++) print ""; print }' \
    "$file.tmp" > "$file" && rm -f "$file.tmp"
}

leak_check() {
  # The payload is public: no employer references may ship. Word-boundary match so
  # ordinary words (false, fallback) do not trip it.
  if grep -riIEn '\bfal\b|fal\.ai|fal-|CLAUDE\.work' "$repo_claude" ; then
    echo "LEAK CHECK FAILED: work references found in the public payload (see above)." >&2
    echo "Fix the live files or the strip step; nothing was pushed." >&2
    return 1
  fi
  echo "Leak check passed: no work references in the payload."
}

if [[ "$dry_run" -eq 1 ]]; then
  echo "Dry run complete; no files changed."
else
  strip_work_import "$repo_claude/CLAUDE.md"
  leak_check
  echo "Collected $copied file(s); $missing missing."
  git -C "$repo_dir" status --short
  echo "Review the diff before committing or pushing."
fi
