---
name: codex-review
description: Ask Codex CLI (gpt-5.6-sol) for an independent code review of uncommitted changes, a branch diff, a commit, or a specific implementation. This is how gpt-5.6-sol is invoked for review work. Use when the user asks Claude to have Codex or gpt-5.6-sol review work, when the model-selection rubric calls for a gpt-5.6-sol review perspective, or when Codex should audit a diff, find bugs or regressions, or compare Claude's implementation against requirements. For a review by Claude itself, use the normal review process instead.
---

# Codex Review

Use Codex as an independent reviewer when the user wants a second-pass review or when a
change is broad enough that another agent's perspective is useful.

Prefer Claude's normal review process for small local checks. Do not delegate review just
to avoid reading the code yourself. Treat Codex's output as evidence, not authority.

## Workflow

1. Identify the review target: uncommitted changes, base branch, commit SHA, PR checkout,
   or specific files.
2. Create a temporary artifact directory for the Codex report.
3. Run `codex review` with a focused review prompt.
4. Read Codex's report and verify important claims against the code before presenting them.

Run these from the repository root (`codex review` requires a git repo and reviews the
working tree there).

IMPORTANT (verified on codex-cli 0.142.4): a **custom prompt and the target flags
(`--uncommitted` / `--base` / `--commit`) are mutually exclusive.** So:

- **Custom review instructions** → give the prompt (positional or stdin `-`) with **no
  target flag**. This defaults to reviewing the **uncommitted working tree** — the most
  common case.
- **A specific target** (branch diff or a commit) → pass the target flag with **no custom
  prompt**; Codex uses its built-in review instructions.

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-review.XXXXXX")"
REPORT="$ARTIFACT_DIR/report.md"
PROMPT="$ARTIFACT_DIR/prompt.md"

# Review uncommitted changes WITH custom instructions (default target). Preferred form.
codex review - < "$PROMPT" > "$REPORT"

# Review current branch against a base branch (built-in review prompt, no custom prompt).
codex review --base main > "$REPORT"

# Review a single commit (built-in review prompt, no custom prompt).
codex review --commit <sha> > "$REPORT"
```

`codex review` runs read-only by default and prints the review to stdout, so redirecting
to `$REPORT` captures it. The trailing `-` reads the review instructions from stdin. If you
need custom focus on a branch/commit diff, stage or check out that state first, then use
the uncommitted form.

## Review Prompt

Write the review instructions to `$PROMPT` first. A good default:

```
Review these changes for bugs, regressions, missing tests, security issues, and
requirement mismatches.

Prioritize findings over summary. For each finding include:
- severity
- file and line reference
- concrete failure mode
- suggested fix direction

Do not edit files. If there are no substantive findings, say so and name any residual
test gaps.
```

Add task-specific context when useful: requirements, risky areas, expected behavior,
relevant tests, or files Claude is unsure about.

## Reporting Back

Before relaying a Codex finding, inspect the cited code or diff enough to decide whether
the finding is real. In the user-facing response, separate confirmed issues from Codex
suggestions you did not verify.

If Codex finds nothing, say that clearly and mention what review target it inspected.

If `codex` is not installed or the command fails, report the error and offer to review the
changes directly instead.
