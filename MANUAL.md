# Bee Marketplace Manual

Quick reference guide for the Bee skills library and workflow system. This monorepo provides 5 plugins with 77 skills, 38 agents, and 30 slash commands for enforcing proven software engineering practices across the entire software delivery value chain.

---

## 🏗️ Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                              MARKETPLACE (5 PLUGINS)                               │
│                     (monorepo: .claude-plugin/marketplace.json)                    │
│                                                                                    │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                         │
│  │ bee-default  │  │ bee-dev-team │  │ bee-pm-team  │                         │
│  │  Skills(26)   │  │  Skills(21)   │  │  Skills(13)   │                         │
│  │  Agents(8)    │  │  Agents(17)   │  │  Agents(4)    │                         │
│  │  Cmds(13)     │  │  Cmds(7)      │  │  Cmds(3)      │                         │
│  └───────────────┘  └───────────────┘  └───────────────┘                         │
│  ┌───────────────┐  ┌───────────────┐                                            │
│  │ bee-tw-team  │  │ bee-pmo-team │                                            │
│  │  Skills(7)    │  │  Skills(9)    │                                            │
│  │  Agents(3)    │  │  Agents(6)    │                                            │
│  │  Cmds(3)      │  │  Cmds(4)      │                                            │
│  └───────────────┘  └───────────────┘                                            │
└────────────────────────────────────────────────────────────────────────────────────┘

                              HOW IT WORKS
                              ────────────

    ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
    │   SESSION    │         │    USER      │         │  CLAUDE CODE │
    │    START     │────────▶│   PROMPT     │────────▶│   WORKING    │
    └──────────────┘         └──────────────┘         └──────────────┘
           │                        │                        │
           ▼                        ▼                        ▼
    ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
    │    HOOKS     │         │   COMMANDS   │         │    SKILLS    │
    │ auto-inject  │         │ user-invoked │         │ auto-applied │
    │   context    │         │  /bee:...   │         │  internally  │
    └──────────────┘         └──────────────┘         └──────────────┘
           │                        │                        │
           │                        ▼                        │
           │                 ┌──────────────┐                │
           └────────────────▶│    AGENTS    │◀───────────────┘
                             │  dispatched  │
                             │  for work    │
                             └──────────────┘

                            COMPONENT ROLES
                            ───────────────

    ┌────────────┬──────────────────────────────────────────────────┐
    │ Component  │ Purpose                                          │
    ├────────────┼──────────────────────────────────────────────────┤
    │ MARKETPLACE│ Monorepo containing all plugins                  │
    │ PLUGIN     │ Self-contained package (skills+agents+commands)  │
    │ HOOK       │ Auto-runs at session events (injects context)    │
    │ SKILL      │ Workflow pattern (Claude Code uses internally)   │
    │ COMMAND    │ User-invokable action (/bee:codereview)         │
    │ AGENT      │ Specialized subprocess (Task tool dispatch)      │
    └────────────┴──────────────────────────────────────────────────┘
