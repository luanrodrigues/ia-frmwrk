---
name: bee:dev-cycle-frontend-vuejs
description: |
  Vue.js/Nuxt 3 frontend development cycle orchestrator with 9 gates. Loads tasks from PM team output
  or backend handoff and executes through implementation → devops → accessibility →
  unit testing → visual testing → E2E testing → performance testing → review → validation.

trigger: |
  - Starting a new Vue.js frontend development cycle with a task file
  - Resuming an interrupted Vue.js frontend development cycle (--resume flag)
  - After backend dev cycle completes (consuming handoff)

prerequisite: |
  - Tasks file exists with structured subtasks
  - Not already in a specific gate skill execution

skip_when: |
  - "Task is simple" → Simple ≠ risk-free. Execute gates.
  - "Tests already pass" → Tests ≠ review. Different concerns.
  - "Backend already tested this" → Frontend has different quality concerns.

sequence:
  before: [bee:dev-feedback-loop]

related:
  complementary: [bee:dev-frontend-accessibility-vuejs, bee:dev-unit-testing, bee:dev-frontend-visual-vuejs, bee:dev-frontend-e2e-vuejs, bee:dev-frontend-performance-vuejs, bee:requesting-code-review, bee:dev-validation, bee:dev-feedback-loop]

verification:
  automated:
    - command: "test -f docs/bee:dev-cycle-frontend-vuejs/current-cycle.json"
      description: "State file exists"
      success_pattern: "exit 0"
  manual:
    - "All gates for current task show PASS in state file"

examples:
  - name: "New Vue.js frontend from backend handoff"
    invocation: "/bee:dev-cycle-frontend-vuejs docs/pre-dev/auth/tasks-frontend.md"
    expected_flow: |
      1. Load tasks with subtasks
      2. Detect UI library mode (sindarian-vue or fallback)
      3. Load backend handoff if available
      4. Ask user for execution mode
      5. Execute Gate 0→1→2→3→4→5→6→7→8 for each task
      6. Generate feedback report
  - name: "Resume interrupted Vue.js frontend cycle"
    invocation: "/bee:dev-cycle-frontend-vuejs --resume"
  - name: "Direct prompt mode"
    invocation: "/bee:dev-cycle-frontend-vuejs Implement dashboard with transaction list and charts"
---

# Vue.js Frontend Development Cycle Orchestrator

## Standards Loading (MANDATORY)

**Before any gate execution, you MUST load Bee Vue.js standards:**

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/CLAUDE.md
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/frontend-vuejs.md
</fetch_required>

Fetch URLs above and extract: Agent Modification Verification requirements, Anti-Rationalization Tables requirements, Critical Rules, and Vue.js Frontend Standards.

<block_condition>
- WebFetch fails or returns empty
- CLAUDE.md not accessible
- frontend-vuejs.md not accessible
</block_condition>

If any condition is true, STOP and report blocker. Cannot proceed without Bee standards.

## Overview

The Vue.js frontend development cycle orchestrator loads tasks/subtasks from PM team output (or manual task files) and executes through 9 gates (Gate 0-8) with **all gates executing per unit** (no deferred execution):

- **Gates 0-8 (per unit):** Write code + run tests/checks per task/subtask
- **All 9 gates are sequential and mandatory**

Unlike the backend `bee:dev-cycle` (which defers integration/chaos test execution), the Vue.js frontend cycle executes all gates fully per unit. Frontend testing tools (Playwright, Vitest, Lighthouse) do not require heavy container infrastructure.

**MUST announce at start:** "I'm using the bee:dev-cycle-frontend-vuejs skill to orchestrate Vue.js frontend task execution through 9 gates (Gate 0-8). All gates execute per unit."

## CRITICAL: Specialized Agents Perform All Tasks

See [shared-patterns/shared-orchestrator-principle.md](../shared-patterns/shared-orchestrator-principle.md) for full ORCHESTRATOR principle, role separation, forbidden/required actions, gate-to-agent mapping, and anti-rationalization table.

**Summary:** You orchestrate. Agents execute. If using Read/Write/Edit/Bash on source code, STOP. Dispatch agent.

---

## ORCHESTRATOR BOUNDARIES (HARD GATE)

### What Orchestrator CAN Do (PERMITTED)

| Action | Tool | Purpose |
|--------|------|---------|
| Read task files | `Read` | Load task definitions from `docs/pre-dev/*/tasks-frontend.md` or `docs/pre-dev/*/tasks.md` |
| Read state files | `Read` | Load/verify `docs/bee:dev-cycle-frontend-vuejs/current-cycle.json` |
| Read PROJECT_RULES.md | `Read` | Load project-specific rules |
| Read backend handoff | `Read` | Load `docs/bee:dev-cycle/handoff-frontend.json` if available |
| Write state files | `Write` | Persist cycle state to JSON |
| Track progress | `TodoWrite` | Maintain task list |
| Dispatch agents | `Task` | Send work to specialist agents |
| Ask user questions | `AskUserQuestion` | Get execution mode, approvals |
| WebFetch standards | `WebFetch` | Load Bee Vue.js standards |

### What Orchestrator CANNOT Do (FORBIDDEN)

