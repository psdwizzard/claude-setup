# claude-setup — project overview

**What this is:** the portable copy of my global Claude Code + Codex setup. The files
under `claude/` are the source of truth for `~/.claude/CLAUDE.md` and the custom skills;
`install.ps1` (via `run.bat`) and `install.sh` apply them to a machine; the matching
collect scripts pull declared live files back into the repo.

## The one rule that matters

`~/.claude` on a machine and `claude/` in this repo are two copies of the same files.
Any session that edits the **live** global CLAUDE.md or a skill in `~/.claude/skills/`
must also run the platform's collect script so they can be pushed, or the machines
drift. Conversely, after a `git pull`, run the platform installer for the machine to
pick it up. **Pushing itself only happens when the user explicitly asks** ("push to
git" / close-out).

## Layout

- `claude/CLAUDE.md` — global instructions (model rubric, close-out routine, etc.)
- `claude/keybindings.json` — Claude Code keybindings (shift+enter = newline)
- `claude/skills/{codex-implementation,codex-review,codex-computer-use,close-out,spin-up}/SKILL.md`
- `install.ps1` / `install.sh` — copy `claude/` → `~/.claude`; back up overwritten files;
  patch exactly three top-level keys in
  `~/.codex/config.toml` (model gpt-5.6-sol, effort medium, approval_policy never) and
  preserves everything else, especially the `[projects]` trust list.
- `collect.ps1` / `collect.sh` — reverse copy for files already declared under `claude/`.
- `run.bat` — runs `install.ps1` and forwards command-line flags.
- `tests/validate.ps1` + `.github/workflows/validate.yml` — repository, privacy, syntax,
  and dry-run checks.
- `docs/devblog.md` — this repo's running log; read the top entry to re-orient.

## Current state (2026-08-30)

- `collect.sh` now sanitizes after copying: strips the "## Work import" `@`-import
  section from `claude/CLAUDE.md` (private employer file, never ships here) and fails
  the sync if a leak check finds any work reference in the payload. `collect.ps1` does
  NOT have this yet — port it (ASCII-only).
- Payload synced with the live Mac config: share-site `file://` rules, delegation
  section, codex foreground-run rule.

## Previous state (2026-08-19)

- Cross-platform PowerShell/Bash install and collect scripts are present, with backup and
  dry-run support.
- Skills in the repo: the three codex skills, close-out (now with multi-account GitHub
  identity resolution), and spin-up (close-out's mirror image, added this session).
- Global CLAUDE.md is cross-platform: machine-specific sections (CUDA/RTX 3090, .bat
  launchers) are tagged "ignore if not your OS".
- Public-facing README, MIT license, privacy-focused `.gitignore`, validation script, and
  GitHub Actions checks are included.
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
- Collectors intentionally copy only files already present under repo `claude/`; never
  change them to mirror the entire live `~/.claude` directory.
- On the Mac this repo's working tree is CRLF but blobs are LF; `core.autocrlf=input`
  is set locally so status stays truthful. Don't mass-renormalize line endings.
