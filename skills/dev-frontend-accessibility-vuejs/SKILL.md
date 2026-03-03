---
name: bee:dev-frontend-accessibility-vuejs
title: Vue.js frontend development cycle accessibility testing (Gate 2)
category: development-cycle-frontend-vuejs
tier: 1
when_to_use: |
  Use after DevOps setup (Gate 1) is complete in the Vue.js frontend dev cycle.
  MANDATORY for all Vue.js frontend development tasks - ensures WCAG 2.1 AA compliance.
description: |
  Gate 2 of the Vue.js frontend development cycle - ensures all components pass axe-core
  automated accessibility scans with zero WCAG 2.1 AA violations.

trigger: |
  - After DevOps setup complete (Gate 1)
  - MANDATORY for all Vue.js frontend development tasks
  - Validates WCAG 2.1 AA compliance

NOT_skip_when: |
  - "It's an internal tool" - WCAG compliance is mandatory for all applications.
  - "The component library handles accessibility" - Library components can be misused.
  - "We'll add accessibility later" - Retrofitting costs 10x more.

sequence:
  after: [bee:dev-devops]
  before: [bee:dev-unit-testing]

related:
  complementary: [bee:dev-cycle-frontend-vuejs, bee:dev-devops, bee:qa-analyst-frontend-vuejs]

input_schema:
  required:
    - name: unit_id
      type: string
      description: "Task or subtask identifier"
    - name: implementation_files
      type: array
      items: string
      description: "Files from Gate 0 implementation"
    - name: language
      type: string
      enum: [typescript]
      description: "Programming language (TypeScript only)"
  optional:
    - name: gate1_handoff
      type: object
      description: "Full handoff from Gate 1 (DevOps)"

output_schema:
  format: markdown
  required_sections:
    - name: "Accessibility Testing Summary"
      pattern: "^## Accessibility Testing Summary"
      required: true
    - name: "Violations Report"
      pattern: "^## Violations Report"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: components_tested
      type: integer
    - name: violations_found
      type: integer
    - name: keyboard_nav_tests
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "grep -rn 'toHaveNoViolations\\|axe(' --include='*.test.ts' --include='*.spec.ts' ."
      description: "axe-core tests exist"
      success_pattern: "toHaveNoViolations\\|axe("
    - command: "grep -rn 'getByRole\\|getByLabel' --include='*.test.ts' --include='*.spec.ts' ."
      description: "Semantic selector tests exist"
      success_pattern: "getByRole\\|getByLabel"
  manual:
    - "axe-core scans return 0 WCAG AA violations"
    - "Keyboard navigation tests cover all interactive elements"
    - "Focus management tests exist for modals and dialogs"

examples:
  - name: "Accessibility tests for login form"
    input:
      unit_id: "task-001"
      implementation_files: ["src/components/LoginForm.vue"]
      language: "typescript"
    expected_output: |
      ## Accessibility Testing Summary
      **Status:** PASS
      **Components Tested:** 1
      **Violations Found:** 0
      **Keyboard Nav Tests:** 3

      ## Violations Report
      | Component | Violations | Status |
      |-----------|-----------|--------|
      | LoginForm | 0 | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 3 (Unit Testing): YES
---

# Dev Frontend Accessibility Testing - Vue.js (Gate 2)

## Overview

Ensure all Vue.js frontend components meet **WCAG 2.1 AA** accessibility standards through automated axe-core scanning, keyboard navigation testing, and focus management validation.

**Core principle:** Accessibility is not optional. All components MUST be accessible to all users, including those using keyboard navigation, screen readers, and assistive technologies.

<block_condition>
- Any WCAG AA violation = FAIL
- Missing keyboard navigation tests = FAIL
- Missing focus management for modals = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. Vue.js Frontend QA Analyst Agent (accessibility mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Frontend Vue.js Agent** | Run axe-core, write keyboard tests, verify ARIA |

---

## Standards Reference

**MANDATORY:** Load testing-accessibility.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/main/dev-team/docs/standards/frontend-vuejs/testing-accessibility.md
</fetch_required>

---

## Step 1: Validate Input

```text
REQUIRED INPUT:
- unit_id: [task/subtask being tested]
- implementation_files: [files from Gate 0]
- language: [typescript only]

OPTIONAL INPUT:
- gate1_handoff: [full Gate 1 output]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"

if language != "typescript":
  → STOP and report: "Vue.js frontend accessibility testing only supported for TypeScript/Vue"
```

## Step 2: Dispatch Vue.js Frontend QA Analyst Agent (Accessibility Mode)

```text
Task tool:
  subagent_type: "bee:qa-analyst-frontend-vuejs"
  model: "opus"
  prompt: |
    **MODE:** ACCESSIBILITY TESTING (Gate 2)

    **Standards:** Load testing-accessibility.md (frontend-vuejs)

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - Language: typescript
    - Framework: Vue 3 with Composition API

    **Requirements:**
    1. Run axe-core scans on all Vue components (all states: default, loading, error, empty, disabled)
    2. Test keyboard navigation (Tab, Enter, Escape, Arrow keys)
    3. Test focus management (trap, restoration, auto-focus) - use Vue's nextTick() where needed
    4. Verify semantic HTML usage within Vue templates
    5. Check ARIA attributes on dynamic Vue template bindings (v-bind:aria-*, :aria-*)
    6. Verify color contrast
    7. Test with Vue Testing Library (@testing-library/vue) + axe-core

    **Vue-Specific Checks:**
    - Teleport components (modals via <Teleport>) have proper focus trapping
    - v-show vs v-if usage does not create hidden but focusable elements unexpectedly
    - Dynamic :disabled bindings properly prevent interaction
    - Transition/animation does not cause focus loss
    - defineExpose() patterns for ref-based focus management are correctly implemented

    **Output Sections Required:**
    - ## Accessibility Testing Summary
    - ## Violations Report
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 2 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → Dispatch fix to implementation agent (bee:frontend-engineer-vuejs or bee:ui-engineer-vuejs)
  → Re-run accessibility tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## Accessibility Testing Summary
**Status:** {PASS|FAIL}
**Components Tested:** {count}
**Violations Found:** {count}
**Keyboard Nav Tests:** {count}
**Focus Management Tests:** {count}

## Violations Report
| Component | States Scanned | Violations | Status |
|-----------|---------------|------------|--------|
| {component} | {states} | {count} | {PASS|FAIL} |

## Handoff to Next Gate
- Ready for Gate 3 (Unit Testing): {YES|NO}
- Iterations: {count}
```

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations. Gate-specific:

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "It's an internal tool" | WCAG compliance is mandatory for all applications. | **Run accessibility tests** |
| "The library handles it" | Components can be misused. axe-core catches misuse. | **Run axe-core scans** |
| "We'll fix accessibility later" | Retrofitting costs 10x. Fix now. | **Fix violations now** |
| "Only one violation, it's minor" | One violation = FAIL. No exceptions. | **Fix all violations** |
| "Keyboard nav works, I tested manually" | Manual ≠ automated. Tests must be repeatable. | **Write automated tests** |
| "Vue transitions handle focus automatically" | Transitions do not manage focus. Implement explicitly. | **Add focus management tests** |
| "v-show hides it visually, accessibility handled" | v-show keeps element in DOM. axe-core still scans it. | **Use v-if or add aria-hidden** |

---
