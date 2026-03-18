---
name: bee:dev-unit-testing
description: |
  Gate 1 of development cycle - ensures unit test coverage meets threshold (85%+)
  for all acceptance criteria using TDD methodology.

trigger: |
  - After implementation complete (Gate 0)
  - Task has acceptance criteria requiring test coverage
  - Need to verify implementation meets requirements

NOT_skip_when: |
  - "Manual testing validates all criteria" → Manual tests are not executable. Gate 3 requires unit tests.
  - "Integration tests are better" → Gate 3 scope is unit tests only.
  - "Coverage is close to 85%" → Close enough is not passing. Meet exact threshold.

sequence:
  after: [bee:dev-implementation]
  before: [bee:requesting-code-review]

related:
  complementary: [bee:test-driven-development, bee:qa-analyst]

input_schema:
  required:
    - name: unit_id
      type: string
      description: "Task or subtask identifier"
    - name: acceptance_criteria
      type: array
      items: string
      description: "List of acceptance criteria to test"
    - name: implementation_files
      type: array
      items: string
      description: "Files from Gate 0 implementation"
    - name: language
      type: string
      enum: [php, typescript, python]
      description: "Programming language"
  optional:
    - name: coverage_threshold
      type: float
      default: 85.0
      description: "Minimum coverage percentage (cannot be below 85)"
    - name: gate0_handoff
      type: object
      description: "Full handoff from Gate 0"
    - name: existing_tests
      type: array
      items: string
      description: "Existing test files"

output_schema:
  format: markdown
  required_sections:
    - name: "Testing Summary"
      pattern: "^## Testing Summary"
      required: true
    - name: "Coverage Report"
      pattern: "^## Coverage Report"
      required: true
    - name: "Traceability Matrix"
      pattern: "^## Traceability Matrix"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: coverage_actual
      type: float
    - name: coverage_threshold
      type: float
    - name: tests_written
      type: integer
    - name: criteria_covered
      type: string
      description: "X/Y format"
    - name: iterations
      type: integer

verification:
  automated:
    - command: "php artisan test --coverage 2>&1 | grep -E 'Total Coverage'"
      description: "PHP tests pass with coverage"
      success_pattern: "[8-9][0-9]|100"
    - command: "npm test -- --coverage | grep -E 'All files|Statements'"
      description: "TypeScript tests pass with coverage"
      success_pattern: "[8-9][0-9]|100"
  manual:
    - "Every acceptance criterion has at least one test"
    - "No skipped or pending tests"

examples:
  - name: "TDD for auth service"
    input:
      unit_id: "task-001"
      acceptance_criteria: ["User can login with valid credentials", "Invalid password returns error"]
      implementation_files: ["app/Services/AuthService.php"]
      language: "php"
    expected_output: |
      ## Testing Summary
      **Status:** PASS
      **Coverage:** 89.5%

      ## Coverage Report
      | Package | Coverage |
      |---------|----------|
      | app/Services | 89.5% |
      
      ## Traceability Matrix
      | AC | Test | Status |
      |----|------|--------|
      | AC-1 | TestAuthService_Login_ValidCredentials | ✅ |
      | AC-2 | TestAuthService_Login_InvalidPassword | ✅ |
      
      ## Handoff to Next Gate
      - Ready for Gate 2: YES
---

# Dev Unit Testing (Gate 1)

## Overview

Ensure every acceptance criterion has at least one **unit test** proving it works. Follow TDD methodology: RED (failing test) -> GREEN (implementation) -> REFACTOR.

**Core principle:** Untested acceptance criteria are unverified claims. Each criterion MUST map to at least one executable unit test.

<block_condition>
- Coverage below 85% = FAIL
- Any acceptance criterion without test = FAIL
</block_condition>

**Coverage threshold:** 85% minimum (Bee standard). PROJECT_RULES.md can raise, not lower.

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. QA Analyst Agent EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Agent** | Write tests, run coverage, report results |

---

## Step 1: Validate Input

```text
REQUIRED INPUT (from bee:dev-cycle orchestrator):
<verify_before_proceed>
- unit_id exists
- acceptance_criteria is not empty
- implementation_files is not empty
- language is valid (php|typescript|python)
</verify_before_proceed>

```text
- unit_id: [task/subtask being tested]
- acceptance_criteria: [list of ACs to test]
- implementation_files: [files from Gate 0]
- language: [php|typescript|python]

OPTIONAL INPUT:
- coverage_threshold: [default 85.0, cannot be lower]
- gate0_handoff: [full Gate 0 output]
- existing_tests: [existing test files]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"
  → Return to orchestrator with error

if coverage_threshold < 85:
  → STOP and report: "Coverage threshold cannot be below Bee minimum (85%)"
  → Use 85% as threshold
