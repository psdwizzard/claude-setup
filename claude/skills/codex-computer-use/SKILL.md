---
name: codex-computer-use
description: Ask Codex CLI (gpt-6.2-astra) to run local app verification that needs computer use — browser automation, simulators, screenshots, app launching, or independent runtime inspection. This is how gpt-6.2-astra is invoked for computer-use work. Use when the user asks Claude to test a flow, verify UI behavior, inspect a running app, capture screenshots, or report confirmation and feedback about implemented behavior that benefits from computer-use functionality.
---

# Codex Computer Use

Use Codex as a separate local verification agent when the task needs real UI interaction,
screenshots, simulator/browser/device state, or an independent runtime check outside
Claude's current context.

Do not use this for ordinary code reading, typechecking, linting, or tests Claude can run
directly. Launching apps, simulators, or browsers to verify the requested work is fine
without asking; ask first only if the run could disrupt the user's environment beyond that
(closing their apps, changing system settings, acting on real accounts or data).

Codex's `computer_use` and `browser_use` features are stable and enabled in this install,
so Codex can drive a browser / control the machine directly.

## Workflow

1. Decide what "verified" means: the concrete flow to exercise and what a pass looks like
   (a screenshot, a specific UI state, a console line, an HTTP response).
2. Create a temporary artifact directory for the prompt, the report, and any screenshots.
3. Write a self-contained prompt telling Codex how to launch/reach the app, what to do, and
   exactly what evidence to capture and where to save it.
4. Run `codex exec` with a sandbox that allows what the task needs (see below).
5. Read the report and inspect any screenshots before relaying the result.

Command shape:

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-cu.XXXXXX")"
REPORT="$ARTIFACT_DIR/report.md"
PROMPT="$ARTIFACT_DIR/prompt.md"

# workspace-write is enough for launching/driving the app from the project dir.
codex exec -s workspace-write -o "$REPORT" - < "$PROMPT"
```

Sandbox choice:
- **`-s workspace-write`** — default. Launch the app, drive the browser, write
  screenshots into the workspace.
- **`-s danger-full-access`** — only when the run genuinely needs to reach outside the
  workspace (system browser profile, ports/paths elsewhere). Prefer workspace-write first.

Approvals are already `never` in the user's config, so Codex won't pause mid-run.

## Verification Prompt

```
Verify: <the flow / behavior to confirm>.

Steps:
- Launch / open: <how to start the app or URL>
- Do: <the interaction to perform>
- Capture: save a screenshot to $ARTIFACT_DIR/<name>.png and report the observed state.

Report whether it passed, what you saw, and the path to each screenshot. Do not change
code or system settings.
```

(Substitute the real `$ARTIFACT_DIR` value into the prompt text before writing it.)

## Reporting Back

Look at the screenshots / captured evidence yourself before telling the user it passed.
Separate what Codex directly observed from what it inferred. If the flow failed, report the
actual observed state, not a guess.

If `codex` is not installed or the run fails, report the error and offer to verify the flow
directly with the tools Claude has.
