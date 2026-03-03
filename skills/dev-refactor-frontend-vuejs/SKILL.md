---
name: bee:dev-refactor-frontend-vuejs
description: |
  Analyzes Vue.js/Nuxt 3 frontend codebase against Bee standards and generates refactoring tasks
  for bee:dev-cycle-frontend-vuejs. Dispatches Vue.js-specific agents in ANALYSIS mode.

trigger: |
  - User wants to refactor existing Vue.js/Nuxt 3 frontend project to follow standards
  - Legacy Vue.js codebase needs modernization (Options API → Composition API, Vuex → Pinia)
  - Vue.js/Nuxt 3 frontend project audit requested

skip_when: |
  - Greenfield project -> Use /bee:pre-dev-* instead
  - Single file fix -> Use bee:dev-cycle-frontend-vuejs directly
  - Backend-only project -> Use bee:dev-refactor instead

sequence:
  before: [bee:dev-cycle-frontend-vuejs]

related:
  complementary: [bee:dev-refactor, bee:dev-cycle-frontend-vuejs, bee:using-dev-team]

input_schema:
  required: []
  optional:
    - name: project_path
      type: string
      description: "Path to Vue.js/Nuxt 3 frontend project root (default: current directory)"
    - name: prompt
      type: string
      description: "Direct instruction for refactoring focus"
    - name: standards_path
      type: string
      description: "Custom standards file path (default: Bee Vue.js standards via WebFetch)"
    - name: analyze_only
      type: boolean
      description: "Generate report without executing bee:dev-cycle-frontend-vuejs"
    - name: critical_only
      type: boolean
      description: "Limit execution to Critical and High severity (analysis still tracks all)"
    - name: dry_run
      type: boolean
      description: "Show what would be analyzed without executing"

output_schema:
  format: markdown
  artifacts:
    - name: "codebase-report.md"
      description: "Codebase analysis from bee:codebase-explorer"
    - name: "reports/{agent-name}-report.md"
      description: "Individual agent analysis reports"
    - name: "findings.md"
      description: "All findings mapped from agent reports"
    - name: "tasks.md"
      description: "1:1 mapped REFACTOR-XXX tasks from findings"
    - name: "change-report.html"
      description: "Visual HTML change report from bee:visual-explainer"
  traceability: "Bee Standard -> Agent Report -> FINDING-XXX -> REFACTOR-XXX -> Implementation"
---

# Dev Refactor Frontend Vue.js Skill

Analyzes existing Vue.js/Nuxt 3 frontend codebase against Bee/Lerian standards and generates refactoring tasks compatible with bee:dev-cycle-frontend-vuejs.

---

## Standards Loading (MANDATORY)

**Before any step execution, you MUST load Bee Vue.js standards.**

### Standards Source Resolution

```text
if standards_path is provided:
  → Read tool: {standards_path}
  → If file not found or empty: STOP and report blocker
  → Use loaded content as Vue.js frontend standards
else:
  → WebFetch the default Bee Vue.js standards (see URLs below)
```

**Default URLs (used when `standards_path` is not provided):**

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/main/CLAUDE.md
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/docs/standards/frontend-vuejs.md
</fetch_required>

Fetch URLs above and extract: Agent Modification Verification requirements, Anti-Rationalization Tables requirements, Critical Rules, and Vue.js Frontend Standards.

<block_condition>
- standards_path provided but file not found or empty
- standards_path not provided AND WebFetch fails or returns empty
- CLAUDE.md not accessible
</block_condition>

If any condition is true, STOP and report blocker. Cannot proceed without Bee standards.

---

## MANDATORY GAP PRINCIPLE (NON-NEGOTIABLE)

**any divergence from Bee standards = MANDATORY gap to implement.**

<cannot_skip>
- All divergences are gaps - Every difference MUST be tracked as FINDING-XXX
- Severity affects PRIORITY, not TRACKING - Low severity = lower priority, not "optional"
- No filtering allowed - You CANNOT decide which divergences "matter"
- No alternative patterns accepted - Different approach = STILL A GAP
- No cosmetic exceptions - Naming, formatting, structure differences = GAPS
</cannot_skip>

Non-negotiable, not open to interpretation - a HARD RULE.

