# Bee Workflows Reference

This document contains detailed workflow instructions for adding skills, agents, hooks, and other Bee components.

---

## Adding a New Skill

### For Core Bee Skills

1. Create directory:

   ```bash
   mkdir default/skills/your-skill-name/
   ```

2. Write `default/skills/your-skill-name/SKILL.md` with frontmatter:

   ```yaml
   ---
   name: your-skill-name
   description: |
     Brief description of WHAT the skill does (method/technique).

   trigger: |
     - Specific condition that mandates this skill
     - Another trigger condition

   skip_when: |
     - When NOT to use → alternative skill
     - Another exclusion

   sequence:
     after: [prerequisite-skill] # Optional: ordering
     before: [following-skill]

   related:
     similar: [differentiate-from] # Optional: disambiguation
     complementary: [pairs-well-with]
   ---
   ```

3. Test with:

   ```
   Skill tool: "bee:testing-skills-with-subagents"
   ```

4. Skill auto-loads next SessionStart via `default/hooks/generate-skills-ref.py`

### Production Readiness Audit (bee-default)

The **production-readiness-audit** skill (`bee:production-readiness-audit`) evaluates codebase production readiness across **27 dimensions** in 5 categories. **Invocation:** use the Skill tool or the `/bee:production-readiness-audit` command when preparing for production, conducting security/quality reviews, or assessing technical debt. **Batch behavior:** runs 10 explorer agents per batch and appends results incrementally to a single report file (`docs/audits/production-readiness-{date}-{time}.md`) to avoid context bloat. **Output:** 27-dimension scored report (0–270) with severity ratings and standards cross-reference. Implementation details: [default/skills/production-readiness-audit/SKILL.md](../default/skills/production-readiness-audit/SKILL.md).

### For Product/Team-Specific Skills

1. Create plugin directory:

   ```bash
   mkdir -p product-xyz/{skills,agents,commands,hooks}
   ```

2. Add to `.claude-plugin/marketplace.json`:

   ```json
   {
     "name": "bee-product-xyz",
     "description": "Product XYZ specific skills",
     "version": "0.1.0",
     "source": "./product-xyz"
   }
   ```

3. Follow same skill structure as default plugin

---

## Modifying Hooks

1. Edit `default/hooks/hooks.json` for trigger configuration

2. Scripts in `default/hooks/`:

   - `session-start.sh` - Runs on startup
   - `claude-md-bootstrap.sh` - CLAUDE.md context

3. Test hook output:

   ```bash
   bash default/hooks/session-start.sh
   ```

   Must output JSON with `additionalContext` field

4. SessionStart hooks run on:

   - `startup|resume`
   - `clear|compact`

5. Note: `${CLAUDE_PLUGIN_ROOT}` resolves to plugin root (`default/` for core plugin)

---

## Plugin-Specific Using-\* Skills

Each plugin auto-loads a `using-{plugin}` skill via SessionStart hook to introduce available agents and capabilities:

### Default Plugin

- `bee:using-bee` → ORCHESTRATOR principle, mandatory workflow
- Always injected, always mandatory
- Located: `default/skills/using-bee/SKILL.md`

### Bee Dev Team Plugin

- `bee:using-dev-team` → 10 specialist developer agents
- Auto-loads when bee-dev-team plugin is enabled
- Located: `dev-team/skills/using-dev-team/SKILL.md`
- Agents (invoke as `bee:{agent-name}`):
  - bee:backend-engineer-typescript
  - bee:devops-engineer
  - bee:frontend-bff-engineer-typescript
  - bee:frontend-designer
  - bee:frontend-engineer
  - bee:prompt-quality-reviewer
  - bee:qa-analyst
  - bee:sre
  - bee:ui-engineer

### Bee PM Team Plugin

- `bee:using-pm-team` → Pre-dev workflow skills (8 gates)
- Auto-loads when bee-pm-team plugin is enabled
- Located: `pm-team/skills/using-pm-team/SKILL.md`
- Skills: 8 pre-dev gates for feature planning

### Bee TW Team Plugin

- `using-tw-team` → 3 technical writing agents for documentation
- Auto-loads when bee-tw-team plugin is enabled
- Located: `tw-team/skills/using-tw-team/SKILL.md`
- Agents (invoke as `bee:{agent-name}`):
  - bee:functional-writer (guides)
  - bee:api-writer (API reference)
  - bee:docs-reviewer (quality review)
- Commands: write-guide, write-api, review-docs

### Bee FinOps Team Plugin

