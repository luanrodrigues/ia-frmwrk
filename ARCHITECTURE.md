# Ring Architecture Documentation

## Table of Contents

1. [Overview](#overview)
2. [Marketplace Structure](#marketplace-structure)
3. [Component Hierarchy](#component-hierarchy)
4. [Core Components](#core-components)
5. [Data & Control Flow](#data--control-flow)
6. [Integration with Claude Code](#integration-with-claude-code)
7. [Execution Patterns](#execution-patterns)
8. [Component Relationships](#component-relationships)

## Overview

Ring is a **Claude Code plugin marketplace** that provides a comprehensive skills library and workflow system with **6 active plugins**. It extends Claude Code's capabilities through structured, reusable patterns that enforce proven software engineering practices across the software delivery value chain: Product Planning → Development → Documentation.

### Architecture Philosophy

Ring operates on three core principles:

1. **Mandatory Workflows** - Critical skills (like ring:using-ring) enforce specific behaviors
2. **Parallel Execution** - Review systems run concurrently for speed
3. **Session Context** - Skills load automatically at session start
4. **Modular Plugins** - Specialized plugins for different domains and teams

### System Boundaries

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Claude Code                                         │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                          Ring Marketplace                                  │  │
│  │  ┌──────────────────────┐  ┌──────────────────────┐                       │  │
│  │  │ bee-default         │  │ bee-dev-team        │                       │  │
│  │  │ Skills(26) Agents(8) │  │ Skills(21) Agents(11)│                       │  │
│  │  │ Cmds(13) Hooks/Lib   │  │ Cmds(7)              │                       │  │
│  │  └──────────────────────┘  └──────────────────────┘                       │  │
│  │  ┌──────────────────────┐  ┌──────────────────────┐                       │  │
│  │  │ bee-pm-team         │  │ bee-tw-team         │                       │  │
│  │  │ Skills(13) Agents(4) │  │ Skills(7) Agents(3)  │                       │  │
│  │  │ Cmds(3)              │  │ Cmds(3)              │                       │  │
│  │  └──────────────────────┘  └──────────────────────┘                       │  │
│  │  ┌──────────────────────┐  ┌──────────────────────┐                       │  │
│  │  │ bee-finops-team     │  │ bee-pmo-team        │                       │  │
│  │  │ Skills(7) Agents(3)  │  │ Skills(9) Agents(6)  │                       │  │
│  │  └──────────────────────┘  │ Cmds(4)              │                       │  │
│  │                            └──────────────────────┘                       │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  Native Tools: Skill, Task, TodoWrite, SlashCommand                             │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Marketplace Structure

Ring is organized as a monorepo marketplace with multiple plugin collections:

```
ring/                                  # Monorepo root
├── .claude-plugin/
│   └── marketplace.json              # Multi-plugin registry (6 active plugins)
├── default/                          # Core plugin: bee-default
├── dev-team/                         # Developer agents: bee-dev-team
├── finops-team/                      # FinOps & regulatory: bee-finops-team
├── pm-team/                          # Product planning: bee-pm-team
├── pmo-team/                         # PMO specialists: bee-pmo-team
└── tw-team/                          # Technical writing: bee-tw-team
```

### Active Plugins

_Versions managed in `.claude-plugin/marketplace.json`_

| Plugin               | Description                          | Components                       |
| -------------------- | ------------------------------------ | -------------------------------- |
| **bee-default**     | Core skills library                  | 26 skills, 8 agents, 13 commands |
| **bee-dev-team**    | Developer agents                     | 21 skills, 11 agents, 7 commands |
| **bee-finops-team** | FinOps regulatory compliance         | 7 skills, 3 agents               |
| **bee-pm-team**     | Product planning workflows           | 13 skills, 4 agents, 3 commands  |
| **bee-pmo-team**    | PMO portfolio management specialists | 9 skills, 6 agents, 4 commands   |
| **bee-tw-team**     | Technical writing specialists        | 7 skills, 3 agents, 3 commands   |

## Component Hierarchy

### 1. Skills (`skills/`)

**Purpose:** Core instruction sets that define workflows and best practices

**Structure:**

```
skills/
├── {skill-name}/
│   └── SKILL.md           # Skill definition with frontmatter
├── shared-patterns/       # Reusable patterns across skills
│   ├── state-tracking.md
│   ├── failure-recovery.md
│   ├── exit-criteria.md
│   └── todowrite-integration.md
```

**Key Characteristics:**

- Self-contained directories with `SKILL.md` files
- YAML frontmatter: `name`, `description`, `when_to_use`
- Invoked via Claude's `Skill` tool
- Can reference shared patterns for common behaviors

### 2. Agents (`agents/`)

**Purpose:** Specialized agents that analyze code/designs or provide domain expertise using AI models

**Structure (bee-default plugin):**

```
default/agents/
├── code-reviewer.md           # Foundation review (`ring:code-reviewer`)
├── business-logic-reviewer.md # Correctness review (`ring:business-logic-reviewer`)
├── security-reviewer.md       # Safety review (`ring:security-reviewer`)
├── test-reviewer.md           # Test coverage and quality review (`ring:test-reviewer`)
├── nil-safety-reviewer.md     # Null/nil safety analysis (`ring:nil-safety-reviewer`)
├── consequences-reviewer.md   # Ripple effect review (`ring:consequences-reviewer`)
├── write-plan.md              # Implementation planning (`ring:write-plan`)
└── codebase-explorer.md       # Deep architecture analysis (`ring:codebase-explorer`)
```

**Structure (bee-dev-team plugin):**

```
dev-team/agents/
├── backend-engineer-golang.md         # Go backend specialist (`ring:backend-engineer-golang`)
├── backend-engineer-typescript.md     # TypeScript backend specialist (`ring:backend-engineer-typescript`)
├── devops-engineer.md                 # DevOps specialist (`ring:devops-engineer`)
├── frontend-bff-engineer-typescript.md # BFF specialist (`ring:frontend-bff-engineer-typescript`)
├── frontend-designer.md               # Visual design specialist (`ring:frontend-designer`)
├── frontend-engineer.md               # Frontend engineer (`ring:frontend-engineer`)
├── prompt-quality-reviewer.md         # Prompt quality specialist (`ring:prompt-quality-reviewer`)
├── qa-analyst.md                      # Backend QA specialist (`ring:qa-analyst`)
├── qa-analyst-frontend.md             # Frontend QA specialist (`ring:qa-analyst-frontend`)
├── sre.md                             # Site reliability engineer (`ring:sre`)
└── ui-engineer.md                     # UI component specialist (`ring:ui-engineer`)
```

**Structure (bee-pmo-team plugin):**

```
pmo-team/agents/
├── delivery-reporter.md          # Delivery progress reporting
├── executive-reporter.md         # Executive dashboards and communications
├── governance-specialist.md      # Gate reviews and process compliance
├── portfolio-manager.md          # Portfolio-level planning and coordination
├── resource-planner.md           # Capacity planning and allocation
└── risk-analyst.md               # Portfolio risk identification and mitigation
```

**Key Characteristics:**

- Invoked via Claude's `Task` tool with `subagent_type`
- Must specify model (typically "opus" for comprehensive analysis)
- Review agents run in parallel (6 reviewers dispatch simultaneously via `/bee:codereview` command)
- Developer agents provide specialized domain expertise
- Return structured reports with severity-based findings

**Note:** Parallel review orchestration is handled by the `/bee:codereview` command

**Standards Compliance Output (bee-dev-team agents):**

All bee-dev-team agents include a `## Standards Compliance` section in their output schema:

```yaml
- name: "Standards Compliance"
  pattern: "^## Standards Compliance"
  required: false # In schema, but MANDATORY when invoked from ring:dev-refactor
  description: "MANDATORY when invoked from ring:dev-refactor skill"
```

**Conditional Requirement: `invoked_from_dev_refactor`**

| Invocation Context            | Standards Compliance | Detection Mechanism                       |
| ----------------------------- | -------------------- | ----------------------------------------- |
| Direct agent call             | Optional             | N/A                                       |
| Via `ring:dev-cycle` skill    | Optional             | N/A                                       |
| Via `ring:dev-refactor` skill | **MANDATORY**        | Prompt contains `**MODE: ANALYSIS ONLY**` |

**How Enforcement Works:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  User invokes: /bee:dev-refactor                          │
│         ↓                                                           │
│  ring:dev-refactor skill dispatches agents with prompt:                  │
│  "**MODE: ANALYSIS ONLY** - Compare codebase with Ring standards"   │
│         ↓                                                           │
│  Agent detects "**MODE: ANALYSIS ONLY**" in prompt                  │
│         ↓                                                           │
│  Agent loads Ring standards via WebFetch                            │
│         ↓                                                           │
│  Agent produces Standards Compliance output (MANDATORY)             │
└─────────────────────────────────────────────────────────────────────┘
```

**Affected Agents:**

- `ring:backend-engineer-golang` → loads `golang.md`
- `ring:backend-engineer-typescript` → loads `typescript.md`
- `ring:devops-engineer` → loads `devops.md`
- `ring:frontend-bff-engineer-typescript` → loads `typescript.md`
- `ring:frontend-designer` → loads `frontend.md`
- `ring:qa-analyst` → loads `testing-*.md` (unit/fuzz/property/integration/chaos)
- `ring:qa-analyst-frontend` → loads `frontend/testing-*.md` (accessibility/visual/e2e/performance)
- `ring:sre` → loads `sre.md`

**Output Format (when non-compliant):**

```markdown
## Standards Compliance

### Lerian/bee Standards Comparison

| Category | Current Pattern | Expected Pattern | Status           | File/Location |
| -------- | --------------- | ---------------- | ---------------- | ------------- |
| Logging  | fmt.Println     | lib-commons/zap  | ⚠️ Non-Compliant | service/\*.go |

### Compliance Summary

- Total Violations: N
- Critical: N, High: N, Medium: N, Low: N

### Required Changes for Compliance

1. **Category Migration**
   - Replace: `current pattern`
   - With: `expected pattern`
   - Files affected: [list]
```

**Cross-References:**

- CLAUDE.md: Standards Compliance (Conditional Output Section)
- `dev-team/skills/dev-refactor/SKILL.md`: HARD GATES defining requirement
- `dev-team/hooks/session-start.sh`: Injects guidance at session start

### 3. Commands (`commands/`)

**Purpose:** Slash commands that provide shortcuts to skills/workflows

**Structure:**

```
default/commands/
├── brainstorm.md         # /bee:brainstorm - Socratic design refinement
├── codereview.md         # /bee:codereview - Parallel 6-reviewer dispatch
├── commit.md             # /bee:commit - Git commit with trailers
├── create-handoff.md     # /bee:create-handoff - Create session handoff
├── execute-plan.md       # /bee:execute-plan - Batch execution
├── explore-codebase.md   # /bee:explore-codebase - Deep architecture analysis
├── interview-me.md       # /bee:interview-me - Interactive interview
├── lint.md               # /bee:lint - Run linters and fix issues
├── release-guide.md      # /bee:release-guide - Release guidance
├── resume-handoff.md     # /bee:resume-handoff - Resume from handoff
├── worktree.md           # /bee:worktree - Git worktree creation
└── write-plan.md         # /bee:write-plan - Implementation planning

pm-team/commands/
├── delivery-status.md    # /bee:delivery-status - Delivery status tracking
├── pre-dev-feature.md    # /bee:pre-dev-feature - 5-gate workflow
└── pre-dev-full.md       # /bee:pre-dev-full - 10-gate workflow

pmo-team/commands/
├── delivery-report.md      # /bee:delivery-report - PMO delivery reporting
├── dependency-analysis.md  # /bee:dependency-analysis - Dependency analysis
├── executive-summary.md    # /bee:executive-summary - Executive summary
└── portfolio-review.md     # /bee:portfolio-review - Portfolio review

dev-team/commands/
├── dev-cancel.md           # /bee:dev-cancel - Cancel dev cycle
├── dev-cycle.md            # /bee:dev-cycle - 11-gate development cycle
├── dev-cycle-frontend.md   # /bee:dev-cycle-frontend - 9-gate frontend cycle
├── dev-refactor.md         # /bee:dev-refactor - Standards refactoring
├── dev-refactor-frontend.md # /bee:dev-refactor-frontend - Frontend standards refactor
├── dev-report.md           # /bee:dev-report - Development reporting
└── dev-status.md           # /bee:dev-status - Development status

tw-team/commands/
├── review-docs.md          # /bee:review-docs - Documentation review
├── write-api.md            # /bee:write-api - API documentation
└── write-guide.md          # /bee:write-guide - Guide writing
```

**Key Characteristics:**

- Simple `.md` files with YAML frontmatter
- Invoked via `/{command}` syntax
- Typically reference a corresponding skill
- Expand into full skill/agent invocation

### 4. Hooks (`hooks/`)

**Purpose:** Session lifecycle management and automatic initialization

**Structure:**

```
default/hooks/
├── hooks.json              # Hook configuration (SessionStart, UserPromptSubmit)
├── session-start.sh        # Main initialization script
├── generate-skills-ref.py  # Dynamic skill reference generator
└── claude-md-reminder.sh   # CLAUDE.md reminder on prompt submit
```

**Key Characteristics:**

- Triggers on SessionStart events (startup|resume, clear|compact)
- Triggers on UserPromptSubmit for reminders
- Injects skills context into Claude's memory
- Auto-generates skills quick reference from frontmatter
- Ensures mandatory workflows are loaded

### 5. Plugin Configuration (`.claude-plugin/`)

**Purpose:** Integration metadata for Claude Code marketplace

**Structure:**

```
.claude-plugin/
└── marketplace.json    # Multi-plugin registry
    ├── bee-default     # Core skills library
    ├── bee-dev-team    # Developer agents
    ├── bee-finops-team # FinOps regulatory
    ├── bee-pm-team     # Product planning
    ├── bee-pmo-team    # PMO specialists
    └── bee-tw-team     # Technical writing
```

**marketplace.json Schema:**

```json
{
  "name": "ring",
  "description": "...",
  "owner": { "name": "...", "email": "..." },
  "plugins": [
    {
      "name": "bee-default",
      "version": "...",
      "source": "./default",
      "keywords": ["skills", "tdd", "debugging", ...]
    },
    {
      "name": "bee-dev-team",
      "version": "...",
      "source": "./dev-team",
      "keywords": ["developer", "agents"]
    },
    {
      "name": "bee-finops-team",
      "version": "...",
      "source": "./finops-team",
      "keywords": ["finops", "regulatory", "compliance"]
    },
    {
      "name": "bee-pm-team",
      "version": "...",
      "source": "./pm-team",
      "keywords": ["product", "planning"]
    },
    {
      "name": "bee-pmo-team",
      "version": "...",
      "source": "./pmo-team",
      "keywords": ["pmo", "portfolio", "governance"]
    },
    {
      "name": "bee-tw-team",
      "version": "...",
      "source": "./tw-team",
      "keywords": ["technical-writing", "documentation"]
    }
  ]
}
```

## Data & Control Flow

### Session Initialization Flow

```mermaid
sequenceDiagram
    participant User
    participant Claude Code
    participant hooks.json
    participant session-start.sh
    participant generate-skills-ref.py
    participant Claude Context

    User->>Claude Code: Start new session
    Claude Code->>hooks.json: Check SessionStart hooks
    hooks.json->>session-start.sh: Execute initialization
    session-start.sh->>generate-skills-ref.py: Generate skills overview
    generate-skills-ref.py-->>session-start.sh: Return formatted reference
    session-start.sh->>Claude Context: Inject skills + ring:using-ring content
    Claude Context-->>User: Session ready with skills loaded
```

### Skill Invocation Flow

```mermaid
sequenceDiagram
    participant User
    participant Claude
    participant Skill Tool
    participant SKILL.md
    participant TodoWrite

    User->>Claude: Request task
    Claude->>Claude: Check ring:using-ring mandatory workflow
    Claude->>Skill Tool: Invoke relevant skill
    Skill Tool->>SKILL.md: Load skill instructions
    SKILL.md-->>Claude: Return structured workflow
    Claude->>TodoWrite: Create task tracking (if multi-step)
    Claude->>User: Execute skill with progress updates
```

### Parallel Review Flow

```mermaid
sequenceDiagram
    participant User
    participant Claude
    participant Task Tool
    participant ring:code-reviewer
    participant ring:business-logic-reviewer
    participant ring:security-reviewer
    participant ring:test-reviewer
    participant ring:nil-safety-reviewer
    participant ring:consequences-reviewer

    User->>Claude: /bee:codereview
    Note over Claude: Command provides<br/>parallel review workflow

    Claude->>Task Tool: Dispatch 6 parallel tasks

    par Parallel Execution
        Task Tool->>ring:code-reviewer: Review architecture
        and
        Task Tool->>ring:business-logic-reviewer: Review correctness
        and
        Task Tool->>ring:security-reviewer: Review vulnerabilities
        and
        Task Tool->>ring:test-reviewer: Review test coverage
        and
        Task Tool->>ring:nil-safety-reviewer: Review nil safety
        and
        Task Tool->>ring:consequences-reviewer: Review ripple effects
    end

    ring:code-reviewer-->>Claude: Return findings
    ring:business-logic-reviewer-->>Claude: Return findings
    ring:security-reviewer-->>Claude: Return findings
    ring:test-reviewer-->>Claude: Return findings
    ring:nil-safety-reviewer-->>Claude: Return findings
    ring:consequences-reviewer-->>Claude: Return findings

    Note over Claude: Aggregate & prioritize by severity
    Claude->>User: Consolidated report
```

## Integration with Claude Code

### Native Tool Integration

Ring leverages four primary Claude Code tools:

1. **Skill Tool**

   - Invokes skills by name: `skill: "ring:test-driven-development"`
   - Skills expand into full instructions within conversation
   - Skill content becomes part of Claude's working context

2. **Task Tool**

   - Dispatches agents to subagent instances: `Task(subagent_type="ring:code-reviewer")`
   - Enables parallel execution (multiple Tasks in one message)
   - Returns structured reports from independent analysis

3. **TodoWrite Tool**

   - Tracks multi-step workflows: `TodoWrite(todos=[...])`
   - Integrates with skills via shared patterns
   - Provides progress visibility to users

4. **SlashCommand Tool**
   - Executes commands: `SlashCommand(command="/bee:brainstorm")`
   - Commands expand to skill/agent invocations
   - Provides user-friendly shortcuts

### Session Context Injection

At session start, Ring injects two critical pieces of context:

1. **Skills Quick Reference** - Auto-generated overview of all available skills
2. **ring:using-ring Skill** - Mandatory workflow that enforces skill checking

This context becomes part of Claude's memory for the entire session, ensuring:

- Claude knows which skills are available
- Mandatory workflows are enforced
- Skills are checked before any task

## Execution Patterns

### Pattern 1: Mandatory Skill Checking

```
User Request → ring:using-ring check → Relevant skill?
    ├─ Yes → Invoke skill → Follow workflow
    └─ No → Proceed with task
```

**Implementation:** The ring:using-ring skill is loaded at session start and contains strict instructions to check for relevant skills before ANY task.

### Pattern 2: Parallel Review Execution

```
Review Request → /bee:codereview → Dispatch 6 Tasks (parallel)
    ├─ ring:code-reviewer           ─┐
    ├─ ring:business-logic-reviewer  │
    ├─ ring:security-reviewer        │
    ├─ ring:test-reviewer            ┼─→ Aggregate findings → Handle by severity
    ├─ ring:nil-safety-reviewer      │
    └─ ring:consequences-reviewer   ─┘
```

**Implementation:** Single message with 5 Task tool calls ensures parallel execution. All reviewers work independently and return simultaneously.

### Pattern 3: Skill-to-Command Mapping

```
User: /bee:brainstorm
    ↓
SlashCommand Tool
    ↓
commands/brainstorm.md
    ↓
"Use and follow the ring:brainstorming skill"
    ↓
Skill Tool: ring:brainstorming
    ↓
skills/brainstorming/SKILL.md
```

**Implementation:** Commands are thin wrappers that immediately invoke corresponding skills.

### Pattern 4: Progressive Skill Execution

```
Complex Skill → TodoWrite tracking
    ├─ Phase 1: Understanding     [in_progress]
    ├─ Phase 2: Exploration       [pending]
    ├─ Phase 3: Design           [pending]
    └─ Phase 4: Documentation    [pending]
```

**Implementation:** Multi-phase skills use TodoWrite to track progress through structured workflows.

## Component Relationships

### Skills ↔ Agents

**Difference:**

- **Skills:** Instructions executed by current Claude instance
- **Agents:** Specialized reviewers executed by separate Claude instances

**Interaction:**

- Skills can invoke agents (e.g., ring:requesting-code-review skill dispatches review agents)
- Agents don't typically invoke skills (they're independent analyzers)

### Skills ↔ Commands

**Relationship:** One-to-one or one-to-many mapping

- Most commands map directly to a single skill
- Some commands (like review) orchestrate multiple components

**Example Mappings:**

- `/bee:brainstorm` → `ring:brainstorming` skill
- `/bee:write-plan` → `ring:writing-plans` skill
- `/bee:codereview` → dispatches 6 parallel review agents (`ring:code-reviewer`, `ring:business-logic-reviewer`, `ring:security-reviewer`, `ring:test-reviewer`, `ring:nil-safety-reviewer`, `ring:consequences-reviewer`)

### Skills ↔ Shared Patterns

**Relationship:** Inheritance/composition

- Skills reference shared patterns for common behaviors
- Patterns provide reusable workflows (state tracking, failure recovery)

**Example:**

```markdown
# In a skill:

See `skills/shared-patterns/todowrite-integration.md` for tracking setup
```

### Hooks ↔ Skills

**Relationship:** Initialization and context loading

- Hooks load skill metadata at session start
- generate-skills-ref.py scans all SKILL.md frontmatter
- session-start.sh injects ring:using-ring skill content

**Data Flow:**

```
SKILL.md frontmatter → generate-skills-ref.py → formatted overview → session context
```

### Agents ↔ Models

**Relationship:** Model requirement specification

- Agents specify required AI model in frontmatter
- Review agents typically require "opus" for comprehensive analysis
- Model choice affects depth and quality of analysis

### TodoWrite ↔ Skills

**Relationship:** Progress tracking integration

- Multi-step skills create TodoWrite items
- Each phase updates todo status (pending → in_progress → completed)
- Provides user visibility into workflow progress

## Key Architectural Decisions

### 1. Parallel vs Sequential Reviews

**Decision:** Reviews run in parallel, not sequentially
**Rationale:** 3x faster feedback, comprehensive coverage, easier prioritization
**Implementation:** Single message with multiple Task calls

### 2. Session Context Injection

**Decision:** Load all skills metadata at session start
**Rationale:** Ensures Claude always knows available capabilities
**Trade-off:** Larger initial context vs. consistent skill awareness

### 3. Mandatory Workflows

**Decision:** Some skills (ring:using-ring) are non-negotiable
**Rationale:** Prevents common failures, enforces best practices
**Enforcement:** Loaded automatically, contains strict instructions

### 4. Skill vs Agent Separation

**Decision:** Skills for workflows, agents for analysis
**Rationale:** Different execution models (local vs. subagent)
**Benefit:** Clear separation of concerns

### 5. Frontmatter-Driven Discovery

**Decision:** All metadata in YAML frontmatter
**Rationale:** Single source of truth, easy parsing, consistent structure
**Usage:** Auto-generation of documentation, skill matching

## Extension Points

### Adding New Skills

1. Create `skills/{name}/SKILL.md` with frontmatter
2. Skills auto-discovered by generate-skills-ref.py
3. Available immediately after session restart

### Adding New Agents

1. Create `{plugin}/agents/{name}.md` with model specification
2. Include YAML frontmatter: `name`, `description`, `model`, `version`
3. Invoke via Task tool with `subagent_type="ring:{name}"`
4. Review agents can run in parallel via `/bee:codereview`
5. Developer agents provide domain expertise via direct Task invocation

### Adding New Commands

1. Create `commands/{name}.md`
2. Reference skill or agent to invoke
3. Available via `/{name}`

### Adding Shared Patterns

1. Create `skills/shared-patterns/{pattern}.md`
2. Reference from skills that need the pattern
3. Maintains consistency across skills

### Adding New Plugins

1. Create plugin directory: `mkdir -p {plugin-name}/{skills,agents,commands,hooks,lib}`
2. Register in `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "bee-{plugin-name}",
     "version": "0.1.0",
     "source": "./{plugin-name}",
     "keywords": [...]
   }
   ```
   (Note: Initial version is 0.1.0, then managed via version bumps)
3. Create `{plugin-name}/hooks/hooks.json` for initialization
4. Add skills/agents following same structure as `default/`

## Performance Considerations

### Parallel Execution Benefits

- **3x faster reviews** - All reviewers run simultaneously
- **No blocking** - Independent agents don't wait for each other
- **Better resource utilization** - Multiple Claude instances work concurrently

### Context Management

- **Session start overhead** - One-time loading of skills context
- **Skill invocation** - Skills expand inline, no additional calls
- **Agent invocation** - Separate instances, clean context per agent

### Optimization Strategies

1. **Selective agent usage** - Only invoke relevant reviewers
2. **Skill caching** - Skills loaded once per session
3. **Parallel by default** - Never chain reviewers sequentially
4. **Early validation** - Preflight checks prevent wasted work

## Common Patterns and Anti-Patterns

### Patterns to Follow

✅ Check for relevant skills before any task
✅ Run reviewers in parallel for speed
✅ Use TodoWrite for multi-step workflows
✅ Reference shared patterns for consistency
✅ Specify models explicitly for agents

### Anti-Patterns to Avoid

❌ Skipping skill checks (violates ring:using-ring)
❌ Running reviewers sequentially (3x slower)
❌ Implementing without tests (violates TDD)
❌ Claiming completion without verification
❌ Hardcoding workflows instead of using skills

## Troubleshooting Guide

### Skills Not Loading

1. Check hooks/hooks.json configuration
2. Verify session-start.sh is executable
3. Ensure SKILL.md has valid frontmatter

### Parallel Reviews Not Working

1. Ensure all Task calls in single message
2. Verify model specification (opus required)
3. Check agent names match exactly

### Commands Not Recognized

1. Verify command file exists in commands/
2. Check command name matches file name
3. Ensure proper frontmatter in command file

### Context Overflow

1. Consider selective skill loading
2. Use focused agent invocations
3. Clear completed todos regularly

## Summary

Ring's architecture is designed for:

- **Modularity** - Independent, composable components across multiple plugins
- **Performance** - Parallel execution wherever possible (3x faster reviews)
- **Reliability** - Mandatory workflows prevent failures
- **Extensibility** - Easy to add new skills/agents/commands/plugins
- **Scalability** - Marketplace structure supports product and team-specific plugins
- **Integration** - Seamless with Claude Code's native tools

### Current State

_Component counts reflect current state; plugin versions managed in `.claude-plugin/marketplace.json`_

| Component                 | Count      | Location               |
| ------------------------- | ---------- | ---------------------- |
| Active Plugins            | 6          | All plugin directories |
| Skills (bee-default)     | 26         | `default/skills/`      |
| Skills (bee-dev-team)    | 21         | `dev-team/skills/`     |
| Skills (bee-finops-team) | 7          | `finops-team/skills/`  |
| Skills (bee-pm-team)     | 13         | `pm-team/skills/`      |
| Skills (bee-pmo-team)    | 9          | `pmo-team/skills/`     |
| Skills (bee-tw-team)     | 7          | `tw-team/skills/`      |
| **Total Skills**          | **83**     | **All plugins**        |
| Agents (bee-default)     | 8          | `default/agents/`      |
| Agents (bee-dev-team)    | 11         | `dev-team/agents/`     |
| Agents (bee-finops-team) | 3          | `finops-team/agents/`  |
| Agents (bee-pm-team)     | 4          | `pm-team/agents/`      |
| Agents (bee-pmo-team)    | 6          | `pmo-team/agents/`     |
| Agents (bee-tw-team)     | 3          | `tw-team/agents/`      |
| **Total Agents**          | **35**     | **All plugins**        |
| Commands (bee-default)   | 13         | `default/commands/`    |
| Commands (bee-dev-team)  | 7          | `dev-team/commands/`   |
| Commands (bee-pm-team)   | 3          | `pm-team/commands/`    |
| Commands (bee-pmo-team)  | 4          | `pmo-team/commands/`   |
| Commands (bee-tw-team)   | 3          | `tw-team/commands/`    |
| **Total Commands**        | **30**     | **All plugins**        |
| Hooks                     | Per plugin | `{plugin}/hooks/`      |

The system achieves these goals through clear component separation, structured workflows, automatic context management, and a modular marketplace architecture, creating a robust foundation for AI-assisted software development.