### Anti-Rationalization: Mandatory Gap Principle

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for:
- **Refactor Gap Tracking** section (mandatory gap principle rationalizations)
- **Gate Execution** section (workflow skip rationalizations)
- **TDD** section (test-first rationalizations)
- **Universal** section (general anti-patterns)

### Verification Rule

```
COUNT(non-checkmark items in all Standards Coverage Tables) == COUNT(FINDING-XXX entries)

If counts don't match -> SKILL FAILURE. Go back and add missing findings.
```

---

## Architecture Pattern Applicability

**Not all architecture patterns apply to all Vue.js/Nuxt 3 frontend projects.** Before flagging gaps, verify the pattern is applicable.

| Service Type | Component Architecture | Directory Structure |
|--------------|------------------------|---------------------|
| Full Vue 3 / Nuxt 3 App | APPLY (Composition API, Pinia, Vue Router) | APPLY (frontend-vuejs.md section 11) |
| Vue 3 Design System / Component Library | APPLY | APPLY |
| Nuxt 3 Content Site / Blog | PARTIAL | APPLY |
| Utility / Config Package | NOT APPLICABLE | NOT APPLICABLE |

### Detection Criteria

**Full Vue 3 / Nuxt 3 App (Vue.js Frontend Standards APPLICABLE):**
- Project uses Vue 3 or Nuxt 3 as framework
- Contains components, pages, and state management
- Uses Composition API (`<script setup>`, `ref()`, `computed()`, `watch()`)
- Uses Pinia for state management (or Vuex — flag as migration gap)
- Has Vue Router or Nuxt routing
- -> **MUST follow frontend-vuejs.md standards**

**Simple Vue.js Frontend (Partial applicability):**
- Content-only sites with minimal interactivity
- Static Nuxt Content sites
- -> Apply directory structure and styling; skip state management, BFF patterns

### Agent Instruction

When dispatching specialist agents, include:

```
ARCHITECTURE APPLICABILITY CHECK:
1. If project is a full Vue 3 / Nuxt 3 app -> APPLY all frontend-vuejs.md sections
2. If project is a Nuxt Content site -> APPLY directory structure and styling only
3. If project is a utility package -> Do not flag Vue-specific gaps
```

---

## MANDATORY: Initialize Todo List FIRST

**Before any other action, create the todo list with all steps:**

```yaml
TodoWrite:
  todos:
    - content: "Validate PROJECT_RULES.md exists"
      status: "pending"
      activeForm: "Validating PROJECT_RULES.md exists"
    - content: "Detect Vue.js/Nuxt 3 stack and UI library mode"
      status: "pending"
      activeForm: "Detecting Vue.js stack"
    - content: "Read PROJECT_RULES.md for context"
      status: "pending"
      activeForm: "Reading PROJECT_RULES.md"
    - content: "Generate codebase report via bee:codebase-explorer"
      status: "pending"
      activeForm: "Generating codebase report"
    - content: "Dispatch Vue.js frontend specialist agents in parallel"
      status: "pending"
      activeForm: "Dispatching Vue.js frontend specialist agents"
    - content: "Save individual agent reports"
      status: "pending"
      activeForm: "Saving agent reports"
    - content: "Map agent findings to FINDING-XXX entries"
      status: "pending"
      activeForm: "Mapping agent findings"
    - content: "Generate findings.md"
      status: "pending"
      activeForm: "Generating findings.md"
    - content: "Map findings 1:1 to REFACTOR-XXX tasks"
      status: "pending"
      activeForm: "Mapping findings to tasks (1:1)"
    - content: "Generate tasks.md"
      status: "pending"
      activeForm: "Generating tasks.md"
    - content: "Generate visual change report"
      status: "pending"
      activeForm: "Generating visual change report"
    - content: "Get user approval"
      status: "pending"
      activeForm: "Getting user approval"
    - content: "Save all artifacts"
      status: "pending"
      activeForm: "Saving artifacts"
    - content: "Handoff to bee:dev-cycle-frontend-vuejs"
      status: "pending"
      activeForm: "Handing off to bee:dev-cycle-frontend-vuejs"
```

**This is NON-NEGOTIABLE. Do not skip creating the todo list.**

---

## Input Flags: Early Exit Check

