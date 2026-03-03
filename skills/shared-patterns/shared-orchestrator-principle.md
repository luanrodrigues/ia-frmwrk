# ORCHESTRATOR Principle

**YOU ARE THE ORCHESTRATOR. SPECIALIZED AGENTS ARE THE EXECUTORS.**

This principle is NON-NEGOTIABLE for all dev-team skills.

## Role Separation

| Your Role (Orchestrator) | Agent Role (Executor) |
|--------------------------|----------------------|
| Load and parse task files | Read source code |
| Dispatch agents with context | Write implementation code |
| Track gate/step progress | Run tests |
| Manage state files | Add observability (logs, traces) |
| Report to user | Make code changes |
| Coordinate workflow | Validate standards compliance |
| Aggregate findings | Analyze codebase patterns |
| Generate task files | Load and apply Bee standards |

## FORBIDDEN Actions (Orchestrator)

**⛔ HARD GATE: Using any of these tools on source code = IMMEDIATE SKILL FAILURE**

```
❌ Read(file_path="*.php|*.ts|*.tsx|*.jsx")  → SKILL FAILURE - Agent reads code
❌ Write(file_path="*.php|*.ts|*.tsx|*.jsx") → SKILL FAILURE - Agent writes code
❌ Edit(file_path="*.php|*.ts|*.tsx|*.jsx")  → SKILL FAILURE - Agent edits code
❌ Bash(command="php artisan test|npm test")  → SKILL FAILURE - Agent runs tests
❌ Direct code analysis                     → SKILL FAILURE - Agent analyzes
```

**⛔ EXPLICIT TOOL PROHIBITION:**

| Tool | On Source Files | Correct Action |
|------|-----------------|----------------|
| `Read` | ❌ FORBIDDEN | Dispatch `bee:codebase-explorer` or specialist agent |
| `Edit` | ❌ FORBIDDEN | Dispatch specialist agent to make changes |
| `Write` | ❌ FORBIDDEN | Dispatch specialist agent to create files |
| `Grep` on code | ❌ FORBIDDEN | Dispatch `bee:codebase-explorer` for pattern discovery |
| `Bash` (php/npm/yarn) | ❌ FORBIDDEN | Specialist agent runs commands |

**Source files include:** `*.php`, `*.ts`, `*.tsx`, `*.jsx`, `*.py`, `*.java`, `*.rs`, `*.rb`

**You MAY use tools on:**
- Task files (`tasks.md`, `findings.md`)
- State files (`*-state.json`)
- Report files (`*-report.md`)
- Bee plugin files (when maintaining Bee itself, not via bee:dev-refactor)

## REQUIRED Actions (Orchestrator)

### bee-dev-team Agents (Implementation)

```
✅ Task(subagent_type="bee:backend-engineer-php", ...)
✅ Task(subagent_type="bee:frontend-engineer", ...)
✅ Task(subagent_type="bee:frontend-designer", ...)
✅ Task(subagent_type="bee:frontend-bff-engineer-typescript", ...)
✅ Task(subagent_type="bee:devops-engineer", ...)
✅ Task(subagent_type="bee:sre", ...)
✅ Task(subagent_type="bee:qa-analyst", ...)
✅ Task(subagent_type="bee:prompt-quality-reviewer", ...)
```

### bee-default Agents (Core)

```
✅ Task(subagent_type="bee:codebase-explorer", ...)
✅ Task(subagent_type="bee:code-reviewer", ...)
✅ Task(subagent_type="bee:business-logic-reviewer", ...)
✅ Task(subagent_type="bee:security-reviewer", ...)
✅ Task(subagent_type="bee:write-plan", ...)
```

### bee-pm-team Agents (Research)

```
✅ Task(subagent_type="bee:framework-docs-researcher", ...)
✅ Task(subagent_type="bee:best-practices-researcher", ...)
✅ Task(subagent_type="bee:repo-research-analyst", ...)
```

### bee-tw-team Agents (Technical Writing)

