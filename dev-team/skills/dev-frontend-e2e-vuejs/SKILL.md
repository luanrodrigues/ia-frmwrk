---
name: bee:dev-frontend-e2e-vuejs
title: Vue.js frontend development cycle E2E testing (Gate 5)
category: development-cycle-frontend-vuejs
tier: 1
when_to_use: |
  Use after visual testing (Gate 4) is complete in the Vue.js frontend dev cycle.
  MANDATORY for all Vue.js frontend development tasks - validates complete user flows.
description: |
  Gate 5 of the Vue.js frontend development cycle - ensures all user flows from
  product-designer have passing E2E tests with Playwright across browsers.

trigger: |
  - After visual testing complete (Gate 4)
  - MANDATORY for all Vue.js frontend development tasks
  - Validates user flows end-to-end

NOT_skip_when: |
  - "Unit tests cover the flow" - Unit tests don't test real browser + API interaction.
  - "We only need Chromium" - Users use Firefox and Safari too.
  - "Happy path is enough" - Error handling MUST be tested.

sequence:
  after: [bee:dev-frontend-visual-vuejs]
  before: [bee:dev-frontend-performance-vuejs]

related:
  complementary: [bee:dev-cycle-frontend-vuejs, bee:dev-frontend-visual-vuejs, bee:qa-analyst-frontend-vuejs]

input_schema:
  required:
    - name: unit_id
      type: string
      description: "Task or subtask identifier"
    - name: implementation_files
      type: array
      items: string
      description: "Files from Gate 0 implementation"
  optional:
    - name: user_flows_path
      type: string
      description: "Path to user-flows.md from product-designer"
    - name: backend_handoff
      type: object
      description: "Backend endpoints and contracts from backend dev cycle"
    - name: gate4_handoff
      type: object
      description: "Full handoff from Gate 4 (visual testing)"

output_schema:
  format: markdown
  required_sections:
    - name: "E2E Testing Summary"
      pattern: "^## E2E Testing Summary"
      required: true
    - name: "Flow Coverage"
      pattern: "^## Flow Coverage"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: flows_tested
      type: integer
    - name: happy_path_tests
      type: integer
    - name: error_path_tests
      type: integer
    - name: browsers_passed
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "grep -rn 'test(' --include='*.spec.ts' --include='*.e2e.ts' ."
      description: "Playwright tests exist"
      success_pattern: "test("
    - command: "grep -rn 'getByRole\\|getByTestId\\|getByLabel' --include='*.spec.ts' ."
      description: "Semantic selectors used"
      success_pattern: "getByRole\\|getByTestId\\|getByLabel"
  manual:
    - "All user flows from product-designer have E2E tests"
    - "Error paths tested (API 500, timeout, validation)"
    - "Tests pass on Chromium, Firefox, and WebKit"
    - "Responsive viewports covered"
    - "3 consecutive passes without flaky failures"

examples:
  - name: "E2E tests for transaction flow"
    input:
      unit_id: "task-001"
      implementation_files: ["src/pages/transactions/index.vue"]
      user_flows_path: "docs/pre-dev/transactions/user-flows.md"
    expected_output: |
      ## E2E Testing Summary
      **Status:** PASS
      **Flows Tested:** 3/3
      **Happy Path Tests:** 3
      **Error Path Tests:** 6
      **Browsers Passed:** 3/3

      ## Flow Coverage
      | User Flow | Happy Path | Error Paths | Browsers | Status |
      |-----------|------------|-------------|----------|--------|
      | Create Transaction | PASS | API 500, Validation | 3/3 | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 6 (Performance Testing): YES
---

# Dev Frontend E2E Testing - Vue.js (Gate 5)

## Overview

Ensure all user flows from `bee:product-designer` have passing **Playwright E2E tests** across Chromium, Firefox, and WebKit with responsive viewport coverage.

**Core principle:** If the product-designer defined a user flow, it must have an E2E test. If the user can encounter an error, it must be tested.

