---
name: bee:dev-frontend-visual-react-native
title: React Native frontend development cycle visual/snapshot testing (Gate 4)
category: development-cycle-frontend-react-native
tier: 1
when_to_use: |
  Use after unit testing (Gate 3) is complete in the React Native frontend dev cycle.
  MANDATORY for all React Native frontend development tasks - ensures visual consistency across platforms.
description: |
  Gate 4 of the React Native frontend development cycle - ensures all components have Jest snapshot
  tests covering all states, both platforms (iOS and Android), and edge cases using
  React Native Testing Library renders.

trigger: |
  - After unit testing complete (Gate 3)
  - MANDATORY for all React Native frontend development tasks
  - Catches visual regressions before review

skip_when: |
  - "Snapshots are brittle" - Brittle snapshots catch unintended changes.
  - "We test visually on device" - Manual testing doesn't catch regressions.
  - "Only default state matters" - Users see error, loading, and empty states too.

sequence:
  after: [bee:dev-unit-testing]
  before: [bee:dev-frontend-e2e-react-native]

related:
  complementary: [bee:dev-cycle-frontend-react-native, bee:dev-unit-testing, bee:qa-analyst-frontend-react-native]

input_schema:
  required:
    - name: unit_id
      type: string
      description: "Task or subtask identifier"
    - name: implementation_files
      type: array
      items: string
      description: "Files from Gate 0 implementation (.tsx files)"
  optional:
    - name: ux_criteria_path
      type: string
      description: "Path to ux-criteria.md from product-designer"
    - name: gate3_handoff
      type: object
      description: "Full handoff from Gate 3 (unit testing)"

output_schema:
  format: markdown
  required_sections:
    - name: "Visual Testing Summary"
      pattern: "^## Visual Testing Summary"
      required: true
    - name: "Snapshot Coverage"
      pattern: "^## Snapshot Coverage"
      required: true
    - name: "Component Duplication Check"
      pattern: "^## Component Duplication Check"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: components_with_snapshots
      type: integer
    - name: total_snapshots
      type: integer
    - name: snapshot_failures
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "grep -rn 'toMatchSnapshot\\|toMatchInlineSnapshot' --include='*.test.tsx' --include='*.snapshot.test.tsx' ."
      description: "Snapshot tests exist"
      success_pattern: "toMatchSnapshot"
    - command: "find . -name '*.snap' -type f | head -5"
      description: "Snapshot files generated"
      success_pattern: ".snap"
  manual:
    - "All component states have snapshots"
    - "iOS and Android platform snapshots captured"
    - "No sindarian-rn component duplication in components/ui/"

examples:
  - name: "Snapshot tests for transaction card component"
    input:
      unit_id: "task-001"
      implementation_files: ["src/components/TransactionCard.tsx"]
    expected_output: |
      ## Visual Testing Summary
      **Status:** PASS
      **Components with Snapshots:** 1
      **Total Snapshots:** 10
      **Snapshot Failures:** 0

      ## Snapshot Coverage
      | Component | States | Platforms | Edge Cases | Status |
      |-----------|--------|-----------|------------|--------|
      | TransactionCard | 4/4 | iOS + Android | Long text, RTL | PASS |

      ## Component Duplication Check
      | Component in components/ui/ | In sindarian-rn? | Status |
      |-----------------------------|-----------------|--------|
      | _No duplications found_ | - | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 5 (E2E Testing): YES
---

# Dev Frontend Visual Testing - React Native (Gate 4)

## Overview

Ensure all React Native frontend components have **Jest snapshot tests** covering all states, both platforms (iOS and Android), and edge cases. Detect visual regressions before code review.

**Core principle:** If a user can see it, it must have a snapshot. All states, both platforms. Platform differences (platform-specific colors, fonts, iconography) MUST be captured.

