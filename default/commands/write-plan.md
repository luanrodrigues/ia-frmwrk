---
name: bee:write-plan
description: Create detailed implementation plan with bite-sized tasks
argument-hint: "[feature-name]"
---

Create a comprehensive implementation plan for a feature, with exact file paths, complete code examples, and verification steps. Plans are designed to be executable by engineers with zero codebase context.

## Usage

```
/bee:write-plan [feature-name]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-name` | Yes | Descriptive name for the feature (e.g., "user-authentication", "payment-webhooks", "email-notifications") |

## Examples

### Create a Feature Plan
```
/bee:write-plan oauth2-integration
```
Creates a detailed plan for implementing OAuth2 authentication.

### Create an API Plan
```
/bee:write-plan rest-api-versioning
```
Plans the implementation of API versioning with migration path.

### Create a Refactoring Plan
```
/bee:write-plan database-connection-pooling
```
Creates a step-by-step plan for implementing connection pooling.

## Process

### Step 1: Dispatch Planning Agent
A specialized planning agent (running on Opus model) is dispatched to:
- Explore the codebase to understand architecture
- Identify all files that need modification
- Break the feature into bite-sized tasks (2-5 minutes each)

### Step 2: Agent Creates Plan
The agent writes a comprehensive plan including:
- Header with goal, architecture, tech stack, prerequisites
- Bite-sized tasks with exact file paths
- Complete, copy-paste ready code for each task
- Exact verification commands with expected output
- Code review checkpoints after task batches
- Recommended agents for each task type
- Failure recovery steps

### Step 3: Save Plan
Plan is saved to: `docs/plans/YYYY-MM-DD-<feature-name>.md`

### Step 4: Choose Execution Mode
After the plan is ready, you'll be asked:

| Option | Description |
|--------|-------------|
| **Execute now** | Start implementation immediately using subagent-driven development |
| **Execute in parallel session** | Open a new agent session in the worktree for batch execution |
| **Save for later** | Keep the plan for manual review before execution |

## Plan Requirements (Zero-Context Test)

Every plan passes the "Zero-Context Test" - executable with only the document:

- **Exact file paths** - Never "somewhere in src"
- **Complete code** - Never "add validation here"
- **Verification commands** - With expected output
- **Failure recovery** - What to do when things go wrong
- **Code review checkpoints** - Severity-based handling
- **Agent recommendations** - Which specialized agent for each task

## Agent Selection in Plans

Plans specify recommended agents for execution:

| Task Type | Recommended Agent |
|-----------|-------------------|
| Backend (Go) | `bee:backend-engineer-golang` |
| Backend (TypeScript) | `bee:backend-engineer-typescript` |
| Frontend (BFF/API Routes) | `frontend-bff-engineer-typescript` |
| Infrastructure | `bee:devops-engineer` |
| Testing | `bee:qa-analyst` |
| Reliability | `bee:sre` |
| Fallback | `general-purpose` (built-in) |

## Related Commands/Skills

| Command/Skill | Relationship |
|---------------|--------------|
| `/bee:brainstorm` | Use first if design is not yet validated |
| `/bee:execute-plan` | Use after to execute the created plan |
| `bee:brainstorming` | Design validation before planning |
| `bee:executing-plans` | Batch execution with review checkpoints |
| `bee:subagent-driven-development` | Alternative execution for current session |

## Troubleshooting

### "Design not validated"
Planning requires a validated design. Use `/bee:brainstorm` first to refine your concept before creating the implementation plan.

### "Plan is too vague"
If the generated plan contains phrases like "implement the logic" or "add appropriate handling", the plan doesn't meet quality standards. Request revision with specific code examples.

### "Worktree not set up"
This command is best run in a dedicated worktree created by the bee:brainstorming skill. You can still run it in main, but isolation is recommended.

### "Agent selection unavailable"
If `bee-dev-team` plugin is not installed, execution falls back to `general-purpose` agents automatically. Plans remain valid regardless.

### When NOT to use this command
- Design is not validated - use `/bee:brainstorm` first
- Requirements still unclear - use pre-dev PRD/TRD workflow first
- Already have a plan - use `/bee:execute-plan` instead

---

## MANDATORY: Load Full Skill

**This command MUST load the skill for complete workflow execution.**

```
Use Skill tool: bee:writing-plans
```

The skill contains the complete workflow with:
- Plan document structure
- Task granularity requirements (2-5 min per task)
- Zero-context test criteria
- Historical precedent integration
- Code review checkpoint requirements