<block_condition>
- Untested user flow = FAIL
- No error path tests = FAIL
- Fails on any browser = FAIL
- Flaky tests (fail on consecutive runs) = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. Vue.js Frontend QA Analyst Agent (e2e mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Frontend Vue.js Agent** | Write Playwright tests, run cross-browser, verify flows |

---

## Standards Reference

**MANDATORY:** Load testing-e2e.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/frontend-vuejs/testing-e2e.md
</fetch_required>

---

## Step 1: Validate Input

```text
REQUIRED INPUT:
- unit_id: [task/subtask being tested]
- implementation_files: [files from Gate 0]

OPTIONAL INPUT:
- user_flows_path: [path to user-flows.md]
- backend_handoff: [endpoints, contracts from backend cycle]
- gate4_handoff: [full Gate 4 output]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"

if user_flows_path provided:
  → Load user flows as E2E test scenarios
  → All flows MUST be covered

if backend_handoff provided:
  → Verify E2E tests exercise backend endpoints
  → Verify request payloads match contracts
```

## Step 2: Dispatch Vue.js Frontend QA Analyst Agent (E2E Mode)

**⛔ Agent Name Resolution:** MUST resolve `bee:` names to runtime-qualified names before dispatch. See [shared-patterns/shared-orchestrator-principle.md](../shared-patterns/shared-orchestrator-principle.md) → "Agent Runtime Resolution".

```text
Task tool:
  subagent_type: "bee:qa-analyst-frontend-vuejs"
  model: "opus"
  prompt: |
    **MODE:** E2E TESTING (Gate 5)

    **Standards:** Load testing-e2e.md (frontend-vuejs)

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - User Flows: {user_flows_path or "N/A"}
    - Backend Handoff: {backend_handoff or "N/A"}
    - Framework: Vue 3 / Nuxt 3

    **Requirements:**
    1. Create Playwright tests for all user flows
    2. Test happy path + error paths (API 500, timeout, validation)
    3. Run on Chromium, Firefox, WebKit
    4. Test responsive viewports (mobile, tablet, desktop)
    5. Use data-testid or semantic role selectors only
    6. Run 3x consecutively to verify no flaky tests

    **Vue/Nuxt-Specific Checks:**
    - Nuxt page transitions do not break test selectors between navigations
    - Pinia store state resets correctly between test scenarios (use store.$reset() in beforeEach)
    - Vue Router navigation guards are tested (auth redirects, role-based access)
    - Async component loading (defineAsyncComponent) resolves before assertions
    - Server-Side Rendering (SSR) hydration does not cause test timing issues
    - useFetch / useAsyncData composables resolve before interaction assertions
    - NuxtLink navigation uses Playwright's waitForNavigation correctly

    **Output Sections Required:**
    - ## E2E Testing Summary
    - ## Flow Coverage
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 5 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → If flow not covered: re-dispatch agent to add missing tests
  → If browser failure: re-dispatch implementation agent to fix
  → If flaky: re-dispatch agent to stabilize tests
  → Re-run E2E tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## E2E Testing Summary
**Status:** {PASS|FAIL}
**Flows Tested:** {X/Y}
**Happy Path Tests:** {count}
**Error Path Tests:** {count}
**Browsers Passed:** {X/3}
**Consecutive Passes:** {X/3}

## Flow Coverage
| User Flow | Happy Path | Error Paths | Browsers | Viewports | Status |
|-----------|------------|-------------|----------|-----------|--------|
| {flow} | {PASS|FAIL} | {descriptions} | {X/3} | {X/3} | {PASS|FAIL} |

## Backend Handoff Verification
| Endpoint | Method | Contract Verified | Status |
|----------|--------|-------------------|--------|
| {endpoint} | {method} | {fields} | {PASS|FAIL} |

## Handoff to Next Gate
- Ready for Gate 6 (Performance Testing): {YES|NO}
- Iterations: {count}
```

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations. Gate-specific:

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Unit tests cover the flow" | Unit tests don't test real browser interaction. | **Write E2E tests** |
| "Only Chromium matters" | Firefox and Safari have different behavior. | **Test all 3 browsers** |
| "Happy path is enough" | Users encounter errors. Test error handling. | **Add error path tests** |
| "CSS selectors are fine" | CSS changes with refactors. Use semantic selectors. | **Use roles and testids** |
| "Product-designer flows are suggestions" | Flows define acceptance criteria. Cover all. | **Test all flows** |
| "Test is flaky, skip it" | Flaky tests indicate real instability. | **Fix the test** |
| "Pinia store doesn't need reset between tests" | Shared state causes test pollution and order dependency. | **Reset store in beforeEach** |
| "SSR makes E2E too complex" | SSR is the production behavior. Test it accurately. | **Write tests for SSR routes** |

---
