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

if [[ "$dry_run" -eq 1 ]]; then
  echo "Dry run complete; no files changed."
else
  echo "Collected $copied file(s); $missing missing."
  git -C "$repo_dir" status --short
  echo "Review the diff before committing or pushing."
fi
