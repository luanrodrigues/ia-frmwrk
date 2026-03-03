---
name: bee:dev-fuzz-testing
title: Development cycle fuzz testing (Gate 4)
category: development-cycle
tier: 1
when_to_use: |
  Use after unit testing (Gate 3) is complete.
  MANDATORY for all development tasks - discovers edge cases and crashes.
description: |
  Gate 4 of development cycle - ensures fuzz tests exist with proper seed corpus
  to discover edge cases, crashes, and unexpected input handling.

trigger: |
  - After unit testing complete (Gate 3)
  - MANDATORY for all development tasks
  - Discovers crashes and edge cases via random input generation

NOT_skip_when: |
  - "Unit tests cover edge cases" - Fuzz tests find cases you didn't think of.
  - "No time for fuzz testing" - Fuzz tests catch crashes before production.
  - "Code is simple" - Simple code can still crash on unexpected input.

sequence:
  after: [bee:dev-unit-testing]
  before: [bee:dev-property-testing]

related:
  complementary: [bee:dev-cycle, bee:dev-unit-testing, bee:qa-analyst]

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
      enum: [php]
      description: "Programming language (PHP mutation testing with Infection)"
  optional:
    - name: gate3_handoff
      type: object
      description: "Full handoff from Gate 3 (unit testing)"

output_schema:
  format: markdown
  required_sections:
    - name: "Fuzz Testing Summary"
      pattern: "^## Fuzz Testing Summary"
      required: true
    - name: "Corpus Report"
      pattern: "^## Corpus Report"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: fuzz_functions
      type: integer
    - name: corpus_entries
      type: integer
    - name: crashes_found
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "./vendor/bin/infection --dry-run 2>&1 | grep -c 'Mutant'"
      description: "Infection mutation testing configured"
      success_pattern: "[1-9]"
    - command: "test -f infection.json5 || test -f infection.json"
      description: "Infection config exists"
      success_pattern: "exit 0"
  manual:
    - "Infection config covers critical source directories"
    - "Mutation Score Indicator (MSI) meets threshold"
    - "No escaped mutants in critical code paths"

examples:
  - name: "Mutation testing for parser"
    input:
      unit_id: "task-001"
      implementation_files: ["app/Services/JsonParserService.php"]
      language: "php"
    expected_output: |
      ## Mutation Testing Summary
      **Status:** PASS
      **Mutants Generated:** 24
      **Mutants Killed:** 22
      **MSI (Mutation Score Indicator):** 91.7%

      ## Mutation Report
      | Source Directory | Mutants | Killed | Escaped | MSI |
      |-----------------|---------|--------|---------|-----|
      | app/Services | 24 | 22 | 2 | 91.7% |

      ## Handoff to Next Gate
      - Ready for Gate 5 (Property Testing): YES
---

# Dev Fuzz Testing (Gate 4)

## Overview

Ensure critical parsing and input handling code has **mutation tests** (via Infection) to discover weaknesses in test suites through code mutation.

**Core principle:** Mutation testing finds weaknesses in your tests that traditional coverage metrics miss. They're mandatory for all code that handles external input.

<block_condition>
- No Infection config = FAIL
- MSI (Mutation Score Indicator) < 80% = FAIL
- Escaped mutants in critical paths = FAIL (add tests and re-run)
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. QA Analyst Agent (fuzz mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Agent** | Write fuzz tests, generate corpus, run fuzz |

---

## Standards Reference

**MANDATORY:** Load testing-mutation.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/docs/standards/php/testing-mutation.md
</fetch_required>

---

## Step 1: Validate Input

```text
REQUIRED INPUT:
- unit_id: [task/subtask being tested]
- implementation_files: [files from Gate 0]
- language: [php for mutation testing with Infection]

OPTIONAL INPUT:
- gate3_handoff: [full Gate 3 output]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"

if language != "php":
  → STOP and report: "Mutation testing via Infection is supported for PHP only"
```

## Step 2: Dispatch QA Analyst Agent (Fuzz Mode)

```text
Task tool:
  subagent_type: "bee:qa-analyst"
  model: "opus"
  prompt: |
    **MODE:** MUTATION TESTING (Gate 4)

    **Standards:** Load testing-mutation.md

    **Input:**
    - Unit ID: {unit_id}
    - Implementation Files: {implementation_files}
    - Language: {language}

    **Requirements:**
    1. Configure Infection (infection.json5) for source directories
    2. Run `./vendor/bin/infection --min-msi=80 --min-covered-msi=90`
    3. Analyze escaped mutants in critical code paths
    4. Add tests to kill escaped mutants

    **Output Sections Required:**
    - ## Mutation Testing Summary
    - ## Mutation Report
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 4 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → Dispatch fix to implementation agent
  → Re-run mutation tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## Mutation Testing Summary
**Status:** {PASS|FAIL}
**Mutants Generated:** {count}
**Mutants Killed:** {count}
**MSI:** {percentage}%

## Mutation Report
| Source Directory | Mutants | Killed | Escaped | MSI |
|-----------------|---------|--------|---------|-----|
| {directory} | {count} | {count} | {count} | {percentage}% |

## Handoff to Next Gate
- Ready for Gate 5 (Property Testing): {YES|NO}
- Iterations: {count}
```

---

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Unit tests cover edge cases" | You can't test what you don't think of. Mutation testing finds weaknesses. | **Run mutation tests** |
| "Code is too simple for mutation testing" | Simple code can still have untested paths. | **Run mutation tests** |
| "Mutation testing is slow" | Minutes per run. Production bugs from weak tests are slower. | **Run mutation tests** |
| "We have high coverage anyway" | Coverage != quality. Mutation testing verifies test assertions. | **Run mutation tests** |

---
