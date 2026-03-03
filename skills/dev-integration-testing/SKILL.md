---
name: bee:dev-integration-testing
title: Development cycle integration testing (Gate 6)
category: development-cycle
tier: 1
when_to_use: |
  Use after property-based testing (Gate 5) is complete.
  MANDATORY for all development tasks - verifies real service integration.
description: |
  Gate 6 of development cycle - ensures integration tests pass for all
  external dependency interactions using real containers via Docker Compose + RefreshDatabase.

trigger: |
  - After property-based testing complete (Gate 5)
  - MANDATORY for all development tasks
  - Verifies real service integration with Docker Compose + RefreshDatabase

NOT_skip_when: |
  - "Unit tests cover it" - Unit tests mock. Integration tests verify real behavior.
  - "No time for integration tests" - Integration bugs cost 10x more in production.
  - "CI doesn't support Docker" - Fix CI. Docker is baseline infrastructure.

sequence:
  after: [bee:dev-property-testing]
  before: [bee:dev-chaos-testing]

related:
  complementary: [bee:dev-cycle, bee:dev-testing, bee:qa-analyst]

input_schema:
  required:
    - name: unit_id
      type: string
      description: "Task or subtask identifier"
    - name: integration_scenarios
      type: array
      items: string
      description: "Integration scenarios to test"
    - name: external_dependencies
      type: array
      items: string
      description: "External services (postgres, redis, rabbitmq, etc.)"
    - name: language
      type: string
      enum: [php, typescript]
      description: "Programming language"
  optional:
    - name: gate3_handoff
      type: object
      description: "Full handoff from Gate 3 (unit testing)"
    - name: implementation_files
      type: array
      items: string
      description: "Files from Gate 0 implementation"

output_schema:
  format: markdown
  required_sections:
    - name: "Integration Testing Summary"
      pattern: "^## Integration Testing Summary"
      required: true
    - name: "Scenario Coverage"
      pattern: "^## Scenario Coverage"
      required: true
    - name: "Quality Gate Results"
      pattern: "^## Quality Gate Results"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL, SKIP]
    - name: scenarios_tested
      type: integer
    - name: tests_written
      type: integer
    - name: tests_passed
      type: integer
    - name: tests_failed
      type: integer
    - name: flaky_tests_detected
      type: integer
    - name: iterations
      type: integer

verification:
  automated:
    - command: "php artisan test --group=integration 2>&1 | tail -20"
      description: "Integration tests pass"
      success_pattern: "PASS"
  manual:
    - "All integration scenarios have at least one test"
    - "No flaky tests (run 3x, all pass)"
    - "All containers properly cleaned up"

examples:
  - name: "Integration tests for user repository"
    input:
      unit_id: "task-001"
      integration_scenarios: ["Create user in DB", "Find user by email", "Update user"]
      external_dependencies: ["postgres"]
      language: "go"
    expected_output: |
      ## Integration Testing Summary
      **Status:** PASS
      **Scenarios:** 3 tested
      **Tests:** 5 passed, 0 failed

      ## Scenario Coverage
      | Scenario | Test File | Tests | Status |
      |----------|-----------|-------|--------|
      | Create user in DB | tests/Feature/UserIntegrationTest.php | 2 | PASS |
      | Find user by email | tests/Feature/UserIntegrationTest.php | 2 | PASS |
      | Update user | tests/Feature/UserIntegrationTest.php | 1 | PASS |

      ## Quality Gate Results
      | Check | Status |
      |-------|--------|
      | @group integration | PASS |
      | No hardcoded ports | PASS |
      | Docker Compose + RefreshDatabase | PASS |
      | RefreshDatabase trait | PASS |

      ## Handoff to Next Gate
      - Ready for Gate 7 (Chaos Testing): YES
---

# Dev Integration Testing (Gate 6)

## Overview

Ensure every integration scenario has at least one **integration test** proving real external dependencies work correctly. Use Docker Compose + RefreshDatabase for all external services.

**Core principle:** Unit tests mock dependencies, integration tests verify real behavior. Both are required.

