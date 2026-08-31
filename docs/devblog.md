# Dev Blog

## 2026-08-30 — Sanitizing collector + upstream config sync

**What changed:** `collect.sh` now sanitizes the payload after copying: it strips the
"Work import" section that machine-specific setups may append to their live global
CLAUDE.md (an `@`-import of a private, employer-specific file that must never ship
here), then runs a word-boundary leak check over `claude/` and fails the sync if any
work reference survives. Synced the latest live config: CLAUDE.md gained share-site
rules (self-contained static HTML that opens from `file://`; a web server only when
genuinely required), a "Protect your context: when to delegate" section (orchestrate
big projects through subagents), and a scoped one-command-launcher rule; close-out
notes that static sites have no launcher; codex-implementation now mandates
foreground `codex exec` with a long timeout plus `codex exec resume --last`, never
backgrounding.

**State:** Collector verified end-to-end (strip + leak check pass on a CRLF live file).

**Where we left off:** Payload current with the live Mac config as of today.

**Open / TODO:** Port the same strip + leak check to `collect.ps1` (ASCII-only
constraint applies) so Windows collections get the same guarantee.

## 2026-08-19 — Public starter-kit hardening

**What changed:** Added an MIT license and privacy-focused `.gitignore`. Reworked both
PowerShell scripts to support dry runs; installation now backs up overwritten Claude and
Codex files, while collection dynamically follows the files already declared under the
repo's `claude/` tree instead of maintaining a hardcoded list. Added equivalent Bash
install/collect scripts for macOS and Linux, and made `run.bat` forward installer flags.
Rewrote the README around prerequisites, safe installation, personalization, security,
and cross-platform use. Added a PowerShell validator plus Windows/Ubuntu GitHub Actions
checks for skill frontmatter, common privacy leaks, script syntax, and installer dry runs.

**State:** Local privacy/static validation passes for all five skills. PowerShell install
and collect dry runs pass; both Bash scripts pass syntax checks and dry runs under Git for
Windows. The opinionated `approval_policy = "never"` default remains unchanged by request.

**Where we left off:** The repository is now structured as a reusable public starter kit,
not only a personal Windows dotfiles snapshot. CI still needs its first GitHub run after
push to confirm native Ubuntu behavior.

**Open / TODO:**
- Confirm the first GitHub Actions run passes on Windows and Ubuntu.
- Exercise a real install on a disposable fresh account or VM to verify backup restoration.
- Consider rewriting existing commit metadata to a GitHub noreply email separately; that
  requires an explicit history rewrite and force-push.

## 2026-08-19 — Mac install, spin-up skill, shareable README, privacy pass

**What changed:** Installed the setup on the Mac (manually — install.ps1 is Windows
PowerShell; copied `claude/` → `~/.claude` and patched the three Codex config keys by
hand). Global CLAUDE.md made cross-platform: machine-specific sections (CUDA/RTX 3090,
run.bat) now say "ignore if not your OS"; launcher rule covers run.bat (Win) and run.sh
(Mac); added a Credentials section pointing at the fal key's local env file (path only,
genericized to `~/...` so no personal home paths in the repo). Synced the updated
close-out skill (multi-account GitHub identity resolution) and added the spin-up skill
to the repo + collect.ps1's file list. Rewrote README for sharing: explains the
dotfiles-for-AI-config idea, per-skill descriptions, Mac setup path. Repo CLAUDE.md
gotchas now include a pre-push leak scan (keys/emails/home-paths/company refs) and the
personal-vs-work GitHub account rule. Set `core.autocrlf=input` on the Mac clone to
stop phantom whole-file diffs (tree is CRLF, blobs are LF).

**State:** Mac session verified skills + CLAUDE.md load. Leak scan of the repo came
back clean. Push rights confirmed for the personal account via `gh` (both accounts
logged in on the Mac).

**Where we left off:** This push is the first close-out from the Mac. Windows desktop
still needs a `git pull` + `run.bat` to pick these changes up.

**Open / TODO:**
- Pull + run.bat on the Windows desktop; confirm nothing Windows-side regressed.
- Verify install end-to-end on a third/fresh machine someday.
- Model table still carries gpt-5.5's old scores for gpt-5.6-sol; revisit after more use.

## 2026-07-19 — Keybindings: shift+enter for newline

**What changed:** Added `claude/keybindings.json` binding shift+enter to `chat:newline`
(soft return in the prompt input); added it to `collect.ps1`'s file list. `install.ps1`
already copies it (recursive copy of `claude/`).
**State:** Works via ctrl+j-equivalent action; shift+enter needs a terminal that
reports it distinctly (some terminals send plain enter — ctrl+j is the fallback).
**Where we left off:** Same as below — verify the installer on a second machine.

## 2026-07-19 — Initial repo: portable Claude Code + Codex setup

**What changed:** Created the repo from the live `~/.claude` setup on the main desktop.
Real files (`claude/CLAUDE.md` + four skills) instead of the old here-string installer;
`install.ps1`/`run.bat` applies them to a machine, `collect.ps1` pulls live edits back.
The setup itself was freshly updated this session: gpt-5.5 → gpt-5.6-sol (medium),
git pushes delegated to a sonnet-low subagent with opus-medium escalation, and plans
authored by fable-5 get handed to gpt-5.6-sol when the work fits its lane.

**State:** Installer logic mirrors the old `setup-claude-codex.ps1` (additive Codex
config patch, preserves `[projects]` trust list) but now also updates the model/effort
keys if they're stale. Not yet run end-to-end on a second machine.

**Where we left off:** Repo pushed to GitHub (private). Next natural step: clone on
another PC, run `run.bat`, and confirm a fresh Claude session picks everything up.

**Open / TODO:**
- Verify install on a second machine.
- Consider retiring `~/.claude/setup-claude-codex.ps1` on the desktop (superseded).
- Model table still carries gpt-5.5's old scores for gpt-5.6-sol; revisit after more use.
