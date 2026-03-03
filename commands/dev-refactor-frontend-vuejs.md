---
name: bee:dev-refactor-frontend-vuejs
description: Analyze existing Vue.js frontend codebase against standards and execute refactoring through bee:dev-cycle-frontend-vuejs
argument-hint: "[path] [options] [prompt]"
---

Analyze existing Vue.js frontend codebase against standards and execute refactoring through bee:dev-cycle-frontend-vuejs.

## PRE-EXECUTION CHECK (EXECUTE FIRST)

**Before loading the skill, you MUST check:**

```
Does docs/PROJECT_RULES.md exist in the target project?
+-- YES -> Load skill: bee:dev-refactor-frontend-vuejs
+-- NO  -> Output blocker below and STOP
```

**If file does not exist, output this EXACT response:**

```markdown
## HARD BLOCK: PROJECT_RULES.md Not Found

**Status:** BLOCKED - Cannot proceed

### Required Action
Create `docs/PROJECT_RULES.md` with your project's:
- Architecture patterns
- Code conventions
- Testing requirements
- DevOps standards

Then re-run `/bee:dev-refactor-frontend-vuejs`.
```

**DO NOT:**
- Use "default" or "industry" standards
- Infer standards from existing code
- Proceed with partial analysis
- Offer to create the file

---

## Usage

```
/bee:dev-refactor-frontend-vuejs [path] [options] [prompt]
/bee:dev-refactor-frontend-vuejs [prompt]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `path` | No | Directory to analyze (default: current project root) |
| `prompt` | No | Direct instruction for refactoring focus (no quotes needed) |

## Options

| Option | Description | Example |
|--------|-------------|---------|
| `--standards PATH` | Custom standards file | `--standards docs/MY_PROJECT_RULES.md` |
| `--analyze-only` | Generate report without executing | `--analyze-only` |
| `--critical-only` | Limit execution/output to Critical and High (analysis still tracks all) | `--critical-only` |
| `--dry-run` | Show what would be analyzed | `--dry-run` |

## Examples

```bash
# Direct prompt - focus refactoring on specific area
/bee:dev-refactor-frontend-vuejs Focus on accessibility compliance and WCAG AA violations

# Direct prompt - another example
/bee:dev-refactor-frontend-vuejs Check component patterns against sindarian-ui and remove shadcn duplicates

# Analyze entire Vue.js frontend project and refactor
/bee:dev-refactor-frontend-vuejs

# Analyze specific directory
/bee:dev-refactor-frontend-vuejs src/components

# Analyze with performance focus
/bee:dev-refactor-frontend-vuejs src/ Focus on Core Web Vitals and bundle size optimization

# Analysis only (no execution)
/bee:dev-refactor-frontend-vuejs --analyze-only

# Only fix critical issues
/bee:dev-refactor-frontend-vuejs --critical-only