```

---

## 🎯 Quick Start

Bee is auto-loaded at session start. Three ways to invoke Bee capabilities:

1. **Slash Commands** – `/command-name`
2. **Skills** – `Skill tool: "bee:skill-name"`
3. **Agents** – `Task tool with subagent_type: "bee:agent-name"`

---

## 📋 Slash Commands

Commands are invoked directly: `/command-name`.

### Project & Feature Workflows

| Command                         | Use Case                                    | Example                                            |
| ------------------------------- | ------------------------------------------- | -------------------------------------------------- |
| `/bee:brainstorm [topic]`      | Interactive design refinement before coding | `/bee:brainstorm user-authentication`             |
| `/bee:explore-codebase [path]` | Autonomous two-phase codebase exploration   | `/bee:explore-codebase payment/`                  |
| `/bee:interview-me [topic]`    | Proactive requirements gathering interview  | `/bee:interview-me auth-system`                   |
| `/bee:md-to-html [file]`       | Transform a markdown file into an HTML page | `/bee:md-to-html architecture.md`                 |
| `/bee:release-guide`           | Generate step-by-step release instructions  | `/bee:release-guide`                              |
| `/bee:pre-dev-feature [name]`  | Plan simple features (<2 days) – 5 gates    | `/bee:pre-dev-feature logout-button`              |
| `/bee:pre-dev-full [name]`     | Plan complex features (≥2 days) – 10 gates  | `/bee:pre-dev-full payment-system`                |
| `/bee:worktree [branch-name]`  | Create isolated git workspace               | `/bee:worktree auth-system`                       |
| `/bee:write-plan [feature]`    | Generate detailed task breakdown            | `/bee:write-plan dashboard-redesign`              |
| `/bee:execute-plan [path]`     | Execute plan in batches with checkpoints    | `/bee:execute-plan docs/pre-dev/feature/tasks.md` |
| `/bee:delivery-status`         | Show delivery status and tracking           | `/bee:delivery-status`                            |

### Code & Integration Workflows

| Command                             | Use Case                                       | Example                                              |
| ----------------------------------- | ---------------------------------------------- | ---------------------------------------------------- |
| `/bee:codereview [files-or-paths]` | Dispatch 6 parallel code reviewers             | `/bee:codereview src/auth/`                         |
| `/bee:commit [message]`            | Create git commit with AI trailers             | `/bee:commit "fix(auth): improve token validation"` |
| `/bee:lint [path]`                 | Run lint and dispatch agents to fix all issues | `/bee:lint src/`                                    |

### Session Management

| Command                       | Use Case                              | Example                                                |
| ----------------------------- | ------------------------------------- | ------------------------------------------------------ |
| `/bee:create-handoff [name]` | Create handoff document before /clear | `/bee:create-handoff auth-refactor`                   |
| `/bee:resume-handoff [path]` | Resume from handoff after /clear      | `/bee:resume-handoff docs/handoffs/auth-refactor/...` |

### Development Cycle (bee-dev-team)

| Command                     | Use Case                           | Example                                 |
| --------------------------- | ---------------------------------- | --------------------------------------- |
| `/bee:dev-cycle [task]`    | Start 8-gate development workflow | `/bee:dev-cycle "implement user auth"` |
| `/bee:dev-cycle-frontend [task]` | Start 9-gate frontend workflow | `/bee:dev-cycle-frontend "improve dashboard UX"` |
| `/bee:dev-refactor [path]` | Analyze codebase against standards | `/bee:dev-refactor src/`               |
| `/bee:dev-refactor-frontend [path]` | Analyze frontend against standards | `/bee:dev-refactor-frontend web/` |
| `/bee:dev-status`          | Show current gate progress         | `/bee:dev-status`                      |
| `/bee:dev-report`          | Generate development cycle report  | `/bee:dev-report`                      |
| `/bee:dev-cancel`          | Cancel active development cycle    | `/bee:dev-cancel`                      |

### Technical Writing (Documentation)

| Command                      | Use Case                         | Example                            |
| ---------------------------- | -------------------------------- | ---------------------------------- |
| `/bee:write-guide [topic]`  | Start writing a functional guide | `/bee:write-guide authentication` |
| `/bee:write-api [endpoint]` | Start writing API documentation  | `/bee:write-api POST /accounts`   |
| `/bee:review-docs [file]`   | Review documentation for quality | `/bee:review-docs docs/guide.md`  |

### PMO Portfolio (bee-pmo-team)

| Command                             | Use Case                         | Example                                    |
| ----------------------------------- | -------------------------------- | ------------------------------------------ |
| `/bee:portfolio-review [scope]`    | Comprehensive portfolio review   | `/bee:portfolio-review Q1-2025`           |
| `/bee:dependency-analysis [scope]` | Cross-project dependency mapping | `/bee:dependency-analysis payment-system` |
| `/bee:executive-summary [scope]`   | Executive status summary         | `/bee:executive-summary board-meeting`    |
| `/bee:delivery-report [scope]`     | Generate delivery status report  | `/bee:delivery-report Q1-2025`            |

---

## 💡 About Skills

Skills (76) are workflows that Claude Code invokes automatically when it detects they're applicable. They handle testing, debugging, verification, planning, and code review enforcement. You don't call them directly - Claude Code uses them internally to enforce best practices.

Examples: bee:test-driven-development, bee:systematic-debugging, bee:requesting-code-review, bee:verification-before-completion, bee:production-readiness-audit (44-dimension audit, up to 10 explorers per batch, incremental report 0-430, max 440 with multi-tenant; see [default/skills/production-readiness-audit/SKILL.md](default/skills/production-readiness-audit/SKILL.md)), etc.

### Skill Selection Criteria

Each skill has structured frontmatter that helps Claude Code determine which skill to use:

| Field         | Purpose                           | Example                                  |
| ------------- | --------------------------------- | ---------------------------------------- |
| `description` | WHAT the skill does               | "Four-phase debugging framework..."      |
| `trigger`     | WHEN to use (specific conditions) | "Bug reported", "Test failure observed"  |
| `skip_when`   | WHEN NOT to use (exclusions)      | "Root cause already known → just fix it" |
| `sequence`    | Workflow ordering (optional)      | `after: [prd-creation]`                  |
| `related`     | Similar/complementary skills      | `similar: [root-cause-tracing]`          |

**How Claude Code chooses skills:**

1. Checks `trigger` conditions against current context
2. Uses `skip_when` to differentiate from similar skills
3. Considers `sequence` for workflow ordering
4. References `related` for disambiguation when multiple skills match

---

## 🤖 Available Agents

Invoke via `Task tool with subagent_type: "..."`.

### Code Review (bee-default)

**Always dispatch all 6 in parallel** (single message, 6 Task calls):

| Agent                          | Purpose                                      | Model |
| ------------------------------ | -------------------------------------------- | ----- |
| `bee:code-reviewer`           | Architecture, patterns, maintainability      | Opus  |
| `bee:business-logic-reviewer` | Domain correctness, edge cases, requirements | Opus  |
| `bee:security-reviewer`       | Vulnerabilities, OWASP, auth, validation     | Opus  |
| `bee:test-reviewer`           | Test coverage, quality, and completeness     | Opus  |
| `bee:nil-safety-reviewer`     | Nil/null pointer safety analysis             | Opus  |
| `bee:consequences-reviewer`   | Ripple effect, caller impact, downstream consequences | Opus  |

**Example:** Before merging, run all 6 parallel reviewers via `/bee:codereview src/`

### Planning & Analysis (bee-default)

| Agent                    | Purpose                                                  | Model |
| ------------------------ | -------------------------------------------------------- | ----- |
| `bee:write-plan`        | Generate implementation plans for zero-context execution | Opus  |
| `bee:codebase-explorer` | Deep architecture analysis (vs `Explore` for speed)      | Opus  |

### Developer Specialists (bee-dev-team)

Use when you need expert depth in specific domains:

| Agent                                   | Specialization               | Technologies                                       |
| --------------------------------------- | ---------------------------- | -------------------------------------------------- |
| `bee:backend-engineer-typescript`      | TypeScript/Node.js backend   | Express, NestJS, Prisma, TypeORM, GraphQL          |
| `bee:database-engineer`                | Database engineering         | PostgreSQL, MySQL, MongoDB, Redis, schema design, indexing, migration safety |
| `bee:frontend-bff-engineer-typescript` | BFF & React/Next.js frontend | Next.js API Routes, Clean Architecture, DDD, React |
| `bee:frontend-designer`                | Visual design & aesthetics   | Typography, motion, CSS, distinctive UI            |
| `bee:frontend-engineer`                | General frontend development | React, TypeScript, CSS, component architecture     |
| `bee:prompt-quality-reviewer`          | AI prompt quality review     | Prompt engineering, clarity, effectiveness         |
| `bee:qa-analyst`                       | Quality assurance            | Test strategy, automation, coverage                |
| `bee:qa-analyst-frontend`              | Frontend QA specialist       | Accessibility, visual regression, E2E, performance |
| `bee:sre`                              | Site reliability & ops       | Monitoring, alerting, incident response, SLOs      |
| `bee:ui-engineer`                      | UI component specialist      | Design systems, accessibility, React               |

**Standards Compliance Output:** All bee-dev-team agents include a `## Standards Compliance` output section with conditional requirement:

