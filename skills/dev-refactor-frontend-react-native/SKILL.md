---
name: bee:dev-refactor-frontend-react-native
description: |
  Analyzes React Native frontend codebase against Bee standards and generates refactoring tasks
  for bee:dev-cycle-frontend-react-native. Dispatches React Native-specific agents in ANALYSIS mode.

trigger: |
  - User wants to refactor existing React Native frontend project to follow standards
  - Legacy React Native codebase needs modernization (class components → functional, Redux → Zustand)
  - React Native frontend project audit requested

skip_when: |
  - Greenfield project -> Use /bee:pre-dev-* instead
  - Single file fix -> Use bee:dev-cycle-frontend-react-native directly
  - Backend-only project -> Use bee:dev-refactor instead

sequence:
  before: [bee:dev-cycle-frontend-react-native]

related:
  complementary: [bee:dev-refactor, bee:dev-cycle-frontend-react-native, bee:using-dev-team]

input_schema:
  required: []
  optional:
    - name: project_path
      type: string
      description: "Path to React Native frontend project root (default: current directory)"
    - name: prompt
      type: string
      description: "Direct instruction for refactoring focus"
    - name: standards_path
      type: string
      description: "Custom standards file path (default: Bee React Native standards via WebFetch)"
    - name: analyze_only
      type: boolean
      description: "Generate report without executing bee:dev-cycle-frontend-react-native"
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

# Dev Refactor Frontend React Native Skill

Analyzes existing React Native frontend codebase against Bee/Lerian standards and generates refactoring tasks compatible with bee:dev-cycle-frontend-react-native.

---

## Standards Loading (MANDATORY)

**Before any step execution, you MUST load Bee React Native standards.**

### Standards Source Resolution

```text
if standards_path is provided:
  → Read tool: {standards_path}
  → If file not found or empty: STOP and report blocker
  → Use loaded content as React Native frontend standards
else:
  → WebFetch the default Bee React Native standards (see URLs below)
```

**Default URLs (used when `standards_path` is not provided):**

<fetch_required>
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/main/CLAUDE.md
https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/main/dev-team/docs/standards/frontend-react-native.md
</fetch_required>

Fetch URLs above and extract: Agent Modification Verification requirements, Anti-Rationalization Tables requirements, Critical Rules, and React Native Frontend Standards.

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

**Not all architecture patterns apply to all React Native projects.** Before flagging gaps, verify the pattern is applicable.

| Service Type | Component Architecture | Directory Structure |
|--------------|------------------------|---------------------|
| Full React Native App (Expo or bare) | APPLY (hooks, navigation, state management) | APPLY (frontend-react-native.md section structure) |
| React Native Design System / Component Library | APPLY | APPLY |
| Expo SDK App | APPLY | APPLY |
| Utility / Config Package | NOT APPLICABLE | NOT APPLICABLE |

### Detection Criteria

**Full React Native App (React Native Frontend Standards APPLICABLE):**
- Project uses React Native (with or without Expo)
- Contains screens, components, and navigation
- Uses functional components with hooks (`useState`, `useEffect`, `useCallback`, `useMemo`)
- Uses Zustand / Redux Toolkit for state management (or Redux — flag as migration gap)
- Has React Navigation or Expo Router for navigation
- -> **MUST follow frontend-react-native.md standards**

**Simple React Native Frontend (Partial applicability):**
- Single-screen utility apps with minimal interactivity
- Expo Snack or prototype apps
- -> Apply directory structure and styling; skip state management patterns

### Agent Instruction

When dispatching specialist agents, include:

```
ARCHITECTURE APPLICABILITY CHECK:
1. If project is a full React Native app (Expo or bare) -> APPLY all frontend-react-native.md sections
2. If project is a component library -> APPLY component architecture and styling only
3. If project is a utility package -> Do not flag React Native-specific gaps
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
    - content: "Detect React Native stack and UI library mode"
      status: "pending"
      activeForm: "Detecting React Native stack"
    - content: "Read PROJECT_RULES.md for context"
      status: "pending"
      activeForm: "Reading PROJECT_RULES.md"
    - content: "Generate codebase report via bee:codebase-explorer"
      status: "pending"
      activeForm: "Generating codebase report"
    - content: "Dispatch React Native frontend specialist agents in parallel"
      status: "pending"
      activeForm: "Dispatching React Native frontend specialist agents"
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
    - content: "Handoff to bee:dev-cycle-frontend-react-native"
      status: "pending"
      activeForm: "Handing off to bee:dev-cycle-frontend-react-native"
```