```

## Step 2: Initialize Testing State

```text
testing_state = {
  unit_id: [from input],
  coverage_threshold: max(85, [from input]),
  coverage_actual: null,
  verdict: null,
  iterations: 0,
  max_iterations: 3,
  traceability_matrix: [],
  tests_written: 0
}
```

## Step 3: Dispatch QA Analyst Agent

<dispatch_required agent="bee:qa-analyst">
Write unit tests for all acceptance criteria with 85%+ coverage.
</dispatch_required>

```yaml
Task:
  subagent_type: "bee:qa-analyst"
  description: "Write unit tests for [unit_id]"
  prompt: |
    ⛔ WRITE UNIT TESTS for All Acceptance Criteria

    ## Input Context
    - **Unit ID:** [unit_id]
    - **Language:** [language]
    - **Coverage Threshold:** [coverage_threshold]%

    ## Acceptance Criteria to Test
    [list acceptance_criteria with AC-1, AC-2, etc.]

    ## Implementation Files to Test
    [list implementation_files]

    ## Standards Reference
    For PHP: https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/php.md
    For TS: https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/typescript.md

    Focus on: Testing Patterns section

    ## Requirements

    ### Test Coverage
    - Minimum: [coverage_threshold]% branch coverage
    - Every AC MUST have at least one test
    - Edge cases REQUIRED (null, empty, boundary, error conditions)

    ### Test Naming
    - PHP (Pest): `it('should {scenario}', ...)->group('{unit}')`
    - PHP (PHPUnit): `test{Unit}{Method}{Scenario}()`
    - TS: `describe('{Unit}', () => { it('should {scenario}', ...) })`

    ### Test Structure
    - One behavior per test
    - Arrange-Act-Assert pattern
    - Mock all external dependencies
    - no database/API calls (unit tests only)

    ### Edge Cases Required per AC Type

    <cannot_skip>
    - Minimum 3 edge cases per AC type
    - null, empty, boundary conditions required
    - Error conditions required
    </cannot_skip>

    | AC Type | Required Edge Cases | Minimum |
    |---------|---------------------|---------|
    | Input validation | null, empty, boundary, invalid format | 3+ |
    | CRUD operations | not found, duplicate, concurrent | 3+ |
    | Business logic | zero, negative, overflow, boundary | 3+ |
    | Error handling | timeout, connection failure, retry | 2+ |

    ## Required Output Format

    ### Test Files Created
    | File | Tests | Lines |
    |------|-------|-------|
    | [path] | [count] | +N |

    ### Coverage Report
    **Command:** [coverage command]
    **Result:**
    ```
    [paste actual coverage output]
    ```

    | Package/File | Coverage |
    |--------------|----------|
    | [name] | [X%] |
    | **TOTAL** | **[X%]** |

    ### Traceability Matrix
    | AC ID | Criterion | Test File | Test Function | Status |
    |-------|-----------|-----------|---------------|--------|
    | AC-1 | [criterion text] | [file] | [function] | ✅/❌ |
    | AC-2 | [criterion text] | [file] | [function] | ✅/❌ |

    ### Quality Checks
    | Check | Status |
    |-------|--------|
    | No skipped tests | ✅/❌ |
    | No assertion-less tests | ✅/❌ |
    | Edge cases per AC | ✅/❌ |
    | Test isolation | ✅/❌ |

    ### VERDICT
    **Coverage:** [X%] vs Threshold [Y%]
    **VERDICT:** PASS / FAIL
    
    If FAIL:
    - **Gap Analysis:** [what needs more tests]
    - **Files needing coverage:** [list with line numbers]
```

## Step 4: Parse QA Analyst Output

```text
Parse agent output:

1. Extract coverage percentage from Coverage Report
2. Extract traceability matrix
3. Extract verdict

testing_state.coverage_actual = [extracted coverage]
testing_state.traceability_matrix = [extracted matrix]
testing_state.tests_written = [count from Test Files Created]

if verdict == "PASS" and coverage_actual >= coverage_threshold:
  → testing_state.verdict = "PASS"
  → Proceed to Step 6

if verdict == "FAIL" or coverage_actual < coverage_threshold:
  → testing_state.verdict = "FAIL"
  → testing_state.iterations += 1
  → if iterations >= max_iterations: Go to Step 7 (Escalate)
  → Go to Step 5 (Dispatch Fix)