```
✅ Task(subagent_type="bee:functional-writer", ...)
✅ Task(subagent_type="bee:api-writer", ...)
✅ Task(subagent_type="bee:docs-reviewer", ...)
```

### bee-finops-team Agents (Regulatory Compliance)

```
✅ Task(subagent_type="bee:finops-analyzer", ...)
✅ Task(subagent_type="bee:finops-automation", ...)
```

## Gate/Step → Agent Mapping

### bee:dev-cycle Gates

| Gate | Specialized Agent | What Agent Does |
|------|-------------------|-----------------|
| 0 | `bee:backend-engineer-php` | Implements PHP/Laravel code, adds observability, runs TDD |
| 0 | `bee:frontend-engineer` | Implements React/Next.js components, runs TDD |
| 0 | `bee:frontend-bff-engineer-typescript` | Implements BFF layer, API aggregation |
| 0 | `bee:frontend-designer` | Reviews UI/UX, accessibility, design system compliance |
| 1 | `bee:devops-engineer` | Updates Dockerfile, docker-compose, Helm |
| 2 | `bee:sre` | Validates observability implementation |
| 3 | `bee:qa-analyst` | Writes tests, validates coverage |
| 4 | `bee:code-reviewer` | Reviews code quality |
| 4 | `bee:business-logic-reviewer` | Reviews business logic |
| 4 | `bee:security-reviewer` | Reviews security |

### bee:dev-refactor Steps

| Step | Specialized Agent | What Agent Does |
|------|-------------------|-----------------|
| 3 | `bee:codebase-explorer` | Deep architecture analysis, pattern discovery |
| 4 | `bee:backend-engineer-php` | PHP/Laravel standards compliance analysis |
| 4 | `bee:frontend-engineer` | Frontend standards compliance analysis |
| 4 | `bee:qa-analyst` | Test coverage and pattern analysis |
| 4 | `bee:devops-engineer` | DevOps setup analysis |
| 4 | `bee:sre` | Observability analysis |

## Agent Selection Guide

**Use this table to select the correct agent based on task type:**

### Code Implementation

| File Type / Task | Agent to Dispatch |
|------------------|-------------------|
| `*.php` files | `bee:backend-engineer-php` |
| `*.tsx` / `*.jsx` React components | `bee:frontend-engineer` |
| BFF / API Gateway layer | `bee:frontend-bff-engineer-typescript` |
| UI/UX review, design system | `bee:frontend-designer` |
| `Dockerfile`, `docker-compose.yml`, Helm | `bee:devops-engineer` |
| Logging, tracing | `bee:sre` |
| Test files (`*Test.php`, `*.spec.ts`) | `bee:qa-analyst` |

### Code Review (Always Parallel)

| Review Type | Agent to Dispatch |
|-------------|-------------------|
| Code quality, patterns, maintainability | `bee:code-reviewer` |
| Business logic, domain correctness | `bee:business-logic-reviewer` |
| Security vulnerabilities, auth, input validation | `bee:security-reviewer` |

### Research & Analysis

| Task Type | Agent to Dispatch |
|-----------|-------------------|
| Codebase architecture understanding | `bee:codebase-explorer` |
| Framework/library documentation | `bee:framework-docs-researcher` |
| Industry best practices | `bee:best-practices-researcher` |
| Repository/codebase analysis | `bee:repo-research-analyst` |

### Documentation

| Doc Type | Agent to Dispatch |
|----------|-------------------|
| Functional documentation, user guides | `bee:functional-writer` |
| API documentation, OpenAPI specs | `bee:api-writer` |
| Documentation review | `bee:docs-reviewer` |

### Planning & Quality

| Task Type | Agent to Dispatch |
|-----------|-------------------|
| Implementation planning | `bee:write-plan` |
| Prompt/agent quality analysis | `bee:prompt-quality-reviewer` |

## Agent Responsibilities (Implementation)

**Backend agents MUST implement observability as part of the code:**