**This is NON-NEGOTIABLE. Do not skip creating the todo list.**

---

## Input Flags: Early Exit Check

```text
if dry_run == true:
  → Execute Step 1 (Validate PROJECT_RULES.md) and Step 1b (Detect React Native Stack)
  → Output dry-run summary:
      - Project path: {project_path or current directory}
      - Standards source: {standards_path or "Bee React Native defaults via WebFetch"}
      - React Native stack detected: {Expo SDK version / bare React Native version}
      - UI library mode: {sindarian-rn / fallback-only}
      - Agents that would be dispatched: {list of 5-6 agents}
      - Conditional agents: {UI Engineer if ux-criteria.md exists}
      - Artifact path: docs/bee:dev-refactor-frontend-react-native/{timestamp}/
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
- Architecture patterns (React Native functional components, hooks, navigation)
- Code conventions (component naming, file structure, StyleSheet usage)
- Testing requirements (RNTL, Jest, Detox)
- Technology stack decisions

Re-run after file exists.
```

---

## Step 1b: Detect React Native Stack

**TodoWrite:** Mark "Detect React Native stack and UI library mode" as `in_progress`

**SCOPE: REACT NATIVE FRONTEND CODE ONLY.** This skill analyzes React Native code exclusively. MUST use `bee:dev-refactor` for backend code.

**FORBIDDEN:** Dispatching backend agents from this skill. Backend agents belong to `bee:dev-refactor`.

**MANDATORY: Verify this is a React Native project. If not, redirect.**

Check for React Native frontend indicators:

| Check | Detection | Result |
|-------|-----------|--------|
| `package.json` exists | Glob for `package.json` | Required |
| React Native in deps | `react-native` or `expo` in dependencies | Required for RN frontend |
| `@lerianstudio/sindarian-rn` in deps | Check dependencies/devDependencies | Store `ui_library_mode` |
| `ux-criteria.md` exists | `docs/pre-dev/*/ux-criteria.md` | Add `bee:ui-engineer-react-native` |
| Redux detected | `redux`, `react-redux` in dependencies | Flag as MANDATORY Zustand/RTK migration gap |
| Class components detected | `extends Component` patterns | Flag as functional component migration gap |
| React Navigation vs Expo Router | Check navigation library | Flag if not using standard |

**Detection Logic:**

```text
1. package.json exists?
   NO  -> STOP: "Not a Node.js project. Use bee:dev-refactor instead."
   YES -> Continue

2. react-native or expo in dependencies?
   NO  -> STOP: "Not a React Native frontend project. Use bee:dev-refactor instead."
   YES -> Continue

3. @lerianstudio/sindarian-rn in dependencies?
   YES -> ui_library_mode = "sindarian-rn"
   NO  -> ui_library_mode = "fallback-only"

4. ux-criteria.md exists?
   YES -> dispatch_ui_engineer = true
   NO  -> dispatch_ui_engineer = false

5. Redux (legacy) in dependencies?
   YES -> flag_redux_migration = true (mandatory Zustand/RTK migration gap)
   NO  -> flag_redux_migration = false

6. Class component patterns detected in source?
   YES -> flag_class_component_migration = true
   NO  -> flag_class_component_migration = false
```

**TodoWrite:** Mark "Detect React Native stack and UI library mode" as `completed`

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
Generate a comprehensive React Native frontend codebase report describing WHAT EXISTS.