```

## Step 5: Dispatch Fix to Implementation Agent

**Coverage below threshold → Return to Gate 0 for more tests**

```yaml
Task:
  subagent_type: "[implementation_agent from Gate 0]"  # e.g., "bee:backend-engineer-php"
  description: "Add tests to meet coverage threshold for [unit_id]"
  prompt: |
    ⛔ COVERAGE BELOW THRESHOLD - Add More Tests

    ## Current Status
    - **Coverage Actual:** [coverage_actual]%
    - **Coverage Threshold:** [coverage_threshold]%
    - **Gap:** [threshold - actual]%
    - **Iteration:** [iterations] of [max_iterations]

    ## Gap Analysis (from QA)
    [paste gap analysis from QA output]

    ## Files Needing Coverage
    [paste files list from QA output]

    ## Requirements
    1. Add tests to cover the identified gaps
    2. Focus on edge cases and error paths
    3. Run coverage after each addition
    4. Stop when coverage >= [threshold]%

    ## Required Output
    - Tests added: [list]
    - New coverage: [X%]
    - Coverage command output
```

After fix → Go back to Step 3 (Re-dispatch QA Analyst)

## Step 6: Prepare Success Output

```text
Generate skill output:

## Testing Summary
**Status:** PASS
**Unit ID:** [unit_id]
**Iterations:** [testing_state.iterations]

## Coverage Report
**Threshold:** [coverage_threshold]%
**Actual:** [coverage_actual]%
**Status:** ✅ PASS

| Package/File | Coverage |
|--------------|----------|
[from QA output]
| **TOTAL** | **[coverage_actual]%** |

## Traceability Matrix
| AC ID | Criterion | Test | Status |
|-------|-----------|------|--------|
[from testing_state.traceability_matrix]

**Criteria Covered:** [X]/[Y] (100%)

## Quality Checks
| Check | Status |
|-------|--------|
| Coverage ≥ threshold | ✅ |
| All ACs tested | ✅ |
| No skipped tests | ✅ |
| Edge cases present | ✅ |

## Handoff to Next Gate
- Testing status: COMPLETE
- Coverage: [coverage_actual]% (threshold: [coverage_threshold]%)
- All criteria tested: ✅
- Ready for Gate 2 (Fuzz Testing): YES
```

## Step 7: Escalate - Max Iterations Reached

```text
Generate skill output:

## Testing Summary
**Status:** FAIL
**Unit ID:** [unit_id]
**Iterations:** [max_iterations] (MAX REACHED)

## Coverage Report
**Threshold:** [coverage_threshold]%
**Actual:** [coverage_actual]%
**Gap:** [threshold - actual]%
**Status:** ❌ FAIL

## Gap Analysis
[from last QA output]

## Files Still Needing Coverage
[from last QA output]

## Handoff to Next Gate
- Testing status: FAILED
- Ready for Gate 4: no
- **Action Required:** User must manually add tests or adjust scope

⛔ ESCALATION: Max iterations (3) reached. Coverage still below threshold.
User intervention required.
```

---

## Pressure Resistance

See [shared-patterns/shared-pressure-resistance.md](../shared-patterns/shared-pressure-resistance.md) for universal pressure scenarios.

| User Says | Your Response |
|-----------|---------------|
| "84% is close enough" | "85% is minimum threshold. 84% = FAIL. Adding more tests." |
| "Manual testing covers it" | "Gate 3 requires executable unit tests. Dispatching QA analyst." |
| "Skip testing, deadline" | "Testing is MANDATORY. Untested code = unverified claims." |

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations.

### Gate 1-Specific Anti-Rationalizations

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Tool shows 83% but real is 90%" | Tool output IS real. Your belief is not. | **Fix issue, re-measure** |
| "Excluding dead code gets us to 85%" | Delete dead code, don't exclude it. | **Delete dead code** |
| "84.5% rounds to 85%" | Rounding is not allowed. 84.5% < 85%. | **Write more tests** |
| "Close enough with all AC tested" | "Close enough" is not passing. | **Meet exact threshold** |
| "Integration tests cover this" | Gate 3 = unit tests only. Different scope. | **Write unit tests** |

## Unit Test vs Integration Test

| Type | Characteristics | Gate 3? |
|------|----------------|---------|
| **Unit** ✅ | Mocks all external deps, tests single function | YES |
| **Integration** ❌ | Hits real database/API/filesystem | no |

---

## Execution Report Format

```markdown
## Testing Summary
**Status:** [PASS|FAIL]
**Unit ID:** [unit_id]
**Duration:** [Xm Ys]
**Iterations:** [N]

## Coverage Report
**Threshold:** [X%]
**Actual:** [Y%]
**Status:** [✅ PASS | ❌ FAIL]

## Traceability Matrix
| AC ID | Criterion | Test | Status |
|-------|-----------|------|--------|
| AC-1 | [text] | [test] | ✅/❌ |

**Criteria Covered:** [X/Y]

## Handoff to Next Gate
- Testing status: [COMPLETE|FAILED]
- Coverage: [X%]
- Ready for Gate 2: [YES|no]
```