| Invocation Context      | Standards Compliance | Trigger                                   |
| ----------------------- | -------------------- | ----------------------------------------- |
| Direct agent call       | Optional             | N/A                                       |
| Via `bee:dev-cycle`    | Optional             | N/A                                       |
| Via `bee:dev-refactor` | **MANDATORY**        | Prompt contains `**MODE: ANALYSIS ONLY**` |

**How it works:**

1. `bee:dev-refactor` dispatches agents with `**MODE: ANALYSIS ONLY**` in prompt
2. Agents detect this pattern and load Bee standards via WebFetch
3. Agents produce comparison tables: Current Pattern vs Expected Pattern
4. Output includes severity, location, and migration recommendations

**Example output when non-compliant:**

```markdown
## Standards Compliance

| Category | Current     | Expected        | Status | Location      |
| -------- | ----------- | --------------- | ------ | ------------- |
| Logging  | echo/error_log | Log::info()    | ⚠️     | app/Services/\*.php |
```

**Cross-references:** CLAUDE.md (Standards Compliance section), `dev-team/skills/dev-refactor/SKILL.md`

### Product Planning Research (bee-pm-team)

For best practices research and repository analysis:

| Agent                            | Purpose                          | Use For                                 |
| -------------------------------- | -------------------------------- | --------------------------------------- |
| `bee:best-practices-researcher` | Best practices research          | Industry patterns, framework standards  |
| `bee:framework-docs-researcher` | Framework documentation research | Official docs, API references, examples |
| `bee:repo-research-analyst`     | Repository analysis              | Codebase patterns, structure analysis   |
| `bee:product-designer`          | Product design and UX research   | UX specifications, user validation, design review |

