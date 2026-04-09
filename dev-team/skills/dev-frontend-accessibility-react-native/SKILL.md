---
name: bee:dev-frontend-accessibility-react-native
title: React Native frontend development cycle accessibility testing (Gate 1)
category: development-cycle-frontend-react-native
tier: 1
when_to_use: |
  Use after implementation (Gate 0) is complete in the React Native frontend dev cycle.
  MANDATORY for all React Native frontend development tasks - ensures VoiceOver/TalkBack compliance.
description: |
  Gate 1 of the React Native frontend development cycle - ensures all components pass accessibility
  checks with zero violations: correct accessibilityLabel, accessibilityRole, accessibilityHint,
  VoiceOver (iOS) and TalkBack (Android) compatibility, and minimum touch target sizes.

trigger: |
  - After implementation complete (Gate 0)
  - MANDATORY for all React Native frontend development tasks
  - Validates VoiceOver/TalkBack compliance on iOS and Android

NOT_skip_when: |
  - "It's an internal tool" - Mobile accessibility is mandatory for all applications.
  - "The component library handles accessibility" - Library components can be misused.
  - "We'll add accessibility later" - Retrofitting costs 10x more.

sequence:
  after: [bee:dev-implementation]
  before: [bee:dev-unit-testing]

related:
  complementary: [bee:dev-cycle-frontend-react-native, bee:qa-analyst-frontend-react-native]

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
    - name: platform_targets
      type: array
      items: string
      description: "Target platforms: ['ios', 'android'] (default: both)"

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
    - name: touch_target_violations
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "grep -rn 'accessibilityLabel\\|accessibilityRole\\|accessibilityHint' --include='*.tsx' --include='*.jsx' ."
      description: "Accessibility props exist"
      success_pattern: "accessibilityLabel\\|accessibilityRole"
    - command: "grep -rn 'getByRole\\|getByLabelText\\|getByA11yRole' --include='*.test.tsx' --include='*.spec.tsx' ."
      description: "Accessibility selector tests exist"
      success_pattern: "getByRole\\|getByLabelText\\|getByA11yRole"
  manual:
    - "All interactive elements have accessibilityLabel"
    - "All interactive elements have accessibilityRole"
    - "Touch targets are >= 44x44pt (iOS) and >= 48x48dp (Android)"
    - "VoiceOver reading order is logical on iOS"
    - "TalkBack reading order is logical on Android"

examples:
  - name: "Accessibility tests for login screen"
    input:
      unit_id: "task-001"
      implementation_files: ["src/screens/LoginScreen.tsx"]
      language: "typescript"
    expected_output: |
      ## Accessibility Testing Summary
      **Status:** PASS
      **Components Tested:** 1
      **Violations Found:** 0
      **Touch Target Violations:** 0

      ## Violations Report
      | Component | Violations | Touch Targets | Status |
      |-----------|-----------|---------------|--------|
      | LoginScreen | 0 | PASS | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 2 (Unit Testing): YES
---

# Dev Frontend Accessibility Testing - React Native (Gate 1)

## Overview

Ensure all React Native frontend components meet **mobile accessibility standards** through correct use of accessibility props, keyboard/switch control navigation testing, and VoiceOver (iOS) / TalkBack (Android) compatibility.

**Core principle:** Accessibility is not optional. All components MUST be accessible to all users, including those using VoiceOver, TalkBack, switch control, and other assistive technologies.

