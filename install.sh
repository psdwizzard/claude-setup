#!/usr/bin/env bash
set -euo pipefail

dry_run=0
no_backup=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --no-backup) no_backup=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_claude="$repo_dir/claude"
live_claude="$HOME/.claude"
live_codex="$HOME/.codex"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="$HOME/.claude-setup-backups/$timestamp"
backup_created=0

copy_file() {
  local source="$1" destination="$2" backup_relative="$3"
  if [[ -f "$destination" ]] && cmp -s "$source" "$destination"; then
    echo "  ok           $destination"
    return
  fi

  if [[ -f "$destination" && "$no_backup" -eq 0 ]]; then
    if [[ "$dry_run" -eq 1 ]]; then
      echo "  would backup $destination -> $backup_root/$backup_relative"
    else
      mkdir -p "$(dirname "$backup_root/$backup_relative")"
      cp -p "$destination" "$backup_root/$backup_relative"
      backup_created=1
    fi
  fi

  if [[ "$dry_run" -eq 1 ]]; then
    echo "  would write  $destination"
  else
    mkdir -p "$(dirname "$destination")"
    cp -p "$source" "$destination"
    echo "  wrote        $destination"
  fi
}

echo "Installing Claude Code + Codex setup from $repo_dir"
[[ "$dry_run" -eq 1 ]] && echo "DRY RUN: no files will change."

while IFS= read -r -d '' source; do
  relative="${source#"$source_claude/"}"
  copy_file "$source" "$live_claude/$relative" "claude/$relative"
done < <(find "$source_claude" -type f -print0)

config_path="$live_codex/config.toml"
temp_config="$(mktemp)"
trap 'rm -f "$temp_config" "$temp_config.next"' EXIT
if [[ -f "$config_path" ]]; then cp "$config_path" "$temp_config"; fi
for setting in \
  'model = "gpt-5.6-sol"' \
  'model_reasoning_effort = "medium"' \
  'approval_policy = "never"'; do
  key="${setting%% *}"
  if grep -Eq "^[[:space:]]*$key[[:space:]]*=" "$temp_config"; then
    awk -v key="$key" -v replacement="$setting" '
      BEGIN { done=0 }
      $0 ~ "^[[:space:]]*" key "[[:space:]]*=" && !done { print replacement; done=1; next }
      { print }
    ' "$temp_config" > "$temp_config.next"
    mv "$temp_config.next" "$temp_config"
  else
    { printf '%s\n' "$setting"; cat "$temp_config"; } > "$temp_config.next"
    mv "$temp_config.next" "$temp_config"
  fi
done

if [[ -f "$config_path" ]] && cmp -s "$temp_config" "$config_path"; then
  echo "  ok           $config_path"
else
  if [[ -f "$config_path" && "$no_backup" -eq 0 ]]; then
    if [[ "$dry_run" -eq 1 ]]; then
      echo "  would backup $config_path -> $backup_root/codex/config.toml"
    else
      mkdir -p "$backup_root/codex"
      cp -p "$config_path" "$backup_root/codex/config.toml"
      backup_created=1
    fi
  fi

  if [[ "$dry_run" -eq 1 ]]; then
    echo "  would update $config_path"
  else
    mkdir -p "$live_codex"
    mv "$temp_config" "$config_path"
    echo "  updated      $config_path"
  fi
fi

if [[ "$dry_run" -eq 0 ]]; then
  rm -f "$temp_config"
fi

if [[ "$dry_run" -eq 1 ]]; then
  echo "Dry run complete; no files changed."
elif [[ "$backup_created" -eq 1 ]]; then
  echo "Backup saved to $backup_root"
fi
echo "Done. Start a new Claude Code session to load the updated files."
