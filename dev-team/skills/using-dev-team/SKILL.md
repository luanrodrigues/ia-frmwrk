---
name: bee:using-dev-team
description: |
  16 specialist developer agents for backend (PHP), database, frontend (React + Vue.js + React Native/Expo),
  design, UI implementation, QA (backend + frontend), and SRE. Dispatch when you need deep technology expertise.

trigger: |
  - Need deep expertise for specific technology (PHP)
  - Frontend with design focus → bee:frontend-designer
  - Frontend from product-designer specs → bee:ui-engineer
  - Frontend from product-designer specs (Vue.js) → bee:ui-engineer-vuejs
  - Vue.js/Nuxt 3 frontend development → bee:frontend-engineer-vuejs
  - Frontend from product-designer specs (React Native) → bee:ui-engineer-react-native
  - React Native/Expo mobile development → bee:frontend-engineer-react-native
  - Frontend test strategy (React Native) → bee:qa-analyst-frontend-react-native
  - Database schema design / optimization → bee:database-engineer
  - Backend test strategy → bee:qa-analyst
  - Frontend test strategy (React) → bee:qa-analyst-frontend
  - Frontend test strategy (Vue.js) → bee:qa-analyst-frontend-vuejs
  - Reliability/monitoring → bee:sre

skip_when: |
  - General code review → use default plugin reviewers
  - Planning/design → use brainstorming
  - Debugging → use bee:systematic-debugging

related:
  similar: [bee:using-bee]
---

# Using Bee Developer Specialists

The bee-dev-team plugin provides 16 specialized developer agents. Use them via `Task tool with subagent_type:`.

See [CLAUDE.md](https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/CLAUDE.md) and [bee:using-bee](https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/default/skills/using-bee/SKILL.md) for canonical workflow requirements and ORCHESTRATOR principle. This skill introduces dev-team-specific agents.

**Remember:** Follow the **ORCHESTRATOR principle** from `bee:using-bee`. Dispatch agents to handle complexity; don't operate tools directly.

---

## Blocker Criteria - STOP and Report

<block_condition>

- Technology Stack decision needed (PHP)
- Architecture decision needed (monolith vs microservices)
- Infrastructure decision needed (cloud provider)
- Testing strategy decision needed (unit vs E2E)
  </block_condition>

If any condition applies, STOP and ask user.

**always pause and report blocker for:**

| Decision Type        | Examples                         | Action                                         |
| -------------------- | -------------------------------- | ---------------------------------------------- |
| **Technology Stack** | PHP for new service | STOP. Check existing patterns. Ask user.       |
| **Architecture**     | Monolith vs microservices        | STOP. This is a business decision. Ask user.   |
| **Infrastructure**   | Cloud provider choice            | STOP. Check existing infrastructure. Ask user. |
| **Testing Strategy** | Unit vs E2E vs both              | STOP. Check QA requirements. Ask user.         |

**You CANNOT make technology decisions autonomously. STOP and ask.**

---

## Common Misconceptions - REJECTED

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations (including Specialist Dispatch section).

**Self-sufficiency bias check:** If you're tempted to implement directly, ask:

1. Is there a specialist for this? (Check the 16 specialists below)
2. Would a specialist follow standards I might miss?
3. Am I avoiding dispatch because it feels like "overhead"?

**If any answer is yes → You MUST DISPATCH the specialist. This is NON-NEGOTIABLE.**

---

## Anti-Rationalization Table

See [shared-patterns/shared-anti-rationalization.md](../shared-patterns/shared-anti-rationalization.md) for universal anti-rationalizations (including Specialist Dispatch section and Universal section).

---

### Cannot Be Overridden

<cannot_skip>

- Dispatch to specialist (standards loading required)
- 8-gate development cycle (quality gates)
- Parallel reviewer dispatch (not sequential)
- TDD in Gate 0 (test-first)
- User approval in Gate 7
  </cannot_skip>

**These requirements are NON-NEGOTIABLE:**

| Requirement                    | Why It Cannot Be Waived                       |
| ------------------------------ | --------------------------------------------- |
| **Dispatch to specialist**     | Specialists have standards loading, you don't |
| **8-gate development cycle**  | Gates prevent quality regressions             |
| **Parallel reviewer dispatch** | Sequential review = 3x slower, same cost      |
| **TDD in Gate 0**              | Test-first ensures testability                |
| **User approval in Gate 7**    | Only users can approve completion             |

**User cannot override these. Time pressure cannot override these. "Simple task" cannot override these.**

---

## Pressure Resistance

See [shared-patterns/shared-pressure-resistance.md](../shared-patterns/shared-pressure-resistance.md) for universal pressure scenarios (including Combined Pressure Scenarios and Emergency Response).

