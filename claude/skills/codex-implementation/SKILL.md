---
name: codex-implementation
description: Ask Codex CLI (gpt-5.6-sol) to implement scoped code changes in the current repository, then have Claude inspect the resulting diff and verification. This is how gpt-5.6-sol is invoked for implementation work. Use when the user asks Claude to delegate implementation to Codex or gpt-5.6-sol, when the model-selection rubric routes the work to gpt-5.6-sol, or when a bounded task would benefit from another coding agent producing a patch.
---

# Codex Implementation

Use Codex as a separate implementation agent for bounded code changes. Claude remains
responsible for scoping the task, reviewing the diff, running or checking verification, and
explaining the final result.

Use this when the user asks for Codex or delegation, or when a bounded task would benefit
from a parallel implementation agent producing a patch. Do not let Codex commit, push,
deploy, or edit global config unless the user explicitly asked for that.

## Workflow

1. Pin the current state with `git status --short` and note any user changes already
   present, so you can tell Codex's edits apart from pre-existing ones.
2. Create a temporary artifact directory for the prompt and report.
3. Write a **self-contained** implementation prompt: the goal, the files in scope, the
   constraints (don't commit/push, don't touch unrelated code), and how to verify.
4. Run `codex exec -s workspace-write` so Codex can edit files in the repo. Approvals are
   already `never` in the user's config, so it won't block.
5. Review the resulting diff yourself (`git diff`), run verification (tests / typecheck /
   run the app), and explain what changed and whether it works.

Run from the repository root. Command shape:

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-impl.XXXXXX")"
REPORT="$ARTIFACT_DIR/report.md"
PROMPT="$ARTIFACT_DIR/prompt.md"

# Write the implementation prompt to $PROMPT first, then:
codex exec -s workspace-write -o "$REPORT" - < "$PROMPT"
```

`-o "$REPORT"` captures Codex's final message. `-s workspace-write` confines edits to the
working directory. Add `--skip-git-repo-check` only if intentionally running outside a git
repo. For a long implementation, run Codex **FOREGROUND with an explicit long Bash timeout
(600000 ms)**; if it times out, continue it with `codex exec resume --last` (repeat as
needed) until it finishes.

**Never run codex in the background and end your turn to "wait for it."** A backgrounded
`codex exec` is not tracked by the harness — an agent that ends its turn while codex runs
is never woken again and stalls indefinitely (this happened in the field, 2026-08-26).
This applies doubly inside subagents/wrappers: stay in the loop, foreground, until the
report file exists.

## Implementation Prompt

Write a prompt Codex can act on with no other context. A good default shape:

```
Implement: <one-sentence goal>.

Context:
- Files in scope: <paths>
- Requirements: <bullets>
- Out of scope / do not touch: <bullets>

Constraints:
- Edit only files in scope. Do not commit, push, or change git state.
- Match the surrounding code style.
- After editing, state what you changed and how to verify it.
```

## Reporting Back

Read the diff before trusting the report — treat Codex's summary as a claim to verify, not
ground truth. In the user-facing response, describe what actually changed and the result of
verification. If verification fails, say so with the output rather than declaring success.

## Parallel implementations

If you run several Codex implementation agents at once (e.g. from a workflow), give each
its own git worktree (`isolation: 'worktree'`) so their edits don't collide in the shared
checkout.

If `codex` is not installed or the command fails, report the error and offer to implement
the change directly instead.
