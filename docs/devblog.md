# Dev Blog

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