<forbidden>
- Read source code (`Read` on `*.vue`, `*.ts`, `*.css`, `*.scss`) - Agent reads code, not orchestrator
- Write source code (`Write`/`Create` on `*.vue`, `*.ts`) - Agent writes code, not orchestrator
- Edit source code (`Edit` on `*.vue`, `*.ts`, `*.css`) - Agent edits code, not orchestrator
- Run tests (`Execute` with `npm test`, `npx playwright`, `npx vitest`) - Agent runs tests in TDD cycle
- Analyze code (Direct pattern analysis) - `bee:codebase-explorer` analyzes
- Make architectural decisions (Choosing Pinia vs Vuex, Vue Router patterns) - User decides, agent implements
</forbidden>

Any of these actions by orchestrator = IMMEDIATE VIOLATION. Dispatch agent instead.

---

### The 3-FILE RULE

**If a task requires editing MORE than 3 files, MUST dispatch specialist agent.**

- 1-3 files of non-source content (markdown, json, yaml) - Orchestrator MAY edit directly
- 1+ source code files (`*.vue`, `*.ts`, `*.css`) - MUST dispatch agent
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
|  6. WebFetch Bee Standards (CLAUDE.md + frontend-vuejs.md)        |
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
  - If "dependencies" or "devDependencies" contains "@luanrodrigues/sindarian-vue"
    → ui_library_mode = "sindarian-vue"
  - Otherwise
    → ui_library_mode = "fallback-only"
```

Store result in state file under `ui_library_mode`.

**`@luanrodrigues/sindarian-vue`** is PRIMARY. shadcn-vue + Radix Vue is FALLBACK for missing components.

| Mode | Meaning | Agent Behavior |
|------|---------|----------------|
| `sindarian-vue` | Sindarian Vue detected in package.json | Use Sindarian components first, shadcn-vue only for gaps |
| `fallback-only` | No Sindarian Vue detected | Use shadcn-vue + Radix Vue as primary component library |

**Anti-Rationalization for UI Library Mode:**

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Skip detection, just use shadcn-vue" | Project may have Sindarian Vue. Skipping = wrong components. | **MUST detect before Gate 0** |
| "Mode doesn't matter for this task" | Mode affects every component decision in Gate 0. | **MUST detect and store in state** |

---

## Backend Handoff Loading (Optional)

If the Vue.js frontend cycle follows a backend `bee:dev-cycle`, load the handoff file:

```text
Check: Does docs/bee:dev-cycle/handoff-frontend.json exist?

  YES -> Load and parse:
    - endpoints: API endpoints implemented by backend
    - types: TypeScript types/interfaces exported by backend
    - contracts: Request/response schemas
    - auth_pattern: Authentication approach (JWT, session, etc.)
    Store in state.backend_handoff

  NO -> Proceed without handoff (standalone Vue.js frontend development)
```

**Handoff contents are CONTEXT for agents, not requirements.** Agents MUST still follow all gate requirements regardless of handoff content.

---

## SUB-SKILL LOADING IS MANDATORY (HARD GATE)

**Before dispatching any agent, you MUST load the corresponding sub-skill first.**

<cannot_skip>
- Gate 0: `Skill("bee:dev-implementation")` → then `Task(subagent_type="bee:frontend-engineer-vuejs" or "bee:ui-engineer-vuejs" or "bee:frontend-bff-engineer-typescript")`
- Gate 1: `Skill("bee:dev-devops")` → then `Task(subagent_type="bee:devops-engineer")`
- Gate 2: `Skill("bee:dev-frontend-accessibility-vuejs")` → then `Task(subagent_type="bee:qa-analyst-frontend-vuejs", test_mode="accessibility")`
- Gate 3: `Skill("bee:dev-unit-testing")` → then `Task(subagent_type="bee:qa-analyst-frontend-vuejs", test_mode="unit")`
- Gate 4: `Skill("bee:dev-frontend-visual-vuejs")` → then `Task(subagent_type="bee:qa-analyst-frontend-vuejs", test_mode="visual")`
- Gate 5: `Skill("bee:dev-frontend-e2e-vuejs")` → then `Task(subagent_type="bee:qa-analyst-frontend-vuejs", test_mode="e2e")`
- Gate 6: `Skill("bee:dev-frontend-performance-vuejs")` → then `Task(subagent_type="bee:qa-analyst-frontend-vuejs", test_mode="performance")`
- Gate 7: `Skill("bee:requesting-code-review")` → then 5x `Task(...)` in parallel
- Gate 8: `Skill("bee:dev-validation")` → N/A (verification only)
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
| "It's just one small Vue component" | File count doesn't determine agent need. Standards do. | **DISPATCH specialist agent** |
| "I already loaded the standards" | Loading standards ≠ permission to implement. Standards are for AGENTS. | **DISPATCH specialist agent** |
| "I can write Vue 3 / TypeScript" | Knowing framework ≠ having Bee standards loaded. Agent has them. | **DISPATCH specialist agent** |
| "Just a quick CSS fix" | "Quick" is irrelevant. All source changes require specialist. | **DISPATCH specialist agent** |
| "Let me check if tests pass first" | Agent runs tests in TDD cycle. You don't run tests. | **DISPATCH specialist agent** |

### Red Flags - Orchestrator Violation in Progress

```text
RED FLAG: About to Read *.vue or *.ts file
   -> STOP. Dispatch agent instead.

RED FLAG: About to Write/Create source code
   -> STOP. Dispatch agent instead.