<block_condition>
- Any integration scenario without test = FAIL
- Any test using production services = FAIL
- Any test with hardcoded ports = FAIL
- Any flaky test (fails on retry) = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. QA Analyst Agent (integration mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather scenarios, check if needed, dispatch agent, validate output |
| **QA Analyst Agent** | Write tests, run coverage, verify quality gates |

---

## Step 0: Detect External Dependencies (Auto-Detection)

**MANDATORY:** When `external_dependencies` is empty or not provided, scan the codebase to detect them automatically before validation.

```text
if external_dependencies is empty or not provided:

  detected_dependencies = []

  1. Scan docker-compose.yml / docker-compose.yaml for service images:
     - Grep tool: pattern "postgres" in docker-compose* files → add "postgres"
     - Grep tool: pattern "mongo" in docker-compose* files → add "mongodb"
     - Grep tool: pattern "valkey" in docker-compose* files → add "valkey"
     - Grep tool: pattern "redis" in docker-compose* files → add "redis"
     - Grep tool: pattern "rabbitmq" in docker-compose* files → add "rabbitmq"

  2. Scan dependency manifests:
     if language == "php":
       - Grep tool: pattern "laravel/framework" in composer.json → add "laravel"
       - Grep tool: pattern "doctrine/dbal" in composer.json → add "postgres"
       - Grep tool: pattern "mongodb/laravel-mongodb" in composer.json → add "mongodb"
       - Grep tool: pattern "predis/predis" in composer.json → add "redis"
       - Grep tool: pattern "vladimir-yuldashev/laravel-queue-rabbitmq" in composer.json → add "rabbitmq"
       - Grep tool: pattern "php-amqplib" in composer.json → add "rabbitmq"

     if language == "typescript":
       - Grep tool: pattern "\"pg\"" in package.json → add "postgres"
       - Grep tool: pattern "@prisma/client" in package.json → add "postgres"
       - Grep tool: pattern "\"mongodb\"" in package.json → add "mongodb"
       - Grep tool: pattern "\"mongoose\"" in package.json → add "mongodb"
       - Grep tool: pattern "\"redis\"" in package.json → add "redis"
       - Grep tool: pattern "\"ioredis\"" in package.json → add "redis"
       - Grep tool: pattern "@valkey" in package.json → add "valkey"
       - Grep tool: pattern "\"amqplib\"" in package.json → add "rabbitmq"
       - Grep tool: pattern "amqp-connection-manager" in package.json → add "rabbitmq"

  3. Deduplicate detected_dependencies
  4. Set external_dependencies = detected_dependencies

  Log: "Auto-detected external dependencies: [detected_dependencies]"
```

<auto_detect_reason>
PM team task files often omit external_dependencies. If the codebase uses postgres, mongodb, valkey, or rabbitmq, these are external dependencies that MUST have integration tests. Auto-detection prevents silent skips.
</auto_detect_reason>

---

## Step 1: Validate Input

```text
REQUIRED INPUT (from bee:dev-cycle orchestrator):
<verify_before_proceed>
- unit_id exists
- language is valid (php|typescript)
</verify_before_proceed>

OPTIONAL INPUT (determines if Gate 6 runs or skips):
- integration_scenarios: [list of scenarios] - if provided and non-empty, Gate 6 runs
- external_dependencies: [list of deps] (from input OR auto-detected in Step 0) - if non-empty, Gate 6 runs
- gate3_handoff: [full Gate 3 output]
- implementation_files: [files from Gate 0]

EXECUTION LOGIC:
1. if any REQUIRED input is missing:
   -> STOP and report: "Missing required input: [field]"
   -> Return to orchestrator with error

2. if integration_scenarios is empty AND external_dependencies is empty (AFTER auto-detection in Step 0):
   -> Gate 6 SKIP (document reason: "No integration scenarios or external dependencies found after codebase scan")
   -> Return skip result with status: "skipped"

3. Otherwise:
   -> Gate 6 REQUIRED - proceed to Step 2
```

## Step 2: Check If Integration Tests Needed

**Decision Tree:**

```text
1. Task has external_dependencies list (from input or auto-detected)?
   |
   +-- YES -> Gate 6 REQUIRED
   |
   +-- NO -> Continue to #2

2. Task has integration_scenarios?
   |
   +-- YES -> Gate 6 REQUIRED
   |
   +-- NO -> Continue to #3

3. Task acceptance criteria mention "integration", "database", "queue"?
   |
   +-- YES -> Gate 6 REQUIRED
   |
   +-- NO -> Gate 6 SKIP (with reason)
```

**If SKIP:**
```text
Return:
  status: SKIP
  skip_reason: "No external dependencies (after codebase scan) or integration scenarios identified"
  ready_for_gate7: YES
```

## Step 3: Initialize Testing State

```text
integration_state = {
  unit_id: [from input],
  scenarios: [from integration_scenarios or derived from external_dependencies],
  dependencies: [from external_dependencies],
  verdict: null,
  iterations: 0,
  max_iterations: 3,
  tests_passed: 0,
  tests_failed: 0,
  flaky_detected: 0
}
```

## Step 4: Dispatch QA Analyst Agent (Integration Mode)

<dispatch_required agent="bee:qa-analyst">
Write integration tests for all scenarios using Docker Compose + RefreshDatabase.
</dispatch_required>

```yaml
Task:
  subagent_type: "bee:qa-analyst"
  description: "Integration testing for [unit_id]"
  prompt: |
    **test_mode: integration**

    ## Input Context
    - **Unit ID:** [unit_id]
    - **Language:** [language]

    ## Integration Scenarios to Test
    [list integration_scenarios with IS-1, IS-2, etc.]

    ## External Dependencies
    [list external_dependencies with container requirements]

    ## Standards Reference
    WebFetch: https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/docs/standards/php/testing-integration.md

    Focus on: All sections, especially @group annotation, RefreshDatabase trait, Docker Compose services

    ## Requirements

    ### File Naming
    - Pattern: `tests/Feature/*IntegrationTest.php` or `tests/Integration/*Test.php`
    - PHPUnit group: `@group integration` (MANDATORY in docblock)

    ### Function Naming
    - Pest: `it('should {scenario}', ...)->group('integration')`
    - PHPUnit: `testIntegration{Component}{Scenario}()`
    - Example: `testIntegrationUserRepositoryCreate()`

    ### Container Usage
    - Use Docker Compose for ALL external dependencies
    - Use `RefreshDatabase` trait for database state management
    - Versions MUST match infra/docker-compose
    - Use `setUp()/tearDown()` for cleanup

    ### Quality Rules
    - Use `RefreshDatabase` trait for clean database state
    - No hardcoded ports - use env variables from Docker Compose
    - No production services - all deps containerized
    - Each scenario MUST have at least one test

    ## Required Output Format

    ### Test Files Created
    | File | Tests | Lines |
    |------|-------|-------|
    | [path] | [count] | +N |

    ### Scenario Coverage
    | IS ID | Scenario | Test File | Test Function | Status |
    |-------|----------|-----------|---------------|--------|
    | IS-1 | [scenario text] | [file] | [function] | PASS/FAIL |
    | IS-2 | [scenario text] | [file] | [function] | PASS/FAIL |

    ### Quality Gate Results
    | Check | Status | Evidence |
    |-------|--------|----------|
    | @group integration present | PASS/FAIL | [file count] |
    | No hardcoded ports | PASS/FAIL | [grep result] |
    | Docker Compose + RefreshDatabase used | PASS/FAIL | [imports] |
    | RefreshDatabase trait | PASS/FAIL | [grep result] |
    | Cleanup present | PASS/FAIL | [setUp/tearDown count] |

    ### VERDICT
    **Tests:** [X passed, Y failed]
    **Quality Gate:** PASS / FAIL
    **VERDICT:** PASS / FAIL

    If FAIL:
    - **Gap Analysis:** [what needs more tests or fixes]
    - **Files needing attention:** [list with issues]
```

## Step 5: Parse QA Analyst Output

```text
Parse agent output:

1. Extract scenario coverage from Scenario Coverage table
2. Extract quality gate results
3. Extract verdict

integration_state.tests_passed = [count from output]
integration_state.tests_failed = [count from output]

if verdict == "PASS" and quality_gate == "PASS":
  -> integration_state.verdict = "PASS"
  -> Proceed to Step 7 (Success)

if verdict == "FAIL" or quality_gate == "FAIL":
  -> integration_state.verdict = "FAIL"
  -> integration_state.iterations += 1
  -> if iterations >= max_iterations: Go to Step 8 (Escalate)
  -> Go to Step 6 (Dispatch Fix)
```

## Step 6: Dispatch Fix to Implementation Agent

**Quality gate failed or tests failing -> Return to implementation agent**

```yaml
Task:
  subagent_type: "[implementation_agent from Gate 0]"
  description: "Fix integration test issues for [unit_id]"
  prompt: |
    Integration Test Issues - Fix Required

    ## Current Status
    - **Tests Passed:** [tests_passed]
    - **Tests Failed:** [tests_failed]
    - **Quality Gate:** FAIL
    - **Iteration:** [iterations] of [max_iterations]

    ## Issues Found (from QA)
    [paste gap analysis from QA output]

    ## Files Needing Attention
    [paste files list from QA output]

    ## Requirements
    1. Fix the identified issues
    2. Ensure all containers use Docker Compose + RefreshDatabase
    3. Ensure RefreshDatabase trait is used in integration tests
    4. Add missing setUp()/tearDown() calls
    5. Replace hardcoded ports with dynamic ports

    ## Required Output
    - Issues fixed: [list]
    - Files modified: [list]
```

After fix -> Go back to Step 4 (Re-dispatch QA Analyst)

## Step 7: Prepare Success Output

```text
Generate skill output:

## Integration Testing Summary
**Status:** PASS
**Unit ID:** [unit_id]
**Iterations:** [integration_state.iterations]

## Scenario Coverage
| IS ID | Scenario | Test | Status |
|-------|----------|------|--------|
[from integration_state]

**Scenarios Covered:** [X]/[Y] (100%)

## Quality Gate Results
| Check | Status |
|-------|--------|
| @group integration | PASS |
| No hardcoded ports | PASS |
| Docker Compose + RefreshDatabase | PASS |
| RefreshDatabase trait | PASS |
| Cleanup present | PASS |
| No flaky tests | PASS |

## Handoff to Next Gate
- Integration testing status: COMPLETE
- Tests passed: [tests_passed]
- Tests failed: 0
- Flaky tests: 0
- Ready for Gate 7 (Chaos Testing): YES
```

## Step 8: Escalate - Max Iterations Reached

```text
Generate skill output:

## Integration Testing Summary
**Status:** FAIL
**Unit ID:** [unit_id]
**Iterations:** [max_iterations] (MAX REACHED)

## Gap Analysis
[from last QA output]

## Files Still Needing Fixes
[from last QA output]

## Handoff to Next Gate
- Integration testing status: FAILED
- Ready for Gate 4: NO
- **Action Required:** User must manually fix integration tests

ESCALATION: Max iterations (3) reached. Integration tests still failing.
User intervention required.
```

---

## Pressure Resistance

See [shared-patterns/shared-pressure-resistance.md](../shared-patterns/shared-pressure-resistance.md) for universal pressure scenarios.

| User Says | Your Response |
|-----------|---------------|
| "Unit tests cover this" | "Unit tests mock dependencies. Integration tests verify real behavior. Both required." |
| "Docker Compose is too slow" | "Correctness > speed. Real dependencies catch real bugs." |
| "CI doesn't have Docker" | "Docker is baseline infrastructure. Fix CI before skipping integration tests." |
| "Skip integration, deadline" | "Integration bugs cost 10x more in production. Testing is non-negotiable." |

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations.

### Gate 6-Specific Anti-Rationalizations

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Database already tested in unit tests" | Unit tests use mocks, not real DB | **Write integration tests** |
| "Docker Compose setup is complex" | Complexity is one-time. Bugs are recurring. | **Use Docker Compose + RefreshDatabase** |
| "Integration tests are flaky" | Flaky = poorly written. Fix isolation. | **Fix the tests** |
| "No external dependencies" | Check task requirements. Often implicit. | **Verify with decision tree** |
| "Parallel tests make CI faster" | Faster but flaky without proper isolation. | **Use RefreshDatabase for isolation** |
| "Hardcoded port works locally" | Fails in CI when port is taken. | **Use dynamic ports** |
| "Production DB is more realistic" | Production DB is dangerous and unreliable for tests. | **Use Docker Compose + RefreshDatabase** |

---

## Execution Report Format

```markdown
## Integration Testing Summary
**Status:** [PASS|FAIL|SKIP]
**Unit ID:** [unit_id]
**Duration:** [Xm Ys]
**Iterations:** [N]

## Scenario Coverage
| IS ID | Scenario | Test | Status |
|-------|----------|------|--------|
| IS-1 | [text] | [test] | PASS/FAIL |

**Scenarios Covered:** [X/Y]

## Quality Gate Results
| Check | Status |
|-------|--------|
| @group integration | PASS/FAIL |
| No hardcoded ports | PASS/FAIL |
| Docker Compose + RefreshDatabase | PASS/FAIL |
| RefreshDatabase trait | PASS/FAIL |
| Cleanup present | PASS/FAIL |
| No flaky tests | PASS/FAIL |

## Handoff to Next Gate
- Integration testing status: [COMPLETE|FAILED|SKIPPED]
- Ready for Gate 7: [YES|NO]
```

---

## Skip Conditions (Documented)

**When Gate 6 can be skipped (MUST document reason):**

| Condition | Skip Reason |
|-----------|-------------|
| No external dependencies | "Task has no database, API, or queue interactions" |
| Pure business logic | "Task is pure function/logic with no I/O" |
| Library/utility code | "Task is internal utility with no external calls" |
| Already covered | "Integration tests exist and pass (verified)" |

**When Gate 6 CANNOT be skipped:**

| Condition | Why Required |
|-----------|--------------|
| Task touches database | Database queries need real verification |
| Task calls external APIs | HTTP behavior varies from mocks |
| Task uses message queues | Pub/sub requires real broker testing |
| Task has transactions | ACID guarantees need real DB |
| Task has migrations | Schema changes need integration verification |