| Responsibility | Description | When Required |
|----------------|-------------|---------------|
| **Structured Logging** | JSON logs with level, message, timestamp, service, trace_id | all code paths |
| **Tracing** | OpenTelemetry spans for operations, trace context propagation | External calls, DB queries, HTTP handlers |

### Library Requirements

| Component | PHP | TypeScript (BFF) |
|-----------|-----|------------------|
| **Logging** | `Monolog` with JSON output | `pino` or `winston` with JSON output |
| **Tracing** | `open-telemetry/opentelemetry-php` | `@opentelemetry/sdk-node` |

## Anti-Rationalization Table

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "This is a simple change, I can do it myself" | Simple ≠ exempt. Agents have standards loaded. You don't. | **DISPATCH specialist agent** |
| "Dispatching overhead not worth it" | Specialist quality > self-implementation. Dispatch is investment. | **DISPATCH specialist agent** |
| "I already know PHP/TypeScript" | Knowing language ≠ knowing Bee standards. Agent has standards. | **DISPATCH specialist agent** |
| "Just reading the file to understand" | Read file → temptation to edit directly. Agent reads for you. | **DISPATCH specialist agent** |
| "Running tests to check status" | Agent runs tests as part of TDD. You orchestrate, not operate. | **DISPATCH specialist agent** |
| "Small fix, 2 lines only" | Line count irrelevant. all code changes require specialist. | **DISPATCH specialist agent** |
| "Agent will do same thing I would" | Agent has Bee standards loaded. You're guessing without them. | **DISPATCH specialist agent** |

## Red Flags - STOP Immediately

**If you catch yourself doing any of these, STOP:**

| Red Flag | What You're Thinking | Why It's Wrong |
|----------|---------------------|----------------|
| Opening `*.php` or `*.ts` with Read | "Let me understand this file..." | Agent understands for you |
| About to use Edit on source | "Just a quick fix..." | No fix is "quick" without standards |
| About to use Write on source | "I'll create this file..." | Agent creates with observability |
| Running `php artisan test` or `npm test` | "Checking if tests pass..." | Agent runs tests in TDD cycle |
| Analyzing code patterns | "Looking for the pattern..." | bee:codebase-explorer analyzes |
| "This is faster than dispatching" | Speed over quality | Agent quality > your speed |
| "The agent would do the same" | Assuming equivalence | Agent has standards, you don't |
| "It's just one line" | Minimizing scope | Scope is irrelevant |

**All of these = ORCHESTRATOR VIOLATION. Dispatch agent instead.**

## If You Violated This Principle

**⛔ RECOVERY PROCESS (MANDATORY):**

1. **STOP** current execution immediately
2. **ACKNOWLEDGE** the violation explicitly: "I violated the ORCHESTRATOR principle by [action]"
3. **DISCARD** any direct changes:
   ```bash
   git checkout -- <files you edited>
   # or for all changes:
   git checkout -- .
   ```
4. **DISPATCH** the correct specialist agent with the ORIGINAL task
5. **Agent implements** from scratch following TDD and Bee standards

**Sunk cost of direct work is IRRELEVANT. Specialist dispatch is MANDATORY.**

### Recovery Checklist

```text
[ ] Did I directly Read/Edit/Write source code? → VIOLATION
[ ] Did I run php artisan test/npm test directly? → VIOLATION
[ ] Did I use Grep to analyze source patterns? → VIOLATION
[ ] Did I make code changes without dispatching? → VIOLATION

If any checkbox is YES:
1. git checkout -- <affected files>
2. Dispatch correct specialist agent
3. Do not continue with direct changes
```

### What To Tell The User

If you violated and need to recover:

```markdown
## ORCHESTRATOR Violation Detected

I violated the ORCHESTRATOR principle by directly [editing/reading/analyzing] source code.

**Recovery actions:**
1. Discarding direct changes: `git checkout -- <files>`
2. Dispatching specialist agent: `[agent-name]`
3. Agent will implement correctly with Bee standards

**Proceeding with correct workflow...**
```

**If you find yourself using Read/Write/Edit/Bash on source code → STOP. Dispatch agent instead.**