**Critical Reminder:**

- **Urgency ≠ Permission to bypass** - Emergencies require MORE care, not less
- **Authority ≠ Permission to bypass** - Bee standards override human preferences
- **Sunk Cost ≠ Permission to bypass** - Wrong approach stays wrong at 80% completion

---

## Emergency Response Protocol

See [shared-patterns/shared-pressure-resistance.md](../shared-patterns/shared-pressure-resistance.md) → Emergency Response section for the complete protocol.

**Emergency Dispatch Template:**

```
Task tool:
  subagent_type: "bee:backend-engineer-php"
  model: "opus"
  prompt: "URGENT PRODUCTION INCIDENT: [brief context]. [Your specific request]"
```

**IMPORTANT:** Specialist dispatch takes 5-10 minutes, not hours. This is NON-NEGOTIABLE even under CEO pressure.

---

## Combined Pressure Scenarios

See [shared-patterns/shared-pressure-resistance.md](../shared-patterns/shared-pressure-resistance.md) → Combined Pressure Scenarios section.

---

## 16 Developer Specialists

<dispatch_required agent="{specialist}">
Use Task tool to dispatch appropriate specialist based on technology need.
</dispatch_required>

| Agent                                       | Specializations                                                                                      | Use When                                                                              |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **`bee:backend-engineer-php`**          | PHP Services, MySQL/MongoDB, Kafka/RabbitMQ, OAuth2/JWT, gRPC, concurrency                  | PHP services, ORM patterns, auth/authz, concurrency issues                              |
| **`bee:database-engineer`**            | Schema design, indexing, query optimization, migration safety, replication, sharding, tuning | DB schema design, index strategy, migration planning, query optimization, scaling       |
| **`bee:frontend-bff-engineer-typescript`** | Next.js API Routes BFF, Clean/Hexagonal Architecture, DDD patterns, Inversify DI, repository pattern | BFF layer, Clean Architecture, DDD domains, API orchestration                         |
| **`bee:frontend-designer`**                | Bold typography, color systems, animations, unexpected layouts, textures/gradients                   | Landing pages, portfolios, distinctive dashboards, design systems                     |
| **`bee:ui-engineer`**                      | Wireframe-to-code, Design System compliance, UX criteria satisfaction, UI states implementation      | Implementing from product-designer specs (ux-criteria.md, user-flows.md, wireframes/) |
| **`bee:qa-analyst`**                       | Test strategy, coverage analysis, API testing, fuzz/property/integration/chaos testing (PHP)          | Backend test planning, coverage gaps, quality gates (PHP-focused)                      |
| **`bee:qa-analyst-frontend`**              | Vitest, Testing Library, axe-core, Playwright, Lighthouse, Core Web Vitals, snapshot testing         | Frontend test planning, accessibility, visual, E2E, performance testing (React)        |
| **`bee:frontend-engineer-vuejs`**          | Vue 3, Nuxt 3, Pinia, VeeValidate, shadcn-vue, Composition API, TypeScript                           | Vue.js/Nuxt 3 components, state management, forms, performance optimization            |
| **`bee:ui-engineer-vuejs`**                | Wireframe-to-Vue-code, Design System compliance (shadcn-vue), UX criteria satisfaction, UI states    | Implementing from product-designer specs (ux-criteria.md, user-flows.md, wireframes/) |
| **`bee:qa-analyst-frontend-vuejs`**        | Vitest, Vue Testing Library, axe-core, Playwright, Lighthouse, Core Web Vitals, Vue snapshots        | Vue.js/Nuxt 3 test planning, accessibility, visual, E2E, performance testing           |
| **`bee:frontend-engineer-react-native`**   | React Native, Expo, NativeWind, Zustand, React Hook Form, Reanimated, React Navigation, TypeScript   | React Native/Expo mobile components, state management, forms, performance optimization |
| **`bee:ui-engineer-react-native`**         | Wireframe-to-RN-code, Design System compliance (NativeWind), UX criteria satisfaction, UI states     | Implementing from product-designer specs into React Native/Expo mobile screens         |
| **`bee:qa-analyst-frontend-react-native`** | Jest, React Native Testing Library, Detox, Maestro, accessibility, device coverage, E2E mobile flows | React Native/Expo test planning, accessibility, E2E, performance testing               |
| **`bee:sre`**                              | Structured logging, tracing, health checks, observability                                            | Logging validation, tracing setup, health endpoint verification                       |

**Dispatch template:**

```
Task tool:
  subagent_type: "bee:{agent-name}"
  model: "opus"
  prompt: "{Your specific request with context}"
```