Include:
- Project structure and directory layout (screens/, components/, hooks/, store/, navigation/, services/)
- React Native / Expo architecture (functional components, hooks usage, class component remnants)
- UI library usage (sindarian-rn, React Native Paper, custom components)
- State management patterns (Zustand stores, Redux if present, Context API usage)
- Navigation structure (React Navigation stack/tabs/drawer, Expo Router)
- Form handling patterns (react-hook-form, native validation)
- Styling approach (StyleSheet.create, NativeWind/Tailwind, styled-components)
- Testing setup (RNTL, Jest, Detox configuration)
- Performance configuration (Hermes enabled, FlatList/FlashList usage, image optimization)
- Key files inventory with file:line references
- Code snippets showing current implementation patterns
- Platform-specific code (Platform.select, .ios.tsx / .android.tsx files)
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
- Bash(command="find ... -name '*.tsx'") -> SKILL FAILURE
- Bash(command="ls -la ...") -> SKILL FAILURE
- Bash(command="tree ...") -> SKILL FAILURE
- Task(subagent_type="Explore", ...) -> SKILL FAILURE
- Task(subagent_type="general-purpose", ...) -> SKILL FAILURE
</forbidden>

**After Task completes, save with Write tool:**

```
Write tool:
  file_path: "docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md"
  content: [Task output]
```

**TodoWrite:** Mark "Generate codebase report via bee:codebase-explorer" as `completed`

---

## Step 4: Dispatch React Native Frontend Specialist Agents

**TodoWrite:** Mark "Dispatch React Native frontend specialist agents in parallel" as `in_progress`

### HARD GATE: Verify codebase-report.md Exists

```
Check 1: Does docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md exist?
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
  subagent_type: "bee:frontend-engineer-react-native"
  description: "React Native frontend standards analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all sections in frontend-react-native.md per shared-patterns/standards-coverage-table.md

    FRAMEWORKS & LIBRARIES DETECTION (MANDATORY):
    1. Read package.json to extract all dependencies used in codebase
    2. Load frontend-react-native.md standards via WebFetch -> extract all listed frameworks/libraries
    3. For each category in standards (Framework, State, Navigation, Forms, UI, Styling, Testing, etc.):
       - Compare codebase dependency vs standards requirement
       - If codebase uses DIFFERENT library than standards (e.g., Redux instead of Zustand) -> ISSUE-XXX
       - If codebase is MISSING required library -> ISSUE-XXX
    4. Any library not in standards that serves same purpose = ISSUE-XXX

    React Native-Specific Analysis:
    - Class component usage (extends Component) -> Flag as functional component migration gaps
    - Redux store usage -> Flag as mandatory Zustand/RTK migration gaps
    - Missing hooks patterns (custom hooks for reusable logic) -> Flag as gap
    - Missing TypeScript in components (no .tsx extension) -> Flag as gap
    - Platform.OS conditional branches not using Platform.select() -> Flag as gap
    - Inline styles instead of StyleSheet.create() -> Flag as gap

    UI Library Mode: {ui_library_mode}
    Redux Migration Required: {flag_redux_migration}
    Class Component Migration Required: {flag_class_component_migration}

    Input:
    - Bee Standards: Load via WebFetch (frontend-react-native.md)
    - Section Index: See shared-patterns/standards-coverage-table.md -> "bee:frontend-engineer-react-native"
    - Codebase Report: docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format)
    2. ISSUE-XXX for each non-compliant finding with: Pattern name, Severity, file:line, Current Code, Expected Code

Task tool 2:
  subagent_type: "bee:qa-analyst-frontend-react-native"
  description: "React Native frontend testing analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all testing sections per shared-patterns/standards-coverage-table.md -> "bee:qa-analyst-frontend-react-native"

    Analyze ALL testing dimensions:
    - Accessibility (ACC-1 to ACC-5): accessibilityLabel, accessibilityRole, accessibilityHint, VoiceOver/TalkBack
    - Visual (VIS-1 to VIS-4): Jest snapshots, platform snapshots (iOS/Android), state coverage, component duplication
    - E2E (E2E-1 to E2E-5): Detox user flows, error paths, iOS + Android, gestures, deep linking
    - Performance (PERF-1 to PERF-5): Bundle size, FlatList vs FlashList, image optimization, Hermes, re-renders

    React Native-Specific Testing Gaps:
    - RNTL vs Enzyme usage (standards require React Native Testing Library)
    - Missing fireEvent.press / fireEvent.changeText in tests
    - No waitFor() calls before async assertions
    - Missing Detox tests for navigation flows
    - FlatList used where FlashList is standard (performance gap)
    - Missing accessibilityLabel on interactive elements

    UI Library Mode: {ui_library_mode}

    Input:
    - Bee Standards: Load via WebFetch (frontend-react-native/testing-accessibility.md, testing-visual.md, testing-e2e.md, testing-performance.md)
    - Section Index: See shared-patterns/standards-coverage-table.md -> "bee:qa-analyst-frontend-react-native"
    - Codebase Report: docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format) for ALL sections
    2. ISSUE-XXX for each non-compliant finding

Task tool 3:
  subagent_type: "bee:frontend-designer-react-native"
  description: "React Native frontend design analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all sections in frontend-react-native.md per shared-patterns/standards-coverage-table.md -> "bee:frontend-designer-react-native"

    Focus on React Native design perspective:
    - Typography standards (font selection, pairing, hierarchy on mobile)
    - Styling standards (StyleSheet.create, NativeWind, design tokens)
    - Animation standards (Animated API, Reanimated, LayoutAnimation)
    - Component patterns (React Native component structure, design system compliance)
    - Accessibility UX (color contrast, touch target sizes >= 44x44pt, reduced motion)
    - Platform design conventions (iOS vs Android patterns)

    UI Library Mode: {ui_library_mode}

    Input:
    - Bee Standards: Load via WebFetch (frontend-react-native.md)
    - Section Index: See shared-patterns/standards-coverage-table.md -> "bee:frontend-designer-react-native"
    - Codebase Report: docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format)
    2. ISSUE-XXX for each non-compliant finding

Task tool 4:
  subagent_type: "bee:devops-engineer"
  description: "DevOps analysis for React Native / Expo"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**
    Check all sections per shared-patterns/standards-coverage-table.md -> "bee:devops-engineer"

    React Native / Expo-specific DevOps focus:
    - EAS Build configuration (eas.json with development, preview, production profiles)
    - app.config.ts or app.json completeness (bundleIdentifier, versionCode, etc.)
    - .env management (react-native-dotenv or expo-constants)
    - Makefile with RN commands (test, e2e, build:ios, build:android, lint)
    - CI/CD pipeline for EAS Build / Fastlane / Bitrise
    - Code signing setup (iOS provisioning, Android keystore documentation)

    Input:
    - Bee Standards: Load via WebFetch (devops.md)
    - Codebase Report: docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output: Standards Coverage Table + ISSUE-XXX for gaps

Task tool 5:
  subagent_type: "bee:sre"
  description: "Observability analysis for React Native / Expo"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**
    Check all sections per shared-patterns/standards-coverage-table.md -> "bee:sre"

    React Native-specific observability focus:
    - Error tracking (ErrorBoundary components, global error handler via ErrorUtils)
    - Crash reporting (Sentry / Bugsnag / Firebase Crashlytics integration)
    - Analytics events (screen views, user actions, custom events)
    - Performance monitoring (react-native-performance, Flipper integration)
    - Network request logging (Axios interceptors, fetch logging)
    - In-app diagnostic logs (structured logging before shipping to backend)

    Input:
    - Bee Standards: Load via WebFetch (sre.md)
    - Codebase Report: docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output: Standards Coverage Table + ISSUE-XXX for gaps
```

