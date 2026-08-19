# claude-setup

A portable [Claude Code](https://claude.com/claude-code) + [Codex CLI](https://github.com/openai/codex)
configuration: one global `CLAUDE.md`, a set of custom skills, keybindings, and Codex CLI
defaults. Clone it on a new machine, run one command, and that machine works like all the
others.

The core idea: **treat your AI-assistant configuration like dotfiles.** The live files in
`~/.claude` are what Claude Code actually reads; this repo is their portable source of
truth. An installer copies repo → machine, a collector copies machine → repo, and git moves
changes between machines.

## Set up a new machine

1. Install [Claude Code](https://claude.com/claude-code) and the Codex CLI
   (`npm install -g @openai/codex`), and sign in to both once.
2. Clone this repo and run:

   ```
   run.bat          (Windows)
   ```

   On a Mac (no PowerShell), copy the files by hand — same effect:

   ```bash
   cp -R claude/ ~/.claude/
   ```

   and add these three top-level keys to `~/.codex/config.toml` if they're missing
   (top of the file, before any `[table]` section):

   ```toml
   model = "gpt-5.6-sol"
   model_reasoning_effort = "medium"
   approval_policy = "never"
   ```

3. Start a **new** Claude Code session so the CLAUDE.md and skills load.

The installer only touches those three Codex keys — everything else in
`~/.codex/config.toml` (project trust lists, plugins, MCP servers) is preserved. Safe to
re-run anytime, e.g. after every `git pull`.

## Update the setup (on the machine where you changed it)

Edits happen to the live files in `~/.claude` (usually via a Claude session). To publish
them:

```
powershell -ExecutionPolicy Bypass -File collect.ps1   # copies live files into the repo
git add -A ; git commit -m "..." ; git push            # or tell Claude to "push to git"
```

Then on every other machine: `git pull` and `run.bat` (or the Mac copy above).

## What's in the global CLAUDE.md

`claude/CLAUDE.md` is loaded into every Claude Code session on the machine. Mine covers:

- **Session workflow** — many short sessions per project, each ending with a close-out
  (dev blog entry + project CLAUDE.md refresh + push) so the next session can re-orient
  without re-explaining anything.
- **Docs conventions** — every project keeps `docs/devblog.md` (running log, newest first),
  `docs/plan.md`, and `docs/progress.md`.
- **A model-selection rubric** — a small cost/intelligence/taste table that tells Claude
  which model to use for subagents and workflows, when to delegate bulk work to Codex
  (gpt-5.6-sol), and when to escalate.
- Project conventions (one-command launchers, Python venvs, Node/npm, dark mode default).

Machine-specific sections (CUDA/GPU stuff) are marked so sessions on other operating
systems skip them.

## The skills

Skills are reusable instruction sets Claude Code loads on demand (or when you type
`/skill-name`). The ones in `claude/skills/`:

| skill | what it does |
|-------|--------------|
| **close-out** | The end-of-session routine, triggered by "push to git" / "close out". Updates the dev blog, refreshes the project CLAUDE.md, resolves which GitHub account can actually push to the repo's remote (multi-account safe: switches, pushes, and always restores the original account), then commits and pushes. Includes safety rules: never force-push, never set a global git identity, always show what's going out before it goes. |
| **spin-up** | The mirror image of close-out, for the start of a session: reads the project CLAUDE.md, the top of the dev blog, and plan/progress docs, checks git state for drift, then delivers a short "where we left off / what's next" briefing and stops for instructions — it never starts working on its own. |
| **codex-implementation** | Delegates a scoped implementation task to the Codex CLI (gpt-5.6-sol), then has Claude inspect the resulting diff and verification before accepting it. |
| **codex-review** | Gets an independent code review from Codex on uncommitted changes, a branch diff, or a commit — a second model's perspective on Claude's (or your) work. |
| **codex-computer-use** | Hands Codex tasks that need computer use: driving a browser, taking screenshots, launching and inspecting a running app to verify behavior. |

The close-out/spin-up pair is the heart of the workflow: close-out writes the handoff,
spin-up reads it back. Together they make Claude Code sessions resumable across days and
machines without any re-explaining.

## Layout

| path | what |
|------|------|
| `claude/CLAUDE.md` | global instructions for all projects |
| `claude/keybindings.json` | Claude Code keybindings (shift+enter = newline) |
| `claude/skills/` | the five skills above |
| `install.ps1` / `run.bat` | apply this repo to the current machine |
| `collect.ps1` | pull live `~/.claude` edits back into the repo |
| `docs/devblog.md` | this repo's own running dev log |

## Adapting it for yourself

Fork it, gut `claude/CLAUDE.md` down to your own conventions, and keep the skills that fit
your workflow. The two scripts don't care what's inside `claude/` — they just sync it.
Nothing in this repo contains credentials; API keys stay in local files outside git (the
CLAUDE.md tells Claude where to find them, never their contents).