**Frontend Agent Selection:**

- `bee:frontend-designer` = visual aesthetics, design specifications (no code)
- `bee:frontend-bff-engineer-typescript` = business logic/architecture, BFF layer
- `bee:ui-engineer` = implementing UI from product-designer specs into React/Next.js
- `bee:ui-engineer-vuejs` = implementing UI from product-designer specs into Vue 3/Nuxt 3
- `bee:ui-engineer-react-native` = implementing UI from product-designer specs into React Native/Expo
- `bee:frontend-engineer-vuejs` = Vue 3/Nuxt 3 development without design specs
- `bee:frontend-engineer-react-native` = React Native/Expo mobile development without design specs

**When to use bee:ui-engineer vs bee:ui-engineer-vuejs vs bee:ui-engineer-react-native:**
Use `bee:ui-engineer` (React), `bee:ui-engineer-vuejs` (Vue.js/Nuxt 3), or `bee:ui-engineer-react-native` (React Native/Expo) when product-designer outputs exist in `docs/pre-dev/{feature}/`. All three agents specialize in translating design specifications into production code while ensuring all UX criteria are satisfied — choose based on the project's frontend stack.

---

## When to Use Developer Specialists vs General Review

### Use Developer Specialists for:

- ✅ **Deep technical expertise needed** – Architecture decisions, complex implementations
- ✅ **Technology-specific guidance** – "How do I optimize this PHP service?"
- ✅ **Specialized domains** – Infrastructure, SRE, testing strategy
- ✅ **Building from scratch** – New service, new pipeline, new testing framework

### Use General Review Agents for:

- ✅ **Code quality assessment** – Architecture, patterns, maintainability
- ✅ **Correctness & edge cases** – Business logic verification
- ✅ **Security review** – OWASP, auth, validation
- ✅ **Post-implementation** – Before merging existing code

**Both can be used together:** Get developer specialist guidance during design, then run general reviewers before merge.

---

## Dispatching Multiple Specialists

If you need multiple specialists (e.g., backend engineer + SRE), dispatch in **parallel** (single message, multiple Task calls):

```
✅ CORRECT:
Task #1: bee:backend-engineer-php
Task #2: bee:sre
(Both run in parallel)

❌ WRONG:
Task #1: bee:backend-engineer-php
(Wait for response)
Task #2: bee:sre
(Sequential = 2x slower)
```

---

## ORCHESTRATOR Principle

Remember:

- **You're the orchestrator** – Dispatch specialists, don't implement directly
- **Don't read specialist docs yourself** – Dispatch to specialist, they know their domain
- **Combine with bee:using-bee principle** – Skills + Specialists = complete workflow

### Good Example (ORCHESTRATOR):

> "I need a PHP service. Let me dispatch `bee:backend-engineer-php` to design it."

### Bad Example (OPERATOR):

> "I'll manually read PHP best practices and design the service myself."

---

## Available in This Plugin

**Agents:** See "16 Developer Specialists" table above.

**Skills:** `bee:using-dev-team` (this), `bee:dev-cycle` (8-gate backend workflow), `bee:dev-cycle-frontend` (9-gate React frontend workflow), `bee:dev-cycle-frontend-vuejs` (9-gate Vue.js/Nuxt 3 frontend workflow), `bee:dev-cycle-frontend-react-native` (9-gate React Native/Expo frontend workflow), `bee:dev-refactor` (backend/general codebase analysis), `bee:dev-refactor-frontend` (React frontend codebase analysis), `bee:dev-refactor-frontend-vuejs` (Vue.js/Nuxt 3 frontend codebase analysis), `bee:dev-refactor-frontend-react-native` (React Native/Expo codebase analysis)

**Commands:** `/bee:dev-cycle` (backend tasks), `/bee:dev-cycle-frontend` (React frontend tasks), `/bee:dev-cycle-frontend-vuejs` (Vue.js frontend tasks), `/bee:dev-cycle-frontend-react-native` (React Native/Expo tasks), `/bee:dev-refactor` (analyze backend/general codebase), `/bee:dev-refactor-frontend` (analyze React frontend codebase), `/bee:dev-refactor-frontend-vuejs` (analyze Vue.js/Nuxt 3 frontend codebase), `/bee:dev-refactor-frontend-react-native` (analyze React Native/Expo codebase), `/bee:dev-status`, `/bee:dev-cancel`, `/bee:dev-report`

**Note:** Missing agents? Check `.claude-plugin/marketplace.json` for bee-dev-team plugin.

---

## Development Workflows

All workflows converge to the 8-gate development cycle:

