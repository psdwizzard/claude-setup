# claude-setup

My portable Claude Code + Codex configuration: global `CLAUDE.md`, custom skills, and
Codex CLI defaults. Clone it on any Windows PC, run one command, and the machine works
like all the others.

## Set up a new PC

1. Install [Claude Code](https://claude.com/claude-code) and the Codex CLI
   (`npm install -g @openai/codex`), and sign in to both once.
2. Clone this repo and run:

   ```
   run.bat
   ```

That copies `claude\` into `~/.claude` (global CLAUDE.md + skills) and sets the three
Codex config keys (`model = gpt-5.6-sol`, `model_reasoning_effort = medium`,
`approval_policy = never`) without touching anything else in `~/.codex/config.toml`.
Safe to re-run anytime. Start a new Claude Code session afterwards so it loads.

## Update the setup (on the machine where you changed it)

Edits happen to the live files in `~/.claude` (usually via a Claude session). To publish
them:

```
powershell -ExecutionPolicy Bypass -File collect.ps1   # copies live files into the repo
git add -A ; git commit -m "..." ; git push            # or tell Claude to "push to git"
```

Then on every other PC: `git pull` and `run.bat`.

## Layout

| path | what |
|------|------|
| `claude/CLAUDE.md` | global instructions for all projects |
| `claude/skills/` | codex-implementation, codex-review, codex-computer-use, close-out |
| `install.ps1` / `run.bat` | apply this repo to the current machine |
| `collect.ps1` | pull live `~/.claude` edits back into the repo |