```text
if dry_run == true:
  → Execute Step 1 (Validate PROJECT_RULES.md) and Step 1b (Detect Vue.js Stack)
  → Output dry-run summary:
      - Project path: {project_path or current directory}
      - Standards source: {standards_path or "Bee Vue.js defaults via WebFetch"}
      - Vue.js stack detected: {Vue 3 / Nuxt 3 version}
      - UI library mode: {sindarian-vue / fallback-only}
      - Agents that would be dispatched: {list of 5-7 agents}
      - Conditional agents: {BFF if detected, UI Engineer if ux-criteria.md exists}
      - Artifact path: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/
  → Mark all remaining todos as `completed` (skipped - dry run)
  → TERMINATE with "Dry run complete. Re-run without --dry-run to execute."
```

**If `dry_run` is not true, continue to next section.**

---

## CRITICAL: Specialized Agents Perform All Tasks

See [shared-patterns/shared-orchestrator-principle.md](../shared-patterns/shared-orchestrator-principle.md) for full ORCHESTRATOR principle, role separation, forbidden/required actions, step-to-agent mapping, and anti-rationalization table.

**Summary:** You orchestrate. Agents execute. If using Bash/Grep/Read to analyze code, STOP. Dispatch agent.

---

## Step 1: Validate PROJECT_RULES.md

**TodoWrite:** Mark "Validate PROJECT_RULES.md exists" as `in_progress`

<block_condition>
- docs/PROJECT_RULES.md does not exist
</block_condition>

If condition is true, output blocker and TERMINATE. Otherwise continue to Step 1b.

**Check:** Does `docs/PROJECT_RULES.md` exist?

- **YES** -> Mark todo as `completed`, continue to Step 1b
- **NO** -> Output blocker and TERMINATE:

```markdown
## BLOCKED: PROJECT_RULES.md Not Found

Cannot proceed without project standards baseline.

**Required Action:** Create `docs/PROJECT_RULES.md` with:
- Architecture patterns (Vue 3 Composition API, Nuxt 3, Pinia)
- Code conventions (SFC structure, composable naming)
- Testing requirements (Vitest, Vue Testing Library, Playwright)
- Technology stack decisions

Re-run after file exists.
```

---

## Step 1b: Detect Vue.js/Nuxt 3 Stack

**TodoWrite:** Mark "Detect Vue.js/Nuxt 3 stack and UI library mode" as `in_progress`

**SCOPE: VUE.JS FRONTEND AND BFF CODE ONLY.** This skill analyzes Vue.js/Nuxt 3 code exclusively. MUST use `bee:dev-refactor` for backend code.

**FORBIDDEN:** Dispatching backend agents from this skill. Backend agents belong to `bee:dev-refactor`.

**MANDATORY: Verify this is a Vue.js/Nuxt 3 project. If not, redirect.**

Check for Vue.js/Nuxt 3 frontend indicators:

| Check | Detection | Result |
|-------|-----------|--------|
| `package.json` exists | Glob for `package.json` | Required |
| Vue 3 / Nuxt 3 in deps | `vue`, `nuxt` in dependencies | Required for Vue frontend |
| `@lerianstudio/sindarian-vue` in deps | Check dependencies/devDependencies | Store `ui_library_mode` |
| BFF layer detected | `/server/api/` routes in Nuxt, or Express/Fastify in deps | Add `bee:frontend-bff-engineer-typescript` |
| `ux-criteria.md` exists | `docs/pre-dev/*/ux-criteria.md` | Add `bee:ui-engineer-vuejs` |
| Vuex detected | `vuex` in dependencies | Flag as MANDATORY Pinia migration gap |
| Options API detected | `defineComponent({ data(), methods: {} })` patterns | Flag as Composition API migration gap |

**Detection Logic:**

```text
1. package.json exists?
   NO  -> STOP: "Not a Node.js project. Use bee:dev-refactor instead."
   YES -> Continue

2. Vue 3 or Nuxt 3 in dependencies?
   NO  -> STOP: "Not a Vue.js frontend project. Use bee:dev-refactor instead."
   YES -> Continue

3. @lerianstudio/sindarian-vue in dependencies?
   YES -> ui_library_mode = "sindarian-vue"
   NO  -> ui_library_mode = "fallback-only"

4. BFF layer detected? (/server/api/ routes in Nuxt, Express/Fastify in deps)
   YES -> dispatch_bff = true
   NO  -> dispatch_bff = false

5. ux-criteria.md exists?
   YES -> dispatch_ui_engineer = true
   NO  -> dispatch_ui_engineer = false

6. Vuex in dependencies?
   YES -> flag_vuex_migration = true (mandatory Pinia migration gap)
   NO  -> flag_vuex_migration = false

7. Options API patterns detected in source?
   YES -> flag_composition_api_migration = true
   NO  -> flag_composition_api_migration = false
```