### Technical Writing (bee-tw-team)

For documentation creation and review:

| Agent                    | Purpose                      | Use For                              |
| ------------------------ | ---------------------------- | ------------------------------------ |
| `bee:functional-writer` | Functional documentation     | Guides, tutorials, conceptual docs   |
| `bee:api-writer`        | API reference documentation  | Endpoints, schemas, examples         |
| `bee:docs-reviewer`     | Documentation quality review | Voice, tone, structure, completeness |

### PMO Specialists (bee-pmo-team)

For portfolio-level project management and oversight:

| Agent                        | Purpose                   | Use For                                         |
| ---------------------------- | ------------------------- | ----------------------------------------------- |
| `bee:portfolio-manager`     | Portfolio-level planning  | Multi-project coordination, strategic alignment |
| `bee:resource-planner`      | Capacity planning         | Resource allocation, conflict resolution        |
| `bee:risk-analyst`          | Portfolio risk management | Risk identification, mitigation planning        |
| `bee:governance-specialist` | Process compliance        | Gate reviews, audit readiness                   |
| `bee:executive-reporter`    | Executive communications  | Dashboards, board packages, status summaries    |
| `bee:delivery-reporter`     | Delivery reporting        | Delivery status reports and tracking            |

---

## 📖 Common Workflows

### New Feature Development

1. **Design** → `/bee:brainstorm feature-name`
2. **Plan** → `/bee:pre-dev-feature feature-name` (or `bee:pre-dev-full` if complex)
3. **Isolate** → `/bee:worktree feature-branch`
4. **Implement** → Use `bee:test-driven-development` skill
5. **Review** → `/bee:codereview src/` (dispatches 6 reviewers)
6. **Commit** → `/bee:commit "message"`

### Bug Investigation

1. **Investigate** → Use `bee:systematic-debugging` skill
2. **Trace** → Use `bee:root-cause-tracing` if needed
3. **Implement** → Use `bee:test-driven-development` skill
4. **Verify** → Use `bee:verification-before-completion` skill
5. **Review & Merge** → `/bee:codereview` + `/bee:commit`

### Code Review

```
/bee:codereview [files-or-paths]
    ↓
Runs in parallel:
  • bee:code-reviewer (Opus)
  • bee:business-logic-reviewer (Opus)
  • bee:security-reviewer (Opus)
  • bee:test-reviewer (Opus)
  • bee:nil-safety-reviewer (Opus)
  • bee:consequences-reviewer (Opus)
    ↓
Consolidated report with recommendations
```

---

## 🎓 Mandatory Rules

These enforce quality standards:

1. **TDD is enforced** – Test must fail (RED) before implementation
2. **Skill check is mandatory** – Use `bee:using-bee` before any task
3. **Reviewers run parallel** – Never sequential review (use `/bee:codereview`)
4. **Verification required** – Don't claim complete without evidence
5. **No incomplete code** – No "TODO" or placeholder comments
6. **Error handling required** – Don't ignore errors

