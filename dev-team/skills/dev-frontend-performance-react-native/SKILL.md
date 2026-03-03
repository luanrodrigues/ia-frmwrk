---
name: bee:dev-frontend-performance-react-native
title: React Native frontend development cycle performance testing (Gate 6)
category: development-cycle-frontend-react-native
tier: 1
when_to_use: |
  Use after E2E testing (Gate 5) is complete in the React Native frontend dev cycle.
  MANDATORY for all React Native frontend development tasks - ensures performance meets mobile thresholds.
description: |
  Gate 6 of the React Native frontend development cycle - ensures JS bundle size within budget,
  Hermes engine enabled, FlatList/FlashList correctly used, image optimization applied,
  and no unnecessary re-renders detected. Covers React Native-specific optimizations including
  memo, useCallback, useMemo, and FlashList for performant list rendering.

trigger: |
  - After E2E testing complete (Gate 5)
  - MANDATORY for all React Native frontend development tasks
  - Validates performance before code review

NOT_skip_when: |
  - "Performance is fine on my machine/simulator" - Physical devices and low-end Android differ greatly.
  - "We'll optimize later" - Performance debt compounds on mobile.
  - "It's a small change" - Small changes can cause re-render cascades.

sequence:
  after: [bee:dev-frontend-e2e-react-native]
  before: [bee:requesting-code-review]

related:
  complementary: [bee:dev-cycle-frontend-react-native, bee:dev-frontend-e2e-react-native, bee:qa-analyst-frontend-react-native]

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
    - name: performance_baseline
      type: object
      description: "Previous performance metrics for comparison"
    - name: gate5_handoff
      type: object
      description: "Full handoff from Gate 5 (E2E testing)"

output_schema:
  format: markdown
  required_sections:
    - name: "Performance Testing Summary"
      pattern: "^## Performance Testing Summary"
      required: true
    - name: "Bundle Analysis"
      pattern: "^## Bundle Analysis"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: bundle_size_kb
      type: integer
    - name: bundle_size_change_percent
      type: float
    - name: hermes_enabled
      type: boolean
    - name: flashlist_violations
      type: integer
    - name: unnecessary_rerender_count
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "grep -rn 'jsEngine.*hermes\\|\"jsEngine\": \"hermes\"' --include='*.json' --include='*.ts' ."
      description: "Hermes engine enabled"
      success_pattern: "hermes"
    - command: "grep -rn 'FlashList\\|FlatList' --include='*.tsx' --include='*.jsx' . | wc -l"
      description: "List component usage detected"
      success_pattern: "[0-9]+"
    - command: "grep -rn 'React.memo\\|useMemo\\|useCallback' --include='*.tsx' --include='*.ts' . | wc -l"
      description: "Memoization usage detected"
      success_pattern: "[0-9]+"
  manual:
    - "JS bundle size increase < 10% vs baseline"
    - "Hermes enabled in app.json / build.gradle"
    - "All lists with > 10 items use FlashList (not FlatList)"
    - "Image components use react-native-fast-image or Expo Image"
    - "No unnecessary re-renders detected via react-native-performance or Flashlight"
    - "UI thread not blocked during animations"

examples:
  - name: "Performance tests for transaction list screen"
    input:
      unit_id: "task-001"
      implementation_files: ["src/screens/TransactionListScreen.tsx"]
    expected_output: |
      ## Performance Testing Summary
      **Status:** PASS
      **Bundle Change:** +2.8% (< 10%)
      **Hermes:** Enabled
      **FlashList Violations:** 0
      **Unnecessary Re-renders:** 0

      ## Bundle Analysis
      | Metric | Current | Baseline | Change | Status |
      |--------|---------|----------|--------|--------|
      | JS Bundle (gzipped) | 2.1MB | 2.04MB | +2.8% | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 7 (Code Review): YES
---

# Dev Frontend Performance Testing - React Native (Gate 6)

## Overview

Ensure all React Native frontend screens and components meet **mobile performance budgets**: JS bundle within budget, Hermes engine enabled, FlashList used for long lists, images optimized, and UI thread not blocked by unnecessary re-renders.

**Core principle:** Performance on mobile is non-negotiable. Low-end Android devices have 1-2GB RAM. Slow UI thread kills the user experience. Performance budgets are enforced, not suggested.