**TodoWrite:** Mark "Detect Vue.js/Nuxt 3 stack and UI library mode" as `completed`

---

## Step 2: Read PROJECT_RULES.md

**TodoWrite:** Mark "Read PROJECT_RULES.md for context" as `in_progress`

```
Read tool: docs/PROJECT_RULES.md
```

Extract project-specific conventions for agent context.

**TodoWrite:** Mark "Read PROJECT_RULES.md for context" as `completed`

---

## Step 3: Generate Codebase Report

**TodoWrite:** Mark "Generate codebase report via bee:codebase-explorer" as `in_progress`

### MANDATORY: Use Task Tool with bee:codebase-explorer

<dispatch_required agent="bee:codebase-explorer">
Generate a comprehensive Vue.js/Nuxt 3 frontend codebase report describing WHAT EXISTS.

Include:
- Project structure and directory layout (pages/, components/, composables/, stores/, layouts/, middleware/)
- Vue 3 / Nuxt 3 architecture (Composition API vs Options API usage, <script setup> adoption)
- UI library usage (sindarian-vue, shadcn-vue, custom components)
- State management patterns (Pinia stores, Vuex if present, composable-based state)
- Form handling patterns (VeeValidate, native Vue validation)
- Styling approach (TailwindCSS, CSS Modules, scoped styles)
- Testing setup (Vitest, Playwright, Vue Testing Library, @vue/test-utils)
- Performance configuration (nuxt.config.ts, image optimization, useAsyncData usage)
- Key files inventory with file:line references
- Code snippets showing current implementation patterns
- Nuxt-specific: middleware, plugins, server/api routes, composables, layouts
</dispatch_required>

<output_required>
## EXPLORATION SUMMARY
[Your summary here]

## KEY FINDINGS
[Your findings here]

## ARCHITECTURE INSIGHTS
[Your insights here]

## RELEVANT FILES
[Your file inventory here]

## RECOMMENDATIONS
[Your recommendations here]
</output_required>

Do not complete without outputting full report in the format above.

### FORBIDDEN Actions for Step 3

<forbidden>
- Bash(command="find ... -name '*.vue'") -> SKILL FAILURE
- Bash(command="ls -la ...") -> SKILL FAILURE
- Bash(command="tree ...") -> SKILL FAILURE
- Task(subagent_type="Explore", ...) -> SKILL FAILURE
- Task(subagent_type="general-purpose", ...) -> SKILL FAILURE
</forbidden>

**After Task completes, save with Write tool:**

```
Write tool:
  file_path: "docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md"
  content: [Task output]
```

**TodoWrite:** Mark "Generate codebase report via bee:codebase-explorer" as `completed`

---

## Step 4: Dispatch Vue.js Frontend Specialist Agents

**TodoWrite:** Mark "Dispatch Vue.js frontend specialist agents in parallel" as `in_progress`

### HARD GATE: Verify codebase-report.md Exists

```
Check 1: Does docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md exist?
  - YES -> Continue to dispatch agents
  - NO  -> STOP. Go back to Step 3.

Check 2: Was codebase-report.md created by bee:codebase-explorer?
  - YES -> Continue
  - NO (created by Bash output) -> DELETE IT. Go back to Step 3. Use correct agent.
```

### Always Dispatched (5 agents in parallel)

**Dispatch all 5 agents in ONE message (parallel):**

