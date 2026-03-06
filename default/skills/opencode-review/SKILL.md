---
name: bee:opencode-review
description: |
  External code review via OpenCode CLI - sends diff to a second AI model
  (e.g., Qwen3-Max, GPT-5-Nano) for independent review. Use after Bee's 6
  parallel reviewers complete, as a complementary external perspective.
  Integrates with bee:requesting-code-review pipeline.

trigger: |
  - After bee:requesting-code-review completes (all 6 reviewers pass)
  - When a second AI opinion is desired on code changes
  - As part of Gate 4 external review step (alongside CodeRabbit)

skip_when: |
  - OpenCode CLI is not installed
  - No code changes to review (documentation-only)
  - User explicitly declines external review

related:
  complementary: [bee:requesting-code-review, bee:code-reviewer]
  sequence_after: [bee:requesting-code-review]
---

# OpenCode External Review

## Overview

Uses [OpenCode CLI](https://github.com/opencode-ai/opencode) to send code diffs to an external AI model for independent review. This provides a **second AI perspective** from a different model, catching issues that Bee's internal reviewers might miss due to shared model biases.

## Prerequisites

OpenCode CLI must be installed and configured:

```bash
which opencode || echo "NOT INSTALLED"
```

If not installed, prompt user to install or skip.

## Step 1: Check OpenCode Installation

```bash
which opencode
```

| Result | Action |
|--------|--------|
| Found | Proceed to Step 2 |
| Not found | Ask user: install OpenCode or skip review |

## Step 2: Collect Diff Context

Gather the code changes to review:

```bash
# Auto-detect base branch
BASE_SHA=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)

# Get the diff
git diff "$BASE_SHA"..HEAD > /tmp/bee-opencode-review-diff.txt

# Get changed files list
git diff --name-only "$BASE_SHA"..HEAD > /tmp/bee-opencode-review-files.txt

# Get commit messages for context
git log --oneline "$BASE_SHA"..HEAD > /tmp/bee-opencode-review-commits.txt
```

## Step 3: Build Review Prompt

Use the comprehensive review instructions from [docs/opencode-instructions.md](../../docs/opencode-instructions.md).

The instructions file covers:
- 6 review focus areas (bugs, security, error handling, performance, architecture, data integrity)
- Language-specific checks (TypeScript, PHP/Laravel)
- AI-generated code detection
- Severity classification and pass/fail rules
- Required output format with VERDICT

## Step 4: Execute OpenCode Review

Run OpenCode with the review instructions and diff as file attachments:

```bash
opencode run \
  -m "bailian-coding-plan/qwen3-max-2026-01-23" \
  -f docs/opencode-instructions.md \
  -f /tmp/bee-opencode-review-diff.txt \
  --format json \
  "Review the attached code diff following the instructions provided. Output your review as markdown."
```

**Model Selection:**

| Model | When to Use |
|-------|-------------|
| `bailian-coding-plan/qwen3-max-2026-01-23` | Default - strong general review |
| `bailian-coding-plan/qwen3-coder-plus` | Code-focused review |
| `opencode/gpt-5-nano` | Fast lightweight review |

MUST use `--format json` to get structured output for parsing.

## Step 5: Parse and Present Results

Parse the OpenCode JSON output and extract the review:

1. Extract the assistant's response text from the JSON output
2. Look for verdict pattern: `VERDICT: (PASS|FAIL|NEEDS_DISCUSSION)`
3. Count issues by severity
4. Present in standard Bee reviewer format

## Step 6: Aggregate with Bee Review Results

Append OpenCode findings to the review summary:

```markdown
## OpenCode External Review

**Model:** qwen3-max-2026-01-23
**Status:** [PASS | FAIL | NEEDS_DISCUSSION]

### Issues Found
- Critical: [N]
- High: [N]
- Medium: [N]
- Low: [N]

### Details
[OpenCode review output]
```

## Handling Issues

| OpenCode Verdict | Action |
|-----------------|--------|
| PASS | Record in review summary, proceed |
| FAIL (CRITICAL/HIGH) | Ask user: fix issues or acknowledge and proceed |
| NEEDS_DISCUSSION | Present findings, ask user for decision |
| Timeout/Error | Log error, proceed without OpenCode review (non-blocking) |

**OpenCode review is advisory, not a hard gate.** Unlike Bee's 6 internal reviewers which are mandatory, OpenCode provides supplementary findings. CRITICAL issues from OpenCode MUST be presented to the user but the user decides whether to act on them.

## Cleanup

After review completes:

```bash
rm -f /tmp/bee-opencode-review-diff.txt
rm -f /tmp/bee-opencode-review-files.txt
rm -f /tmp/bee-opencode-review-commits.txt
```

## Blocker Criteria

STOP and report if:

| Decision Type | Blocker Condition | Required Action |
|---|---|---|
| OpenCode not installed | CLI binary not found in PATH | Ask user to install or skip |
| No diff available | No code changes between base and HEAD | Skip review (nothing to review) |
| OpenCode execution fails | Non-zero exit code or timeout | Log error, proceed without review |

### Cannot Be Overridden

- MUST present CRITICAL findings from OpenCode to user
- MUST NOT modify source files based on OpenCode review (report only)
- MUST clean up temporary files after review

## Severity Calibration

| Severity | Condition | Required Action |
|---|---|---|
| CRITICAL | OpenCode finds security vulnerability or data loss risk | MUST present to user immediately |
| HIGH | OpenCode finds bugs or logic errors | Present to user, recommend fix |
| MEDIUM | Code quality or architecture concerns | Include in review summary |
| LOW | Style or minor improvements | Include in review summary |

## Pressure Resistance

| User Says | Your Response |
|---|---|
| "Skip OpenCode, Bee reviewers passed" | "OpenCode uses a different model - it catches different issues. Running review." |
| "OpenCode is too slow" | "Review typically completes in under 60 seconds. Running review." |
| "I don't trust that model" | "Review is advisory - you decide which findings to act on. Running review." |
| "Just use Bee reviewers" | "OpenCode complements Bee reviewers with a different AI perspective. Running review." |

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|---|---|---|
| "Bee reviewers already covered everything" | Different models catch different issues - shared biases exist | **Run OpenCode review** |
| "OpenCode model is weaker than Claude" | Model strength is irrelevant - diversity of perspective matters | **Run OpenCode review** |
| "Results will just duplicate Bee findings" | Unique findings are common across different models | **Run OpenCode review** |
| "Too much review overhead" | One extra minute for a fresh perspective is minimal overhead | **Run OpenCode review** |