### Conditionally Dispatched

**Add to the parallel dispatch if conditions from Step 1b are met:**

```yaml
Task tool 6 (if dispatch_ui_engineer == true):
  subagent_type: "bee:ui-engineer-react-native"
  description: "React Native UI engineer standards analysis"
  model: "opus"
  prompt: |
    **MODE: ANALYSIS only**

    MANDATORY: Check all sections in frontend-react-native.md per shared-patterns/standards-coverage-table.md -> "bee:ui-engineer-react-native"

    Additionally verify against product-designer outputs:
    - UX criteria compliance (ux-criteria.md)
    - User flow implementation (user-flows.md)
    - Wireframe adherence (wireframes/*.yaml)
    - UI states coverage (loading, error, empty, success) using ActivityIndicator, ErrorBoundary patterns
    - Touch target sizes (minimum 44x44pt for iOS, 48x48dp for Android)

    UI Library Mode: {ui_library_mode}

    Input:
    - Bee Standards: Load via WebFetch (frontend-react-native.md)
    - UX Criteria: docs/pre-dev/{feature}/ux-criteria.md
    - Codebase Report: docs/bee:dev-refactor-frontend-react-native/{timestamp}/codebase-report.md
    - Project Rules: docs/PROJECT_RULES.md

    Output:
    1. Standards Coverage Table (per shared-patterns format)
    2. UX Criteria Compliance table
    3. ISSUE-XXX for each non-compliant finding
```