# Use custom standards with focus
/bee:dev-refactor-frontend-vuejs --standards docs/team-standards.md Prioritize testing gaps
```

## Workflow

**See skill `bee:dev-refactor-frontend-vuejs` for the complete workflow with TodoWrite template.**

The skill defines all steps including: Vue.js stack detection, Nuxt.js detection, UI library mode detection, bee:codebase-explorer dispatch, individual agent reports, finding mapping, gate escape detection, and artifact generation.

## Analysis Dimensions

**All seven dimensions are MANDATORY for analysis/tracking. The `--critical-only` flag filters execution/output only.**

| Dimension | What's Checked | Standards Reference |
|-----------|----------------|---------------------|
| **Component Architecture** | Vue 3 Composition API patterns, `<script setup>`, Single File Components, Nuxt page/layout structure | `frontend.md` sections 1-3 |
| **UI Library Compliance** | sindarian-ui usage, duplication check | `frontend.md` section 14 |
| **Styling & Design** | Typography, animations, CSS patterns, scoped styles, CSS Modules | `frontend.md` sections 5-7 |
| **Accessibility** | WCAG 2.1 AA, semantic HTML, keyboard navigation, ARIA attributes | `frontend/testing-accessibility.md` |
| **Testing** | Unit coverage, visual snapshots, E2E, performance | `frontend/testing-*.md` |
| **Performance** | Core Web Vitals, Lighthouse, bundle size, Nuxt SSR/SSG optimization | `frontend/testing-performance.md` |
| **DevOps** | Dockerfile, docker-compose, Nginx, CI/CD | `devops.md` |

**Analysis vs Execution:**
- **Analysis (always):** All seven dimensions analyzed, all severities (Critical, High, Medium, Low) tracked
- **Execution (filterable):** `--critical-only` limits execution/prioritization to Critical and High severity issues

Example: `/bee:dev-refactor-frontend-vuejs --critical-only` analyzes all issues but only executes fixes for Critical and High.

## Output

**Timestamp format:** `{timestamp}` = `YYYY-MM-DDTHH:MM:SS` (e.g., `2026-02-10T15:30:00`)

**Codebase Report** (`docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md`):
- Project architecture and structure analysis
- Vue 3 component patterns and UI library usage
- Nuxt.js configuration and module usage (if applicable)

**Agent Reports** (`docs/bee:dev-refactor-frontend-vuejs/{timestamp}/reports/`):
- Individual analysis from each dispatched agent (5-7 agents)
- Standards Coverage Tables per agent

**Findings** (`docs/bee:dev-refactor-frontend-vuejs/{timestamp}/findings.md`):
- All findings with severity, category, file:line references
- Gate escape detection (maps to 9-gate Vue.js frontend cycle)

**Tasks File** (`docs/bee:dev-refactor-frontend-vuejs/{timestamp}/tasks.md`):
- 1:1 mapped REFACTOR-XXX tasks from findings
- Compatible with bee:dev-cycle-frontend-vuejs execution

## Severity Levels (all ARE MANDATORY)

| Level | Description | Priority | Tracking |
|-------|-------------|----------|----------|
| **Critical** | Accessibility violations, security risks, production crashes | Fix immediately | **MANDATORY** |
| **High** | Architecture violations, major performance regressions | Fix in current sprint | **MANDATORY** |
| **Medium** | Convention violations, moderate testing gaps | Fix in next sprint | **MANDATORY** |
| **Low** | Style issues, minor optimization opportunities | Fix when capacity | **MANDATORY** |

**all severities are MANDATORY to track and fix. Low is not Optional. Low = Lower priority, still required.**

## Prerequisites

1. **PROJECT_RULES.md (MANDATORY)**: `docs/PROJECT_RULES.md` MUST exist - no defaults, no fallback
2. **Vue.js frontend project**: `package.json` with `vue` in dependencies (redirects to `bee:dev-refactor` otherwise); Nuxt.js projects detected via `nuxt.config.ts`
3. **Git repository**: Project should be under version control
4. **Readable codebase**: Access to source files

**If PROJECT_RULES.md does not exist:** This command will output a blocker message and terminate.
**If not a Vue.js frontend project:** This command will redirect to `/bee:dev-refactor`.

## Related Commands

| Command | Description |
|---------|-------------|
| `/bee:dev-cycle-frontend-vuejs` | Execute Vue.js frontend development cycle (used after analysis) |
| `/bee:dev-refactor` | Analyze backend/general codebase (use for non-frontend) |
| `/bee:pre-dev-feature` | Plan new features (use instead for greenfield) |
| `/bee:codereview` | Manual code review (bee:dev-cycle-frontend-vuejs includes this) |

---

## MANDATORY: Load Full Skill

**After PROJECT_RULES.md check passes, load the skill:**

```
Use Skill tool: bee:dev-refactor-frontend-vuejs
```

The skill file is located at: `skills/dev-refactor-frontend-vuejs/SKILL.md`

The skill contains the complete analysis workflow with:
- Anti-rationalization tables for codebase exploration
- Mandatory use of `bee:codebase-explorer` (not Bash/Explore)
- Standards coverage table requirements
- Vue.js-specific gate escape detection (9-gate cycle)
- Nuxt.js module, plugin, and composable pattern detection
- Vue 3 Composition API compliance checks (`<script setup>` enforcement, Options API detection)
- Finding -> Task mapping gates
- Full agent dispatch prompts with `**MODE: ANALYSIS only**`
- Handoff to `bee:dev-cycle-frontend-vuejs` (not `bee:dev-cycle` or `bee:dev-cycle-frontend`)

## Execution Context

Pass the following context to the skill:

| Parameter | Value |
|-----------|-------|
| `path` | First argument if it's a directory path (default: project root) |
| `prompt` | Remaining text after path and options (direct instruction for focus) |
| `--standards` | If provided, custom standards file path |
| `--analyze-only` | If provided, skip bee:dev-cycle-frontend-vuejs execution |
| `--critical-only` | If provided, filter to Critical/High only |
| `--dry-run` | If provided, show what would be analyzed |

**Argument Parsing:**
- If first argument is a path (contains `/` or is a known directory) -> treat as path
- If first argument is an option (`--*`) -> no path specified
- Remaining non-option text -> prompt (refactoring focus)

## User Approval (MANDATORY)

**Before executing bee:dev-cycle-frontend-vuejs, you MUST ask:**

```yaml
AskUserQuestion:
  questions:
    - question: "Review Vue.js frontend refactoring plan. How to proceed?"
      header: "Approval"
      options:
        - label: "Approve all"
          description: "Proceed to bee:dev-cycle-frontend-vuejs execution"
        - label: "Critical only"
          description: "Execute only Critical/High tasks"
        - label: "Cancel"
          description: "Keep analysis, skip execution"
```

## Quick Reference

See skill `bee:dev-refactor-frontend-vuejs` for full details. Key rules:

- **All agents dispatch in parallel** - Single message, multiple Task calls
- **Specify model: "opus"** - All agents need opus for comprehensive analysis
- **MODE: ANALYSIS only** - Agents analyze, they DO NOT implement
- **Save artifacts** to `docs/bee:dev-refactor-frontend-vuejs/{timestamp}/`
- **Get user approval** before executing bee:dev-cycle-frontend-vuejs
- **Handoff**: `bee:dev-cycle-frontend-vuejs docs/bee:dev-refactor-frontend-vuejs/{timestamp}/tasks.md`
- **Vue 3 only** - Flag any Options API usage as a High severity finding; `<script setup>` is the required pattern
- **Nuxt-aware** - Detect `nuxt.config.ts` and apply Nuxt-specific analysis (auto-imports, server routes, composables, layouts)
