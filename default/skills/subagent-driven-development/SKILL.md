---
name: ring:subagent-driven-development
description: |
  Autonomous plan execution - fresh subagent per task with automated code review
  between tasks. No human-in-loop, high throughput with quality gates.

trigger: |
  - Staying in current session (no worktree switch)
  - Tasks are independent (can be executed in isolation)
  - Want continuous progress without human pause points

skip_when: |
  - Need human review between tasks → use ring:executing-plans
  - Tasks are tightly coupled → execute manually
  - Plan needs revision → use brainstorming first

sequence:
  after: [ring:writing-plans, ring:pre-dev-task-breakdown]

related:
  similar: [ring:executing-plans]
---

# Subagent-Driven Development

Execute plan by dispatching fresh subagent per task, with code review after each.

**Core principle:** Fresh subagent per task + review between tasks = high quality, fast iteration

## Overview

**vs. Executing Plans (parallel session):**
- Same session (no context switch)
- Fresh subagent per task (no context pollution)
- Code review after each task (catch issues early)
- Faster iteration (no human-in-loop between tasks)

**When to use:**
- Staying in this session
- Tasks are mostly independent
- Want continuous progress with quality gates

**When NOT to use:**
- Need to review plan first (use ring:executing-plans)
- Tasks are tightly coupled (manual execution better)
- Plan needs revision (brainstorm first)

## The Process

### 1. Load Plan

Read plan file, create TodoWrite with all tasks.

### 1.5 Handle Multi-Module Tasks (if applicable)

**If plan has tasks with `target:` and `working_directory:` fields:**

1. **Track current module context:**
   ```
   current_module = None
   current_directory = "."
   ```

2. **Before dispatching task subagent, check for context switch:**
   ```
   IF task.target != current_module AND current_module != None:
     # Prompt user for confirmation
     AskUserQuestion:
       question: "Switching to {task.target} module at {task.working_directory}. Continue?"
       header: "Context"
       options:
         - label: "Continue"
           description: "Switch and execute task"
         - label: "Skip task"
           description: "Skip this task"
         - label: "Stop"
           description: "Stop execution"

     Handle response accordingly
   ```

3. **Include working directory in subagent prompt:**
   ```
   Task(
     subagent_type=task.agent,
     model="opus",
     prompt="Working directory: {task.working_directory}

     FIRST: cd {task.working_directory}
     THEN: Check for PROJECT_RULES.md and follow if exists

     {original task prompt}"
   )
   ```

**Optimization:** Reorder tasks to minimize context switches (if no dependencies between modules).

---

### 2. Execute Task with Subagent

**Dispatch:** `Task tool` with: Task N from [plan-file], working directory (if multi-module), instructions (implement, test with TDD, verify, commit, report back). Subagent reports summary.

### 3. Review Subagent's Work (Parallel Execution)

**CRITICAL: Single message with 5 Task tool calls** - all reviewers execute simultaneously.

| Reviewer | Context |
|----------|---------|
| `ring:code-reviewer` | WHAT_WAS_IMPLEMENTED, PLAN, BASE_SHA, HEAD_SHA |
| `ring:business-logic-reviewer` | Same context |
| `ring:security-reviewer` | Same context |
| `ring:test-reviewer` | Same context |
| `ring:nil-safety-reviewer` | Same context |

**Each returns:** Strengths, Issues (Critical/High/Medium/Low/Cosmetic), Assessment (PASS/FAIL)

### 4. Aggregate and Handle Review Feedback

**Aggregate** all issues by severity across all 5 reviewers.

| Severity | Action |
|----------|--------|
| **Critical/High/Medium** | Dispatch fix subagent → Re-run all 5 reviewers → Repeat until clear |
| **Low** | Add `# TODO(review): [issue] - reviewer, date, Severity: Low` |
| **Cosmetic** | Add `# FIXME(nitpick): [issue] - reviewer, date, Severity: Cosmetic` |

Commit TODO/FIXME comments with fixes.

### 5. Mark Complete, Next Task

After all Critical/High/Medium issues resolved for current task:
- Mark task as completed in TodoWrite
- Commit all changes (including TODO/FIXME comments)
- Move to next task
- Repeat steps 2-5

### 6. Final Review (After All Tasks)

**Same pattern as Step 3** but reviewing entire implementation (all tasks, full BASE_SHA→HEAD_SHA range). Aggregate, fix, re-run until all 5 PASS.

### 7. Complete Development

After final review passes:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## Example Workflow

**Task 1:** Implement → All 5 reviewers PASS → Mark complete.

**Task 2:** Implement → Review finds: Critical (hardcoded secret), High (missing password reset, missing input validation), Low (extract token logic) → Dispatch fix subagent → Re-run reviewers → All PASS → Add TODO for Low → Mark complete.