```yaml
Task tool 1:
  subagent_type: "bee:frontend-engineer-vuejs"
  description: "Vue.js frontend standards analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all sections in frontend-vuejs.md per shared-patterns/standards-coverage-table.md

    FRAMEWORKS & LIBRARIES DETECTION (MANDATORY):
    1. Read package.json to extract all dependencies used in codebase
    2. Load frontend-vuejs.md standards via WebFetch -> extract all listed frameworks/libraries
    3. For each category in standards (Framework, State, Forms, UI, Styling, Testing, etc.):
       - Compare codebase dependency vs standards requirement
       - If codebase uses DIFFERENT library than standards (e.g., Vuex instead of Pinia) -> ISSUE-XXX
       - If codebase is MISSING required library -> ISSUE-XXX
    4. Any library not in standards that serves same purpose = ISSUE-XXX

    Vue.js-Specific Analysis:
    - Options API usage (data(), methods:, computed:) -> Flag as Composition API migration gaps
    - Vuex store usage -> Flag as mandatory Pinia migration gaps
    - Missing <script setup> syntax -> Flag as gap
    - VeeValidate v3 usage when v4 is standard -> Flag as gap
    - Missing TypeScript in SFCs (lang="ts" not set) -> Flag as gap

    UI Library Mode: {ui_library_mode}
    Vuex Migration Required: {flag_vuex_migration}
    Composition API Migration Required: {flag_composition_api_migration}

    Input:
    - Bee Standards: Load via WebFetch (frontend-vuejs.md)
    - Section Index: See shared-patterns/standards-coverage-table.md -> "bee:frontend-engineer-vuejs"
    - Codebase Report: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format)
    2. ISSUE-XXX for each non-compliant finding with: Pattern name, Severity, file:line, Current Code, Expected Code

Task tool 2:
  subagent_type: "bee:qa-analyst-frontend-vuejs"
  description: "Vue.js frontend testing analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all testing sections per shared-patterns/standards-coverage-table.md -> "bee:qa-analyst-frontend-vuejs"

    Analyze ALL testing dimensions:
    - Accessibility (ACC-1 to ACC-5): axe-core with @testing-library/vue, semantic HTML, keyboard nav, focus, color contrast
    - Visual (VIS-1 to VIS-4): Vitest snapshots, state coverage, responsive, component duplication
    - E2E (E2E-1 to E2E-5): Playwright user flows, error paths, cross-browser (Chromium/Firefox/WebKit), responsive, selectors
    - Performance (PERF-1 to PERF-5): Core Web Vitals, Lighthouse, bundle, client-only components ratio, anti-patterns

    Vue.js-Specific Testing Gaps:
    - @vue/test-utils vs @testing-library/vue usage (standards require Vue Testing Library)
    - Pinia store not using createTestingPinia() in tests
    - No flushPromises() calls before async assertions
    - Missing Playwright tests for Vue Router navigation guards
    - NuxtImg not present where bare <img> is used (performance gap)

    UI Library Mode: {ui_library_mode}

    Input:
    - Bee Standards: Load via WebFetch (frontend-vuejs/testing-accessibility.md, testing-visual.md, testing-e2e.md, testing-performance.md)
    - Section Index: See shared-patterns/standards-coverage-table.md -> "bee:qa-analyst-frontend-vuejs"
    - Codebase Report: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format) for ALL sections
    2. ISSUE-XXX for each non-compliant finding

Task tool 3:
  subagent_type: "bee:frontend-designer-vuejs"
  description: "Vue.js frontend design analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all sections in frontend-vuejs.md per shared-patterns/standards-coverage-table.md -> "bee:frontend-designer-vuejs"

    Focus on Vue.js design perspective:
    - Typography standards (font selection, pairing, hierarchy)
    - Styling standards (TailwindCSS, CSS variables, scoped styles, design tokens)
    - Animation standards (Vue Transition/TransitionGroup, CSS transitions)
    - Component patterns (Vue SFC structure, design system compliance)
    - Accessibility UX (color contrast, focus indicators, motion preferences via prefers-reduced-motion)
    - Scoped styles vs global styles consistency

    UI Library Mode: {ui_library_mode}

    Input:
    - Bee Standards: Load via WebFetch (frontend-vuejs.md)
    - Section Index: See shared-patterns/standards-coverage-table.md -> "bee:frontend-designer-vuejs"
    - Codebase Report: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format)
    2. ISSUE-XXX for each non-compliant finding

Task tool 4:
  subagent_type: "bee:devops-engineer"
  description: "DevOps analysis for Vue.js/Nuxt 3"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**
    Check all sections per shared-patterns/standards-coverage-table.md -> "bee:devops-engineer"

    Vue.js/Nuxt 3-specific DevOps focus:
    - Dockerfile for Nuxt 3 SSR app (Node.js runtime, output: standalone)
    - Docker Compose for local development (Nuxt dev server + API)
    - Nginx configuration for Nuxt SSR static assets / reverse proxy
    - .env management for Nuxt runtime config (runtimeConfig, useRuntimeConfig())
    - Makefile with Nuxt/Vue commands (dev, build, generate, lint, test, e2e)
    - CI/CD pipeline for Nuxt build/test/deploy

    Input:
    - Bee Standards: Load via WebFetch (devops.md)
    - Codebase Report: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output: Standards Coverage Table + ISSUE-XXX for gaps

Task tool 5:
  subagent_type: "bee:sre"
  description: "Observability analysis for Vue.js/Nuxt 3"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**
    Check all sections per shared-patterns/standards-coverage-table.md -> "bee:sre"

    Vue.js/Nuxt 3-specific observability focus:
    - Error tracking (Vue error boundaries via onErrorCaptured(), Nuxt error.vue page, global error handling)
    - Health check endpoints (Nuxt server routes for SSR health)
    - Real User Monitoring (RUM) / Core Web Vitals reporting via useWebVitals composable
    - Structured client-side logging
    - Distributed tracing for Nuxt server API calls (useFetch, $fetch)
    - Nuxt plugin for global error handler registration

    Input:
    - Bee Standards: Load via WebFetch (sre.md)
    - Codebase Report: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output: Standards Coverage Table + ISSUE-XXX for gaps
```

