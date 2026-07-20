# claude-setup — project overview

**What this is:** the portable copy of my global Claude Code + Codex setup. The files
under `claude/` are the source of truth for `~/.claude/CLAUDE.md` and the four custom
skills; `install.ps1` (via `run.bat`) applies them to a machine, `collect.ps1` pulls
live edits back into the repo.

## The one rule that matters

`~/.claude` on a machine and `claude/` in this repo are two copies of the same files.
Any session that edits the **live** global CLAUDE.md or a skill in `~/.claude/skills/`
must also run `collect.ps1` (or copy the changed files here by hand) and push, or the
machines drift. Conversely, after a `git pull`, `run.bat` must run for the machine to
pick it up.

## Layout

- `claude/CLAUDE.md` — global instructions (model rubric, close-out routine, etc.)
- `claude/keybindings.json` — Claude Code keybindings (shift+enter = newline)
- `claude/skills/{codex-implementation,codex-review,codex-computer-use,close-out}/SKILL.md`
- `install.ps1` — copies `claude/` → `~/.claude`; patches exactly three top-level keys in
  `~/.codex/config.toml` (model gpt-5.6-sol, effort medium, approval_policy never) and
  preserves everything else, especially the `[projects]` trust list.
- `collect.ps1` — reverse copy (live → repo) + `git status` so you see what changed.
- `run.bat` — just runs `install.ps1`.

## Current state (2026-07-19)

- Repo created from the live setup on the main desktop (RTX 3090 machine), which had
  just been updated: gpt-5.5 → gpt-5.6-sol everywhere, push-delegation policy
  (sonnet-low agent for pushes, opus-medium on issues), planning-stays-with-fable rule.
- `~/.claude/setup-claude-codex.ps1` on the desktop is the OLD monolithic installer
  (files embedded as here-strings). This repo supersedes it; don't update that script,
  update the files here.

## Gotchas

- `install.ps1` must stay ASCII-only (Windows PowerShell 5.1 misreads BOM-less UTF-8
  as ANSI, so em dashes etc. would garble). The markdown files under `claude/` are
  UTF-8 and that's fine — only the .ps1/.bat files have this constraint.
- The Codex config patch is per-key and prepends new keys at the top of the file so
  they stay top-level TOML (before any `[table]` section). Don't "simplify" it into a
  whole-file overwrite — `config.toml` accumulates machine-specific `[projects]` trust
  entries that must survive.
