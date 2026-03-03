---
name: bee:dev-frontend-e2e-react-native
title: React Native frontend development cycle E2E testing (Gate 5)
category: development-cycle-frontend-react-native
tier: 1
when_to_use: |
  Use after visual testing (Gate 4) is complete in the React Native frontend dev cycle.
  MANDATORY for all React Native frontend development tasks - validates complete user flows on device/simulator.
description: |
  Gate 5 of the React Native frontend development cycle - ensures all user flows from
  product-designer have passing Detox E2E tests on both iOS (simulator) and Android (emulator/device).

trigger: |
  - After visual testing complete (Gate 4)
  - MANDATORY for all React Native frontend development tasks
  - Validates user flows end-to-end on iOS and Android

NOT_skip_when: |
  - "Unit tests cover the flow" - Unit tests don't test real device + native gestures.
  - "We only need iOS" - Android users exist and behavior differs.
  - "Happy path is enough" - Error handling MUST be tested.

sequence:
  after: [bee:dev-frontend-visual-react-native]
  before: [bee:dev-frontend-performance-react-native]

related:
  complementary: [bee:dev-cycle-frontend-react-native, bee:dev-frontend-visual-react-native, bee:qa-analyst-frontend-react-native]

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
    - name: deep_link_schemes
      type: array
      items: string
      description: "Deep link schemes to test (e.g., ['myapp://auth', 'myapp://dashboard'])"

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
    - name: platforms_passed
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "grep -rn 'describe\\|it(' --include='*.e2e.ts' --include='*.e2e.js' ."
      description: "Detox E2E tests exist"
      success_pattern: "describe\\|it("
    - command: "grep -rn 'element(by\\|waitFor\\|expect(' --include='*.e2e.ts' ."
      description: "Detox element queries used"
      success_pattern: "element(by\\|waitFor"
  manual:
    - "All user flows from product-designer have E2E tests"
    - "Error paths tested (API 500, timeout, network loss, validation)"
    - "Tests pass on iOS simulator and Android emulator"
    - "Deep linking tested if applicable"
    - "Native gestures (swipe, pinch, long press) tested where used"
    - "3 consecutive passes without flaky failures"

examples:
  - name: "E2E tests for payment flow"
    input:
      unit_id: "task-001"
      implementation_files: ["src/screens/PaymentScreen.tsx"]
      user_flows_path: "docs/pre-dev/payment/user-flows.md"
    expected_output: |
      ## E2E Testing Summary
      **Status:** PASS
      **Flows Tested:** 3/3
      **Happy Path Tests:** 3
      **Error Path Tests:** 6
      **Platforms Passed:** 2/2 (iOS + Android)

      ## Flow Coverage
      | User Flow | Happy Path | Error Paths | iOS | Android | Status |
      |-----------|------------|-------------|-----|---------|--------|
      | Process Payment | PASS | Network loss, API 500 | PASS | PASS | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 6 (Performance Testing): YES
---

# Dev Frontend E2E Testing - React Native (Gate 5)

## Overview

Ensure all user flows from `bee:product-designer` have passing **Detox E2E tests** on iOS (simulator) and Android (emulator) with coverage for native gestures, deep linking, navigation flows, and error paths.

**Core principle:** If the product-designer defined a user flow, it must have a Detox E2E test. If the user can encounter an error, it must be tested. If the app handles deep links, they must be tested.

