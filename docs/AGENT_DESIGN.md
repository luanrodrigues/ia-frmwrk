# Agent Design Reference

This document contains agent output schema archetypes and standards compliance requirements for Bee agents.

---

## Agent Output Schema Archetypes

Agents use standard output schema patterns based on their purpose:

### Implementation Schema

**For agents that write code/configs:**

```yaml
output_schema:
  format: "markdown"
  required_sections:
    - name: "Summary"
      pattern: "^## Summary"
      required: true
    - name: "Implementation"
      pattern: "^## Implementation"
      required: true
    - name: "Files Changed"
      pattern: "^## Files Changed"
      required: true
    - name: "Testing"
      pattern: "^## Testing"
      required: true
    - name: "Next Steps"
      pattern: "^## Next Steps"
      required: true
```

**Used by:** `bee:backend-engineer-typescript`, `frontend-bff-engineer-typescript`, `bee:qa-analyst`, `bee:sre`, `finops-automation`

---

### Analysis Schema

**For agents that analyze and recommend:**

```yaml
output_schema:
  format: "markdown"
  required_sections:
    - name: "Analysis"
      pattern: "^## Analysis"
      required: true
    - name: "Findings"
      pattern: "^## Findings"
      required: true
    - name: "Recommendations"
      pattern: "^## Recommendations"
      required: true
    - name: "Next Steps"
      pattern: "^## Next Steps"
      required: true
```

**Used by:** `bee:frontend-designer`, `finops-analyzer`

---

### Reviewer Schema

**For code review agents:**

```yaml
output_schema:
  format: "markdown"
  required_sections:
    - name: "VERDICT"
      pattern: "^## VERDICT: (PASS|FAIL|NEEDS_DISCUSSION)$"
      required: true
    - name: "Summary"
      pattern: "^## Summary"
      required: true
    - name: "Issues Found"
      pattern: "^## Issues Found"
      required: true
    - name: "Categorized Issues"
      pattern: "^### (Critical|High|Medium|Low)"
      required: false
    - name: "What Was Done Well"
      pattern: "^## What Was Done Well"
      required: true
    - name: "Next Steps"
      pattern: "^## Next Steps"
      required: true
```

**Used by:** `bee:code-reviewer`, `bee:business-logic-reviewer`, `bee:security-reviewer`

**Note:** `bee:business-logic-reviewer` and `bee:security-reviewer` extend the base Reviewer Schema with additional domain-specific required sections:
- `bee:business-logic-reviewer` adds: "Mental Execution Analysis", "Business Requirements Coverage", "Edge Cases Analysis"
- `bee:security-reviewer` adds: "OWASP Top 10 Coverage", "Compliance Status"

---

### Exploration Schema

**For deep codebase analysis:**

```yaml
output_schema:
  format: "markdown"
  required_sections:
    - name: "EXPLORATION SUMMARY"
      pattern: "^## EXPLORATION SUMMARY$"
      required: true
    - name: "KEY FINDINGS"
      pattern: "^## KEY FINDINGS$"
      required: true
    - name: "ARCHITECTURE INSIGHTS"
      pattern: "^## ARCHITECTURE INSIGHTS$"
      required: true
    - name: "RELEVANT FILES"
      pattern: "^## RELEVANT FILES$"
      required: true
    - name: "RECOMMENDATIONS"
      pattern: "^## RECOMMENDATIONS$"
      required: true
```

**Used by:** `bee:codebase-explorer`

---

### Planning Schema

**For implementation planning:**

```yaml
output_schema:
  format: "markdown"
  required_sections:
    - name: "Goal"
      pattern: "^\\*\\*Goal:\\*\\*"
      required: true
    - name: "Architecture"
      pattern: "^\\*\\*Architecture:\\*\\*"
      required: true
    - name: "Tech Stack"
      pattern: "^\\*\\*Tech Stack:\\*\\*"
      required: true
    - name: "Global Prerequisites"
      pattern: "^\\*\\*Global Prerequisites:\\*\\*"
      required: true
    - name: "Task"
      pattern: "^### Task \\d+:"
      required: true
```

**Used by:** `bee:write-plan`

---

## Standards Compliance (Conditional Output Section)

The `bee-dev-team` agents include a **Standards Compliance** output section that is conditionally required based on invocation context.