### Conditionally Dispatched

**Add to the parallel dispatch if conditions from Step 1b are met:**

```yaml
Task tool 6 (if dispatch_bff == true):
  subagent_type: "bee:frontend-bff-engineer-typescript"
  description: "Nuxt server API / BFF TypeScript standards analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all sections in typescript.md per shared-patterns/standards-coverage-table.md -> "frontend-bff-engineer-typescript"

    Vue.js/Nuxt 3 BFF focus:
    - Nuxt server routes in /server/api/ follow TypeScript standards
    - defineEventHandler() used correctly for all handlers
    - H3 utilities (readBody(), getQuery(), etc.) used instead of raw request parsing
    - $fetch and useFetch used correctly from composables (not raw fetch())
    - Server-side validation (zod schemas) applied to API inputs

    UI Library Mode: {ui_library_mode}

    Input:
    - Bee Standards: Load via WebFetch (typescript.md)
    - Codebase Report: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format)
    2. ISSUE-XXX for each non-compliant finding

Task tool 7 (if dispatch_ui_engineer == true):
  subagent_type: "bee:ui-engineer-vuejs"
  description: "Vue.js UI engineer standards analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all sections in frontend-vuejs.md per shared-patterns/standards-coverage-table.md -> "bee:ui-engineer-vuejs"

    Additionally verify against product-designer outputs:
    - UX criteria compliance (ux-criteria.md)
    - User flow implementation (user-flows.md)
    - Wireframe adherence (wireframes/*.yaml)
    - UI states coverage (loading, error, empty, success) using Vue's v-if/v-show patterns

    UI Library Mode: {ui_library_mode}

    Input:
    - Bee Standards: Load via WebFetch (frontend-vuejs.md)
    - UX Criteria: docs/pre-dev/{feature}/ux-criteria.md
    - Codebase Report: docs/bee:dev-refactor-frontend-vuejs/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format)
    2. UX Criteria Compliance table
    3. ISSUE-XXX for each non-compliant finding
```

### Agent Dispatch Summary

| Condition | Agents to Dispatch |
|-----------|-------------------|
| Always | Tasks 1-5 (Frontend Engineer Vue.js + QA Frontend Vue.js + Designer Vue.js + DevOps + SRE) |
| BFF layer detected | + Task 6 (BFF Engineer) |
| ux-criteria.md exists | + Task 7 (UI Engineer Vue.js) |

**TodoWrite:** Mark "Dispatch Vue.js frontend specialist agents in parallel" as `completed`

---

## Step 4.5: Agent Report -> Findings Mapping (HARD GATE)

**TodoWrite:** Mark "Map agent findings to FINDING-XXX entries" as `in_progress`

**MANDATORY: all agent-reported issues MUST become findings.**