RED FLAG: About to Edit source code or CSS
   -> STOP. Dispatch agent instead.

RED FLAG: About to run "npm test" or "npx playwright test" or "npx vitest"
   -> STOP. Agent runs tests, not you.

RED FLAG: Thinking "I'll just..."
   -> STOP. "Just" is the warning word. Dispatch agent.

RED FLAG: Thinking "This Vue component is simple enough..."
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
- Accessibility Blocker: WCAG AA violations found -> STOP, fix before proceeding
</block_condition>

### Cannot Be Overridden

<cannot_skip>
- All 9 gates must execute (0->1->2->3->4->5->6->7->8) - Each gate catches different issues
- All testing gates (2-6) are MANDATORY - Comprehensive test coverage ensures quality
- Gates execute in order (0->1->2->3->4->5->6->7->8) - Dependencies exist between gates
- Gate 7 requires all 5 reviewers - Different review perspectives are complementary
- Unit test coverage threshold >= 85% - Industry standard for quality code
- WCAG 2.1 AA compliance is non-negotiable - Accessibility is a legal requirement
- Core Web Vitals thresholds are non-negotiable - Performance affects user experience
- PROJECT_RULES.md must exist - Cannot verify standards without target
</cannot_skip>

No exceptions. User cannot override. Time pressure cannot override.

---

## The 9 Gates

| Gate | Skill | Purpose | Agent | Standards Module |
|------|-------|---------|-------|------------------|
| 0 | bee:dev-implementation | Write code following TDD | bee:frontend-engineer-vuejs / bee:ui-engineer-vuejs / bee:frontend-bff-engineer-typescript | frontend-vuejs.md |
| 1 | bee:dev-devops | Docker/compose/Nginx setup | bee:devops-engineer | devops.md |
| 2 | bee:dev-frontend-accessibility-vuejs | WCAG 2.1 AA compliance | bee:qa-analyst-frontend-vuejs (test_mode: accessibility) | testing-accessibility.md |
| 3 | bee:dev-unit-testing | Unit tests 85%+ coverage | bee:qa-analyst-frontend-vuejs (test_mode: unit) | frontend-vuejs.md |
| 4 | bee:dev-frontend-visual-vuejs | Vitest snapshot/visual regression tests | bee:qa-analyst-frontend-vuejs (test_mode: visual) | testing-visual.md |
| 5 | bee:dev-frontend-e2e-vuejs | E2E tests with Playwright | bee:qa-analyst-frontend-vuejs (test_mode: e2e) | testing-e2e.md |
| 6 | bee:dev-frontend-performance-vuejs | Core Web Vitals + Lighthouse + Nuxt optimizations | bee:qa-analyst-frontend-vuejs (test_mode: performance) | testing-performance.md |
| 7 | bee:requesting-code-review | Parallel code review (5 reviewers) | bee:code-reviewer, bee:business-logic-reviewer, bee:security-reviewer, bee:test-reviewer, bee:frontend-engineer-vuejs (review mode) | N/A |
| 8 | bee:dev-validation | Final acceptance validation | N/A (verification) | N/A |

**All gates are MANDATORY. No exceptions. No skip reasons.**

### Gate 0: Agent Selection Logic

| Condition | Agent to Dispatch |
|-----------|-------------------|
| Vue 3 / Nuxt 3 component implementation | `bee:frontend-engineer-vuejs` |
| Design system / Sindarian Vue component | `bee:ui-engineer-vuejs` |
| Nuxt server API / BFF aggregation layer | `bee:frontend-bff-engineer-typescript` |
| Mixed (component + BFF) | Dispatch `bee:frontend-engineer-vuejs` first, then `bee:frontend-bff-engineer-typescript` |

**UI library mode (detected in Step 0) MUST be passed to the agent as context.**

### Gate 0: Vue.js Frontend TDD Policy

**TDD (RED→GREEN) applies to behavioral logic. Visual/presentational Vue components use test-after.**

| Component Layer | TDD Required? | Where Tests Are Created | Rationale |
|-----------------|---------------|-------------------------|-----------|
| Composables (custom hooks) | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines the composable contract before code |
| Form validation (VeeValidate schemas) | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines validation rules before code |
| Pinia store actions and getters | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines state transitions before code |
| Conditional rendering (v-if logic) | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines when elements show/hide |
| API integration (useFetch/useAsyncData) | YES - TDD RED→GREEN | Gate 0 (implementation) | Test defines expected request/response |
| Layout / styling (templates without logic) | NO - test-after | Gate 4 (visual testing) | Visual output is exploratory; snapshot locks it |
| Animations / Vue transitions | NO - test-after | Gate 4 (visual testing) | Motion is iterative; test captures final state |
| Static presentational components | NO - test-after | Gate 4 (visual testing) | No logic to drive with RED phase |

**Rules:**
1. **Behavioral composables and Pinia stores** in Gate 0 MUST produce TDD RED failure output before implementation
2. **Visual/presentational Vue SFCs** in Gate 0 are implemented without RED phase; Gate 4 creates their snapshot tests
3. **Mixed components** (behavior + visual): TDD for the behavioral part, test-after for the visual part
4. Gate 3 (Unit Testing) coverage threshold (85%) still applies to ALL component types

