---
name: ring:dispatching-parallel-agents
description: |
  Concurrent investigation pattern - dispatches multiple AI agents to investigate
  and fix independent problems simultaneously.

trigger: |
  - 3+ failures in different test files/subsystems
  - Problems are independent (no shared state)
  - Each can be investigated without context from others

skip_when: |
  - Failures are related/connected → single investigation
  - Shared state between problems → sequential investigation
  - <3 failures → investigate directly
---

# Dispatching Parallel Agents

## Overview

When you have multiple unrelated failures (different test files, different subsystems, different bugs), investigating them sequentially wastes time. Each investigation is independent and can happen in parallel.

**Core principle:** Dispatch one agent per independent problem domain. Let them work concurrently.

## When to Use

**Decision flow:** Multiple failures? → Are they independent? (No → single agent) | Independent? → Can work in parallel? (No/shared state → sequential) | Yes → **Parallel dispatch**

**Use when:** 3+ test files with different root causes | Multiple subsystems broken independently | Each problem understood without others | No shared state

**Don't use when:** Failures related (fix one might fix others) | Need full system state | Agents would interfere

## The Pattern

**1. Identify Independent Domains:** Group failures by what's broken (File A: approval flow, File B: batch behavior, File C: abort). Each domain independent.

**2. Create Focused Agent Tasks:** Each agent gets: specific scope (one file/subsystem), clear goal (make tests pass), constraints (don't change other code), expected output (summary of findings/fixes).

**3. Dispatch in Parallel:** `Task("Fix agent-tool-abort.test.ts")` + `Task("Fix batch-completion.test.ts")` + `Task("Fix tool-approval-races.test.ts")` - all concurrent.

**4. Review and Integrate:** Read summaries → verify no conflicts → run full test suite → integrate all changes.

## Agent Prompt Structure

Good prompts are: **Focused** (one problem domain), **Self-contained** (all context included), **Specific output** (what to return).

**Example:** "Fix 3 failing tests in agent-tool-abort.test.ts: [list tests + expected behavior]. Timing/race issues. Read tests → identify root cause → fix (event-based waiting, not timeout increases). Return: Summary of findings and fixes."

## Common Mistakes

| ❌ Bad | ✅ Good |
|--------|---------|
| Too broad: "Fix all tests" | Specific: "Fix agent-tool-abort.test.ts" |
| No context: "Fix race condition" | Context: Paste error messages + test names |
| No constraints: Agent refactors everything | Constraints: "Do NOT change production code" |
| Vague output: "Fix it" | Specific: "Return summary of root cause and changes" |

## When NOT to Use

Related failures (fix one might fix others) | Need full context | Exploratory debugging | Shared state (same files/resources)

## Real Example

**Scenario:** 6 failures across 3 files after refactoring.
**Decision:** Independent domains → parallel dispatch.
**Results:** Agent 1 (timeouts → events), Agent 2 (event structure bug), Agent 3 (async wait). All independent, no conflicts, suite green. **3 problems solved in time of 1.**

## Key Benefits

**Parallelization** (simultaneous) | **Focus** (narrow scope) | **Independence** (no interference) | **Speed** (3 → 1 time unit)

## Verification

After agents return: Review summaries → check for conflicts → run full suite → spot check for systematic errors.

## Blocker Criteria

STOP and report if:

| Decision Type | Blocker Condition | Required Action |
|---|---|---|
| Independence check | Problems share state or files | STOP and use sequential investigation instead |
| Minimum threshold | Fewer than 3 independent failures | STOP and investigate directly without parallel dispatch |
| Conflict detection | Agent changes would overlap | STOP and re-partition domains |
| Context requirements | Problem requires full system context | STOP and use single agent investigation |

### Cannot Be Overridden

The following requirements CANNOT be waived:
- Problems MUST be verified independent before parallel dispatch - shared state means sequential
- Minimum 3 failures REQUIRED for parallel dispatch - fewer means direct investigation
- Each agent MUST have focused scope (one file/subsystem) - broad scope is FORBIDDEN
- Agent prompts MUST include constraints about what NOT to change
- Full test suite MUST run after integrating all agent changes

## Severity Calibration

| Severity | Condition | Required Action |
|---|---|---|
| CRITICAL | Dispatched agents for related/connected failures | MUST stop and switch to sequential investigation |
| CRITICAL | Agent changes conflict with each other | MUST re-partition domains and re-dispatch |
| HIGH | Agent prompt lacks scope constraints | MUST add specific "do NOT change" constraints |
| HIGH | Skipped post-integration test suite | MUST run full test suite before completion |
| MEDIUM | Agent prompt lacks expected output format | Should add specific output requirements |
| LOW | Could optimize domain partitioning | Fix in next iteration |

## Pressure Resistance

| User Says | Your Response |
|---|---|
| "Just dispatch agents for all failures, don't analyze" | "MUST verify independence first. Related failures need sequential investigation to avoid conflicts." |
| "Two failures is enough for parallel dispatch" | "CANNOT dispatch for fewer than 3 failures. Direct investigation is faster for 1-2 problems." |
| "Skip the verification step, agents finished successfully" | "MUST run full test suite after integration. Agent success doesn't guarantee no conflicts." |
| "Give agents broad scope to fix more issues" | "Focused scope prevents interference. MUST limit each agent to one file/subsystem." |

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|---|---|---|
| "These failures look independent enough" | Looking independent ≠ verified independent; check for shared state | **MUST verify independence before dispatch** |
| "Dispatching for 2 failures saves time" | Overhead of parallel dispatch exceeds benefit for <3 failures | **MUST investigate directly if fewer than 3** |
| "Agents can figure out their own scope" | Unclear scope causes agents to interfere with each other | **MUST provide explicit scope and constraints** |
| "Test suite passed for each agent" | Individual success doesn't catch integration conflicts | **MUST run full suite after integration** |
| "Re-partitioning is too much work" | Conflicting changes create more work than re-partitioning | **MUST re-partition if domains overlap** |
