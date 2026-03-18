---
name: bee:dev-cycle-frontend-react-native
description: |
  React Native frontend development cycle orchestrator with 8 gates. Loads tasks from PM team output
  or backend handoff and executes through implementation → accessibility →
  unit testing → visual testing → E2E testing → performance testing → review → validation.

trigger: |
  - Starting a new React Native frontend development cycle with a task file
  - Resuming an interrupted React Native frontend development cycle (--resume flag)
  - After backend dev cycle completes (consuming handoff)

prerequisite: |
  - Tasks file exists with structured subtasks
  - Not already in a specific gate skill execution

skip_when: |
  - "Task is simple" → Simple ≠ risk-free. Execute gates.
  - "Tests already pass" → Tests ≠ review. Different concerns.
  - "Backend already tested this" → Mobile frontend has different quality concerns.

sequence:
  before: [bee:dev-feedback-loop]

related:
  complementary: [bee:dev-frontend-accessibility-react-native, bee:dev-unit-testing, bee:dev-frontend-visual-react-native, bee:dev-frontend-e2e-react-native, bee:dev-frontend-performance-react-native, bee:requesting-code-review, bee:dev-validation, bee:dev-feedback-loop]

verification:
  automated:
    - command: "test -f docs/bee:dev-cycle-frontend-react-native/current-cycle.json"
      description: "State file exists"
      success_pattern: "exit 0"
  manual:
    - "All gates for current task show PASS in state file"

examples:
  - name: "New React Native frontend from backend handoff"
    invocation: "/bee:dev-cycle-frontend-react-native docs/pre-dev/auth/tasks-frontend.md"
    expected_flow: |
      1. Load tasks with subtasks
      2. Detect UI library mode (sindarian-rn or fallback)
      3. Load backend handoff if available
      4. Ask user for execution mode
      5. Execute Gate 0→1→2→3→4→5→6→7 for each task
      6. Generate feedback report
  - name: "Resume interrupted React Native frontend cycle"
    invocation: "/bee:dev-cycle-frontend-react-native --resume"
  - name: "Direct prompt mode"
    invocation: "/bee:dev-cycle-frontend-react-native Implement home screen with transaction list and balance card"
---

# React Native Frontend Development Cycle Orchestrator

## Standards Loading (MANDATORY)

**Before any gate execution, you MUST load Bee React Native standards:**

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/CLAUDE.md
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/frontend-react-native.md
</fetch_required>

Fetch URLs above and extract: Agent Modification Verification requirements, Anti-Rationalization Tables requirements, Critical Rules, and React Native Frontend Standards.

<block_condition>
- WebFetch fails or returns empty
- CLAUDE.md not accessible
- frontend-react-native.md not accessible
</block_condition>

If any condition is true, STOP and report blocker. Cannot proceed without Bee standards.

## Overview

The React Native frontend development cycle orchestrator loads tasks/subtasks from PM team output (or manual task files) and executes through 8 gates (Gate 0-7) with **all gates executing per unit** (no deferred execution):

- **Gates 0-7 (per unit):** Write code + run tests/checks per task/subtask
- **All 8 gates are sequential and mandatory**

Unlike the backend `bee:dev-cycle` (which defers integration/chaos test execution), the React Native frontend cycle executes all gates fully per unit. Frontend testing tools (Detox, RNTL, Jest, bundle analyzer) do not require heavy container infrastructure.

**MUST announce at start:** "I'm using the bee:dev-cycle-frontend-react-native skill to orchestrate React Native frontend task execution through 8 gates (Gate 0-7). All gates execute per unit."

## CRITICAL: Specialized Agents Perform All Tasks

See [shared-patterns/shared-orchestrator-principle.md](../shared-patterns/shared-orchestrator-principle.md) for full ORCHESTRATOR principle, role separation, forbidden/required actions, gate-to-agent mapping, and anti-rationalization table.

**Summary:** You orchestrate. Agents execute. If using Read/Write/Edit/Bash on source code, STOP. Dispatch agent.

---

## ORCHESTRATOR BOUNDARIES (HARD GATE)

### What Orchestrator CAN Do (PERMITTED)