| Workflow         | Entry Point                           | Output                                        | Then                         |
| ---------------- | ------------------------------------- | --------------------------------------------- | ---------------------------- |
| **New Feature**  | `/bee:pre-dev-feature "description"` | `docs/pre-dev/{feature}/tasks.md`             | → `/bee:dev-cycle tasks.md` |
| **Direct Tasks** | `/bee:dev-cycle tasks.md`            | —                                             | Execute 6 gates directly     |
| **Refactoring**  | `/bee:dev-refactor`                  | `docs/bee:dev-refactor/{timestamp}/tasks.md` | → `/bee:dev-cycle tasks.md` |
| **Frontend Refactoring** | `/bee:dev-refactor-frontend` | `docs/bee:dev-refactor-frontend/{timestamp}/tasks.md` | → `/bee:dev-cycle-frontend tasks.md` |
| **Vue.js Refactoring** | `/bee:dev-refactor-frontend-vuejs` | `docs/bee:dev-refactor-frontend-vuejs/{timestamp}/tasks.md` | → `/bee:dev-cycle-frontend-vuejs tasks.md` |
| **React Native Refactoring** | `/bee:dev-refactor-frontend-react-native` | `docs/bee:dev-refactor-frontend-react-native/{timestamp}/tasks.md` | → `/bee:dev-cycle-frontend-react-native tasks.md` |

**8-Gate Development Cycle:**

| Gate                  | Focus                            | Agent(s)                                                                               |
| --------------------- | -------------------------------- | -------------------------------------------------------------------------------------- |
| **0: Implementation** | TDD: RED→GREEN→REFACTOR          | `bee:backend-engineer-*`, `bee:frontend-bff-engineer-typescript`, `bee:ui-engineer`, `bee:ui-engineer-vuejs`, `bee:ui-engineer-react-native` |
| **1: Unit Testing**   | Unit tests, coverage ≥85%        | `bee:qa-analyst`                                                                      |
| **2: Fuzz Testing**   | Input mutation, edge cases       | `bee:qa-analyst`                                                                      |
| **3: Property Testing** | Invariant testing              | `bee:qa-analyst`                                                                      |
| **4: Integration Testing** | External dependencies       | `bee:qa-analyst`                                                                      |
| **5: Chaos Testing**  | Failure injection                | `bee:qa-analyst`                                                                      |
| **6: Review**         | 6 reviewers IN PARALLEL          | `bee:code-reviewer`, `bee:business-logic-reviewer`, `bee:security-reviewer`, `bee:test-reviewer`, `bee:nil-safety-reviewer`, `bee:consequences-reviewer` |
| **7: Validation**     | User approval: APPROVED/REJECTED | User decision                                                                          |

**Gate 0 Agent Selection for Frontend:**

- If `docs/pre-dev/{feature}/ux-criteria.md` exists (React stack) → use `bee:ui-engineer`
- If `docs/pre-dev/{feature}/ux-criteria.md` exists (Vue.js stack) → use `bee:ui-engineer-vuejs`
- If `docs/pre-dev/{feature}/ux-criteria.md` exists (React Native stack) → use `bee:ui-engineer-react-native`
- Otherwise (React) → use `bee:frontend-bff-engineer-typescript`
- Otherwise (Vue.js) → use `bee:frontend-engineer-vuejs`
- Otherwise (React Native) → use `bee:frontend-engineer-react-native`

**Key Principle:** Backend follows the 8-gate process. Frontend (React, Vue.js, and React Native) follows the 9-gate process.

### Frontend Development Cycle — React (9 Gates)

**Use `/bee:dev-cycle-frontend` for React/Next.js frontend-specific development:**

| Gate                      | Focus                                | Agent(s)                        |
| ------------------------- | ------------------------------------ | ------------------------------- |
| **0: Implementation**     | TDD: RED→GREEN→REFACTOR              | `bee:frontend-engineer`, `bee:ui-engineer`, `bee:frontend-bff-engineer-typescript` |
| **1: Accessibility**      | WCAG 2.1 AA, axe-core, keyboard nav | `bee:qa-analyst-frontend`      |
| **3: Unit Testing**       | Vitest + Testing Library, ≥85%       | `bee:qa-analyst-frontend`      |
| **4: Visual Testing**     | Snapshots, states, responsive        | `bee:qa-analyst-frontend`      |
| **5: E2E Testing**        | Playwright, cross-browser, user flows| `bee:qa-analyst-frontend`      |
| **6: Performance**        | Core Web Vitals, Lighthouse > 90     | `bee:qa-analyst-frontend`      |
| **7: Review**             | 6 reviewers IN PARALLEL              | `bee:code-reviewer`, `bee:business-logic-reviewer`, `bee:security-reviewer`, `bee:test-reviewer`, `bee:nil-safety-reviewer`, `bee:consequences-reviewer` |
| **8: Validation**         | User approval: APPROVED/REJECTED     | User decision                   |

