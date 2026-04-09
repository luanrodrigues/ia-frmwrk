---
name: bee:dev-frontend-performance-vuejs
title: Vue.js frontend development cycle performance testing (Gate 6)
category: development-cycle-frontend-vuejs
tier: 1
when_to_use: |
  Use after E2E testing (Gate 5) is complete in the Vue.js frontend dev cycle.
  MANDATORY for all Vue.js frontend development tasks - ensures performance meets thresholds.
description: |
  Gate 6 of the Vue.js frontend development cycle - ensures Core Web Vitals compliance,
  Lighthouse performance score > 90, and bundle size within budget. Covers Nuxt 3-specific
  optimizations including useAsyncData, useLazyFetch, and NuxtImg.

trigger: |
  - After E2E testing complete (Gate 5)
  - MANDATORY for all Vue.js frontend development tasks
  - Validates performance before code review

NOT_skip_when: |
  - "Performance is fine on my machine" - Users have slower devices.
  - "We'll optimize later" - Performance debt compounds.
  - "It's a small change" - Small changes can cause big regressions.

sequence:
  after: [bee:dev-frontend-e2e-vuejs]
  before: [bee:requesting-code-review]

related:
  complementary: [bee:dev-cycle-frontend-vuejs, bee:dev-frontend-e2e-vuejs, bee:qa-analyst-frontend-vuejs]

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
    - name: "Core Web Vitals Report"
      pattern: "^## Core Web Vitals Report"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: lcp_ms
      type: integer
    - name: cls_score
      type: float
    - name: inp_ms
      type: integer
    - name: lighthouse_score
      type: integer
    - name: bundle_size_change_percent
      type: float
    - name: iterations
      type: integer

verification:
  automated:
    - command: "npx lighthouse http://localhost:3000 --output=json --quiet 2>/dev/null | jq '.categories.performance.score'"
      description: "Lighthouse performance score"
      success_pattern: "0\\.[9-9]"
    - command: "grep -rn 'useLazyFetch\\|useAsyncData\\|useLazyAsyncData' --include='*.vue' --include='*.ts' src/ | wc -l"
      description: "Count async data composables (Nuxt optimizations)"
      success_pattern: "[0-9]+"
  manual:
    - "LCP < 2.5s on all pages"
    - "CLS < 0.1 on all pages"
    - "INP < 200ms on all pages"
    - "Bundle size increase < 10%"
    - "No bare <img> tags (all use <NuxtImg> or <NuxtPicture>)"

examples:
  - name: "Performance tests for dashboard"
    input:
      unit_id: "task-001"
      implementation_files: ["src/pages/dashboard/index.vue"]
    expected_output: |
      ## Performance Testing Summary
      **Status:** PASS
      **LCP:** 1.8s (< 2.5s)
      **CLS:** 0.03 (< 0.1)
      **INP:** 95ms (< 200ms)
      **Lighthouse:** 94 (> 90)
      **Bundle Change:** +3.2% (< 10%)

      ## Core Web Vitals Report
      | Page | LCP | CLS | INP | Status |
      |------|-----|-----|-----|--------|
      | /dashboard | 1.8s | 0.03 | 95ms | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 7 (Code Review): YES
---

# Dev Frontend Performance Testing - Vue.js (Gate 6)

## Overview

Ensure all Vue.js / Nuxt 3 frontend pages meet **Core Web Vitals** thresholds, achieve **Lighthouse Performance > 90**, maintain **bundle size within budget**, and use Nuxt 3 data-fetching composables correctly for optimal performance.

**Core principle:** Performance is a feature. Users on slow devices and connections deserve a fast experience. Performance budgets are enforced, not suggested.