| Action | Tool | Purpose |
|--------|------|---------|
| Read task files | `Read` | Load task definitions from `docs/pre-dev/*/tasks-frontend.md` or `docs/pre-dev/*/tasks.md` |
| Read state files | `Read` | Load/verify `docs/bee:dev-cycle-frontend-react-native/current-cycle.json` |
| Read PROJECT_RULES.md | `Read` | Load project-specific rules |
| Read backend handoff | `Read` | Load `docs/bee:dev-cycle/handoff-frontend.json` if available |
| Write state files | `Write` | Persist cycle state to JSON |
| Track progress | `TodoWrite` | Maintain task list |
| Dispatch agents | `Task` | Send work to specialist agents |
| Ask user questions | `AskUserQuestion` | Get execution mode, approvals |
| WebFetch standards | `WebFetch` | Load Bee React Native standards |

### What Orchestrator CANNOT Do (FORBIDDEN)

<forbidden>
- Read source code (`Read` on `*.tsx`, `*.ts`, `*.jsx`, `*.js`, `*.styles.ts`) - Agent reads code, not orchestrator
- Write source code (`Write`/`Create` on `*.tsx`, `*.ts`) - Agent writes code, not orchestrator
- Edit source code (`Edit` on `*.tsx`, `*.ts`) - Agent edits code, not orchestrator
- Run tests (`Execute` with `npx jest`, `npx detox test`, `npx react-native bundle`) - Agent runs tests in TDD cycle
- Analyze code (Direct pattern analysis) - `bee:codebase-explorer` analyzes
- Make architectural decisions (Choosing state management, navigation library) - User decides, agent implements
</forbidden>

Any of these actions by orchestrator = IMMEDIATE VIOLATION. Dispatch agent instead.

---

### The 3-FILE RULE

**If a task requires editing MORE than 3 files, MUST dispatch specialist agent.**

- 1-3 files of non-source content (markdown, json, yaml) - Orchestrator MAY edit directly
- 1+ source code files (`*.tsx`, `*.ts`, `*.js`) - MUST dispatch agent
- 4+ files of any type - MUST dispatch agent

### Orchestrator Workflow Order (MANDATORY)

```text
+------------------------------------------------------------------+
|  CORRECT WORKFLOW ORDER                                           |
+------------------------------------------------------------------+
|                                                                   |
|  1. Load task file (Read docs/pre-dev/*/tasks-frontend.md)        |
|  2. Detect UI library mode (Step 0)                               |
|  3. Load backend handoff if available                             |
|  4. Ask execution mode (AskUserQuestion)                          |
|  5. Determine state path + Check/Load state                       |
|  6. WebFetch Bee Standards (CLAUDE.md + frontend-react-native.md) |
|  7. LOAD SUB-SKILL for current gate (Skill tool)                  |
|  8. Execute sub-skill instructions (dispatch agent via Task)      |
|  9. Wait for agent completion                                     |
|  10. Verify agent output (Standards Coverage Table)               |
|  11. Update state (Write to JSON)                                 |
|  12. Proceed to next gate                                         |
|                                                                   |
|  ================================================================ |
|  WRONG: Load -> Mode -> Standards -> Task(agent) directly         |
|  RIGHT: Load -> Mode -> Standards -> Skill(sub) -> Task(agent)    |
|  ================================================================ |
+------------------------------------------------------------------+
```

---

## UI Library Mode Detection (MANDATORY - Step 0)

Before any gate execution, detect the project's UI library configuration:

```text
Read tool: package.json

Parse the JSON content:
  - If "dependencies" or "devDependencies" contains "@luanrodrigues/sindarian-rn"
    → ui_library_mode = "sindarian-rn"
  - Otherwise
    → ui_library_mode = "fallback-only"
```

Store result in state file under `ui_library_mode`.

**`@luanrodrigues/sindarian-rn`** is PRIMARY. React Native Paper + RNUI is FALLBACK for missing components.

| Mode | Meaning | Agent Behavior |
|------|---------|----------------|
| `sindarian-rn` | Sindarian RN detected in package.json | Use Sindarian components first, React Native Paper only for gaps |
| `fallback-only` | No Sindarian RN detected | Use React Native Paper + RNUI as primary component library |

**Anti-Rationalization for UI Library Mode:**

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Skip detection, just use React Native Paper" | Project may have Sindarian RN. Skipping = wrong components. | **MUST detect before Gate 0** |
| "Mode doesn't matter for this task" | Mode affects every component decision in Gate 0. | **MUST detect and store in state** |

---

## Backend Handoff Loading (Optional)

If the React Native frontend cycle follows a backend `bee:dev-cycle`, load the handoff file:

```text
Check: Does docs/bee:dev-cycle/handoff-frontend.json exist?

  YES -> Load and parse:
    - endpoints: API endpoints implemented by backend
    - types: TypeScript types/interfaces exported by backend
    - contracts: Request/response schemas
    - auth_pattern: Authentication approach (JWT, session, etc.)
    Store in state.backend_handoff

  NO -> Proceed without handoff (standalone React Native frontend development)
```

**Handoff contents are CONTEXT for agents, not requirements.** Agents MUST still follow all gate requirements regardless of handoff content.

---

## SUB-SKILL LOADING IS MANDATORY (HARD GATE)

**Before dispatching any agent, you MUST load the corresponding sub-skill first.**

<cannot_skip>
- Gate 0: `Skill("bee:dev-implementation")` → then `Task(subagent_type="bee:frontend-engineer-react-native" or "bee:ui-engineer-react-native")`
- Gate 1: `Skill("bee:dev-frontend-accessibility-react-native")` → then `Task(subagent_type="bee:qa-analyst-frontend-react-native", test_mode="accessibility")`
- Gate 2: `Skill("bee:dev-unit-testing")` → then `Task(subagent_type="bee:qa-analyst-frontend-react-native", test_mode="unit")`
- Gate 3: `Skill("bee:dev-frontend-visual-react-native")` → then `Task(subagent_type="bee:qa-analyst-frontend-react-native", test_mode="visual")`
- Gate 4: `Skill("bee:dev-frontend-e2e-react-native")` → then `Task(subagent_type="bee:qa-analyst-frontend-react-native", test_mode="e2e")`
- Gate 5: `Skill("bee:dev-frontend-performance-react-native")` → then `Task(subagent_type="bee:qa-analyst-frontend-react-native", test_mode="performance")`
- Gate 6: `Skill("bee:requesting-code-review")` → then 5x `Task(...)` in parallel
- Gate 7: `Skill("bee:dev-validation")` → N/A (verification only)
</cannot_skip>

Between "WebFetch standards" and "Task(agent)" there MUST be "Skill(sub-skill)".

### Anti-Rationalization for Skipping Sub-Skills

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "I know what the sub-skill does" | Knowledge ≠ execution. Sub-skill has iteration logic. | **Load Skill() first** |
| "Task() directly is faster" | Faster ≠ correct. Sub-skill has validation rules. | **Load Skill() first** |
| "Sub-skill just wraps Task()" | Sub-skills have retry logic, fix dispatch, validation. | **Load Skill() first** |

**Between "WebFetch standards" and "Task(agent)" there MUST be "Skill(sub-skill)".**

---

### Anti-Rationalization for Direct Coding

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "It's just one small React Native component" | File count doesn't determine agent need. Standards do. | **DISPATCH specialist agent** |
| "I already loaded the standards" | Loading standards ≠ permission to implement. Standards are for AGENTS. | **DISPATCH specialist agent** |
| "I can write React Native / TypeScript" | Knowing framework ≠ having Bee standards loaded. Agent has them. | **DISPATCH specialist agent** |
| "Just a quick StyleSheet fix" | "Quick" is irrelevant. All source changes require specialist. | **DISPATCH specialist agent** |
| "Let me check if tests pass first" | Agent runs tests in TDD cycle. You don't run tests. | **DISPATCH specialist agent** |

### Red Flags - Orchestrator Violation in Progress

```text
RED FLAG: About to Read *.tsx or *.ts file
   -> STOP. Dispatch agent instead.

RED FLAG: About to Write/Create source code
   -> STOP. Dispatch agent instead.

RED FLAG: About to Edit source code or StyleSheet
   -> STOP. Dispatch agent instead.

RED FLAG: About to run "npx jest" or "npx detox test" or "npx react-native bundle"
   -> STOP. Agent runs tests, not you.

RED FLAG: Thinking "I'll just..."
   -> STOP. "Just" is the warning word. Dispatch agent.

RED FLAG: Thinking "This RN component is simple enough..."
   -> STOP. Simplicity is irrelevant. Dispatch agent.

RED FLAG: Standards loaded, but next action is not Task tool
   -> STOP. After standards, IMMEDIATELY dispatch agent.
```

---

## Blocker Criteria - STOP and Report