**Vue.js-Specific TDD Anti-Rationalization:**

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "This composable is simple, skip TDD" | Simple composables still need contract verification. | **TDD RED→GREEN for all composables** |
| "VeeValidate handles validation, skip TDD" | Your schema rules need test-driven definition. | **TDD RED→GREEN for VeeValidate schemas** |
| "Pinia action is obvious, skip TDD" | State mutations need deterministic tests before code. | **TDD RED→GREEN for Pinia actions** |
| "Template rendering is visual" | v-if conditions are logic, not presentation. | **TDD RED→GREEN for conditional rendering logic** |
| "useFetch is just a wrapper" | Composables wrapping useFetch define caching, error handling contracts. | **TDD for composable behavior** |

### Gate 7: Code Review Adaptation (5 Reviewers)

For the Vue.js frontend cycle, the 5 parallel reviewers are:

| # | Reviewer | Focus Area |
|---|----------|------------|
| 1 | `bee:code-reviewer` | Code quality, patterns, maintainability, Vue 3 Composition API best practices |
| 2 | `bee:business-logic-reviewer` | Business logic correctness, domain rules, acceptance criteria |
| 3 | `bee:security-reviewer` | XSS, CSRF, auth handling, sensitive data exposure, CSP, Nuxt server route security |
| 4 | `bee:test-reviewer` | Test quality, coverage gaps, Vitest/Playwright patterns, assertion quality |
| 5 | `bee:frontend-engineer-vuejs` (review mode) | Accessibility compliance, Vue.js/Nuxt 3 standards, component architecture, Pinia patterns |

**NOTE:** The 5th reviewer slot uses `bee:frontend-engineer-vuejs` in review mode. The Vue.js frontend engineer reviews accessibility compliance, Composition API adherence, Pinia store patterns, and Nuxt 3 standards.

**All 5 reviewers MUST be dispatched in a single message with 5 parallel Task calls.**

```yaml
# Gate 7: Dispatch all 5 reviewers in parallel (SINGLE message)
Task 1: { subagent_type: "bee:code-reviewer", ... }
Task 2: { subagent_type: "bee:business-logic-reviewer", ... }
Task 3: { subagent_type: "bee:security-reviewer", ... }
Task 4: { subagent_type: "bee:test-reviewer", ... }
Task 5: { subagent_type: "bee:frontend-engineer-vuejs", prompt: "REVIEW MODE: Review accessibility compliance, Composition API patterns, Pinia store usage, and Vue.js/Nuxt 3 standards adherence...", ... }
```

---

## Gate Completion Definition (HARD GATE)

**A gate is COMPLETE only when all components finish successfully:**

| Gate | Components Required | Partial = FAIL |
|------|---------------------|----------------|
| 0.1 | TDD-RED: Failing test written + failure output captured (behavioral components only - see Vue.js TDD Policy) | Test exists but no failure output = FAIL. Visual-only components skip to 0.2 |
| 0.2 | TDD-GREEN: Implementation passes test (behavioral) OR implementation complete (visual) | Code exists but test fails = FAIL |
| 0 | Both 0.1 and 0.2 complete (behavioral) OR 0.2 complete (visual - snapshots deferred to Gate 4) | 0.1 done without 0.2 = FAIL |
| 1 | Dockerfile + docker-compose/nginx + .env.example | Missing any = FAIL |
| 2 | 0 WCAG AA violations + keyboard navigation tested + screen reader tested | Any violation = FAIL |
| 3 | Unit test coverage >= 85% + all AC tested | 84% = FAIL |
| 4 | All state snapshots pass + responsive breakpoints covered | Missing snapshots = FAIL |
| 5 | All user flows tested + cross-browser (Chromium, Firefox, WebKit) + 3x stable pass | Flaky = FAIL |
| 6 | LCP < 2.5s + CLS < 0.1 + INP < 200ms + Lighthouse >= 90 + NuxtImg used for all images | Any threshold missed = FAIL |
| 7 | All 5 reviewers PASS | 4/5 reviewers = FAIL |
| 8 | Explicit "APPROVED" from user | "Looks good" = not approved |

**CRITICAL for Gate 7:** Running 4 of 5 reviewers is not a partial pass - it's a FAIL. Re-run all 5 reviewers.

---

## Gate Order Enforcement (HARD GATE)

**Gates MUST execute in order: 0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8. All 9 gates are MANDATORY.**

| Violation | Why It's WRONG | Consequence |
|-----------|----------------|-------------|
| Skip Gate 1 (DevOps) | "No infra changes" | App without container = works on my machine only |
| Skip Gate 2 (Accessibility) | "It's internal tool" | Internal tools MUST be accessible. Legal requirement. |
| Skip Gate 3 (Unit Testing) | "E2E covers it" | E2E is slow, Vitest unit tests catch logic bugs faster |
| Skip Gate 4 (Visual) | "Snapshots are brittle" | Fix brittleness, don't skip regression detection |
| Skip Gate 5 (E2E) | "Manual testing done" | Manual testing is not reproducible or automated |
| Skip Gate 6 (Performance) | "Optimize later" | Later = never. NuxtImg, useAsyncData apply NOW |
| Reorder Gates | "Review before test" | Reviewing untested Vue code wastes reviewer time |
| Parallel Gates | "Run 2 and 3 together" | Dependencies exist. Order is intentional. |

---

## Execution Order

**Core Principle:** Each execution unit passes through all 9 gates. All gates execute and complete per unit.

