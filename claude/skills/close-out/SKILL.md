---
name: close-out
description: Wrap up a work session the way the user likes — update the dev blog, refresh the project's CLAUDE.md overview, then commit and push to the right branch. Use when the user says "push to git", "close out", "wrap up", "let's push", or otherwise signals the session is done and the work should be pushed.
---

# Close Out

This runs the user's end-of-session routine. Their global CLAUDE.md defines it: when they
tell you to push, you (1) update the dev blog, (2) refresh the project CLAUDE.md overview,
then (3) push. Do these three in order.

The trigger ("push to git" / "close out" / "wrap up") is the user's authorization to
commit and push. You still show what you're about to commit and to which branch before the
push, but you don't need to ask permission again for the push itself.

## Step 1 — Survey the session

```bash
git status --short
git diff --stat
git log --oneline -5
```

Recall what changed this session: what got built/fixed, what's in a good state, and what's
still open. You'll need this for both the dev blog and the CLAUDE.md refresh.

## Step 2 — Update `docs/devblog.md`

One single running file, newest entry on top, dated. Create `docs/` and the file if they
don't exist (first line `# Dev Blog`).

Get today's date: `date +%Y-%m-%d`.

Prepend a new entry directly under the `# Dev Blog` heading:

```markdown
## YYYY-MM-DD — <short title of the work>

**What changed:** <the substantive changes this session>
**State:** <what works / is verified now>
**Where we left off:** <the exact next thing to pick up>
**Open / TODO:** <anything unfinished or deferred>
```

Keep it to what a future session actually needs to resume — not a changelog of every edit.

## Step 3 — Refresh the project `CLAUDE.md`

Keep it **under 200 lines**. You decide what's most useful for a cold restart. Aim to cover:

- **One-liner:** what this project is.
- **Stack:** language, framework, key deps.
- **Run it:** the one-command launcher (`run.bat` on Windows, `run.sh` on Mac) and any
  setup (venv, env vars).
- **Architecture at a glance:** the few files/dirs that matter and how they fit.
- **Current state:** where things stand (mirror the dev blog's "where we left off").
- **Gotchas:** anything non-obvious that would trip up a fresh agent.

Update the "current state" section every close-out so it never goes stale. If the project
has no CLAUDE.md yet, create one.

## Step 4 — Commit and push

**Delegate this step to a subagent** (Agent tool, `model: 'sonnet'`, `effort: 'low'`) —
commit + push are mechanical. Give it the target branch, the commit message, and the
Safety rules below. If it reports a problem needing judgment — merge conflict, rejected
push, failing hook — spawn a follow-up agent on `model: 'opus'`, `effort: 'medium'` to
resolve and finish (the Safety rules still apply; never force-push).

Determine the target branch:

```bash
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
```

- If the user **named a branch**, use that. If it differs from the current branch, create
  it from HEAD: `git checkout -b <name>`.
- Else if `BRANCH` is **not** `main`/`master`, push to `BRANCH` (we're already working on a
  feature branch — stay on it).
- Else push to `main`.

Then commit everything (including the docs/CLAUDE.md updates) and push:

```bash
git add -A
git commit -m "<concise summary of the session's work>"
git push -u origin "<target-branch>"
```

Write a concise, specific commit message summarizing the session — not "update files".

### Safety

- Before pushing, print the commit's `git diff --stat` and state the target branch so the
  user sees what's going out.
- **Never force-push.** Never rewrite history unless the user explicitly asks.
- If there's nothing to commit, skip the commit and say so; only push if there are unpushed
  commits.
- If no remote is configured, make the commit, then tell the user there's no remote to push
  to and ask how they want to proceed (the user is still learning git — offer to help set a
  remote).
- If the push is rejected (remote has new commits), stop and report it — don't force it.