<block_condition>
- Gate Failure: Tests not passing, review failed -> STOP, cannot proceed to next gate
- Missing Standards: No PROJECT_RULES.md -> STOP, report blocker and wait
- Agent Failure: Specialist agent returned errors -> STOP, diagnose and report
- User Decision Required: Component library choice, design system variance -> STOP, present options
- Accessibility Blocker: VoiceOver/TalkBack violations found -> STOP, fix before proceeding
</block_condition>

### Cannot Be Overridden

<cannot_skip>
- All 8 gates must execute (0->1->2->3->4->5->6->7) - Each gate catches different issues
- All testing gates (1-5) are MANDATORY - Comprehensive test coverage ensures quality
- Gates execute in order (0->1->2->3->4->5->6->7) - Dependencies exist between gates
- Gate 6 requires all 5 reviewers - Different review perspectives are complementary
- Unit test coverage threshold >= 85% - Industry standard for quality code
- VoiceOver/TalkBack accessibility compliance is non-negotiable - Accessibility is a legal requirement
- Performance thresholds are non-negotiable - Performance affects user experience on mobile devices
- PROJECT_RULES.md must exist - Cannot verify standards without target
</cannot_skip>

No exceptions. User cannot override. Time pressure cannot override.

---

## The 8 Gates

| Gate | Skill | Purpose | Agent | Standards Module |
|------|-------|---------|-------|------------------|
| 0 | bee:dev-implementation | Write code following TDD | bee:frontend-engineer-react-native / bee:ui-engineer-react-native | frontend-react-native.md |
| 1 | bee:dev-frontend-accessibility-react-native | VoiceOver/TalkBack compliance | bee:qa-analyst-frontend-react-native (test_mode: accessibility) | testing-accessibility-rn.md |
| 2 | bee:dev-unit-testing | Unit tests 85%+ coverage (RNTL + Jest) | bee:qa-analyst-frontend-react-native (test_mode: unit) | frontend-react-native.md |
| 3 | bee:dev-frontend-visual-react-native | Jest snapshot/visual regression tests | bee:qa-analyst-frontend-react-native (test_mode: visual) | testing-visual-rn.md |
| 4 | bee:dev-frontend-e2e-react-native | E2E tests with Detox (iOS + Android) | bee:qa-analyst-frontend-react-native (test_mode: e2e) | testing-e2e-rn.md |
| 5 | bee:dev-frontend-performance-react-native | Bundle size + FlatList + Hermes optimizations | bee:qa-analyst-frontend-react-native (test_mode: performance) | testing-performance-rn.md |
| 6 | bee:requesting-code-review | Parallel code review (5 reviewers) | bee:code-reviewer, bee:business-logic-reviewer, bee:security-reviewer, bee:test-reviewer, bee:frontend-engineer-react-native (review mode) | N/A |
| 7 | bee:dev-validation | Final acceptance validation | N/A (verification) | N/A |

**All gates are MANDATORY. No exceptions. No skip reasons.**

### Gate 0: Agent Selection Logic

| Condition | Agent to Dispatch |
|-----------|-------------------|
| React Native screen / component implementation | `bee:frontend-engineer-react-native` |
| Design system / Sindarian RN component | `bee:ui-engineer-react-native` |
| Mixed (screen + design system component) | Dispatch `bee:frontend-engineer-react-native` first, then `bee:ui-engineer-react-native` |

**UI library mode (detected in Step 0) MUST be passed to the agent as context.**

### Gate 0: React Native TDD Policy

**TDD (RED→GREEN) applies to behavioral logic. Visual/presentational components use test-after.**

| Component Layer | TDD Required? | Where Tests Are Created | Rationale |
|-----------------|---------------|-------------------------|-----------|
| Custom hooks (useX) | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines the hook contract before code |
| Form validation logic | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines validation rules before code |
| Zustand/Redux store slices | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines state transitions before code |
| Conditional rendering logic | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines when elements show/hide |
| API integration (fetch/axios hooks) | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines expected request/response |
| Layout / styling (StyleSheet without logic) | NO - test-after | Gate 3 (visual testing) | Visual output is exploratory; snapshot locks it |
| Animations (Animated/Reanimated) | NO - test-after | Gate 3 (visual testing) | Motion is iterative; test captures final state |
| Static presentational components | NO - test-after | Gate 3 (visual testing) | No logic to drive with RED phase |

