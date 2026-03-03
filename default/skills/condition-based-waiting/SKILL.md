---
name: ring:condition-based-waiting
description: |
  Flaky test fix pattern - replaces arbitrary timeouts with condition polling
  that waits for actual state changes.

trigger: |
  - Tests use setTimeout/sleep with arbitrary values
  - Tests are flaky (pass sometimes, fail under load)
  - Tests timeout when run in parallel
  - Waiting for async operations in tests

skip_when: |
  - Testing actual timing behavior (debounce, throttle) → timeout is correct
  - Synchronous tests → no waiting needed
---

# Condition-Based Waiting

## Overview

Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load or in CI.

**Core principle:** Wait for the actual condition you care about, not a guess about how long it takes.

## When to Use

**Decision flow:** Test uses setTimeout/sleep? → Testing actual timing behavior? → (yes: document WHY timeout needed) | (no: **use condition-based waiting**)

**Use when:** Arbitrary delays (`setTimeout`, `sleep`) | Flaky tests (pass sometimes, fail under load) | Timeouts in parallel runs | Async operation waits

**Don't use when:** Testing actual timing behavior (debounce, throttle) - document WHY if using arbitrary timeout

## Core Pattern

```typescript
// ❌ BEFORE: Guessing at timing
await new Promise(r => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// ✅ AFTER: Waiting for condition
await waitFor(() => getResult() !== undefined);
const result = getResult();
expect(result).toBeDefined();
```

## Quick Patterns

| Scenario | Pattern |
|----------|---------|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| Wait for state | `waitFor(() => machine.state === 'ready')` |
| Wait for count | `waitFor(() => items.length >= 5)` |
| Wait for file | `waitFor(() => fs.existsSync(path))` |
| Complex condition | `waitFor(() => obj.ready && obj.value > 10)` |

## Implementation

**Generic polling:** `waitFor(condition, description, timeoutMs=5000)` - poll every 10ms, throw on timeout with clear message. See @example.ts for domain-specific helpers (`waitForEvent`, `waitForEventCount`, `waitForEventMatch`).

## Common Mistakes

| ❌ Bad | ✅ Fix |
|--------|--------|
| Polling too fast (`setTimeout(check, 1)`) | Poll every 10ms |
| No timeout (loop forever) | Always include timeout with clear error |
| Stale data (cache before loop) | Call getter inside loop for fresh data |

## When Arbitrary Timeout IS Correct

`await waitForEvent(...); await setTimeout(200)` - OK when: (1) First wait for triggering condition (2) Based on known timing, not guessing (3) Comment explaining WHY (e.g., "200ms = 2 ticks at 100ms intervals")

## Real-World Impact

Fixed 15 flaky tests across 3 files: 60% → 100% pass rate, 40% faster execution, zero race conditions.

## Blocker Criteria

STOP and report if:

| Decision Type | Blocker Condition | Required Action |
|---|---|---|
| Timing behavior | Test is intentionally testing timing (debounce, throttle) | STOP and document WHY timeout is correct |
| Condition identification | Cannot determine what condition to wait for | STOP and analyze expected state change |
| Timeout configuration | No maximum timeout defined for wait loop | STOP and add timeout with clear error message |
| Polling interval | Polling faster than 10ms without justification | STOP and adjust to 10ms minimum |

### Cannot Be Overridden

The following requirements CANNOT be waived:
- Wait loops MUST have maximum timeout - infinite loops are FORBIDDEN
- Polling interval MUST NOT be less than 10ms without documented justification
- Condition function MUST call getter inside loop for fresh data - stale data caching is FORBIDDEN
- Arbitrary timeouts MUST have documented reasoning if used alongside condition-based waiting
- Timeout error messages MUST describe what condition was being waited for

## Severity Calibration

| Severity | Condition | Required Action |
|---|---|---|
| CRITICAL | Wait loop without timeout (potential infinite loop) | MUST add timeout immediately |
| CRITICAL | Polling at 1ms intervals (CPU thrashing) | MUST increase to minimum 10ms |
| HIGH | Stale data - condition checked against cached value | MUST move getter call inside loop |
| HIGH | Arbitrary timeout without condition-based wait first | MUST add condition wait before timeout |
| MEDIUM | Timeout error message lacks context | Should add descriptive failure message |
| LOW | Polling interval could be optimized | Fix in next iteration |

## Pressure Resistance

| User Says | Your Response |
|---|---|
| "Just increase the timeout, the test is flaky" | "Increasing timeouts masks race conditions. MUST identify actual condition to wait for instead." |
| "Adding a small sleep is simpler" | "Arbitrary sleeps cause flaky tests. MUST wait for the actual state change condition." |
| "The 10ms polling is too slow" | "Polling faster than 10ms risks CPU thrashing. MUST justify with documented performance requirement." |
| "We don't need a timeout, it will always complete" | "CANNOT have wait loops without timeout. Infinite loops are FORBIDDEN - add max timeout." |

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|---|---|---|
| "A small sleep is good enough for this test" | Arbitrary delays cause flaky tests under load | **MUST use condition-based waiting** |
| "Polling every 1ms will be faster" | CPU thrashing harms overall test performance | **MUST use minimum 10ms interval** |
| "This will always complete quickly" | Assumptions about timing fail in CI/parallel runs | **MUST add timeout with error message** |
| "The timeout handles the failure case" | Timeout masks root cause; condition reveals intent | **MUST wait for condition, timeout is safety net** |
| "Test is testing timing, so timeout is fine" | Timing tests still need documented justification | **MUST document WHY timeout is correct** |
