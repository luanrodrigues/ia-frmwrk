---
name: bee:dev-chaos-testing
title: Development cycle chaos testing (Gate 7)
category: development-cycle
tier: 1
when_to_use: |
  Use after integration testing (Gate 6) is complete.
  MANDATORY for all development tasks with external dependencies - verifies graceful degradation under failure.
description: |
  Gate 7 of development cycle - ensures chaos tests exist using Toxiproxy
  to verify graceful degradation under connection loss, latency, and partitions.

trigger: |
  - After integration testing complete (Gate 6)
  - MANDATORY for all development tasks with external dependencies
  - Verifies system behavior under failure conditions

NOT_skip_when: |
  - "Infrastructure is reliable" - All infrastructure fails eventually. Be prepared.
  - "Integration tests cover failures" - Integration tests verify happy path. Chaos verifies failures.
  - "Toxiproxy is complex" - One container, 20 minutes setup. Prevents production incidents.

sequence:
  after: [bee:dev-integration-testing]
  before: [bee:requesting-code-review]

related:
  complementary: [bee:dev-cycle, bee:dev-integration-testing, bee:qa-analyst]

input_schema:
  required:
    - name: unit_id
      type: string
      description: "Task or subtask identifier"
    - name: external_dependencies
      type: array
      items: string
      description: "External services (postgres, redis, rabbitmq, etc.)"
    - name: language
      type: string
      enum: [php, typescript]
      description: "Programming language"
  optional:
    - name: gate6_handoff
      type: object
      description: "Full handoff from Gate 6 (integration testing)"

output_schema:
  format: markdown
  required_sections:
    - name: "Chaos Testing Summary"
      pattern: "^## Chaos Testing Summary"
      required: true
    - name: "Failure Scenarios"
      pattern: "^## Failure Scenarios"
      required: true
    - name: "Handoff to Next Gate"
      pattern: "^## Handoff to Next Gate"
      required: true
  metrics:
    - name: result
      type: enum
      values: [PASS, FAIL]
    - name: dependencies_tested
      type: integer
    - name: scenarios_tested
      type: integer
    - name: recovery_verified
      type: boolean
    - name: iterations
      type: integer

verification:
  automated:
    - command: "grep -rn 'chaos\\|Chaos' --include='*Test.php' tests/"
      description: "Chaos test functions exist"
      success_pattern: "chaos\\|Chaos"
    - command: "grep -rn 'CHAOS.*1' --include='*Test.php' tests/"
      description: "CHAOS env check present"
      success_pattern: "CHAOS"
  manual:
    - "Chaos tests follow testChaos{Component}{Scenario} naming (PHPUnit) or it('chaos: {scenario}')->group('chaos') (Pest)"
    - "All external dependencies have failure scenarios"
    - "Recovery verified after each failure injection"

examples:
  - name: "Chaos tests for database operations"
    input:
      unit_id: "task-001"
      external_dependencies: ["postgres", "redis"]
      language: "go"
    expected_output: |
      ## Chaos Testing Summary
      **Status:** PASS
      **Dependencies Tested:** 2
      **Scenarios Tested:** 6
      **Recovery Verified:** Yes

      ## Failure Scenarios
      | Component | Scenario | Status | Recovery |
      |-----------|----------|--------|----------|
      | PostgreSQL | Connection Loss | PASS | Yes |
      | PostgreSQL | High Latency | PASS | Yes |
      | PostgreSQL | Network Partition | PASS | Yes |
      | Redis | Connection Loss | PASS | Yes |
      | Redis | High Latency | PASS | Yes |
      | Redis | Network Partition | PASS | Yes |

      ## Handoff to Next Gate
      - Ready for Gate 8 (Code Review): YES
---

# Dev Chaos Testing (Gate 7)

## Overview

Ensure code handles **failure conditions gracefully** by injecting faults using Toxiproxy. Verify connection loss, latency, and network partitions don't cause crashes.

**Core principle:** All infrastructure fails. Chaos testing ensures your code handles it gracefully.

<block_condition>
- No chaos tests = FAIL
- Any dependency without failure test = FAIL
- Recovery not verified = FAIL
- System crashes on failure = FAIL
</block_condition>

## CRITICAL: Role Clarification