### Agent Dispatch Summary

| Condition | Agents to Dispatch |
|-----------|-------------------|
| Always | Tasks 1-5 (Frontend Engineer RN + QA Frontend RN + Designer RN + DevOps + SRE) |
| ux-criteria.md exists | + Task 6 (UI Engineer RN) |

**TodoWrite:** Mark "Dispatch React Native frontend specialist agents in parallel" as `completed`

---

## Step 4.5: Agent Report -> Findings Mapping (HARD GATE)

**TodoWrite:** Mark "Map agent findings to FINDING-XXX entries" as `in_progress`

**MANDATORY: all agent-reported issues MUST become findings.**

| Agent Report | Action |
|--------------|--------|
| Any difference between current code and Bee standard | -> Create FINDING-XXX |
| Any missing pattern from Bee standards | -> Create FINDING-XXX |
| Any deprecated pattern usage (class components, Redux) | -> Create FINDING-XXX |
| Any accessibility gap | -> Create FINDING-XXX |
| Any testing gap | -> Create FINDING-XXX |
| Any performance issue | -> Create FINDING-XXX |

### Gate Escape Detection (React Native 9-Gate Cycle)

**When mapping findings, identify which gate SHOULD have caught the issue:**

| Finding Category | Should Be Caught In | Flag |
|------------------|---------------------|------|
| Class components / Redux usage | Gate 0 (Implementation) | Normal finding |
| React Native component architecture issues | Gate 0 (Implementation) | Normal finding |
| EAS Build/DevOps gaps | Gate 1 (DevOps) | GATE 1 ESCAPE |
| Missing accessibilityLabel/accessibilityRole | Gate 2 (Accessibility) | GATE 2 ESCAPE |
| VoiceOver/TalkBack violations | Gate 2 (Accessibility) | GATE 2 ESCAPE |
| Touch target size violations (<44x44pt) | Gate 2 (Accessibility) | GATE 2 ESCAPE |
| Unit test gaps, coverage <85% | Gate 3 (Unit Testing) | GATE 3 ESCAPE |
| Missing RNTL patterns in tests | Gate 3 (Unit Testing) | GATE 3 ESCAPE |
| Missing Jest snapshot tests | Gate 4 (Visual) | GATE 4 ESCAPE |
| Missing platform snapshots (iOS/Android) | Gate 4 (Visual) | GATE 4 ESCAPE |
| sindarian-rn component duplication | Gate 4 (Visual) | GATE 4 ESCAPE |
| Untested user flows (Detox) | Gate 5 (E2E) | GATE 5 ESCAPE |
| Navigation flows not tested | Gate 5 (E2E) | GATE 5 ESCAPE |
| Deep linking not tested | Gate 5 (E2E) | GATE 5 ESCAPE |
| FlatList used instead of FlashList | Gate 6 (Performance) | GATE 6 ESCAPE |
| Bundle size over budget | Gate 6 (Performance) | GATE 6 ESCAPE |
| Hermes not enabled | Gate 6 (Performance) | GATE 6 ESCAPE |
| Unoptimized images (no FastImage) | Gate 6 (Performance) | GATE 6 ESCAPE |
| Code quality (reviewer-catchable) | Gate 7 (Review) | GATE 7 ESCAPE |

**TodoWrite:** Mark "Map agent findings to FINDING-XXX entries" as `completed`

---

## Step 4.6: Save Individual Agent Reports

**TodoWrite:** Mark "Save individual agent reports" as `in_progress`

```
docs/bee:dev-refactor-frontend-react-native/{timestamp}/reports/
+-- bee:frontend-engineer-react-native-report.md     (always)
+-- bee:qa-analyst-frontend-react-native-report.md   (always)
+-- bee:frontend-designer-react-native-report.md     (always)
+-- bee:devops-engineer-report.md                    (always)
+-- bee:sre-report.md                                (always)
+-- bee:ui-engineer-react-native-report.md           (if ux-criteria.md exists)
```

