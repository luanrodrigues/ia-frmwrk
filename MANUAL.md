# Ring Marketplace Manual

Quick reference guide for the Ring skills library and workflow system. This monorepo provides 6 plugins with 83 skills, 35 agents, and 30 slash commands for enforcing proven software engineering practices across the entire software delivery value chain.

---

## 🏗️ Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                              MARKETPLACE (6 PLUGINS)                               │
│                     (monorepo: .claude-plugin/marketplace.json)                    │
│                                                                                    │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │
│  │ ring-default  │  │ ring-dev-team │  │ ring-pm-team  │  │ring-finops-   │      │
│  │  Skills(26)   │  │  Skills(21)   │  │  Skills(13)   │  │  team         │      │
│  │  Agents(8)    │  │  Agents(11)   │  │  Agents(4)    │  │  Skills(7)    │      │
│  │  Cmds(13)     │  │  Cmds(7)      │  │  Cmds(3)      │  │  Agents(3)    │      │
│  └───────────────┘  └───────────────┘  └───────────────┘  └───────────────┘      │
│  ┌───────────────┐  ┌───────────────┐                                            │
│  │ ring-tw-team  │  │ ring-pmo-team │                                            │
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

Ring is auto-loaded at session start. Three ways to invoke Ring capabilities:

1. **Slash Commands** – `/command-name`
2. **Skills** – `Skill tool: "ring:skill-name"`
3. **Agents** – `Task tool with subagent_type: "ring:agent-name"`

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

### Development Cycle (ring-dev-team)

| Command                     | Use Case                           | Example                                 |
| --------------------------- | ---------------------------------- | --------------------------------------- |
| `/bee:dev-cycle [task]`    | Start 11-gate development workflow | `/bee:dev-cycle "implement user auth"` |
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

### PMO Portfolio (ring-pmo-team)

| Command                             | Use Case                         | Example                                    |
| ----------------------------------- | -------------------------------- | ------------------------------------------ |
| `/bee:portfolio-review [scope]`    | Comprehensive portfolio review   | `/bee:portfolio-review Q1-2025`           |
| `/bee:dependency-analysis [scope]` | Cross-project dependency mapping | `/bee:dependency-analysis payment-system` |
| `/bee:executive-summary [scope]`   | Executive status summary         | `/bee:executive-summary board-meeting`    |
| `/bee:delivery-report [scope]`     | Generate delivery status report  | `/bee:delivery-report Q1-2025`            |

---

## 💡 About Skills

Skills (83) are workflows that Claude Code invokes automatically when it detects they're applicable. They handle testing, debugging, verification, planning, and code review enforcement. You don't call them directly - Claude Code uses them internally to enforce best practices.

Examples: ring:test-driven-development, ring:systematic-debugging, ring:requesting-code-review, ring:verification-before-completion, ring:production-readiness-audit (44-dimension audit, up to 10 explorers per batch, incremental report 0-430, max 440 with multi-tenant; see [default/skills/production-readiness-audit/SKILL.md](default/skills/production-readiness-audit/SKILL.md)), etc.

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

### Code Review (ring-default)

**Always dispatch all 6 in parallel** (single message, 6 Task calls):

| Agent                          | Purpose                                      | Model |
| ------------------------------ | -------------------------------------------- | ----- |
| `ring:code-reviewer`           | Architecture, patterns, maintainability      | Opus  |
| `ring:business-logic-reviewer` | Domain correctness, edge cases, requirements | Opus  |
| `ring:security-reviewer`       | Vulnerabilities, OWASP, auth, validation     | Opus  |
| `ring:test-reviewer`           | Test coverage, quality, and completeness     | Opus  |
| `ring:nil-safety-reviewer`     | Nil/null pointer safety analysis             | Opus  |
| `ring:consequences-reviewer`   | Ripple effect, caller impact, downstream consequences | Opus  |

**Example:** Before merging, run all 6 parallel reviewers via `/bee:codereview src/`

### Planning & Analysis (ring-default)

| Agent                    | Purpose                                                  | Model |
| ------------------------ | -------------------------------------------------------- | ----- |
| `ring:write-plan`        | Generate implementation plans for zero-context execution | Opus  |
| `ring:codebase-explorer` | Deep architecture analysis (vs `Explore` for speed)      | Opus  |

### Developer Specialists (ring-dev-team)

Use when you need expert depth in specific domains:

| Agent                                   | Specialization               | Technologies                                       |
| --------------------------------------- | ---------------------------- | -------------------------------------------------- |
| `ring:backend-engineer-golang`          | Go microservices & APIs      | Fiber, gRPC, PostgreSQL, MongoDB, Kafka, OAuth2    |
| `ring:backend-engineer-typescript`      | TypeScript/Node.js backend   | Express, NestJS, Prisma, TypeORM, GraphQL          |
| `ring:devops-engineer`                  | Infrastructure & CI/CD       | Docker, Kubernetes, Terraform, GitHub Actions      |
| `ring:frontend-bff-engineer-typescript` | BFF & React/Next.js frontend | Next.js API Routes, Clean Architecture, DDD, React |
| `ring:frontend-designer`                | Visual design & aesthetics   | Typography, motion, CSS, distinctive UI            |
| `ring:frontend-engineer`                | General frontend development | React, TypeScript, CSS, component architecture     |
| `ring:prompt-quality-reviewer`          | AI prompt quality review     | Prompt engineering, clarity, effectiveness         |
| `ring:qa-analyst`                       | Quality assurance            | Test strategy, automation, coverage                |
| `ring:qa-analyst-frontend`              | Frontend QA specialist       | Accessibility, visual regression, E2E, performance |
| `ring:sre`                              | Site reliability & ops       | Monitoring, alerting, incident response, SLOs      |
| `ring:ui-engineer`                      | UI component specialist      | Design systems, accessibility, React               |

**Standards Compliance Output:** All ring-dev-team agents include a `## Standards Compliance` output section with conditional requirement:

| Invocation Context      | Standards Compliance | Trigger                                   |
| ----------------------- | -------------------- | ----------------------------------------- |
| Direct agent call       | Optional             | N/A                                       |
| Via `ring:dev-cycle`    | Optional             | N/A                                       |
| Via `ring:dev-refactor` | **MANDATORY**        | Prompt contains `**MODE: ANALYSIS ONLY**` |

**How it works:**

1. `ring:dev-refactor` dispatches agents with `**MODE: ANALYSIS ONLY**` in prompt
2. Agents detect this pattern and load Ring standards via WebFetch
3. Agents produce comparison tables: Current Pattern vs Expected Pattern
4. Output includes severity, location, and migration recommendations

**Example output when non-compliant:**

```markdown
## Standards Compliance

| Category | Current     | Expected        | Status | Location      |
| -------- | ----------- | --------------- | ------ | ------------- |
| Logging  | fmt.Println | lib-commons/zap | ⚠️     | service/\*.go |
```

**Cross-references:** CLAUDE.md (Standards Compliance section), `dev-team/skills/dev-refactor/SKILL.md`

### Product Planning Research (ring-pm-team)

For best practices research and repository analysis:

| Agent                            | Purpose                          | Use For                                 |
| -------------------------------- | -------------------------------- | --------------------------------------- |
| `ring:best-practices-researcher` | Best practices research          | Industry patterns, framework standards  |
| `ring:framework-docs-researcher` | Framework documentation research | Official docs, API references, examples |
| `ring:repo-research-analyst`     | Repository analysis              | Codebase patterns, structure analysis   |
| `ring:product-designer`          | Product design and UX research   | UX specifications, user validation, design review |

### Technical Writing (ring-tw-team)

For documentation creation and review:

| Agent                    | Purpose                      | Use For                              |
| ------------------------ | ---------------------------- | ------------------------------------ |
| `ring:functional-writer` | Functional documentation     | Guides, tutorials, conceptual docs   |
| `ring:api-writer`        | API reference documentation  | Endpoints, schemas, examples         |
| `ring:docs-reviewer`     | Documentation quality review | Voice, tone, structure, completeness |

### Regulatory & FinOps (ring-finops-team)

For Brazilian financial compliance workflows and cost analysis:

| Agent                                | Purpose                        | Use For                                         |
| ------------------------------------ | ------------------------------ | ----------------------------------------------- |
| `ring:finops-analyzer`               | Regulatory compliance analysis | Field mapping, BACEN/RFB validation (Gates 1-2) |
| `ring:finops-automation`             | Template generation            | Create .tpl files (Gate 3)                      |
| `ring:infrastructure-cost-estimator` | Cost estimation and analysis   | Infrastructure cost planning and optimization   |

### PMO Specialists (ring-pmo-team)

For portfolio-level project management and oversight:

| Agent                        | Purpose                   | Use For                                         |
| ---------------------------- | ------------------------- | ----------------------------------------------- |
| `ring:portfolio-manager`     | Portfolio-level planning  | Multi-project coordination, strategic alignment |
| `ring:resource-planner`      | Capacity planning         | Resource allocation, conflict resolution        |
| `ring:risk-analyst`          | Portfolio risk management | Risk identification, mitigation planning        |
| `ring:governance-specialist` | Process compliance        | Gate reviews, audit readiness                   |
| `ring:executive-reporter`    | Executive communications  | Dashboards, board packages, status summaries    |
| `ring:delivery-reporter`     | Delivery reporting        | Delivery status reports and tracking            |

---

## 📖 Common Workflows

### New Feature Development

1. **Design** → `/bee:brainstorm feature-name`
2. **Plan** → `/bee:pre-dev-feature feature-name` (or `ring:pre-dev-full` if complex)
3. **Isolate** → `/bee:worktree feature-branch`
4. **Implement** → Use `ring:test-driven-development` skill
5. **Review** → `/bee:codereview src/` (dispatches 6 reviewers)
6. **Commit** → `/bee:commit "message"`

### Bug Investigation

1. **Investigate** → Use `ring:systematic-debugging` skill
2. **Trace** → Use `ring:root-cause-tracing` if needed
3. **Implement** → Use `ring:test-driven-development` skill
4. **Verify** → Use `ring:verification-before-completion` skill
5. **Review & Merge** → `/bee:codereview` + `/bee:commit`

### Code Review

```
/bee:codereview [files-or-paths]
    ↓
Runs in parallel:
  • ring:code-reviewer (Opus)
  • ring:business-logic-reviewer (Opus)
  • ring:security-reviewer (Opus)
  • ring:test-reviewer (Opus)
  • ring:nil-safety-reviewer (Opus)
  • ring:consequences-reviewer (Opus)
    ↓
Consolidated report with recommendations
```

---

## 🎓 Mandatory Rules

These enforce quality standards:

1. **TDD is enforced** – Test must fail (RED) before implementation
2. **Skill check is mandatory** – Use `ring:using-ring` before any task
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
| Implementation planning           | `ring:write-plan`                           |
| Deep codebase analysis            | `ring:codebase-explorer`                    |
| Go backend expertise              | `ring:backend-engineer-golang`              |
| TypeScript/Node.js backend        | `ring:backend-engineer-typescript`          |
| Infrastructure/DevOps             | `ring:devops-engineer`                      |
| React/Next.js frontend & BFF      | `ring:frontend-bff-engineer-typescript`     |
| General frontend development      | `ring:frontend-engineer`                    |
| Visual design & aesthetics        | `ring:frontend-designer`                    |
| UI component development          | `ring:ui-engineer`                          |
| AI prompt quality review          | `ring:prompt-quality-reviewer`              |
| Backend quality assurance          | `ring:qa-analyst`                           |
| Frontend quality assurance         | `ring:qa-analyst-frontend`                  |
| Site reliability & operations     | `ring:sre`                                  |
| Best practices research           | `ring:best-practices-researcher`            |
| Framework documentation research  | `ring:framework-docs-researcher`            |
| Repository analysis               | `ring:repo-research-analyst`                |
| Product design & UX research      | `ring:product-designer`                     |
| Functional documentation (guides) | `ring:functional-writer`                    |
| API reference documentation       | `ring:api-writer`                           |
| Documentation quality review      | `ring:docs-reviewer`                        |
| Regulatory compliance analysis    | `ring:finops-analyzer`                      |
| Regulatory template generation    | `ring:finops-automation`                    |
| Infrastructure cost estimation    | `ring:infrastructure-cost-estimator`        |
| Portfolio-level planning          | `ring:portfolio-manager`                    |
| Resource capacity planning        | `ring:resource-planner`                     |
| Portfolio risk assessment         | `ring:risk-analyst`                         |
| Governance and compliance         | `ring:governance-specialist`                |
| Executive reporting               | `ring:executive-reporter`                   |
| Delivery status reporting         | `ring:delivery-reporter`                    |

---

## 🔧 How Ring Works

### Session Startup

1. SessionStart hook runs automatically
2. All 83 skills are auto-discovered and available
3. `ring:using-ring` workflow is activated (skill checking is now mandatory)

### Agent Dispatching

```
Task tool:
  subagent_type: "ring:code-reviewer"
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

Task #1: ring:code-reviewer
Task #2: ring:business-logic-reviewer
Task #3: ring:security-reviewer
Task #4: ring:test-reviewer
Task #5: ring:nil-safety-reviewer
Task #6: ring:consequences-reviewer
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
- **How to use Ring?** → Check skill names in this manual or in `ring:using-ring` skill
- **Feature/bug tracking?** → https://github.com/luanrodrigues/bee/issues