**Rules:**
1. **Behavioral hooks and store slices** in Gate 0 MUST produce TDD RED failure output before implementation
2. **Visual/presentational components** in Gate 0 are implemented without RED phase; Gate 3 creates their snapshot tests
3. **Mixed components** (behavior + visual): TDD for the behavioral part, test-after for the visual part
4. Gate 2 (Unit Testing) coverage threshold (85%) still applies to ALL component types

**React Native-Specific TDD Anti-Rationalization:**

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "This hook is simple, skip TDD" | Simple hooks still need contract verification. | **TDD RED→GREEN for all custom hooks** |
| "Validation library handles it, skip TDD" | Your validation schema rules need test-driven definition. | **TDD RED→GREEN for validation logic** |
| "Zustand action is obvious, skip TDD" | State mutations need deterministic tests before code. | **TDD RED→GREEN for store actions** |
| "Conditional render is visual" | show/hide conditions are logic, not presentation. | **TDD RED→GREEN for conditional rendering logic** |
| "useFetch is just a wrapper" | Custom hooks wrapping fetch define caching, error handling contracts. | **TDD for hook behavior** |

### Gate 6: Code Review Adaptation (5 Reviewers)

For the React Native frontend cycle, the 5 parallel reviewers are:

| # | Reviewer | Focus Area |
|---|----------|------------|
| 1 | `bee:code-reviewer` | Code quality, patterns, maintainability, React Native best practices |
| 2 | `bee:business-logic-reviewer` | Business logic correctness, domain rules, acceptance criteria |
| 3 | `bee:security-reviewer` | Secure storage, deep link handling, certificate pinning, sensitive data exposure |
| 4 | `bee:test-reviewer` | Test quality, coverage gaps, RNTL/Detox patterns, assertion quality |
| 5 | `bee:frontend-engineer-react-native` (review mode) | Accessibility compliance, React Native standards, component architecture, navigation patterns |

**NOTE:** The 5th reviewer slot uses `bee:frontend-engineer-react-native` in review mode. The React Native frontend engineer reviews VoiceOver/TalkBack compliance, hooks patterns, navigation, and React Native standards.

**All 5 reviewers MUST be dispatched in a single message with 5 parallel Task calls.**

```yaml
# Gate 6: Dispatch all 5 reviewers in parallel (SINGLE message)
Task 1: { subagent_type: "bee:code-reviewer", ... }
Task 2: { subagent_type: "bee:business-logic-reviewer", ... }
Task 3: { subagent_type: "bee:security-reviewer", ... }
Task 4: { subagent_type: "bee:test-reviewer", ... }
Task 5: { subagent_type: "bee:frontend-engineer-react-native", prompt: "REVIEW MODE: Review accessibility compliance (VoiceOver/TalkBack), hooks patterns, navigation, and React Native standards adherence...", ... }
```

---

## Gate Completion Definition (HARD GATE)

**A gate is COMPLETE only when all components finish successfully:**

| Gate | Components Required | Partial = FAIL |
|------|---------------------|----------------|
| 0.1 | TDD-RED: Failing test written + failure output captured (behavioral components only - see RN TDD Policy) | Test exists but no failure output = FAIL. Visual-only components skip to 0.2 |
| 0.2 | TDD-GREEN: Implementation passes test (behavioral) OR implementation complete (visual) | Code exists but test fails = FAIL |
| 0 | Both 0.1 and 0.2 complete (behavioral) OR 0.2 complete (visual - snapshots deferred to Gate 3) | 0.1 done without 0.2 = FAIL |
| 1 | 0 VoiceOver/TalkBack violations + accessibilityLabel on all interactive elements + accessibilityRole set | Any violation = FAIL |
| 2 | Unit test coverage >= 85% + all AC tested | 84% = FAIL |
| 3 | All state snapshots pass + platform snapshots (iOS + Android) covered | Missing snapshots = FAIL |
| 4 | All user flows tested on iOS + Android + 3x stable pass (Detox) | Flaky = FAIL |
| 5 | JS bundle size within budget + FlatList/FlashList used for lists + Hermes enabled + image optimization applied | Any threshold missed = FAIL |
| 6 | All 5 reviewers PASS | 4/5 reviewers = FAIL |
| 7 | Explicit "APPROVED" from user | "Looks good" = not approved |

**CRITICAL for Gate 6:** Running 4 of 5 reviewers is not a partial pass - it's a FAIL. Re-run all 5 reviewers.

---

## Gate Order Enforcement (HARD GATE)

