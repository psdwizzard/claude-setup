---
name: spin-up
description: Start a work session by re-orienting on a project — read the project CLAUDE.md, the dev blog, and the plan/progress docs, check git state, then report a short briefing and STOP for instructions. The mirror image of close-out. Use when the user says "spin up", "start a session", "catch me up", "where were we", "orient yourself", "read the docs and wait", or opens a session with no task yet.
---

# Spin Up

The mirror image of `close-out`. Close-out writes the handoff; spin-up reads it back.

The user runs many short sessions per project and does not re-explain context. The project
`CLAUDE.md` + dev blog exist precisely so a fresh agent can re-orient instantly. This skill
does that, then **hands control back to the user**.

## The one hard rule

**End your turn with the briefing. Do not start work.**

No edits, no fixes, no refactors, no "while I was in there…", no launching the app, no
running builds or test suites. If you spot something broken or half-finished, that's a line
in the briefing, not a task you take on. The user picks what happens next — that's the whole
point of the skill.

## Step 1 — Read the handoff docs

Read these in order, and only what exists (don't create anything):

1. **Project `CLAUDE.md`** — often already in your context; if so, don't re-read it, and skip
   ahead. The "current state" section is the most important part.
2. **`docs/devblog.md`** — newest entries are on top. Read the **top 2–3 entries**, not the
   whole file. That's where "where we left off" lives.
3. **`docs/progress.md`** — if it exists, this is the truth about what's done vs. not in a
   multi-step effort.
4. **`docs/plan.md`** — if progress.md shows work in flight, read the parts of the plan that
   cover the *next* steps. Skim, don't absorb the whole plan.
5. Any doc the project `CLAUDE.md` flags as authoritative (a spec, a build contract, a port
   guide) — but only if it's relevant to the next step, and only the relevant part.

Then read whatever else you need to actually understand the next step — the source files the
docs point at. Prefer a subagent for broad reading so the briefing stays the deliverable and
not a wall of file dumps.

## Step 2 — Check the live state

```bash
git status --short
git log --oneline -8
git rev-parse --abbrev-ref HEAD
```

Look for the mismatches that matter:

- **Uncommitted changes** — the last session ended without a close-out. Say what's dirty.
- **Commits newer than the dev blog's top entry** — the docs are behind the code; trust git.
- **A non-`main` branch** — we're mid-feature; note it (and remember close-out pushes to
  *that* branch, not main).

If the docs and the repo disagree, **the repo wins** — and flag the drift in the briefing.

## Step 3 — Brief the user, then stop

Keep it tight — under ~15 lines. The user wrote these docs; they need the delta and the
decision, not a summary of their own project back at them.

```
**Where we left off:** <the one thing that was in progress, from the dev blog / progress.md>
**Repo state:** <branch, clean or dirty, anything newer than the docs>
**Next up:** <the specific next step the docs name>
**Worth knowing:** <only real surprises — doc/code drift, a blocked item, a stale gotcha>

Ready — what do you want to work on?
```

Rules for the briefing:

- Cite files as `path:line` where it helps them jump in.
- **Verify before you repeat.** Docs go stale. If the docs name a file, flag, function, or
  command as the next step, confirm it still exists before putting it in the briefing. Say
  so if it doesn't.
- If the docs offer several candidate next steps, list them as short options — don't pick one
  for them.
- If there's genuinely nothing in flight (clean tree, docs say a phase closed), say that
  plainly and ask what's next. A short briefing is a good briefing.
- If the project has **no** `CLAUDE.md` or dev blog, don't improvise a substitute: orient
  from git log + the tree, say the handoff docs are missing, and offer to create them (the
  `init` skill does the CLAUDE.md).

Then end the turn.