<block_condition>
- Any accessibilityLabel missing on interactive element = FAIL
- Any accessibilityRole missing on interactive element = FAIL
- Touch target < 44x44pt (iOS) or < 48x48dp (Android) = FAIL
- Missing accessibility tests in RNTL = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. React Native Frontend QA Analyst Agent (accessibility mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Frontend React Native Agent** | Write RNTL accessibility tests, verify props, audit touch targets |

---

## Standards Reference

**MANDATORY:** Load testing-accessibility-rn.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/frontend-react-native/testing-accessibility.md
</fetch_required>

---

## Step 1: Validate Input

```text
REQUIRED INPUT:
- unit_id: [task/subtask being tested]
- implementation_files: [files from Gate 0]
- language: [typescript only]

OPTIONAL INPUT:
- platform_targets: [ios, android] (default: both)

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"

if language != "typescript":
  → STOP and report: "React Native accessibility testing only supported for TypeScript/TSX"
```

## Step 2: Dispatch React Native Frontend QA Analyst Agent (Accessibility Mode)

**⛔ Agent Name Resolution:** MUST resolve `bee:` names to runtime-qualified names before dispatch. See [shared-patterns/shared-orchestrator-principle.md](../shared-patterns/shared-orchestrator-principle.md) → "Agent Runtime Resolution".

```text
Task tool:
  subagent_type: "bee:qa-analyst-frontend-react-native"
  model: "opus"
  prompt: |
    **MODE:** ACCESSIBILITY TESTING (Gate 1)

    **Standards:** Load testing-accessibility.md (frontend-react-native)

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - Language: typescript
    - Framework: React Native (Expo or bare)
    - Platform Targets: {platform_targets or ['ios', 'android']}

    **Requirements:**
    1. Verify accessibilityLabel on ALL interactive elements (Touchable*, Pressable, Button, TextInput)
    2. Verify accessibilityRole on ALL interactive elements (button, link, checkbox, etc.)
    3. Verify accessibilityHint where action outcome is not self-evident
    4. Check accessibilityState for dynamic elements (disabled, checked, selected, expanded)
    5. Verify touch target sizes (>= 44x44pt iOS, >= 48x48dp Android) using hitSlop or minHeight/minWidth
    6. Test with React Native Testing Library (RNTL) using getByRole, getByLabelText, getByA11yRole
    7. Verify logical reading order for VoiceOver and TalkBack
    8. Check importantForAccessibility on decorative elements (set to 'no')
    9. Verify Modal accessible prop and accessibility focus management
    10. Check FlatList/FlashList item accessibilityLabel patterns

    **React Native-Specific Checks:**
    - Pressable / TouchableOpacity have accessibilityLabel (not just visible text)
    - TextInput has accessibilityLabel + accessibilityHint for assistive context
    - Image has accessible={true} with accessibilityLabel, OR accessible={false} for decorative images
    - ScrollView content is accessible with correct reading order
    - Modal uses accessible={true} and dispatches focus to first element on open
    - Animated views that convey state have accessibilityLiveRegion set ('polite' or 'assertive')
    - Platform-specific: iOS accessibilityTraits vs Android accessibilityRole (use accessibilityRole for both)
    - accessibilityElementsHidden used correctly for visually hidden content that should be skipped

    **Output Sections Required:**
    - ## Accessibility Testing Summary
    - ## Violations Report
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 1 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → Dispatch fix to implementation agent (bee:frontend-engineer-react-native or bee:ui-engineer-react-native)
  → Re-run accessibility tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## Accessibility Testing Summary
**Status:** {PASS|FAIL}
**Components Tested:** {count}
**Violations Found:** {count}
**Touch Target Violations:** {count}
**Missing accessibilityLabel:** {count}
**Missing accessibilityRole:** {count}

## Violations Report
| Component | States Scanned | Violations | Touch Targets | Status |
|-----------|---------------|------------|---------------|--------|
| {component} | {states} | {count} | {PASS|FAIL} | {PASS|FAIL} |

## Handoff to Next Gate
- Ready for Gate 2 (Unit Testing): {YES|NO}
- Iterations: {count}
```

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations. Gate-specific:

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "It's an internal tool" | Mobile accessibility is mandatory for all applications. | **Run accessibility tests** |
| "The library handles it" | Components can be misused. RNTL catches misuse. | **Run RNTL accessibility checks** |
| "We'll fix accessibility later" | Retrofitting costs 10x. Fix now. | **Fix violations now** |
| "Only one violation, it's minor" | One violation = FAIL. No exceptions. | **Fix all violations** |
| "Text label is visible, no need for accessibilityLabel" | Screen readers need explicit props. Visible text ≠ accessible. | **Add accessibilityLabel** |
| "Touchable is big enough visually" | Visual size ≠ hit area. Use hitSlop or minHeight/minWidth. | **Verify touch target >= 44x44pt** |
| "VoiceOver works, TalkBack is similar" | iOS and Android accessibility differ. Test both. | **Test VoiceOver AND TalkBack** |
| "Decorative image doesn't need props" | Set accessible={false} explicitly. Omitting leaves it up to OS. | **Set accessible={false} on decorative images** |

---