**Gates MUST execute in order: 0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7. All 8 gates are MANDATORY.**

| Violation | Why It's WRONG | Consequence |
|-----------|----------------|-------------|
| Skip Gate 1 (Accessibility) | "It's internal tool" | Mobile apps MUST be accessible. Legal requirement. |
| Skip Gate 2 (Unit Testing) | "E2E covers it" | E2E is slow, RNTL unit tests catch logic bugs faster |
| Skip Gate 3 (Visual) | "Snapshots are brittle" | Fix brittleness, don't skip regression detection |
| Skip Gate 4 (E2E) | "Manual testing done" | Manual testing is not reproducible or automated |
| Skip Gate 5 (Performance) | "Optimize later" | Later = never. FlashList, image optimization apply NOW |
| Reorder Gates | "Review before test" | Reviewing untested RN code wastes reviewer time |
| Parallel Gates | "Run 1 and 2 together" | Dependencies exist. Order is intentional. |

---

## Execution Order

**Core Principle:** Each execution unit passes through all 8 gates. All gates execute and complete per unit.

**Per-Unit Flow:** Unit -> Gate 0->1->2->3->4->5->6->7 -> Unit Checkpoint -> Task Checkpoint -> Next Unit

| Scenario | Execution Unit | Gates Per Unit |
|----------|----------------|----------------|
| Task without subtasks | Task itself | 8 gates |
| Task with subtasks | Each subtask | 8 gates per subtask |

## Commit Timing

**User selects when commits happen (during initialization).**

| Option | When Commit Happens | Use Case |
|--------|---------------------|----------|
| **(a) Per subtask** | After each subtask passes Gate 7 | Fine-grained history, easy rollback per subtask |
| **(b) Per task** | After all subtasks of a task complete | Logical grouping, one commit per feature chunk |
| **(c) At the end** | After entire cycle completes | Single commit with all changes, clean history |

### Commit Message Format

| Timing | Message Format | Example |
|--------|----------------|---------|
| Per subtask | `feat({subtask_id}): {subtask_title}` | `feat(ST-001-02): implement transaction list screen` |
| Per task | `feat({task_id}): {task_title}` | `feat(T-001): implement home screen` |
| At the end | `feat({cycle_id}): complete react native frontend dev cycle for {feature}` | `feat(cycle-abc123): complete react native frontend dev cycle for dashboard` |

---

## State Management

### State Path

| Task Source | State Path |
|-------------|------------|
| Any source | `docs/bee:dev-cycle-frontend-react-native/current-cycle.json` |

### State File Structure

```json
{
  "version": "1.0.0",
  "cycle_id": "uuid",
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "source_file": "path/to/tasks-frontend.md",
  "state_path": "docs/bee:dev-cycle-frontend-react-native/current-cycle.json",
  "cycle_type": "frontend-react-native",
  "ui_library_mode": "sindarian-rn | fallback-only",
  "backend_handoff": {
    "loaded": true,
    "source": "docs/bee:dev-cycle/handoff-frontend.json",
    "endpoints": [],
    "types": [],
    "contracts": []
  },
  "execution_mode": "manual_per_subtask|manual_per_task|automatic",
  "commit_timing": "per_subtask|per_task|at_end",
  "custom_prompt": {
    "type": "string",
    "optional": true,
    "max_length": 500,
    "description": "User-provided context for agents. Max 500 characters."
  },
  "status": "in_progress|completed|failed|paused|paused_for_approval|paused_for_task_approval",
  "feedback_loop_completed": false,
  "current_task_index": 0,
  "tasks": [],
  "platform_targets": ["ios", "android"]
}
```

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations. Cycle-specific:

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "iOS and Android behave the same" | Platform-specific behaviors exist. Test both. | **Run Detox on iOS and Android** |
| "Simulator testing is enough" | Physical devices have different performance. | **Gate 6 uses device-representative benchmarks** |
| "React Native Paper is fine without checking" | Sindarian RN may be the required library. | **MUST detect UI library mode before Gate 0** |
| "Accessibility is only for web" | VoiceOver (iOS) and TalkBack (Android) are used by millions. | **Run accessibility gate on both platforms** |
| "FlatList is fine for this list" | FlatList has known performance limits. FlashList is standard. | **Use FlashList for long lists** |
| "Hermes doesn't matter for dev" | Hermes is production default. Test with it enabled. | **Ensure Hermes is enabled** |

---