| Agent Report | Action |
|--------------|--------|
| Any difference between current code and Bee standard | -> Create FINDING-XXX |
| Any missing pattern from Bee standards | -> Create FINDING-XXX |
| Any deprecated pattern usage (Options API, Vuex) | -> Create FINDING-XXX |
| Any accessibility gap | -> Create FINDING-XXX |
| Any testing gap | -> Create FINDING-XXX |
| Any performance issue | -> Create FINDING-XXX |

### Gate Escape Detection (Vue.js Frontend 9-Gate Cycle)

**When mapping findings, identify which gate SHOULD have caught the issue:**

| Finding Category | Should Be Caught In | Flag |
|------------------|---------------------|------|
| Options API / Vuex usage | Gate 0 (Implementation) | Normal finding |
| Vue component architecture issues | Gate 0 (Implementation) | Normal finding |
| Docker/DevOps gaps | Gate 1 (DevOps) | GATE 1 ESCAPE |
| WCAG violations, keyboard nav, ARIA | Gate 2 (Accessibility) | GATE 2 ESCAPE |
| Vue template aria binding issues | Gate 2 (Accessibility) | GATE 2 ESCAPE |
| Unit test gaps, coverage <85% | Gate 3 (Unit Testing) | GATE 3 ESCAPE |
| Missing createTestingPinia() in tests | Gate 3 (Unit Testing) | GATE 3 ESCAPE |
| Missing Vitest snapshot tests | Gate 4 (Visual) | GATE 4 ESCAPE |
| Missing state/responsive coverage | Gate 4 (Visual) | GATE 4 ESCAPE |
| sindarian-vue component duplication | Gate 4 (Visual) | GATE 4 ESCAPE |
| Untested user flows | Gate 5 (E2E) | GATE 5 ESCAPE |
| Vue Router navigation guards not tested | Gate 5 (E2E) | GATE 5 ESCAPE |
| Pinia store state not reset in E2E | Gate 5 (E2E) | GATE 5 ESCAPE |
| CWV violations (LCP > 2.5s, CLS > 0.1, INP > 200ms) | Gate 6 (Performance) | GATE 6 ESCAPE |
| Lighthouse < 90 | Gate 6 (Performance) | GATE 6 ESCAPE |
| Bare <img> tags (not NuxtImg) | Gate 6 (Performance) | GATE 6 ESCAPE |
| Missing useLazyFetch for non-critical data | Gate 6 (Performance) | GATE 6 ESCAPE |
| Code quality (reviewer-catchable) | Gate 7 (Review) | GATE 7 ESCAPE |

**TodoWrite:** Mark "Map agent findings to FINDING-XXX entries" as `completed`

---

## Step 4.6: Save Individual Agent Reports

**TodoWrite:** Mark "Save individual agent reports" as `in_progress`

```
docs/bee:dev-refactor-frontend-vuejs/{timestamp}/reports/
+-- bee:frontend-engineer-vuejs-report.md         (always)
+-- bee:qa-analyst-frontend-vuejs-report.md       (always)
+-- bee:frontend-designer-vuejs-report.md         (always)
+-- bee:devops-engineer-report.md                 (always)
+-- bee:sre-report.md                             (always)
+-- bee:frontend-bff-engineer-typescript-report.md  (if BFF detected)
+-- bee:ui-engineer-vuejs-report.md               (if ux-criteria.md exists)
```

**Use Write tool for each agent report.**

**TodoWrite:** Mark "Save individual agent reports" as `completed`

---

## Step 5: Generate findings.md

**TodoWrite:** Mark "Generate findings.md" as `in_progress`

**Use Write tool to create findings.md.** Format follows the standard FINDING-XXX structure with Vue.js-specific categories:

**Vue.js-specific categories:** `composition-api-migration | pinia-migration | sfc-structure | vue-router | nuxt-config | accessibility | testing | performance | devops`

**CRITICAL: Every issue reported by agents in Step 4 MUST appear here as a FINDING-XXX entry.**

**TodoWrite:** Mark "Generate findings.md" as `completed`

---

## Step 6: Map Findings to Tasks (1:1)

**TodoWrite:** Mark "Map findings 1:1 to REFACTOR-XXX tasks" as `in_progress`

**HARD GATE: One FINDING-XXX = One REFACTOR-XXX task. No grouping.**