**Final:** All 5 reviewers PASS entire implementation → Done.

**Why parallel:** 5x faster, all feedback at once, TODO/FIXME tracks tech debt.

## Advantages

| vs. | Benefits |
|-----|----------|
| **Manual execution** | Fresh context per task, TDD enforced, parallel-safe |
| **Executing Plans** | Same session (no handoff), continuous progress, automatic review |

**Cost:** More invocations, but catches issues early (cheaper than debugging later).

## Red Flags

**Never:**
- Skip code review between tasks
- Proceed with unfixed Critical/High/Medium issues
- Dispatch reviewers sequentially (use parallel - 5x faster!)
- Dispatch multiple implementation subagents in parallel (conflicts)
- Implement without reading plan task
- Forget to add TODO/FIXME comments for Low/Cosmetic issues

**Always:**
- Launch all 5 reviewers in single message with 5 Task calls
- Wait for all reviewers before aggregating findings
- Fix Critical/High/Medium immediately
- Add TODO for Low, FIXME for Cosmetic
- Re-run all 5 reviewers after fixes

**If subagent fails task:**
- Dispatch fix subagent with specific instructions
- Don't try to fix manually (context pollution)

## Integration

**Required workflow skills:**
- **ring:writing-plans** - REQUIRED: Creates the plan that this skill executes
- **ring:requesting-code-review** - REQUIRED: Review after each task (see Step 3)
- **ring:finishing-a-development-branch** - REQUIRED: Complete development after all tasks (see Step 7)

**Subagents must use:**
- **ring:test-driven-development** - Subagents follow TDD for each task

**Alternative workflow:**
- **ring:executing-plans** - Use for parallel session instead of same-session execution

See reviewer agent definitions: ring:code-reviewer (agents/code-reviewer.md), ring:security-reviewer (agents/security-reviewer.md), ring:business-logic-reviewer (agents/business-logic-reviewer.md)

---

## Blocker Criteria

STOP and report if:

| Decision Type | Blocker Condition | Required Action |
|---|---|---|
| Plan missing | No plan file available to execute | STOP and use ring:writing-plans first |
| Critical issue unfixed | Code review found Critical/High/Medium issue that cannot be resolved | STOP and report blocker to human partner |
| Task dependency | Current task depends on incomplete previous task | STOP and resolve dependency before proceeding |
| Subagent failure | Subagent cannot complete task after retry | STOP and report for manual intervention |

### Cannot Be Overridden

The following requirements CANNOT be waived:
- MUST dispatch all 5 reviewers in parallel (single message with 5 Task calls)
- MUST NOT proceed with unfixed Critical/High/Medium issues
- MUST NOT dispatch multiple implementation subagents in parallel
- MUST add TODO/FIXME comments for Low/Cosmetic issues
- MUST use ring:finishing-a-development-branch at completion

## Severity Calibration

| Severity | Condition | Required Action |
|---|---|---|
| CRITICAL | Review finds security vulnerability or data loss risk | MUST fix immediately, re-run all 5 reviewers |
| HIGH | Review finds logic error or missing functionality | MUST fix before marking task complete |
| MEDIUM | Review finds code quality issue affecting maintainability | MUST fix before proceeding to next task |
| LOW | Review finds minor improvement opportunity | Add TODO comment, continue to next task |

## Pressure Resistance

| User Says | Your Response |
|---|---|
| "Skip the code review, we're behind schedule" | "CANNOT skip review between tasks. Review catches issues early, which is cheaper than debugging later." |
| "Run reviewers one at a time to see results faster" | "MUST dispatch all 5 reviewers in parallel. Sequential execution is 5x slower with no benefit." |
| "That Medium issue can wait" | "MUST fix Medium and above before proceeding. Technical debt compounds and blocks later tasks." |
| "Just implement multiple tasks at once" | "CANNOT dispatch parallel implementation subagents. Conflicts and context pollution will corrupt the codebase." |

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|---|---|---|
| "One quick review is enough" | Single reviewer misses issues. 5 reviewers catch different problem types. | **MUST run all 5 reviewers** |
| "This task is simple, skip review" | Simple tasks have simple bugs that compound. Review is cheap insurance. | **MUST review after every task** |
| "Low severity issues don't need tracking" | Low issues become Medium over time. TODO comments ensure they're not forgotten. | **MUST add TODO/FIXME for Low/Cosmetic** |
| "I'll fix the Medium issue in the next task" | Issues from task N don't belong in task N+1. Fix in context, not later. | **MUST fix Medium+ before proceeding** |
| "Parallel implementation would be faster" | Parallel implementation causes merge conflicts and context pollution. | **MUST execute tasks sequentially** |