- `using-finops-team` → 3 FinOps agents for Brazilian compliance and cost estimation
- Auto-loads when bee-finops-team plugin is enabled
- Located: `finops-team/skills/using-finops-team/SKILL.md`
- Agents (invoke as `{agent-name}`):
  - finops-analyzer (compliance analysis)
  - infrastructure-cost-estimator (cost estimation)
  - finops-automation (template generation)

### Hook Configuration

- Each plugin has: `{plugin}/hooks/hooks.json` + `{plugin}/hooks/session-start.sh`
- SessionStart hook executes, outputs additionalContext with skill reference
- Only plugins in marketplace.json get loaded (conditional)

---

## Creating Review Agents

1. Add to `default/agents/your-reviewer.md` with output_schema (see [AGENT_DESIGN.md](AGENT_DESIGN.md))

2. Reference in `default/skills/requesting-code-review/SKILL.md:85`

3. Dispatch via Task tool:

   ```
   subagent_type="bee:your-reviewer"
   ```

4. **MUST run in parallel** with other reviewers (single message, multiple Tasks)

---

## Pre-Dev Workflow

### Simple Features (<2 days): `/bee:pre-dev-feature`

```
├── Gate 0: pm-team/skills/pre-dev-research
│   └── Output: docs/pre-dev/feature/research.md (parallel agents)
├── Gate 1: pm-team/skills/pre-dev-prd-creation
│   └── Output: docs/pre-dev/feature/PRD.md
├── Gate 2: pm-team/skills/pre-dev-trd-creation
│   └── Output: docs/pre-dev/feature/TRD.md
└── Gate 3: pm-team/skills/pre-dev-task-breakdown
    └── Output: docs/pre-dev/feature/tasks.md
```

### Complex Features (≥2 days): `/bee:pre-dev-full`

```
├── Gate 0: Research Phase
│   └── 3 parallel agents: repo-research, best-practices, framework-docs
├── Gates 1-3: Same as simple workflow
├── Gate 4: pm-team/skills/pre-dev-api-design
│   └── Output: docs/pre-dev/feature/API.md
├── Gate 5: pm-team/skills/pre-dev-data-model
│   └── Output: docs/pre-dev/feature/data-model.md
├── Gate 6: pm-team/skills/pre-dev-dependency-map
│   └── Output: docs/pre-dev/feature/dependencies.md
├── Gate 7: pm-team/skills/pre-dev-task-breakdown
│   └── Output: docs/pre-dev/feature/tasks.md
└── Gate 8: pm-team/skills/pre-dev-subtask-creation
    └── Output: docs/pre-dev/feature/subtasks.md
```

---

## Development Cycle (8-gate)

The **bee:dev-cycle** skill orchestrates task execution through **8 gates**: implementation (Gate 0) → devops (Gate 0 pre-check) → unit-testing (Gate 1) → fuzz-testing (Gate 2) → property-testing (Gate 3) → integration-testing (Gate 4) → chaos-testing (Gate 5) → review (Gate 6) → validation (Gate 7). All gates are MANDATORY. Invoke with `/bee:dev-cycle [tasks-file]` or Skill tool `bee:dev-cycle`. State is persisted to `docs/bee:dev-cycle/current-cycle.json`. See [dev-team/skills/dev-cycle/SKILL.md](../dev-team/skills/dev-cycle/SKILL.md) for full protocol.

---

## Parallel Code Review

### Instead of sequential (100 min)

```python
review1 = Task("bee:code-reviewer")           # 20 min
review2 = Task("bee:business-logic-reviewer") # 20 min
review3 = Task("bee:security-reviewer")       # 20 min
review4 = Task("bee:test-reviewer")           # 20 min
review5 = Task("bee:nil-safety-reviewer")     # 20 min
```

### Run parallel (20 min total)

```python
Task.parallel([
    ("bee:code-reviewer", prompt),
    ("bee:business-logic-reviewer", prompt),
    ("bee:security-reviewer", prompt),
    ("bee:nil-safety-reviewer", prompt),
    ("bee:test-reviewer", prompt),
    ("bee:consequences-reviewer", prompt)
])  # Single message, 6 tool calls
```

### Key rule

Always dispatch all 6 reviewers in a single message with multiple Task tool calls.

---

## Related Documents

- [CLAUDE.md](../CLAUDE.md) - Main project instructions (references this document)
- [AGENT_DESIGN.md](AGENT_DESIGN.md) - Agent output schemas
- [PROMPT_ENGINEERING.md](PROMPT_ENGINEERING.md) - Language patterns