**1:1 Mapping Rule:**
- FINDING-001 -> REFACTOR-001
- FINDING-002 -> REFACTOR-002
- FINDING-NNN -> REFACTOR-NNN

**TodoWrite:** Mark "Map findings 1:1 to REFACTOR-XXX tasks" as `completed`

---

## Step 7: Generate tasks.md

**TodoWrite:** Mark "Generate tasks.md" as `in_progress`

**Use Write tool to create tasks.md** with REFACTOR-XXX entries. Each entry includes Current Code, Bee Standard Reference, Required Actions, and Acceptance Criteria. Vue.js-specific acceptance criteria must reference Composition API patterns, Pinia store patterns, and VeeValidate v4 patterns where applicable.

**TodoWrite:** Mark "Generate tasks.md" as `completed`

---

## Step 7.5: Visual Change Report

**TodoWrite:** Mark "Generate visual change report" as `in_progress`

**MANDATORY: Generate a visual HTML report before user approval.**

Invokes `Skill("bee:visual-explainer")` to produce a self-contained HTML page showing all planned Vue.js refactoring changes.

**Output:** Save to `docs/bee:dev-refactor-frontend-vuejs/{timestamp}/change-report.html`

```text
macOS: open docs/bee:dev-refactor-frontend-vuejs/{timestamp}/change-report.html
Linux: xdg-open docs/bee:dev-refactor-frontend-vuejs/{timestamp}/change-report.html
```

**TodoWrite:** Mark "Generate visual change report" as `completed`

---

## Step 8: User Approval

**TodoWrite:** Mark "Get user approval" as `in_progress`

```text
if analyze_only == true:
  → Auto-select "Cancel" (analysis complete, skip execution)
  → Output: "analyze_only=true — analysis artifacts saved, skipping bee:dev-cycle-frontend-vuejs."
  → Skip to Step 9, then TERMINATE.

if critical_only == true:
  → Auto-select "Critical only"
  → Output: "critical_only=true — auto-selecting Critical/High tasks only."
  → Continue to Step 9, then Step 10 with Critical/High tasks.
```

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

**TodoWrite:** Mark "Get user approval" as `completed`

---

## Step 9: Save Artifacts

**TodoWrite:** Mark "Save all artifacts" as `in_progress`

```
docs/bee:dev-refactor-frontend-vuejs/{timestamp}/
+-- codebase-report.md  (Step 3)
+-- reports/            (Step 4.6)
|   +-- bee:frontend-engineer-vuejs-report.md
|   +-- bee:qa-analyst-frontend-vuejs-report.md
|   +-- bee:frontend-designer-vuejs-report.md
|   +-- bee:devops-engineer-report.md
|   +-- bee:sre-report.md
|   +-- bee:frontend-bff-engineer-typescript-report.md    (conditional)
|   +-- bee:ui-engineer-vuejs-report.md                   (conditional)
+-- findings.md         (Step 5)
+-- tasks.md            (Step 7)
+-- change-report.html  (Step 7.5)
```

**TodoWrite:** Mark "Save all artifacts" as `completed`

---

## Step 10: Handoff to bee:dev-cycle-frontend-vuejs

**TodoWrite:** Mark "Handoff to bee:dev-cycle-frontend-vuejs" as `in_progress`

```yaml
Skill tool:
  skill: "bee:dev-cycle-frontend-vuejs"
```

**Pass tasks file path in context:**
- Tasks file: `docs/bee:dev-refactor-frontend-vuejs/{timestamp}/tasks.md`

**HARD GATE: When execution is approved, you CANNOT complete bee:dev-refactor-frontend-vuejs without invoking `Skill tool: bee:dev-cycle-frontend-vuejs`.**

**TodoWrite:** Mark "Handoff to bee:dev-cycle-frontend-vuejs" as `completed`

---

## Execution Report

| Metric | Value |
|--------|-------|
| Agents Dispatched | N (5-7) |
| UI Library Mode | sindarian-vue / fallback-only |
| Vuex Migration Gaps | N |
| Composition API Migration Gaps | N |
| Findings Generated | N |
| Tasks Created | N |
| Gate Escapes Detected | N |
| Artifacts Location | docs/bee:dev-refactor-frontend-vuejs/{timestamp}/ |

---
