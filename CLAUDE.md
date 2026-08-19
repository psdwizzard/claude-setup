# claude-setup — project overview

**What this is:** the portable copy of my global Claude Code + Codex setup. The files
under `claude/` are the source of truth for `~/.claude/CLAUDE.md` and the custom skills;
`install.ps1` (via `run.bat`) applies them to a Windows machine, `collect.ps1` pulls
live edits back into the repo. On the Mac there's no PowerShell — apply/collect by
copying the files (see README).

## The one rule that matters

`~/.claude` on a machine and `claude/` in this repo are two copies of the same files.
Any session that edits the **live** global CLAUDE.md or a skill in `~/.claude/skills/`
must also run `collect.ps1` (or copy the changed files here by hand) so they can be
pushed, or the machines drift. Conversely, after a `git pull`, `run.bat` (or the Mac
copy) must run for the machine to pick it up. **Pushing itself only happens when the
user explicitly asks** ("push to git" / close-out).

## Layout

- `claude/CLAUDE.md` — global instructions (model rubric, close-out routine, etc.)
- `claude/keybindings.json` — Claude Code keybindings (shift+enter = newline)
- `claude/skills/{codex-implementation,codex-review,codex-computer-use,close-out,spin-up}/SKILL.md`
- `install.ps1` — copies `claude/` → `~/.claude`; patches exactly three top-level keys in
  `~/.codex/config.toml` (model gpt-5.6-sol, effort medium, approval_policy never) and
  preserves everything else, especially the `[projects]` trust list.
- `collect.ps1` — reverse copy (live → repo) + `git status` so you see what changed.
- `run.bat` — just runs `install.ps1`.
- `docs/devblog.md` — this repo's running log; read the top entry to re-orient.

## Current state (2026-08-19)

- Installed on the Mac (manually — no pwsh) and verified: skills + CLAUDE.md load.
- Skills in the repo: the three codex skills, close-out (now with multi-account GitHub
  identity resolution), and spin-up (close-out's mirror image, added this session).
- Global CLAUDE.md is cross-platform: machine-specific sections (CUDA/RTX 3090, .bat
  launchers) are tagged "ignore if not your OS".
- README rewritten for sharing with other people.
- `~/.claude/setup-claude-codex.ps1` on the desktop is the OLD monolithic installer
  (files embedded as here-strings). This repo supersedes it; don't update that script,
  update the files here.

## Gotchas

- **This repo may be shared publicly.** Before every push, scan the diff for leaks:
  API keys/tokens, email addresses, absolute home paths (they contain the user's real
  name), and employer/company references. Repo files point at credential locations
  (e.g. `~/.config/fal/env`) but must never contain credentials or personal paths.
- The push goes to the repo owner's **personal** GitHub account (see the remote URL);
  the machine's active `gh` account is often the work one. The close-out skill's Step 4
  resolves and switches identity safely — follow it.
- `install.ps1` and `collect.ps1` must stay ASCII-only (Windows PowerShell 5.1 misreads
  BOM-less UTF-8 as ANSI, so em dashes etc. would garble). The markdown files under
  `claude/` are UTF-8 and that's fine — only the .ps1/.bat files have this constraint.
- The Codex config patch is per-key and prepends new keys at the top of the file so
  they stay top-level TOML (before any `[table]` section). Don't "simplify" it into a
  whole-file overwrite — `config.toml` accumulates machine-specific `[projects]` trust
  entries that must survive.
- On the Mac this repo's working tree is CRLF but blobs are LF; `core.autocrlf=input`
  is set locally so status stays truthful. Don't mass-renormalize line endings.