<block_condition>
- Missing state snapshots = FAIL
- Snapshot test failures = FAIL
- sindarian-rn component duplicated in components/ui/ = FAIL
- iOS snapshot present but Android snapshot missing (or vice versa) for platform-aware components = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. React Native Frontend QA Analyst Agent (visual mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Frontend React Native Agent** | Write snapshot tests, verify states, check duplication |

---

## Standards Reference

**MANDATORY:** Load testing-visual-rn.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/frontend-react-native/testing-visual.md
</fetch_required>

---

## Step 1: Validate Input

```text
REQUIRED INPUT:
- unit_id: [task/subtask being tested]
- implementation_files: [.tsx files from Gate 0]

OPTIONAL INPUT:
- ux_criteria_path: [path to ux-criteria.md]
- gate3_handoff: [full Gate 3 output]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"
```

## Step 2: Dispatch React Native Frontend QA Analyst Agent (Visual Mode)

**⛔ Agent Name Resolution:** MUST resolve `bee:` names to runtime-qualified names before dispatch. See [shared-patterns/shared-orchestrator-principle.md](../shared-patterns/shared-orchestrator-principle.md) → "Agent Runtime Resolution".

```text
Task tool:
  subagent_type: "bee:qa-analyst-frontend-react-native"
  model: "opus"
  prompt: |
    **MODE:** VISUAL TESTING (Gate 4)

    **Standards:** Load testing-visual.md (frontend-react-native)

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - UX Criteria: {ux_criteria_path or "N/A"}
    - Framework: React Native (Expo or bare)
    - Testing Tool: Jest + React Native Testing Library (RNTL)

    **Requirements:**
    1. Create snapshot tests for all React Native components using Jest + RNTL (render())
    2. Cover all states (Default, Empty, Loading, Error, Success, Disabled)
    3. Add platform-specific snapshots for components that use Platform.select() or Platform.OS
    4. Test edge cases (long text, 0 items, special characters, RTL layout if applicable)
    5. Verify no sindarian-rn component duplication in components/ui/
    6. Use render() from RNTL with appropriate mocks for navigation and native modules

    **React Native-Specific Snapshot Requirements:**
    - Test all prop combinations that produce visually distinct outputs
    - Snapshot conditional rendering branches explicitly (show/hide logic)
    - Snapshot Platform.select() variations: render once with Platform.OS = 'ios', once with 'android'
    - Snapshot StyleSheet variations (pressed state, focused state via accessibility)
    - Verify Animated component initial state is captured correctly (mocked or with runAllTimers)
    - Store-connected components: test with different Zustand state slices (mockStore or manual state injection)
    - Async components: use waitFor + act() before taking snapshot
    - Icon components: mock vector icon libraries to prevent snapshot noise
    - Native modules: mock with jest.mock() to prevent native call errors in snapshot tests
    - Text components with dynamic content: use representative long strings and empty strings

    **Output Sections Required:**
    - ## Visual Testing Summary
    - ## Snapshot Coverage
    - ## Component Duplication Check
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 4 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → If missing snapshots: re-dispatch agent to add missing
  → If duplication found: re-dispatch implementation agent to fix
  → Re-run visual tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## Visual Testing Summary
**Status:** {PASS|FAIL}
**Components with Snapshots:** {count}
**Total Snapshots:** {count}
**Snapshot Failures:** {count}

## Snapshot Coverage
| Component | States | Platforms | Edge Cases | Status |
|-----------|--------|-----------|------------|--------|
| {component} | {X/Y} | {iOS+Android or N/A} | {description} | {PASS|FAIL} |

## Component Duplication Check
| Component in components/ui/ | In sindarian-rn? | Status |
|-----------------------------|-----------------|--------|
| {component} | {Yes|No} | {PASS|FAIL} |

## Handoff to Next Gate
- Ready for Gate 5 (E2E Testing): {YES|NO}
- Iterations: {count}
```

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations. Gate-specific:

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Snapshots are brittle" | Brittle = catches unintended changes. That's the point. | **Write snapshot tests** |
| "We test visually on device" | Manual testing misses regressions. Automated is repeatable. | **Add snapshot tests** |
| "Only default state matters" | Error and loading states are user-facing. | **Test all states** |
| "iOS and Android look the same" | Platform.select() produces different output per platform. | **Add platform snapshots** |
| "This React Native Paper component is better" | sindarian-rn is PRIMARY. Don't duplicate. | **Check sindarian-rn first** |
| "Conditional branches are covered by unit tests" | Unit tests verify logic. Snapshots verify rendered output. | **Snapshot each conditional branch** |
| "Animated initial state is too complex to snapshot" | Mock Animated or use runAllTimers() to capture initial state. | **Snapshot with controlled animation state** |
| "Zustand state is mocked, snapshot is wrong" | Inject realistic state via mockStore or manual Zustand state that represents real usage. | **Snapshot with realistic store state** |
| "Vector icons cause snapshot noise" | Mock icon libraries in Jest setup to get stable snapshots. | **Mock icon libraries** |

---
