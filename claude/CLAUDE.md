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
- **This applies to real apps only** (backends, servers, anything with a venv/env setup).
  For demo/share sites, see **Share Sites** below — those should be plain HTML I can
  double-click, with **no launcher and no web server**.
- For real apps: always provide a **one-command launcher** at the project root that does
  **everything** needed to start the app (activate the venv, set env, launch). On Windows
  that's a `run.bat`; on the Mac a `run.sh`. I want one command to get going.
## Python
- **Always use a virtualenv** — `.venv` inside the project folder. **Avoid `conda` and
  `uv`** — they tend to fill up my primary drive.
## AI / ML / CUDA (Windows desktop only)
- If this does not pertain to the operating system you are on, please ignore this section.
- For anything AI/ML, use **CUDA-enabled builds**. My GPU is an **RTX 3090** (Ampere).
- Check what the specific project needs and **match the CUDA/toolkit version** to it.
  After setup, **verify the GPU is actually being used** and tell me if it can't be.
## Share Sites
- if the users ask for a site for any reason, such as comparing outputs, displaying reports or any other reason they give never use an artifact.
- Have the site be in a folder so it can be zipped up with everything in it.
- **Default: a self-contained static site that opens with a double-click on the HTML file**
  (`file://`). No web server, no `run.sh`, no build step, no `npm install`. Inline the
  CSS/JS or use relative paths within the folder; reference media (videos, images) by
  relative path so the zipped folder works anywhere.
- Write the site so it works from `file://`: no `fetch()` of local files (inline data as
  JS instead), no ES modules from local paths if it can be avoided, no absolute paths.
- A web server is the **rare exception**, only when the site genuinely can't work from
  `file://` (e.g. it needs an API backend, streaming, or something CORS-blocked on
  `file://`). If you must use one, say why in one sentence — and even then prefer a static
  rewrite if it's feasible.
- After building, open the HTML directly (`open path/index.html` on Mac) to verify it
  actually works from `file://`.
- If `~/.claude/site-template/` exists on this machine, start share sites from it — read
  the template folder's own CLAUDE.md design guide first. Otherwise style per the
  Frontend section below.
## Frontend / Node
- Prefer **Node.js**. Use **npm** as the package manager. Choose the framework per project
  as needed.
- **Dark mode is the default theme.** Add a light/dark toggle when it makes sense.
## Protect your context: when to delegate
The main session's context is the scarce resource on big projects — once it fills with
file dumps and logs, quality degrades. Act as the **orchestrator**: plan, dispatch,
integrate, review. A subagent's transcript never enters your context; you only get its
report back.
- **Delegate by default when:**
  - **Orienting/searching** across many files or an unfamiliar area → an **Explore**
    agent that returns conclusions (paths + facts), not file contents.
  - **Bulky or mechanical implementation** with a clear spec → a subagent (or
    gpt-5.6-sol per the model rubric below). Parallel implementers need
    `isolation: 'worktree'`.
  - **A step with long output** (test suites, builds, migrations, scraping) → run it in
    a subagent that reports only failures/summary.
  - **Review/verification** → a fresh-context reviewer agent (independent perspective
    is a bonus).
- **Keep inline when:** small targeted edits in files you've already read, judgment-heavy
  design decisions, or anything touching ≤ ~3 files you already understand — handing off
  would cost more than doing it. Don't spawn agents as ceremony.
- **On long multi-step work**, keep durable state in `docs/plan.md` + `docs/progress.md`,
  not in conversation memory — so any step can go to a fresh agent and a fresh session
  can resume without the main context holding everything.
- **Subagent prompts must be self-contained** (paths, spec, constraints, expected report
  format) — subagents don't see the conversation. Ask for a concise report, never raw
  output.
## Picking models for workflows and subagents
(For *when* to delegate, see the section above; this section picks *who*.)
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