**Per-Unit Flow:** Unit -> Gate 0->1->2->3->4->5->6->7->8 -> Unit Checkpoint -> Task Checkpoint -> Next Unit

| Scenario | Execution Unit | Gates Per Unit |
|----------|----------------|----------------|
| Task without subtasks | Task itself | 9 gates |
| Task with subtasks | Each subtask | 9 gates per subtask |

## Commit Timing

**User selects when commits happen (during initialization).**

| Option | When Commit Happens | Use Case |
|--------|---------------------|----------|
| **(a) Per subtask** | After each subtask passes Gate 8 | Fine-grained history, easy rollback per subtask |
| **(b) Per task** | After all subtasks of a task complete | Logical grouping, one commit per feature chunk |
| **(c) At the end** | After entire cycle completes | Single commit with all changes, clean history |

### Commit Message Format

| Timing | Message Format | Example |
|--------|----------------|---------|
| Per subtask | `feat({subtask_id}): {subtask_title}` | `feat(ST-001-02): implement transaction list component` |
| Per task | `feat({task_id}): {task_title}` | `feat(T-001): implement dashboard page` |
| At the end | `feat({cycle_id}): complete vue.js frontend dev cycle for {feature}` | `feat(cycle-abc123): complete vue.js frontend dev cycle for dashboard` |

---

## State Management

### State Path

| Task Source | State Path |
|-------------|------------|
| Any source | `docs/bee:dev-cycle-frontend-vuejs/current-cycle.json` |

### State File Structure

```json
{
  "version": "1.0.0",
  "cycle_id": "uuid",
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "source_file": "path/to/tasks-frontend.md",
  "state_path": "docs/bee:dev-cycle-frontend-vuejs/current-cycle.json",
  "cycle_type": "frontend-vuejs",
  "ui_library_mode": "sindarian-vue | fallback-only",
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
  "current_gate": 0,
  "current_subtask_index": 0,
  "tasks": [
    {
      "id": "T-001",
      "title": "Task title",
      "status": "pending|in_progress|completed|failed|blocked",
      "feedback_loop_completed": false,
      "subtasks": [
        {
          "id": "ST-001-01",
          "file": "subtasks/T-001/ST-001-01.md",
          "status": "pending|completed"
        }
      ],
      "gate_progress": {
        "implementation": {
          "status": "pending|in_progress|completed",
          "started_at": "...",
          "tdd_red": {
            "status": "pending|in_progress|completed",
            "test_file": "path/to/composable.spec.ts",
            "failure_output": "FAIL: expected element not found",
            "completed_at": "ISO timestamp"
          },
          "tdd_green": {
            "status": "pending|in_progress|completed",
            "implementation_file": "path/to/Component.vue",
            "test_pass_output": "PASS: 12 tests passed",
            "completed_at": "ISO timestamp"
          }
        },
        "devops": {"status": "pending"},
        "accessibility": {
          "status": "pending|in_progress|completed",
          "wcag_violations": 0,
          "keyboard_nav_tested": false,
          "screen_reader_tested": false
        },
        "unit_testing": {
          "status": "pending|in_progress|completed",
          "coverage_actual": 0,
          "coverage_threshold": 85
        },
        "visual_testing": {
          "status": "pending|in_progress|completed",
          "snapshots_total": 0,
          "snapshots_passed": 0,
          "responsive_breakpoints_covered": []
        },
        "e2e_testing": {
          "status": "pending|in_progress|completed",
          "flows_tested": 0,
          "browsers_tested": [],
          "stability_runs": 0
        },
        "performance_testing": {
          "status": "pending|in_progress|completed",
          "lcp_ms": 0,
          "cls": 0,
          "inp_ms": 0,
          "lighthouse_score": 0
        },
        "review": {"status": "pending"},
        "validation": {"status": "pending"}
      },
      "agent_outputs": {
        "implementation": {
          "agent": "bee:frontend-engineer-vuejs",
          "output": "## Summary\n...",
          "timestamp": "ISO timestamp",
          "duration_ms": 0,
          "iterations": 1,
          "standards_compliance": {
            "total_sections": 12,
            "compliant": 12,
            "not_applicable": 0,
            "non_compliant": 0,
            "gaps": []
          }
        },
        "devops": {
          "agent": "bee:devops-engineer",
          "output": "## Summary\n...",
          "timestamp": "ISO timestamp",
          "duration_ms": 0,
          "iterations": 1,
          "artifacts_created": ["Dockerfile", "nginx.conf", ".env.example"],
          "verification_errors": [],
          "standards_compliance": {}
        },
        "accessibility": {
          "agent": "bee:qa-analyst-frontend-vuejs",
          "test_mode": "accessibility",
          "output": "## Summary\n...",
          "verdict": "PASS",
          "wcag_violations": 0,
          "keyboard_nav_issues": 0,
          "screen_reader_issues": 0,
          "iterations": 1,
          "timestamp": "ISO timestamp"
        },
        "unit_testing": {
          "agent": "bee:qa-analyst-frontend-vuejs",
          "test_mode": "unit",
          "output": "## Summary\n...",
          "verdict": "PASS",
          "coverage_actual": 87.5,
          "coverage_threshold": 85,
          "iterations": 1,
          "timestamp": "ISO timestamp"
        },
        "visual_testing": {
          "agent": "bee:qa-analyst-frontend-vuejs",
          "test_mode": "visual",
          "output": "## Summary\n...",
          "verdict": "PASS",
          "snapshots_total": 15,
          "snapshots_passed": 15,
          "iterations": 1,
          "timestamp": "ISO timestamp"
        },
        "e2e_testing": {
          "agent": "bee:qa-analyst-frontend-vuejs",
          "test_mode": "e2e",
          "output": "## Summary\n...",
          "verdict": "PASS",
          "flows_tested": 5,
          "browsers_tested": ["chromium", "firefox", "webkit"],
          "stability_runs": 3,
          "iterations": 1,
          "timestamp": "ISO timestamp"
        },
        "performance_testing": {
          "agent": "bee:qa-analyst-frontend-vuejs",
          "test_mode": "performance",
          "output": "## Summary\n...",
          "verdict": "PASS",
          "lcp_ms": 2100,
          "cls": 0.05,
          "inp_ms": 150,
          "lighthouse_score": 93,
          "iterations": 1,
          "timestamp": "ISO timestamp"
        },
        "review": {
          "iterations": 1,
          "timestamp": "ISO timestamp",
          "duration_ms": 0,
          "code_reviewer": {
            "agent": "bee:code-reviewer",
            "output": "...",
            "verdict": "PASS",
            "issues": []
          },
          "business_logic_reviewer": {
            "agent": "bee:business-logic-reviewer",
            "output": "...",
            "verdict": "PASS",
            "issues": []
          },
          "security_reviewer": {
            "agent": "bee:security-reviewer",
            "output": "...",
            "verdict": "PASS",
            "issues": []
          },
          "test_reviewer": {
            "agent": "bee:test-reviewer",
            "output": "...",
            "verdict": "PASS",
            "issues": []
          },
          "frontend_engineer_reviewer": {
            "agent": "bee:frontend-engineer-vuejs",
            "mode": "review",
            "output": "...",
            "verdict": "PASS",
            "issues": []
          }
        },
        "validation": {
          "result": "approved|rejected",
          "timestamp": "ISO timestamp"
        }
      }
    }
  ],
  "metrics": {
    "total_duration_ms": 0,
    "gate_durations": {},
    "review_iterations": 0,
    "testing_iterations": 0
  }
}
```