<block_condition>
- Untested user flow = FAIL
- No error path tests = FAIL
- Fails on iOS or Android = FAIL
- Flaky tests (fail on consecutive runs) = FAIL
- Untested deep link schemes = FAIL (if deep_link_schemes provided)
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. React Native Frontend QA Analyst Agent (E2E mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Frontend React Native Agent** | Write Detox tests, run on iOS/Android, verify flows |

---

## Standards Reference

**MANDATORY:** Load testing-e2e-rn.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/docs/standards/frontend-react-native/testing-e2e.md
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
- deep_link_schemes: [list of deep link URIs to test]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"

if user_flows_path provided:
  → Load user flows as E2E test scenarios
  → All flows MUST be covered

if backend_handoff provided:
  → Verify E2E tests exercise backend endpoints
  → Verify request payloads match contracts

if deep_link_schemes provided:
  → All listed schemes MUST have E2E tests
```

## Step 2: Dispatch React Native Frontend QA Analyst Agent (E2E Mode)

```text
Task tool:
  subagent_type: "bee:qa-analyst-frontend-react-native"
  model: "opus"
  prompt: |
    **MODE:** E2E TESTING (Gate 5)

    **Standards:** Load testing-e2e.md (frontend-react-native)

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - User Flows: {user_flows_path or "N/A"}
    - Backend Handoff: {backend_handoff or "N/A"}
    - Deep Link Schemes: {deep_link_schemes or "N/A"}
    - Framework: React Native (Expo or bare)
    - E2E Framework: Detox

    **Requirements:**
    1. Create Detox tests for all user flows
    2. Test happy path + error paths (API 500, timeout, network loss, validation errors)
    3. Run on iOS simulator and Android emulator
    4. Test native gestures where used (swipe, long press, pinch, drag)
    5. Use testID or accessibilityLabel selectors only (no brittle XPath)
    6. Run 3x consecutively to verify no flaky tests
    7. Test deep links if deep_link_schemes provided

    **React Native-Specific Checks:**
    - Navigation stack state resets correctly between test scenarios (use device.reloadReactNative() in beforeEach)
    - Async storage and secure storage clear between test suites
    - React Navigation navigation guards are tested (auth redirects, role-based access)
    - Animated transitions complete before element interaction (use waitFor + toBeVisible)
    - Keyboard dismissal behavior tested on both platforms
    - Back button behavior tested (Android hardware back, iOS swipe-back gesture)
    - Permission dialogs handled (camera, location, notifications) via device.disableSynchronization() if needed
    - Offline mode: network request errors when device.setURLBlacklist() or network intercept applied
    - Deep link routing: device.launchApp({ url: 'myapp://path' }) navigates to correct screen
    - Biometric authentication flows: device.setBiometricEnrollment(true) pattern used

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
  → If platform failure: re-dispatch implementation agent to fix platform-specific issue
  → If flaky: re-dispatch agent to stabilize tests (use waitFor + toBeVisible patterns)
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
**Platforms Passed:** {X/2} (iOS + Android)
**Consecutive Passes:** {X/3}

## Flow Coverage
| User Flow | Happy Path | Error Paths | iOS | Android | Gestures | Status |
|-----------|------------|-------------|-----|---------|----------|--------|
| {flow} | {PASS|FAIL} | {descriptions} | {PASS|FAIL} | {PASS|FAIL} | {N/A or PASS|FAIL} | {PASS|FAIL} |

## Deep Link Coverage
| Deep Link Scheme | Screen Navigated | Parameters | Status |
|-----------------|-----------------|------------|--------|
| {scheme} | {screen} | {params} | {PASS|FAIL} |

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
| "Unit tests cover the flow" | Unit tests don't test real device interaction or native gestures. | **Write Detox E2E tests** |
| "Only iOS matters" | Android users exist. Behavior differs significantly. | **Test on iOS AND Android** |
| "Happy path is enough" | Users encounter errors. Test network loss, API 500, timeouts. | **Add error path tests** |
| "testID is optional" | CSS selectors don't exist in RN. testID / accessibilityLabel are the only stable selectors. | **Use testID or accessibilityLabel** |
| "Product-designer flows are suggestions" | Flows define acceptance criteria. Cover all. | **Test all flows** |
| "Test is flaky, skip it" | Flaky tests indicate real instability. Use waitFor + toBeVisible. | **Fix the test** |
| "State doesn't need reset between tests" | Shared state causes test pollution and order dependency. | **Reset in beforeEach** |
| "Deep links are rarely used" | Deep links are entry points. They must work reliably. | **Test all deep link schemes** |
| "Android back button is an edge case" | Android back navigation is a core platform pattern. | **Test back button behavior** |

---