### Frontend Development Cycle — Vue.js/Nuxt 3 (9 Gates)

**Use `/bee:dev-cycle-frontend-vuejs` for Vue.js/Nuxt 3 frontend-specific development:**

| Gate                      | Focus                                | Agent(s)                        |
| ------------------------- | ------------------------------------ | ------------------------------- |
| **0: Implementation**     | TDD: RED→GREEN→REFACTOR              | `bee:frontend-engineer-vuejs`, `bee:ui-engineer-vuejs`, `bee:frontend-bff-engineer-typescript` |
| **1: Accessibility**      | WCAG 2.1 AA, axe-core, keyboard nav | `bee:qa-analyst-frontend-vuejs` |
| **3: Unit Testing**       | Vitest + Vue Testing Library, ≥85%   | `bee:qa-analyst-frontend-vuejs` |
| **4: Visual Testing**     | Snapshots, states, responsive        | `bee:qa-analyst-frontend-vuejs` |
| **5: E2E Testing**        | Playwright, cross-browser, user flows| `bee:qa-analyst-frontend-vuejs` |
| **6: Performance**        | Core Web Vitals, Lighthouse > 90     | `bee:qa-analyst-frontend-vuejs` |
| **7: Review**             | 6 reviewers IN PARALLEL              | `bee:code-reviewer`, `bee:business-logic-reviewer`, `bee:security-reviewer`, `bee:test-reviewer`, `bee:nil-safety-reviewer`, `bee:consequences-reviewer` |
| **8: Validation**         | User approval: APPROVED/REJECTED     | User decision                   |

### Frontend Development Cycle — React Native/Expo (9 Gates)

**Use `/bee:dev-cycle-frontend-react-native` for React Native/Expo mobile-specific development:**

| Gate                      | Focus                                | Agent(s)                        |
| ------------------------- | ------------------------------------ | ------------------------------- |
| **0: Implementation**     | TDD: RED→GREEN→REFACTOR              | `bee:frontend-engineer-react-native`, `bee:ui-engineer-react-native` |
| **1: Accessibility**      | WCAG 2.1 AA, accessible labels, focus | `bee:qa-analyst-frontend-react-native` |
| **3: Unit Testing**       | Jest + React Native Testing Library, ≥85% | `bee:qa-analyst-frontend-react-native` |
| **4: Visual Testing**     | Snapshots, states, responsive        | `bee:qa-analyst-frontend-react-native` |
| **5: E2E Testing**        | Detox/Maestro, device coverage, user flows | `bee:qa-analyst-frontend-react-native` |
| **6: Performance**        | JS thread, startup time, bundle size | `bee:qa-analyst-frontend-react-native` |
| **7: Review**             | 6 reviewers IN PARALLEL              | `bee:code-reviewer`, `bee:business-logic-reviewer`, `bee:security-reviewer`, `bee:test-reviewer`, `bee:nil-safety-reviewer`, `bee:consequences-reviewer` |
| **8: Validation**         | User approval: APPROVED/REJECTED     | User decision                   |

**Backend → Frontend Handoff:**
When backend dev cycle completes, it produces a handoff with endpoints, types, and contracts. The frontend dev cycle consumes this handoff to verify E2E tests exercise the correct API endpoints.

| Step | Command | Output |
|------|---------|--------|
| 1. Backend | `/bee:dev-cycle tasks.md` | Backend code + handoff (endpoints, contracts) |
| 2. Frontend (React) | `/bee:dev-cycle-frontend tasks-frontend.md` | React/Next.js frontend code consuming backend endpoints |
| 2. Frontend (Vue.js) | `/bee:dev-cycle-frontend-vuejs tasks-frontend.md` | Vue 3/Nuxt 3 frontend code consuming backend endpoints |
| 2. Frontend (React Native) | `/bee:dev-cycle-frontend-react-native tasks-frontend.md` | React Native/Expo mobile code consuming backend endpoints |

---

## Integration with Other Plugins

- **bee:using-bee** (default) – ORCHESTRATOR principle for all agents
- **bee:using-pm-team** – Pre-dev workflow agents
- **bee:using-finops-team** – Financial/regulatory agents

Dispatch based on your need:

- General code review → default plugin agents
- Specific domain expertise → bee-dev-team agents
- Feature planning → bee-pm-team agents
- Regulatory compliance → bee-finops-team agents