<block_condition>
- JS bundle size increase > 10% without justification = FAIL
- Hermes not enabled = FAIL
- FlatList used for list with > 10 items (FlashList not used) = FAIL
- Unoptimized images (bare Image without FastImage or Expo Image) for remote URLs = FAIL
- UI thread blocked during scroll/animation = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. React Native Frontend QA Analyst Agent (performance mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Frontend React Native Agent** | Run bundle analysis, audit components, check Hermes, detect re-renders |

---

## Standards Reference

**MANDATORY:** Load testing-performance-rn.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/frontend-react-native/testing-performance.md
</fetch_required>

---

## Step 1: Validate Input

```text
REQUIRED INPUT:
- unit_id: [task/subtask being tested]
- implementation_files: [files from Gate 0]

OPTIONAL INPUT:
- performance_baseline: [previous metrics for comparison]
- gate5_handoff: [full Gate 5 output]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"
```

## Step 2: Dispatch React Native Frontend QA Analyst Agent (Performance Mode)

```text
Task tool:
  subagent_type: "bee:qa-analyst-frontend-react-native"
  model: "opus"
  prompt: |
    **MODE:** PERFORMANCE TESTING (Gate 6)

    **Standards:** Load testing-performance.md (frontend-react-native)

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - Baseline: {performance_baseline or "N/A"}
    - Framework: React Native (Expo or bare)

    **Requirements:**
    1. Analyze JS bundle size change vs baseline (use react-native-bundle-visualizer or metro bundle output)
    2. Verify Hermes engine is enabled (app.json jsEngine: "hermes" or build.gradle setting)
    3. Audit all list components: FlatList with > 10 items MUST be replaced with FlashList
    4. Audit image components: remote URLs MUST use react-native-fast-image or Expo Image
    5. Detect unnecessary re-renders using React.memo, useCallback, useMemo audit
    6. Verify UI thread is not blocked: no heavy computation in render path
    7. Check Reanimated usage for animations (not Animated API for performance-critical animations)
    8. Detect InteractionManager usage for deferred post-animation work

    **React Native-Specific Performance Checks:**
    - FlashList from @shopify/flash-list used for ALL lists with > 10 items (never FlatList)
    - FlashList has correct estimatedItemSize prop set
    - FlatList keyExtractor returns stable unique string keys (not index)
    - React.memo applied to list item components that receive complex props
    - useCallback applied to event handlers passed as props (prevent child re-renders)
    - useMemo applied to expensive computations in render
    - Image components for remote URLs use react-native-fast-image or expo-image (not bare <Image>)
    - Image components have defined width/height to prevent layout shifts
    - InteractionManager.runAfterInteractions() used for heavy work after navigation transitions
    - No synchronous heavy computation in render (move to useMemo or background thread)
    - setNativeDriver: true used for all Animated animations that don't modify layout
    - Reanimated 2/3 used for gesture-driven animations (not Animated for 60fps requirements)
    - No anonymous functions as direct props to pure components
    - Zustand selectors are granular (avoid selecting entire store, select only needed slice)
    - No Redux useSelector selecting entire state object
    - Navigation screen options are stable (not inline object literals causing re-renders)

    **Output Sections Required:**
    - ## Performance Testing Summary
    - ## Bundle Analysis
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 6 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → Dispatch fix to implementation agent (bee:frontend-engineer-react-native)
  → Re-run performance tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## Performance Testing Summary
**Status:** {PASS|FAIL}
**Bundle Change:** {+X%} (< 10%)
**Hermes:** {Enabled|DISABLED - FAIL}
**FlashList Violations:** {count}
**Unnecessary Re-renders:** {count}
**Image Optimization Violations:** {count}

## Bundle Analysis
| Metric | Current | Baseline | Change | Status |
|--------|---------|----------|--------|--------|
| JS Bundle (gzipped) | {size} | {size} | {change}% | {PASS|FAIL} |
| Total Assets | {size} | {size} | {change}% | {PASS|FAIL} |

## List Component Audit
| Screen/Component | List Type | Item Count | Status |
|-----------------|-----------|------------|--------|
| {name} | {FlatList|FlashList} | {count} | {PASS|FAIL} |

## Image Optimization Audit
| Component | Image Type | Library Used | Status |
|-----------|------------|--------------|--------|
| {name} | {remote|local} | {FastImage|ExpoImage|bare Image} | {PASS|FAIL} |

## Re-render Analysis
| Component | Re-render Cause | Fix Applied | Status |
|-----------|-----------------|-------------|--------|
| {name} | {reason} | {memo/useCallback/useMemo} | {PASS|FAIL} |

## Anti-Pattern Detection
| Pattern | Occurrences | Status |
|---------|-------------|--------|
| FlatList with > 10 items (not FlashList) | {count} | {PASS|FAIL} |
| Remote image without FastImage/ExpoImage | {count} | {PASS|FAIL} |
| Animated without setNativeDriver: true | {count} | {PASS|FAIL} |
| Anonymous function as prop to pure component | {count} | {PASS|FAIL} |
| Heavy computation in render (not memoized) | {count} | {PASS|FAIL} |
| Hermes disabled | {Yes|No} | {PASS|FAIL} |

## Handoff to Next Gate
- Ready for Gate 7 (Code Review): {YES|NO}
- Iterations: {count}
```

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations. Gate-specific:

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Works fine on simulator" | Simulators don't reflect low-end Android performance. | **Measure on representative device** |
| "We'll optimize later" | Performance debt compounds. Fix during development. | **Meet thresholds now** |
| "FlatList is fine for 20 items" | FlashList is always faster. 10+ items = FlashList. | **Replace FlatList with FlashList** |
| "Hermes doesn't matter for dev builds" | Hermes is production default. Disable it = production regression. | **Ensure Hermes enabled** |
| "FastImage is complex to set up" | FastImage gives free caching + performance. Always use it for remote URLs. | **Use FastImage or Expo Image** |
| "React.memo is premature optimization" | Without memo, parent re-renders force child re-renders in RN. Apply it. | **Apply React.memo to list items** |
| "useCallback everywhere is verbose" | Without useCallback, handlers cause child re-renders on every render. | **Apply useCallback to stable handlers** |
| "Bundle size doesn't matter" | Large bundles increase launch time, especially on cold start. | **Stay within 10% budget** |
| "Animated API is fine for animations" | Animated runs on JS thread. Reanimated runs on UI thread. Use Reanimated for smooth 60fps. | **Use Reanimated for performance-critical animations** |

---
