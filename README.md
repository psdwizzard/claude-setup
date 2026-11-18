# claude-setup

An opinionated, portable [Claude Code](https://claude.com/claude-code) and
[Codex CLI](https://github.com/openai/codex) configuration. It keeps global instructions,
custom skills, keybindings, and selected Codex defaults in Git so the same workflow can be
installed on multiple machines.

The central idea is to treat AI-assistant configuration like dotfiles. The live files in
`~/.claude` are what Claude Code reads; this repository is the reviewed, portable source of
truth. An installer copies repository to machine, a collector copies declared files back,
and Git moves reviewed changes between machines.

## Why this setup is useful

The `close-out` and `spin-up` skills form a session handoff loop:

1. `close-out` records what changed, refreshes project context, and safely commits and pushes.
2. `spin-up` reads that handoff, compares it with the live repository, and provides a short
   briefing before new work begins.

The other skills use Codex as a separate implementation, review, or runtime-verification
agent while Claude remains responsible for scope and verification.

## Prerequisites

- Git
- Claude Code, signed in once
- Codex CLI, signed in once (`npm install -g @openai/codex`)
- GitHub CLI (`gh`) for the multi-account push workflow
- Windows: Windows PowerShell 5.1 or PowerShell 7
- macOS/Linux: Bash plus standard Unix tools (`awk`, `find`, `grep`, and `mktemp`)

## Install

First clone or fork the repository. Forking is recommended if you want to keep your own
preferences under version control.

### Windows

Preview the operation:

```powershell
run.bat -DryRun
```

Install:

```powershell
run.bat
```

### macOS and Linux

Preview the operation:

```bash
./install.sh --dry-run
```

Install:

```bash
./install.sh
```

Existing files are backed up by default under
`~/.claude-setup-backups/<timestamp>/`. Pass `-NoBackup` on Windows or `--no-backup` on
macOS/Linux only when you intentionally do not want a backup.

The installer copies `claude/` into `~/.claude/` and changes only these top-level Codex
settings in `~/.codex/config.toml`:

```toml
model = "gpt-6.2-astra"
model_reasoning_effort = "medium"
approval_policy = "never"
```

All other Codex configuration, including project trust entries, plugins, and MCP servers,
is preserved. Review these opinionated defaults before installing; in particular,
`approval_policy = "never"` assumes you are comfortable supervising non-interactive runs.

Start a new Claude Code session after installation so the instructions and skills load.

## Update the portable source

Edits normally happen in the live `~/.claude` files. The collector copies back only files
that are already declared under this repository's `claude/` directory. This allowlist-by-tree
design prevents caches, credentials, conversation history, and newly installed third-party
skills from being swept into Git accidentally.

Windows:

```powershell
.\collect.ps1 -DryRun
.\collect.ps1
```

macOS/Linux:

```bash
./collect.sh --dry-run
./collect.sh
```

Always inspect `git diff` before committing. To add another portable skill, first create its
destination under `claude/skills/<skill-name>/SKILL.md`; later collection runs will include
it automatically.

## Included skills

| Skill | Purpose |
|---|---|
| `close-out` | Updates the dev blog and project overview, resolves the correct GitHub identity, then commits and pushes safely. |
| `spin-up` | Reads the handoff documents and Git state, then gives a concise session briefing and waits. |
| `codex-implementation` | Delegates a bounded implementation to Codex, then requires Claude to inspect and verify the result. |
| `codex-review` | Requests an independent Codex review of working changes, a branch, or a commit. |
| `codex-computer-use` | Delegates browser, screenshot, simulator, or running-app verification to Codex. |

## Repository layout

| Path | Purpose |
|---|---|
| `claude/CLAUDE.md` | Global instructions loaded into Claude Code sessions |
| `claude/keybindings.json` | Shared Claude Code keybindings |
| `claude/skills/` | Portable custom skills |
| `install.ps1`, `install.sh`, `run.bat` | Safe installers with backup and dry-run support |
| `collect.ps1`, `collect.sh` | Copy declared live files back into the repository |
| `tests/validate.ps1` | Static repository and privacy checks |
| `docs/devblog.md` | Running development handoff for this repository |

## Adapt it for yourself

Before installing a fork, review `claude/CLAUDE.md` and change or remove:

- machine-specific hardware and credential-location notes;
- model names and routing preferences;
- language, package-manager, UI, and documentation conventions;
- the GitHub account workflow if you use only one account;
- any instructions tied to tools unavailable in your environment.

Model availability and CLI syntax change over time, so treat model identifiers as user
configuration rather than permanent recommendations.

## Security notes

- Credentials belong in environment variables or an external secret store, never this repo.
- `.gitignore` excludes common Claude/Codex state, local settings, credentials, logs, and
  private-key formats.
- Collection is limited to repository-declared files, but that is not a substitute for
  reviewing the diff.
- Enable GitHub secret scanning and push protection when your account supports them.
- Git commit metadata may expose your configured author email. Use GitHub's noreply address
  if you do not want a personal email published.

## License

Released under the [MIT License](LICENSE).