**This skill ORCHESTRATES. QA Analyst Agent (chaos mode) EXECUTES.**

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Gather requirements, dispatch agent, track iterations |
| **QA Analyst Agent** | Write chaos tests, setup Toxiproxy, verify recovery |

---

## Standards Reference

**MANDATORY:** Load testing-chaos.md standards via WebFetch.

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/php/testing-chaos.md
</fetch_required>

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
PM team task files often omit external_dependencies. If the codebase uses postgres, mongodb, valkey, or rabbitmq, these are external dependencies that MUST have chaos tests. Auto-detection prevents silent skips.
</auto_detect_reason>

---

## Step 1: Validate Input

```text
REQUIRED INPUT:
- unit_id: [task/subtask being tested]
- external_dependencies: [postgres, mongodb, valkey, redis, rabbitmq, etc.] (from input OR auto-detected in Step 0)
- language: [php|typescript]

OPTIONAL INPUT:
- gate6_handoff: [full Gate 6 output]

if any REQUIRED input is missing:
  → STOP and report: "Missing required input: [field]"

if external_dependencies is empty (AFTER auto-detection in Step 0):
  → STOP and report: "No external dependencies found after codebase scan - chaos testing requires dependencies"
```

## Step 2: Dispatch QA Analyst Agent (Chaos Mode)

```text
Task tool:
  subagent_type: "bee:qa-analyst"
  model: "opus"
  prompt: |
    **MODE:** CHAOS TESTING (Gate 7)

    **Standards:** Load testing-chaos.md

    **Input:**
    - Unit ID: {unit_id}
    - External Dependencies: {external_dependencies}
    - Language: {language}

    **Requirements:**
    1. Setup Toxiproxy infrastructure in tests/utils/chaos/
    2. Create chaos tests (testChaos{Component}{Scenario} naming for PHPUnit, or group('chaos') for Pest)
    3. Use environment gating (CHAOS=1 env variable check in setUp())
    4. Test failure scenarios: Connection Loss, High Latency, Network Partition
    5. Verify 5-phase structure: Normal → Inject → Verify → Restore → Recovery

    **Output Sections Required:**
    - ## Chaos Testing Summary
    - ## Failure Scenarios
    - ## Handoff to Next Gate
```

## Step 3: Evaluate Results

```text
Parse agent output:

if "Status: PASS" in output:
  → Gate 7 PASSED
  → Return success with metrics

if "Status: FAIL" in output:
  → Dispatch fix to implementation agent
  → Re-run chaos tests (max 3 iterations)
  → If still failing: ESCALATE to user
```

## Step 4: Generate Output

```text
## Chaos Testing Summary
**Status:** {PASS|FAIL}
**Dependencies Tested:** {count}
**Scenarios Tested:** {count}
**Recovery Verified:** {Yes|No}

## Failure Scenarios
| Component | Scenario | Status | Recovery |
|-----------|----------|--------|----------|
| {component} | {scenario} | {PASS|FAIL} | {Yes|No} |

## Handoff to Next Gate
- Ready for Gate 8 (Code Review): {YES|NO}
- Iterations: {count}
```

---

## Failure Scenarios by Dependency

| Dependency | Required Scenarios |
|------------|-------------------|
| PostgreSQL | Connection Loss, High Latency, Network Partition |
| MongoDB | Connection Loss, High Latency, Network Partition |
| Valkey | Connection Loss, High Latency, Timeout |
| Redis | Connection Loss, High Latency, Timeout |
| RabbitMQ | Connection Loss, Network Partition, Slow Consumer |
| HTTP APIs | Timeout, 5xx Errors, Connection Refused |

---

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Infrastructure is reliable" | AWS, GCP, Azure all have outages. Your code must handle them. | **Write chaos tests** |
| "Integration tests cover failures" | Integration tests verify happy path. Chaos tests verify failure handling. | **Write chaos tests** |
| "Toxiproxy is complex" | One container. 20 minutes setup. Prevents production incidents. | **Write chaos tests** |
| "We have monitoring" | Monitoring detects problems. Chaos testing prevents them. | **Write chaos tests** |
| "Circuit breakers handle it" | Circuit breakers need testing too. Chaos tests verify they work. | **Write chaos tests** |

---