### State Persistence Rule (MANDATORY)

**"Update state" means BOTH update the object and write to file. Not just in-memory.**

After every gate transition, MUST execute:

```yaml
# Step 1: Update state object with gate results
state.tasks[current_task_index].gate_progress.[gate_name].status = "completed"
state.current_gate = [next_gate_number]
state.updated_at = "[ISO timestamp]"

# Step 2: Write to file (MANDATORY - use Write tool)
Write tool:
  file_path: "docs/bee:dev-cycle-frontend-vuejs/current-cycle.json"
  content: [full JSON state]

# Step 3: Verify persistence (MANDATORY - use Read tool)
Read tool:
  file_path: "docs/bee:dev-cycle-frontend-vuejs/current-cycle.json"
```

---

## Checkpoint Modes

| Mode | Checkpoint Behavior | Gate Behavior |
|------|---------------------|---------------|
| **Manual per subtask** | Pause after each subtask completes all 9 gates | All 9 gates execute without pause |
| **Manual per task** | Pause after all subtasks of a task complete | All 9 gates execute without pause |
| **Automatic** | No pauses | All 9 gates execute without pause |

**CRITICAL:** Execution mode affects CHECKPOINTS (user approval pauses), not GATES (quality checks). All gates execute regardless of mode.

### Checkpoint Questions

**Unit Checkpoint (after subtask completes Gate 8):**

**VISUAL CHANGE REPORT (MANDATORY - before checkpoint question):**
- MUST invoke `Skill("bee:visual-explainer")` to generate a code-diff HTML report for this execution unit
- Content sourced from state JSON `agent_outputs` for the current unit:
  * **TDD Output:** `tdd_red` (failing test) + `tdd_green` (implementation)
  * **Files Changed:** Per-file before/after diff panels using `git diff` data from the implementation agent
  * **Vue.js-Specific Metrics:** WCAG violations resolved (Gate 2), Vitest snapshot pass rate (Gate 4), LCP/CLS/INP values (Gate 6), Lighthouse score (Gate 6)
  * **Review Verdicts:** Summary of all 5 reviewer verdicts from Gate 7
- Save to: `docs/bee:dev-cycle-frontend-vuejs/reports/unit-{unit_id}-report.html`
- Open in browser and tell the user the file path

---

## Step 0: Verify PROJECT_RULES.md Exists (HARD GATE)

```text
Check: Does docs/PROJECT_RULES.md exist?

  YES -> Proceed to Step 1 (Initialize or Resume)

  NO -> ASK: "Is this a LEGACY project?"
    YES (legacy) -> Dispatch bee:codebase-explorer + ask 3 questions + generate PROJECT_RULES.md
    NO (new) -> Check for PM documents (PRD/TRD/Feature Map)
      HAS PM docs -> Generate PROJECT_RULES.md from PM docs
      NO PM docs -> HARD BLOCK: "Run /bee:pre-dev-full or /bee:pre-dev-feature first"
```

---

## Step 1: Initialize or Resume

### Prompt-Only Mode (no task file)

