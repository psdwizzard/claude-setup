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
  setup (venv, env vars). For a static share site there is no launcher — just note which
  HTML file to double-click.
- **Architecture at a glance:** the few files/dirs that matter and how they fit.
- **Current state:** where things stand (mirror the dev blog's "where we left off").
- **Gotchas:** anything non-obvious that would trip up a fresh agent.

Update the "current state" section every close-out so it never goes stale. If the project
has no CLAUDE.md yet, create one.

## Step 4 — Resolve the pushing identity

Do this **before** committing. The user has separate work and personal GitHub accounts and
works on both from the same machine, so the machine's default account is not automatically
the right one. Resolve it from evidence; only ask when the evidence is ambiguous.

### 4a. Is there a repo, and a remote?

```bash
git rev-parse --git-dir >/dev/null 2>&1 && echo "repo: yes" || echo "repo: NO"
git remote -v
```

- **No repo** → ask which account this project belongs to and whether to `git init`. Stop
  until answered; don't init and guess.
- **Repo, no remote** → make the commit, then ask (see Safety).

### 4b. Which logged-in account can actually push there?

```bash
SLUG=$(git remote get-url origin | sed -E 's#(git@|https://)github\.com[:/]##; s#\.git$##')
gh auth status                                   # all accounts on this host
gh api "repos/$SLUG" --jq '.permissions.push'    # can the ACTIVE account push?
```

Resolve in this order:

1. Active account has `push: true` → **use it, change nothing.**
2. Otherwise check the other logged-in accounts without switching:
   ```bash
   GH_TOKEN="$(gh auth token -u <login>)" gh api "repos/$SLUG" --jq '.permissions.push'
   ```
   Exactly one can push → use that one (4c).
3. Nothing can push, or it's ambiguous → report the remote's owner, the accounts you found,
   and ask. **Never push under an identity you inferred without evidence.**

A `git log` author is a hint about which account a repo belongs to, but it is not proof of
push rights — always confirm with the `permissions.push` check above.

### 4c. Borrow the needed account for the push, then give it back

The active gh account is **global** — it applies to every repo on the machine. The user does
most of their git work on this machine under their *work* account, so the needed account is
borrowed for the push and the original is restored afterwards.

Record what was active before touching anything:

```bash
ORIGINAL_ACTIVE=$(gh auth status 2>&1 | grep -B1 "Active account: true" \
  | grep -o "account [A-Za-z0-9-]*" | awk '{print $2}')
echo "original active account: $ORIGINAL_ACTIVE"
```

Switch only if the account resolved in 4b differs:

```bash
gh auth switch -u <login>
```

Then push (Step 5), and **restore `$ORIGINAL_ACTIVE` in Step 6 — even if the push fails.**
Never leave the session with a different active account than you found.

Switching gh accounts is not sufficient on its own. Git only follows gh's choice if this
repo uses gh's credential helper — an inherited helper such as `osxkeychain` caches one
account per host and would keep serving the wrong one no matter what gh says. An empty
value resets the inherited list for this repo only:

```bash
git config --local --replace-all credential.helper ""
git config --local --add credential.helper "!gh auth git-credential"
```

Check with `git config --get-all credential.helper`; the blank entry followed by
`!gh auth git-credential` is what you want.

If a push still fails as the wrong identity, override the token for that one command
without touching global state — also the way to test a non-active account:

```bash
GH_TOKEN="$(gh auth token -u <login>)" git push -u origin "<branch>"
```

If the account isn't logged in yet, `gh auth login` is interactive — ask the user to run it
themselves (`! gh auth login`); don't try to drive it. Note that a fresh `gh auth login`
makes the new account active as a side effect.

### 4d. Commit author identity

`git commit` fails outright when no identity is set, and a wrong identity is worse than a
missing one. Check what's in effect:

```bash
git config user.email    # empty = nothing set locally or globally
```

If empty, derive it from the repo's own history instead of guessing:

```bash
git log -1 --format='%an <%ae>'
```

Set it **repo-local only** — a global identity would leak into the other account's repos:

```bash
git config --local user.name "<name>"
git config --local user.email "<email>"
```

If the repo has no commits and nothing is configured, ask which identity to use.

## Step 5 — Commit and push

**Delegate this step to a subagent** (Agent tool, `model: 'sonnet'`, `effort: 'low'`) —
commit + push are mechanical. Give it the target branch, the commit message, the identity
resolved in Step 4, and the Safety rules below. Do the account switch yourself in 4c and the
restore yourself in Step 6 — don't delegate either, so the restore still happens if the
subagent fails or dies. If it reports a problem needing judgment — merge conflict, rejected
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

## Step 6 — Restore the original active account

If you switched in 4c, switch back — **whether the push succeeded, failed, or was rejected.**
The user does most of their git work on this machine under the other account, so leaving it
switched is a real hazard: their next commit elsewhere would go out under the wrong identity.

```bash
gh auth switch -u "$ORIGINAL_ACTIVE"
gh auth status | grep -A1 "Active account: true"   # confirm
```

Then report both facts: which account pushed, and which account is active now. If the
restore itself fails, say so loudly and tell the user to run `gh auth switch -u <login>`
themselves — a silent failure here is exactly the mix-up this step exists to prevent.

### Safety

- Before pushing, print the commit's `git diff --stat`, the target branch, **and which
  GitHub account the push will use**, so the user sees what's going out and as whom.
- **Never set a global `user.name`/`user.email`** — a global author identity bleeds into the
  other account's repos. Commit identity stays repo-local.
- **Always restore the original active gh account** (Step 6), even on failure. Report the
  account that pushed and the account left active.
- **Never force-push.** Never rewrite history unless the user explicitly asks.
- If there's nothing to commit, skip the commit and say so; only push if there are unpushed
  commits.
- If no remote is configured, make the commit, then tell the user there's no remote to push
  to and ask how they want to proceed (the user is still learning git — offer to help set a
  remote).
- If the push is rejected (remote has new commits), stop and report it — don't force it.