**Use Write tool for each agent report.**

**TodoWrite:** Mark "Save individual agent reports" as `completed`

---

## Step 5: Generate findings.md

**TodoWrite:** Mark "Generate findings.md" as `in_progress`

**Use Write tool to create findings.md.** Format follows the standard FINDING-XXX structure with React Native-specific categories:

**React Native-specific categories:** `class-component-migration | redux-migration | hooks-pattern | navigation | accessibility | testing | performance | devops | styling`

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

**Use Write tool to create tasks.md** with REFACTOR-XXX entries. Each entry includes Current Code, Bee Standard Reference, Required Actions, and Acceptance Criteria. React Native-specific acceptance criteria must reference functional component patterns, hooks patterns, Zustand store patterns, and RNTL testing patterns where applicable.

**TodoWrite:** Mark "Generate tasks.md" as `completed`

---

## Step 7.5: Visual Change Report

**TodoWrite:** Mark "Generate visual change report" as `in_progress`

**MANDATORY: Generate a visual HTML report before user approval.**

Invokes `Skill("bee:visual-explainer")` to produce a self-contained HTML page showing all planned React Native refactoring changes.

**Output:** Save to `docs/bee:dev-refactor-frontend-react-native/{timestamp}/change-report.html`

```text
macOS: open docs/bee:dev-refactor-frontend-react-native/{timestamp}/change-report.html
Linux: xdg-open docs/bee:dev-refactor-frontend-react-native/{timestamp}/change-report.html
```

**TodoWrite:** Mark "Generate visual change report" as `completed`

---

## Step 8: User Approval

**TodoWrite:** Mark "Get user approval" as `in_progress`

```text
if analyze_only == true:
  → Auto-select "Cancel" (analysis complete, skip execution)
  → Output: "analyze_only=true — analysis artifacts saved, skipping bee:dev-cycle-frontend-react-native."
  → Skip to Step 9, then TERMINATE.

if critical_only == true:
  → Auto-select "Critical only"
  → Output: "critical_only=true — auto-selecting Critical/High tasks only."
  → Continue to Step 9, then Step 10 with Critical/High tasks.
```

```yaml
AskUserQuestion:
  questions:
    - question: "Review React Native frontend refactoring plan. How to proceed?"
      header: "Approval"
      options:
        - label: "Approve all"
          description: "Proceed to bee:dev-cycle-frontend-react-native execution"
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
docs/bee:dev-refactor-frontend-react-native/{timestamp}/
+-- codebase-report.md  (Step 3)
+-- reports/            (Step 4.6)
|   +-- bee:frontend-engineer-react-native-report.md
|   +-- bee:qa-analyst-frontend-react-native-report.md
|   +-- bee:frontend-designer-react-native-report.md
|   +-- bee:devops-engineer-report.md
|   +-- bee:sre-report.md
|   +-- bee:ui-engineer-react-native-report.md           (conditional)
+-- findings.md         (Step 5)
+-- tasks.md            (Step 7)
+-- change-report.html  (Step 7.5)
```

**TodoWrite:** Mark "Save all artifacts" as `completed`

---

## Step 10: Handoff to bee:dev-cycle-frontend-react-native

**TodoWrite:** Mark "Handoff to bee:dev-cycle-frontend-react-native" as `in_progress`

```yaml
Skill tool:
  skill: "bee:dev-cycle-frontend-react-native"
```

**Pass tasks file path in context:**
- Tasks file: `docs/bee:dev-refactor-frontend-react-native/{timestamp}/tasks.md`

**HARD GATE: When execution is approved, you CANNOT complete bee:dev-refactor-frontend-react-native without invoking `Skill tool: bee:dev-cycle-frontend-react-native`.**

**TodoWrite:** Mark "Handoff to bee:dev-cycle-frontend-react-native" as `completed`

---

## Execution Report

| Metric | Value |
|--------|-------|
| Agents Dispatched | N (5-6) |
| UI Library Mode | sindarian-rn / fallback-only |
| Redux Migration Gaps | N |
| Class Component Migration Gaps | N |
| Findings Generated | N |
| Tasks Created | N |
| Gate Escapes Detected | N |
| Artifacts Location | docs/bee:dev-refactor-frontend-react-native/{timestamp}/ |

---