1. **Detect prompt-only mode:** No task file argument provided
2. **Analyze prompt:** Extract intent, scope, and Vue.js/Nuxt 3 frontend requirements
3. **Explore codebase:** Dispatch `bee:codebase-explorer` to understand project structure
4. **Generate tasks:** Create task structure internally based on prompt + codebase analysis
5. **Present generated tasks:** Show user the auto-generated task breakdown
6. **Confirm with user:** "I generated X tasks from your prompt. Proceed?"
7. **Continue to execution mode selection**

### New Cycle (with task file path)

1. **Detect input:** File -> Load directly | Directory -> Load tasks-frontend.md + discover subtasks/
2. **Build order:** Read tasks, check for subtasks (ST-XXX-01, 02...)
3. **Detect UI library mode** (Step 0 above)
4. **Load backend handoff** if `docs/bee:dev-cycle/handoff-frontend.json` exists
5. **Capture and validate custom instructions:** If second argument provided
6. **Initialize state:** Generate cycle_id, create state file, set indices to 0
7. **Display plan:** "Loaded X tasks with Y subtasks. UI mode: {mode}. Backend handoff: {loaded/not found}."
8. **ASK EXECUTION MODE (MANDATORY - AskUserQuestion):**
   - Options: (a) Manual per subtask (b) Manual per task (c) Automatic
   - **Do not skip:** User hints ≠ mode selection. Only explicit a/b/c is valid.
9. **ASK COMMIT TIMING (MANDATORY - AskUserQuestion):**
   - Options: (a) Per subtask (b) Per task (c) At the end
10. **Start:** Display mode + commit timing, proceed to Gate 0

### Resume Cycle (--resume flag)

1. **Find existing state file:** Check `docs/bee:dev-cycle-frontend-vuejs/current-cycle.json`
2. Load state file, validate
3. Display: cycle started, tasks completed/total, current task/subtask/gate, paused reason
4. **Handle paused states:**

| Status | Action |
|--------|--------|
| `paused_for_approval` | Re-present unit checkpoint |
| `paused_for_task_approval` | Re-present task checkpoint |
| `paused` (generic) | Ask user to confirm resume |
| `in_progress` | Resume from current gate |

---

## Step 2-10: Gate Execution (Per Unit)

### Step 2: Gate 0 - Implementation

**REQUIRED SUB-SKILL:** `Skill("bee:dev-implementation")`

Dispatch appropriate Vue.js agent based on task type. Agent follows TDD (RED then GREEN) with frontend-vuejs.md standards.

### Step 3: Gate 1 - DevOps

**REQUIRED SUB-SKILL:** `Skill("bee:dev-devops")`

Dispatch `bee:devops-engineer` for Dockerfile (Nuxt 3 standalone output), docker-compose, Nginx configuration, and .env.example (Nuxt runtimeConfig pattern).

### Step 4: Gate 2 - Accessibility

**REQUIRED SUB-SKILL:** `Skill("bee:dev-frontend-accessibility-vuejs")`

Dispatch `bee:qa-analyst-frontend-vuejs` with `test_mode="accessibility"`. MUST verify:
- 0 WCAG 2.1 AA violations (axe-core scan with @testing-library/vue)
- Keyboard navigation works for all interactive elements
- Screen reader announcements are correct
- Focus management via Vue's nextTick() and Teleport components is proper
- Color contrast ratios meet AA thresholds

### Step 5: Gate 3 - Unit Testing

**REQUIRED SUB-SKILL:** `Skill("bee:dev-unit-testing")`

Dispatch `bee:qa-analyst-frontend-vuejs` with `test_mode="unit"`. MUST verify:
- Coverage >= 85% (Vitest)
- All acceptance criteria have corresponding tests
- Composables, Pinia store actions, and event handlers tested
- createTestingPinia() used for store-dependent component tests
- flushPromises() used for async composable tests

### Step 6: Gate 4 - Visual Testing

**REQUIRED SUB-SKILL:** `Skill("bee:dev-frontend-visual-vuejs")`

Dispatch `bee:qa-analyst-frontend-vuejs` with `test_mode="visual"`. MUST verify:
- All Vue SFC component states have Vitest snapshots (default, hover, active, disabled, error, loading)
- Responsive breakpoints covered (mobile 375px, tablet 768px, desktop 1280px)
- No sindarian-vue component duplication in components/ui/
- Visual regression baseline established

### Step 7: Gate 5 - E2E Testing

**REQUIRED SUB-SKILL:** `Skill("bee:dev-frontend-e2e-vuejs")`

Dispatch `bee:qa-analyst-frontend-vuejs` with `test_mode="e2e"`. MUST verify:
- All user flows tested end-to-end with Playwright
- Cross-browser: Chromium, Firefox, WebKit
- 3x consecutive stable pass (no flakiness)
- Vue Router navigation guards tested
- Pinia store reset between test scenarios

### Step 8: Gate 6 - Performance Testing

**REQUIRED SUB-SKILL:** `Skill("bee:dev-frontend-performance-vuejs")`

Dispatch `bee:qa-analyst-frontend-vuejs` with `test_mode="performance"`. MUST verify:
- LCP (Largest Contentful Paint) < 2.5s
- CLS (Cumulative Layout Shift) < 0.1
- INP (Interaction to Next Paint) < 200ms
- Lighthouse Performance score >= 90
- NuxtImg used for ALL images (no bare `<img>` tags)
- useAsyncData/useLazyFetch used for all page data fetching (not raw fetch())

