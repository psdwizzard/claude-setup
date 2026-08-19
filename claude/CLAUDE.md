# Global instructions (all projects)

These are my personal defaults for every project. Project-level `CLAUDE.md` files add
to or override these.

**Note:** this file is shared across my machines (Windows desktop and Mac). Some sections
are machine-specific — if a section does not pertain to the operating system you are on,
please ignore it.

## Communication
- I frequently use **voice-to-text**, so my messages often contain mis-transcribed words
  (e.g. "Cloud ND" → "CLAUDE.md", "Kanda" → "conda"). When a word looks odd or out of
  place, interpret it phonetically / by context and confirm the intended meaning rather
  than acting on the garbled version.

## How I work: sessions & close-out
- I run **multiple sessions per project**: do a task, wrap it up, then start a fresh
  session without re-explaining everything. The project `CLAUDE.md` + dev blog are how a
  new session re-orients itself instantly.
- When I say **"push to git"** (or otherwise tell you to push), run the **close-out
  routine** in order:
  1. Update **`docs/devblog.md`** (see below).
  2. Update the **project `CLAUDE.md`** overview (see below).
  3. **Push**: to **`main`** by default, or to the branch I name. **Exception:** if we're
     already working on a non-`main` branch, push to *that* branch — don't switch to main.
- **Delegate git pushes to a subagent** on **sonnet, effort low** (commit + push are
  mechanical). If it hits problems — merge conflicts, rejected push, failing hooks,
  anything needing judgment — escalate to **opus, effort medium** to resolve and finish.
- I don't use **pull requests** yet. Don't create PRs. (You may offer to teach me PRs when
  it's relevant — I'm open to learning.)

## Project `CLAUDE.md` overview (keep < 200 lines)
- Maintain a concise overview so a fresh agent is productive immediately. **You decide the
  contents** — include whatever *you* would find most useful to restart cold. Good
  candidates: stack/dependencies, how to run it, architecture at a glance, current state /
  where we left off, and gotchas.
- Refresh it as part of every close-out.

## Docs (everything lives in `docs/`)
- **`docs/devblog.md`** — one single running file. Add an entry **before each git push**
  so we always know where we left off. Newest entries at the top, dated.
- **`docs/plan.md`** — the plan for any multi-step work.
- **`docs/progress.md`** — where we are in that plan: what's done, what's not.

## Running things
- Always provide a **one-command launcher** at the project root that does **everything**
  needed to start the app (activate the venv, set env, launch). On Windows that's a
  `run.bat`; on the Mac a `run.sh`. I want one command to get going.

## Python
- **Always use a virtualenv** — `.venv` inside the project folder. **Avoid `conda` and
  `uv`** — they tend to fill up my primary drive.

## Credentials / API keys
- **fal API key**: on the Mac it lives in `~/.config/fal/env`.
  When a task needs fal, source that file (or read the key from it) instead of asking me
  for the key. Never print the key itself or commit it anywhere.

## AI / ML / CUDA (Windows desktop only)
- If this does not pertain to the operating system you are on, please ignore this section.
- For anything AI/ML, use **CUDA-enabled builds**. My GPU is an **RTX 3090** (Ampere).
- Check what the specific project needs and **match the CUDA/toolkit version** to it.
  After setup, **verify the GPU is actually being used** and tell me if it can't be.

## Share Sites
- if the users ask for a site for any reason, such as comparing outputs, displaying reports or any other reason they give never use an artifact.
- Have the site be in a folder so it can be zipped up with everything in it.

## Frontend / Node
- Prefer **Node.js**. Use **npm** as the package manager. Choose the framework per project
  as needed.
- **Dark mode is the default theme.** Add a light/dark toggle when it makes sense.

## Picking models for workflows and subagents

Rankings, higher = better. Cost reflects what I actually pay (OpenAI has really generous
limits), not list price. Intelligence = how hard a problem you can hand it unsupervised.
Taste = UI/UX, code quality, API design, and copy.

| model    | cost | intelligence | taste |
|----------|-----:|-------------:|------:|
| gpt-5.6-sol  | 9    | 8            | 5     |
| sonnet-5 | 5    | 5            | 7     |
| opus-5 | 4    | 7            | 8     |
| fable-5  | 2    | 9            | 9     |

How to apply:
- These are **defaults, not limits**. You have standing permission to override them: if a
  cheaper model's output doesn't meet the bar, rerun or redo with a smarter model without
  asking. Judge the output, not the price tag. Escalating costs less than shipping
  mediocre work.
- **Cost is a tie-breaker only.** When axes conflict for anything that ships:
  intelligence > taste > cost.
- **Planning stays with fable-5.** Fable writes the plan/architecture; when the resulting
  work fits the gpt lane (clear-spec implementation, bulk/mechanical), hand the finished
  plan to **gpt-5.6-sol** to execute rather than implementing it on a Claude model.
- **Bulk/mechanical work** (clear-spec implementation, data analysis, migrations):
  **gpt-5.6-sol**. It's effectively free.
- **Anything user-facing** (UI, copy, API design) needs **taste ≥ 7**.
- **Reviews** of plans/implementations: **fable-5** or **opus-4.8**, optionally gpt-5.6-sol as
  an extra independent perspective.
- **Never use Haiku.**
- Mechanics: gpt-5.6-sol is only reachable through the **Codex CLI** (`codex exec` /
  `codex review`; `~/.codex/config.toml` defaults to gpt-5.6-sol at **medium** reasoning
  effort — leave it there unless a task clearly needs more). Use the
  `codex-implementation`, `codex-review`, and `codex-computer-use` skills. For work they
  don't cover (investigation, data analysis), run `codex exec -s read-only` with a
  self-contained prompt.
- Claude models (`sonnet-5`, `opus-4.8`, `fable-5`) run through the Agent/Workflow model
  parameter.

Using gpt-5.6-sol inside workflows/subagents (the model parameter only takes Claude models, so
use a wrapper):
- Spawn a thin Claude wrapper agent with `model: 'sonnet', effort: 'low'` whose prompt
  tells it to write a self-contained Codex prompt, run `codex exec` via Bash, and return
  the report. Use `schema` on the wrapper for structured output.
- Always label these agents with a **`gpt-5.6-sol:`** prefix (e.g. `{label:
  'gpt-5.6-sol:review-auth'}`). The UI shows the wrapper's Claude model, so the label is the
  only signal that the real worker is gpt-5.6-sol.
- Codex runs can exceed Bash's 10-minute timeout — pass an explicit timeout, or run in the
  background and poll for the report file.
- Parallel gpt-5.6-sol implementation agents must use `isolation: 'worktree'` so Codex edits
  don't collide in the shared checkout.
- Workflow token budgets only count Claude tokens; Codex work is free and invisible to
  `budget.spent()`.