---

## 💡 Best Practices

### Command Selection

| Situation                                              | Use This                |
| ------------------------------------------------------ | ----------------------- |
| New feature, unsure about design                       | `/bee:brainstorm`      |
| Feature will take < 2 days                             | `/bee:pre-dev-feature` |
| Feature will take ≥ 2 days or has complex dependencies | `/bee:pre-dev-full`    |
| Need implementation tasks                              | `/bee:write-plan`      |
| Before merging code                                    | `/bee:codereview`      |

### Agent Selection

| Need                              | Agent to Use                                |
| --------------------------------- | ------------------------------------------- |
| General code quality review       | 6 parallel reviewers via `/bee:codereview` |
| Implementation planning           | `bee:write-plan`                           |
| Deep codebase analysis            | `bee:codebase-explorer`                    |
| TypeScript/Node.js backend        | `bee:backend-engineer-typescript`          |
| Database design & optimization    | `bee:database-engineer`                    |
| React/Next.js frontend & BFF      | `bee:frontend-bff-engineer-typescript`     |
| General frontend development      | `bee:frontend-engineer`                    |
| Visual design & aesthetics        | `bee:frontend-designer`                    |
| UI component development          | `bee:ui-engineer`                          |
| AI prompt quality review          | `bee:prompt-quality-reviewer`              |
| Backend quality assurance          | `bee:qa-analyst`                           |
| Frontend quality assurance         | `bee:qa-analyst-frontend`                  |
| Site reliability & operations     | `bee:sre`                                  |
| Best practices research           | `bee:best-practices-researcher`            |
| Framework documentation research  | `bee:framework-docs-researcher`            |
| Repository analysis               | `bee:repo-research-analyst`                |
| Product design & UX research      | `bee:product-designer`                     |
| Functional documentation (guides) | `bee:functional-writer`                    |
| API reference documentation       | `bee:api-writer`                           |
| Documentation quality review      | `bee:docs-reviewer`                        |
| Portfolio-level planning          | `bee:portfolio-manager`                    |
| Resource capacity planning        | `bee:resource-planner`                     |
| Portfolio risk assessment         | `bee:risk-analyst`                         |
| Governance and compliance         | `bee:governance-specialist`                |
| Executive reporting               | `bee:executive-reporter`                   |
| Delivery status reporting         | `bee:delivery-reporter`                    |

---

## 🔧 How Bee Works

### Session Startup

1. SessionStart hook runs automatically
2. All 76 skills are auto-discovered and available
3. `bee:using-bee` workflow is activated (skill checking is now mandatory)

### Agent Dispatching

```
Task tool:
  subagent_type: "bee:code-reviewer"
  model: "opus"
  prompt: [context]
    ↓
Runs agent with Opus model
    ↓
Returns structured output per agent's output_schema
```

### Parallel Review Pattern

```
Single message with 6 Task calls (not sequential):

Task #1: bee:code-reviewer
Task #2: bee:business-logic-reviewer
Task #3: bee:security-reviewer
Task #4: bee:test-reviewer
Task #5: bee:nil-safety-reviewer
Task #6: bee:consequences-reviewer
    ↓
All run in parallel (saves ~15 minutes vs sequential)
    ↓
Consolidated report
```

### Environment Variables

| Variable                | Default | Purpose                                                |
| ----------------------- | ------- | ------------------------------------------------------ |
| `CLAUDE_PLUGIN_ROOT`    | (auto)  | Path to installed plugin directory                     |

---

## 📚 More Information

- **Full Documentation** → `default/skills/*/SKILL.md` files
- **Agent Definitions** → `default/agents/*.md` files
- **Commands** → `default/commands/*.md` files
- **Plugin Config** → `.claude-plugin/marketplace.json`
- **CLAUDE.md** → Project-specific instructions (checked into repo)

---

## ❓ Need Help?

- **How to use Claude Code?** → Ask about Claude Code features, MCP servers, slash commands
- **How to use Bee?** → Check skill names in this manual or in `bee:using-bee` skill
- **Feature/bug tracking?** → https://github.com/luanrodrigues/ia-frmwrk/issues