### Schema Definition

All bee-dev-team agents include this in their `output_schema`:

```yaml
- name: "Standards Compliance"
  pattern: "^## Standards Compliance"
  required: false  # In schema, but MANDATORY when invoked from bee:dev-refactor
  description: "Comparison of codebase against Lerian/bee standards. MANDATORY when invoked from bee:dev-refactor skill."
```

### Conditional Requirement: `invoked_from_dev_refactor`

| Context | Standards Compliance Required | Enforcement |
|---------|------------------------------|-------------|
| Direct agent invocation | Optional | Agent may include if relevant |
| Via `bee:dev-cycle` | Optional | Agent may include if relevant |
| Via `bee:dev-refactor` | **MANDATORY** | Prompt includes `MODE: ANALYSIS ONLY` |

**How It's Triggered:**
1. User invokes `/bee:dev-refactor` command
2. The skill dispatches agents with prompts starting with `**MODE: ANALYSIS ONLY**`
3. This prompt pattern signals to agents that Standards Compliance output is MANDATORY
4. Agents load Bee standards via WebFetch and produce comparison tables

**Detection in Agent Prompts:**
```text
If prompt contains "**MODE: ANALYSIS ONLY**":
  → Standards Compliance section is MANDATORY
  → Agent MUST load Bee standards via WebFetch
  → Agent MUST produce comparison tables

If prompt does NOT contain "**MODE: ANALYSIS ONLY**":
  → Standards Compliance section is optional
  → Agent focuses on implementation/other tasks
```

### Affected Agents

All bee-dev-team agents support Standards Compliance:

| Agent | Standards Source | Categories Checked |
|-------|------------------|-------------------|
| `bee:backend-engineer-typescript` | `typescript.md` | Type Safety, Error Handling, Validation |
| `frontend-bff-engineer-typescript` | `frontend.md` | Component patterns, State management |
| `bee:frontend-designer` | `frontend.md` | Accessibility, Design patterns |
| `bee:qa-analyst` | `qa.md` | Test coverage, Test patterns |
| `bee:sre` | `sre.md` | Health endpoints, Logging, Tracing |

### Output Format Examples

**When ALL categories are compliant:**
```markdown
## Standards Compliance

Fully Compliant - Codebase follows all Lerian/bee Standards.

No migration actions required.
```

**When ANY category is non-compliant:**
```markdown
## Standards Compliance

### Lerian/bee Standards Comparison

| Category | Current Pattern | Expected Pattern | Status | File/Location |
|----------|----------------|------------------|--------|---------------|
| Error Handling | Using die() | throw new Exception() | Non-Compliant | UserController.php:45 |
| Logging | Uses echo/var_dump | Log::info() / Monolog | Non-Compliant | app/Services/*.php |
| Config | $_ENV direct | config() / env() helper | Non-Compliant | config/app.php:15 |

### Compliance Summary
- **Total Violations:** 3
- **Critical:** 0
- **High:** 1
- **Medium:** 2
- **Low:** 0

### Required Changes for Compliance

1. **Error Handling Migration**
   - Replace: `die("error message")`
   - With: `throw new \RuntimeException("error message")`
   - Files affected: UserController.php, OrderService.php

2. **Logging Migration**
   - Replace: `echo "debug info"`
   - With: `Log::info("debug info", ['key' => 'value'])`
   - Files affected: app/Services/*.php
```

### Cross-References

| Document | Location | What It Contains |
|----------|----------|-----------------|
| **Skill Definition** | `dev-team/skills/dev-refactor/SKILL.md` | HARD GATES requiring Standards Compliance |
| **Standards Source** | `dev-team/docs/standards/*.md` | Source of truth for compliance checks |
| **Agent Definitions** | `dev-team/agents/*.md` | output_schema includes Standards Compliance |
| **Session Hook** | `dev-team/hooks/session-start.sh` | Injects Standards Compliance guidance |

---

## Related Documents

- [CLAUDE.md](../CLAUDE.md) - Main project instructions (references this document)
- [PROMPT_ENGINEERING.md](PROMPT_ENGINEERING.md) - Language patterns for agent prompts
- [WORKFLOWS.md](WORKFLOWS.md) - How to add/modify agents
