---
name: ring:defense-in-depth
description: |
  Multi-layer validation pattern - validates data at EVERY layer it passes through
  to make bugs structurally impossible, not just caught.

trigger: |
  - Bug caused by invalid data reaching deep layers
  - Single validation point can be bypassed
  - Need to prevent bug category, not just instance

skip_when: |
  - Validation already exists at all layers → check other issues
  - Simple input validation sufficient → add single check

related:
  complementary: [root-cause-tracing]
---

# Defense-in-Depth Validation

## Overview

When you fix a bug caused by invalid data, adding validation at one place feels sufficient. But that single check can be bypassed by different code paths, refactoring, or mocks.

**Core principle:** Validate at EVERY layer data passes through. Make the bug structurally impossible.

## Why Multiple Layers

Single validation: "We fixed the bug"
Multiple layers: "We made the bug impossible"

Different layers catch different cases:
- Entry validation catches most bugs
- Business logic catches edge cases
- Environment guards prevent context-specific dangers
- Debug logging helps when other layers fail

## The Four Layers

| Layer | Purpose | Example |
|-------|---------|---------|
| **1. Entry Point** | Reject invalid input at API boundary | `if (!workingDir \|\| !existsSync(workingDir)) throw new Error(...)` |
| **2. Business Logic** | Ensure data makes sense for operation | `if (!projectDir) throw new Error('projectDir required')` |
| **3. Environment Guards** | Prevent dangerous ops in contexts | `if (NODE_ENV === 'test' && !path.startsWith(tmpdir())) throw...` |
| **4. Debug Instrumentation** | Capture context for forensics | `logger.debug('About to git init', { directory, cwd, stack })` |

## Applying the Pattern

**Steps:** (1) Trace data flow (origin → error) (2) Map all checkpoints (3) Add validation at each layer (4) Test each layer (try to bypass layer 1, verify layer 2 catches it)

## Example

**Bug:** Empty `projectDir` caused `git init` in source code

**Flow:** Test setup (`''`) → `Project.create(name, '')` → `WorkspaceManager.createWorkspace('')` → `git init` in `process.cwd()`

**Layers added:** L1: `Project.create()` validates not empty/exists/writable | L2: `WorkspaceManager` validates not empty | L3: Refuse git init outside tmpdir in tests | L4: Stack trace logging

**Result:** 1847 tests passed, bug impossible to reproduce

## Key Insight

All four layers necessary - each caught bugs others missed: different code paths bypassed entry validation | mocks bypassed business logic | edge cases needed environment guards | debug logging identified structural misuse.

**Don't stop at one validation point.** Add checks at every layer.

## Blocker Criteria

STOP and report if:

| Decision Type | Blocker Condition | Required Action |
|---|---|---|
| Data flow analysis | Cannot trace data from origin to error point | STOP and map complete data flow first |
| Layer identification | Cannot identify all checkpoint layers | STOP and document entry, business, environment, and debug layers |
| Validation coverage | Single validation point without layer analysis | STOP and identify remaining layers |
| Test verification | Cannot test each layer independently | STOP and design layer isolation tests |

### Cannot Be Overridden

The following requirements CANNOT be waived:
- MUST evaluate all four layers - entry, business logic, environment guards, debug instrumentation
- MUST test each layer independently to prove it catches bypasses of other layers
- MUST trace data flow from origin to error before adding validation
- MUST have environment guards that prevent dangerous operations in test/production contexts
- MUST have debug instrumentation that captures context for forensics even when other layers fail

## Severity Calibration

| Severity | Condition | Required Action |
|---|---|---|
| CRITICAL | Single validation point with no layer analysis | MUST identify and validate all layers |
| CRITICAL | No environment guard for dangerous operations | MUST add context-specific protections |
| HIGH | Missing entry point validation | MUST add validation at API boundary |
| HIGH | No debug logging for validation failures | MUST add forensic instrumentation |
| MEDIUM | Layer cannot be tested independently | Should refactor for testability |
| LOW | Debug logging lacks stack trace | Fix in next iteration |

## Pressure Resistance

| User Says | Your Response |
|---|---|
| "Entry validation is enough, we don't need all layers" | "Single validation can be bypassed. MUST validate at every layer to make bug structurally impossible." |
| "Adding validation everywhere is overkill" | "Each layer catches bugs others miss. All four layers are REQUIRED for defense-in-depth." |
| "Just fix the bug, don't add all this validation" | "Fixing one instance doesn't prevent the category. MUST add multi-layer validation." |
| "We can skip environment guards, it's just internal code" | "Environment guards prevent context-specific dangers. CANNOT skip - test vs production matters." |

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|---|---|---|
| "We already have validation at the entry point" | Entry validation can be bypassed by different code paths | **MUST add validation at all layers** |
| "This is just a simple fix, layers are excessive" | Simple fixes recur; multi-layer prevents the bug category | **MUST implement all four layers** |
| "Mocks bypass this validation anyway" | That's why business logic layer exists - catches mock bypasses | **MUST add business logic validation** |
| "We'll add more validation later" | Later never comes; bugs ship without defense | **MUST add all layers now** |
| "Debug logging is noise" | Debug logging is forensic evidence when layers fail | **MUST add debug instrumentation** |