### Step 9: Gate 7 - Code Review

**REQUIRED SUB-SKILL:** `Skill("bee:requesting-code-review")`

Dispatch all 5 reviewers in parallel (see Gate 7: Code Review Adaptation above).

### Step 10: Gate 8 - Validation

**REQUIRED SUB-SKILL:** `Skill("bee:dev-validation")`

Present implementation summary to user. Require explicit "APPROVED" response.

---

## Execution Report

| Metric | Value |
|--------|-------|
| Duration | Xm Ys |
| Iterations | N |
| Result | PASS/FAIL/PARTIAL |

### Vue.js Frontend-Specific Metrics

| Metric | Value |
|--------|-------|
| UI Library Mode | sindarian-vue / fallback-only |
| Backend Handoff | loaded / not found |
| WCAG Violations | 0 |
| Unit Coverage | XX.X% |
| Visual Snapshots | X/Y passed |
| E2E Stability | 3/3 runs |
| LCP | Xms |
| CLS | X.XX |
| INP | Xms |
| Lighthouse | XX |
| NuxtImg Compliance | YES/NO |
| Reviewers | 5/5 PASS |

---

## Pressure Resistance

**Vue.js-specific pressure scenarios:**

| Pressure Type | Request | Agent Response |
|---------------|---------|----------------|
| **Accessibility** | "Skip accessibility, it's an internal tool" | "FORBIDDEN. Internal tools MUST be accessible. WCAG AA is a legal requirement in many jurisdictions. Gate 2 executes fully." |
| **Browser Coverage** | "Only test Chromium, it's the main browser" | "All 3 browsers (Chromium, Firefox, WebKit) are REQUIRED. Cross-browser issues are the most common production bugs." |
| **Performance** | "Performance will be optimized later" | "Performance thresholds apply NOW. LCP < 2.5s, CLS < 0.1, INP < 200ms, Lighthouse >= 90. useAsyncData and NuxtImg apply NOW." |
| **Visual Tests** | "Vitest snapshots are too brittle to maintain" | "Fix the brittleness (use threshold tolerances or more stable selectors), don't skip regression detection. Gate 4 is MANDATORY." |
| **Design System** | "We'll align with design system later" | "Design system compliance is part of Gate 0. Components MUST use Sindarian Vue (or shadcn-vue fallback) from the start." |
| **Pinia** | "Vuex works fine, we'll migrate later" | "Vuex-to-Pinia migration is a standards gap. Gate 0 implements with Pinia. Vuex usage = FINDING-XXX." |

---

## Common Rationalizations - REJECTED

| Excuse | Reality |
|--------|---------|
| "Backend already tested this endpoint" | Backend tests verify API logic. Frontend tests verify Vue rendering, Pinia state management, user interaction, and accessibility. Different concerns entirely. |
| "Accessibility is optional for MVP" | Accessibility is NEVER optional. WCAG AA compliance is mandatory. Building without it means expensive retrofitting later. |
| "Vitest snapshots are brittle" | Snapshots catch visual regressions that no other test type detects. Fix brittleness with stable slot content and representative store states, don't skip the gate. |
| "E2E tests are slow, unit tests are enough" | Vitest unit tests verify composables in isolation. Playwright E2E tests verify user flows end-to-end. Both are MANDATORY. |
| "Lighthouse score is close enough at 88" | Close enough ≠ passing. Threshold is >= 90. Use NuxtImg, lazy load routes, use useLazyFetch until threshold is met. |
| "Automatic mode means faster" | Automatic mode skips CHECKPOINTS, not GATES. Same quality, less interruption. |
| "Only desktop matters, skip mobile testing" | Responsive design is mandatory. Visual tests MUST cover mobile, tablet, and desktop breakpoints. |
| "Options API works, Composition API migration is optional" | Options API = FINDING-XXX. Composition API with <script setup> is the standard. Not optional. |
| "Pinia is optional, Vuex is still supported" | Vuex usage = mandatory FINDING-XXX. Pinia is the Vue 3 standard state manager. |

---

## Red Flags - STOP

- "Skip accessibility, we'll add aria labels later"
- "Only test happy path in E2E"
- "Performance optimization is a separate ticket"
- "Visual tests will be added when design stabilizes"
- "The designer didn't provide mobile mockups, skip responsive"
- "This browser doesn't matter for our users"
- "It works in Chromium, ship it"
- "Vuex still works, don't migrate to Pinia yet"
- "Options API is fine for this component"
- "useLazyFetch is complicated, use fetch() instead"

If you catch yourself thinking any of those patterns, STOP immediately and return to gate execution.

---

## Incremental Compromise Prevention

**The "just this once" pattern leads to complete gate erosion:**

```text
Day 1: "Skip accessibility just this once" -> Approved (precedent set)
Day 2: "Skip visual tests, we did it last time" -> Approved (precedent extended)
Day 3: "Skip performance, pattern established" -> Approved (gates meaningless)
Day 4: Production incident: inaccessible UI + layout regression + 5s load time + Vuex in Vue 3 codebase
```

**Prevention rules:**
1. **No incremental exceptions** - Each exception becomes the new baseline
2. **Document every pressure** - Log who requested, why, outcome
3. **Escalate patterns** - If same pressure repeats, escalate to team lead
4. **Gates are binary** - Complete or incomplete. No "mostly done".

---