<block_condition>
- LCP > 2.5s on any page = FAIL
- CLS > 0.1 on any page = FAIL
- INP > 200ms on any page = FAIL
- Lighthouse Performance < 90 = FAIL
- Bundle size increase > 10% without justification = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. Vue.js Frontend QA Analyst Agent (performance mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Frontend Vue.js Agent** | Run Lighthouse, measure CWV, analyze bundles, audit components |

---

## Standards Reference

**MANDATORY:** Load testing-performance.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/frontend-vuejs/testing-performance.md
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

## Step 2: Dispatch Vue.js Frontend QA Analyst Agent (Performance Mode)

**⛔ Agent Name Resolution:** MUST resolve `bee:` names to runtime-qualified names before dispatch. See [shared-patterns/shared-orchestrator-principle.md](../shared-patterns/shared-orchestrator-principle.md) → "Agent Runtime Resolution".

```text
Task tool:
  subagent_type: "bee:qa-analyst-frontend-vuejs"
  model: "opus"
  prompt: |
    **MODE:** PERFORMANCE TESTING (Gate 6)

    **Standards:** Load testing-performance.md (frontend-vuejs)

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - Baseline: {performance_baseline or "N/A"}
    - Framework: Vue 3 / Nuxt 3

    **Requirements:**
    1. Measure Core Web Vitals (LCP, CLS, INP) on all affected pages
    2. Run Lighthouse audit (Performance score > 90)
    3. Analyze bundle size change vs baseline
    4. Audit client-side only code (components with <ClientOnly> or .client.vue) - should be < 40% of components
    5. Detect performance anti-patterns (bare <img>, synchronous data fetching on client, blocking watch())
    6. Verify sindarian-vue imports are tree-shakeable

    **Nuxt 3 / Vue-Specific Performance Checks:**
    - useAsyncData() used for server-side data fetching on page components (not client fetch())
    - useLazyFetch() or useLazyAsyncData() used for non-critical data (deferred loading)
    - <NuxtImg> or <NuxtPicture> used for ALL images (never bare <img>)
    - <NuxtImg> has correct sizes, format, and loading="lazy" for below-fold images
    - defineAsyncComponent() used for heavy components not needed on initial render
    - Pinia stores use lazy initialization where appropriate (avoid loading all store data upfront)
    - v-once directive applied to static subtrees that never change
    - v-memo applied to list items with expensive rendering and stable key conditions
    - No synchronous heavy computation in computed() - offload to Web Workers if needed
    - No unnecessary watchers (watch with { immediate: true } on large reactive objects)
    - Nuxt route-level code splitting is active (automatic with pages/ directory)
    - Nuxt payload de-duplication active (useState() for shared SSR state, not duplicated fetch calls)
    - <TransitionGroup> used with key for list animations instead of forcing DOM re-renders

    **Output Sections Required:**
    - ## Performance Testing Summary
    - ## Core Web Vitals Report
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 6 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → Dispatch fix to implementation agent (bee:frontend-engineer-vuejs)
  → Re-run performance tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## Performance Testing Summary
**Status:** {PASS|FAIL}
**LCP:** {value}s (< 2.5s)
**CLS:** {value} (< 0.1)
**INP:** {value}ms (< 200ms)
**Lighthouse:** {score} (> 90)
**Bundle Change:** {+X%} (< 10%)

## Core Web Vitals Report
| Page | LCP | CLS | INP | Status |
|------|-----|-----|-----|--------|
| {page} | {value} | {value} | {value} | {PASS|FAIL} |

## Bundle Analysis
| Metric | Current | Baseline | Change | Status |
|--------|---------|----------|--------|--------|
| Total JS (gzipped) | {size} | {size} | {change}% | {PASS|FAIL} |

## Client Component Audit
| Metric | Value |
|--------|-------|
| Total .vue files | {count} |
| Client-only components (<ClientOnly> or .client.vue) | {count} |
| Client ratio | {percent}% (< 40%) |

## Anti-Pattern Detection
| Pattern | Occurrences | Status |
|---------|-------------|--------|
| Bare <img> (not NuxtImg) | {count} | {PASS|FAIL} |
| Client fetch() for server data | {count} | {PASS|FAIL} |
| Wildcard sindarian-vue imports | {count} | {PASS|FAIL} |
| Blocking watch() on large objects | {count} | {PASS|FAIL} |
| Missing useLazyFetch for non-critical data | {count} | {PASS|FAIL} |

## Handoff to Next Gate
- Ready for Gate 7 (Code Review): {YES|NO}
- Iterations: {count}
```

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations. Gate-specific:

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Works fine on my machine" | Your machine ≠ user's device. Measure objectively. | **Run Lighthouse** |
| "We'll optimize later" | Performance debt compounds. Fix during development. | **Meet thresholds now** |
| "Bundle size doesn't matter" | Mobile 3G users exist. Every KB matters. | **Stay within budget** |
| "Everything needs ClientOnly" | Server-rendered components reduce JS. Audit first. | **Minimize client-only components** |
| "NuxtImg is too complex" | NuxtImg gives free optimization. Always use it. | **Use NuxtImg** |
| "Lighthouse 85 is close enough" | 90 is the threshold. 85 = FAIL. | **Optimize to 90+** |
| "useAsyncData is the same as fetch()" | useAsyncData runs on server, reducing client JS + waterfall. | **Use useAsyncData for page data** |
| "useLazyFetch complicates the code" | Deferred loading prevents blocking the initial render. | **Use useLazyFetch for non-critical data** |
| "v-memo is premature optimization" | v-memo prevents unnecessary re-renders in lists. Apply it. | **Apply v-memo to expensive list items** |

---
