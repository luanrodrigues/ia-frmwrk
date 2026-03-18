# Bee Dev Team

> A Claude AI plugin that provides **14 specialized developer agents**, **21 development skills**, and **9 slash commands** for enterprise-grade software development workflows.

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

Bee Dev Team orchestrates a complete development team through Claude AI. It enforces quality through **gate-based development cycles** — 10 gates for backend (PHP/Laravel) and 9 gates for frontend (React/Next.js and Vue.js/Nuxt 3) — with mandatory standards compliance, automated testing strategies, and anti-rationalization safeguards.

## Agents

| Agent | Specialty |
|-------|-----------|
| **Backend Engineer** | PHP 8.2+ / Laravel 11+ — APIs, microservices, Eloquent, queues |
| **Database Engineer** | PostgreSQL, MySQL, MongoDB, Redis — schema design, indexing, migration safety, query optimization, replication, sharding |
| **Frontend Engineer** | React 18+ / Next.js — components, state management, performance |
| **Frontend Engineer (Vue.js)** | Vue 3 / Nuxt 3 — Composition API, Pinia, VeeValidate, shadcn-vue |
| **BFF Engineer** | TypeScript — API aggregation layer, type-safe data transformation |
| **Frontend Designer** | UX research, information architecture, visual design specs |
| **UI Engineer** | Design-to-code (React), component libraries, UX criteria satisfaction |
| **UI Engineer (Vue.js)** | Design-to-code (Vue 3/Nuxt 3), shadcn-vue, UX criteria satisfaction |
| **DevOps Engineer** | Docker, Terraform, Kubernetes, Helm, CI/CD |
| **SRE** | Observability, health checks, structured logging, tracing |
| **QA Analyst (Backend)** | Pest/PHPUnit, integration, chaos, fuzz, property testing |
| **QA Analyst (Frontend)** | Vitest, Playwright, accessibility, visual regression (React) |
| **QA Analyst (Frontend Vue.js)** | Vitest, Vue Testing Library, Playwright, accessibility, visual regression (Vue.js/Nuxt 3) |
| **Prompt Quality Reviewer** | Agent quality evaluation and improvement |

## Development Cycles

### Backend — 8 Gates

```
Gate 0  Implementation     →  Code implementation (PHP/Laravel)
Gate 1  Unit Testing       →  Pest/PHPUnit coverage
Gate 2  Fuzz Testing       →  Input mutation testing
Gate 3  Property Testing   →  Property-based testing
Gate 4  Integration Testing →  Integration scenarios
Gate 5  Chaos Testing      →  Failure injection
Gate 6  Code Review        →  Peer review
Gate 7  Validation         →  Final quality gates
```

### Frontend — 8 Gates (React/Next.js)

```
Gate 0  Implementation       →  React/Next.js code
Gate 1  Accessibility        →  WCAG 2.1 AA compliance
Gate 2  Unit Testing         →  Vitest + Testing Library
Gate 3  Visual Testing       →  Visual regression
Gate 4  E2E Testing          →  Playwright
Gate 5  Performance          →  Core Web Vitals
Gate 6  Code Review          →  Peer review
Gate 7  Validation           →  Final quality gates
```

### Frontend — 8 Gates (Vue.js/Nuxt 3)

```
Gate 0  Implementation       →  Vue 3/Nuxt 3 code (Composition API, Pinia)
Gate 1  Accessibility        →  WCAG 2.1 AA compliance (axe-core, Radix Vue)
Gate 2  Unit Testing         →  Vitest + Vue Testing Library
Gate 3  Visual Testing       →  Visual regression (snapshots, Storybook)
Gate 4  E2E Testing          →  Playwright (Nuxt 3 flows)
Gate 5  Performance          →  Core Web Vitals, Nuxt performance
Gate 6  Code Review          →  Peer review
Gate 7  Validation           →  Final quality gates
```

## Commands

| Command | Description |
|---------|-------------|
| `/bee:dev-cycle [tasks] [prompt]` | Execute backend development cycle (9 gates) |
| `/bee:dev-cycle-frontend [tasks] [prompt]` | Execute React/Next.js frontend development cycle (8 gates) |
| `/bee:dev-cycle-frontend-vuejs [tasks] [prompt]` | Execute Vue.js/Nuxt 3 frontend development cycle (8 gates) |
| `/bee:dev-refactor [path] [prompt]` | Analyze and refactor backend code |
| `/bee:dev-refactor-frontend [path] [prompt]` | Analyze and refactor React/Next.js frontend code |
| `/bee:dev-refactor-frontend-vuejs [path] [prompt]` | Analyze and refactor Vue.js/Nuxt 3 frontend code |
| `/bee:dev-status` | Show current cycle status |
| `/bee:dev-cancel` | Cancel current development cycle |
| `/bee:dev-report` | Generate execution report |

## Tech Stack

### Backend
- **PHP 8.2+** with **Laravel 11+**
- **Pest + PHPUnit** — testing
- **PHPStan Level 8+** — static analysis
- **PHP CS Fixer** — code style
- **Infection PHP** — mutation testing
- **Redis / RabbitMQ** — caching & messaging

### Frontend (React)
- **React 18+** / **Next.js**
- **TypeScript 5+**
- **TailwindCSS** / **shadcn/ui** / **Radix UI**
- **TanStack Query** / **Zustand** — state management
- **React Hook Form + Zod** — forms & validation
- **Vitest** / **Playwright** / **axe-core** — testing

### Frontend (Vue.js)
- **Vue 3** (Composition API, `<script setup>`) / **Nuxt 3**
- **TypeScript 5+** (strict mode)
- **TailwindCSS** / **shadcn-vue** / **Radix Vue**
- **Pinia** — state management
- **VeeValidate + Zod** — forms & validation
- **Vitest** / **Vue Testing Library** / **Playwright** / **axe-core** — testing

### Infrastructure
- **Docker** / **Kubernetes** / **Helm**
- **Terraform** — IaC
- **GitHub Actions** — CI/CD
- **OpenTelemetry** — observability

## Project Structure

```
bee-dev-team/
├── agents/                 # 14 specialized agent definitions
├── skills/                 # 21 development workflow skills
│   └── shared-patterns/    # Reusable patterns & anti-rationalization
├── commands/               # 9 slash command definitions
├── docs/standards/         # Standards (PHP, Frontend React, Frontend Vue.js, DevOps, SRE)
├── hooks/                  # Session lifecycle hooks
└── .claude-plugin/         # Plugin metadata
```

## Installation

1. Clone into your Claude plugins directory:
   ```bash
   git clone https://github.com/luanrodrigues/ia-frmwrk.git
   ```

2. The plugin auto-initializes on session start via `hooks/session-start.sh`.

3. Use slash commands to start a development cycle:
   ```
   /bee:dev-cycle "Implement user authentication with Laravel Sanctum"
   ```

## Usage Guide

### Prerequisites

Before using refactoring commands, your project must have a `docs/PROJECT_RULES.md` file defining your architecture patterns, code conventions, testing requirements, and DevOps standards. This file is **mandatory** — the plugin will block execution without it.

### Starting a Backend Development Cycle

Use `/bee:dev-cycle` to run a full 8-gate backend cycle. You can pass a tasks file or a direct prompt:

```bash
# Direct prompt — the plugin generates tasks internally
/bee:dev-cycle Implement user authentication with Laravel Sanctum

# From a tasks file
/bee:dev-cycle docs/tasks/sprint-001.md

# Execute a specific task only
/bee:dev-cycle docs/tasks/sprint-001.md --task AUTH-003

# Skip specific gates (e.g., devops and review)
/bee:dev-cycle docs/tasks/sprint-001.md --skip-gates devops,review

# Dry run — validate tasks without executing
/bee:dev-cycle docs/tasks/sprint-001.md --dry-run

# Resume an interrupted cycle
/bee:dev-cycle --resume
```

### Starting a Frontend Development Cycle

Use `/bee:dev-cycle-frontend` for the React/Next.js 9-gate frontend cycle, or `/bee:dev-cycle-frontend-vuejs` for Vue.js/Nuxt 3. Same syntax:

```bash
# Direct prompt (React)
/bee:dev-cycle-frontend Implement dashboard with transaction list, charts, and filters

# From a tasks file (React)
/bee:dev-cycle-frontend docs/tasks/sprint-001-frontend.md

# Resume (React)
/bee:dev-cycle-frontend --resume

# Direct prompt (Vue.js/Nuxt 3)
/bee:dev-cycle-frontend-vuejs Implement dashboard with transaction list, charts, and filters

# From a tasks file (Vue.js/Nuxt 3)
/bee:dev-cycle-frontend-vuejs docs/tasks/sprint-001-frontend.md

# Resume (Vue.js/Nuxt 3)
/bee:dev-cycle-frontend-vuejs --resume
```

### Refactoring Existing Code

Use `/bee:dev-refactor` to analyze your codebase against standards and generate a refactoring plan:

```bash
# Analyze entire project
/bee:dev-refactor

# Analyze a specific directory
/bee:dev-refactor src/domain

# Focus on a specific area
/bee:dev-refactor Focus on multi-tenant patterns and ensure all repositories use TenantManager

# Analysis only — generate report without executing fixes
/bee:dev-refactor --analyze-only

# Fix only critical/high severity issues
/bee:dev-refactor --critical-only

# Use custom standards file
/bee:dev-refactor --standards docs/team-standards.md
```

For React/Next.js frontend refactoring, use `/bee:dev-refactor-frontend` with the same options. For Vue.js/Nuxt 3 frontend refactoring, use `/bee:dev-refactor-frontend-vuejs`.

### Monitoring and Control

```bash
# Check current cycle status (tasks completed, current gate, metrics)
/bee:dev-status

# Cancel a running cycle (state is preserved for resume)
/bee:dev-cancel

# View the execution report from the last cycle
/bee:dev-report

# View report from a specific date
/bee:dev-report 2024-01-15
```

### Tasks File Format

Tasks files are markdown files with structured task definitions:

```markdown
## AUTH-001 — Implement login endpoint

Create POST /api/auth/login with email/password validation,
JWT token generation, and rate limiting.

## AUTH-002 — Implement refresh token

Create POST /api/auth/refresh with token rotation
and revocation support.
```

### Typical Workflow

1. **Plan** — Define tasks in a markdown file or describe them in a prompt
2. **Execute** — Run `/bee:dev-cycle` or `/bee:dev-cycle-frontend`
3. **Monitor** — Check progress with `/bee:dev-status`
4. **Review** — The cycle includes automated code review (Gate 8 backend / Gate 6 frontend)
5. **Report** — View results with `/bee:dev-report`
6. **Iterate** — Use `/bee:dev-refactor` to find and fix remaining gaps against standards

## Code Review

The code review pipeline runs at **Gate 8** (backend) or **Gate 6** (frontend) and combines three review layers for maximum coverage:

### Review Layers

| Layer | Tool | Role | Mandatory? |
|-------|------|------|------------|
| **Bee Reviewers** | 6 internal agents | Primary review (code, business logic, security, tests, nil safety, consequences) | Yes - all 6 must pass |
| **CodeRabbit** | CodeRabbit CLI | External AI review with semantic diff analysis | Yes if installed |
| **OpenCode** | OpenCode CLI | Second AI opinion from a different model (e.g., Qwen3-Max) | Advisory |

### How to Trigger

**Automatic (within a development cycle):**

Code review runs automatically as part of the dev cycle gates:

```bash
# Backend — review runs at Gate 8
/bee:dev-cycle "Implement user authentication"

# Frontend — review runs at Gate 6
/bee:dev-cycle-frontend "Implement dashboard"
```

**Standalone (outside a development cycle):**

```bash
# Trigger code review on current branch changes
/bee:codereview

# The skill auto-detects:
# - Base SHA (via git merge-base HEAD main)
# - Changed files (via git diff)
# - Commit messages for context
```

### What Happens During Review

```
1. Pre-Analysis    →  Static analysis + AST extraction (Mithril)
2. Bee Reviewers   →  6 agents dispatched in parallel
3. Fix Cycle       →  Issues found → implementation agent fixes → re-review (max 3 iterations)
4. CodeRabbit      →  External review per subtask (if installed)
5. OpenCode        →  Second AI model review (if installed)
6. Visual Report   →  HTML report generated and opened in browser
```

### OpenCode Integration

OpenCode sends the diff to a different AI model for an independent review:

```bash
# Requires OpenCode CLI installed
# https://github.com/opencode-ai/opencode

# Default model: Qwen3-Max
# Configurable via opencode_model parameter
```

Available models for review:

| Model | Use Case |
|-------|----------|
| `bailian-coding-plan/qwen3-max-2026-01-23` | Default - strong general review |
| `bailian-coding-plan/qwen3-coder-plus` | Code-focused review |
| `opencode/gpt-5-nano` | Fast lightweight review |

OpenCode findings are **advisory** — CRITICAL issues are presented to the user, who decides whether to fix or acknowledge them. See [docs/opencode-instructions.md](docs/opencode-instructions.md) for the review instructions sent to the external model.

### Review Output

Each review produces:
- **Reviewer Verdicts** — PASS/FAIL per reviewer with issue counts
- **Issues by Severity** — CRITICAL, HIGH, MEDIUM, LOW breakdown
- **CodeRabbit Findings** — External review results (if applicable)
- **OpenCode Findings** — Second model review results (if applicable)
- **Visual HTML Report** — Interactive report at `docs/codereview/review-report-{unit_id}.html`

## Standards

The plugin enforces comprehensive standards loaded at runtime:

| Domain | Sections | Covers |
|--------|----------|--------|
| **PHP/Laravel** | 46 | Versions, DB, Eloquent, HTTP, testing, architecture, multi-tenant |
| **Frontend (React)** | 20 | React, state, forms, styling, accessibility, performance |
| **Frontend (Vue.js)** | 20 | Vue 3/Nuxt 3, Pinia, VeeValidate, shadcn-vue, accessibility, performance |
| **DevOps** | 8 | Cloud, Terraform, containers, Helm, security, CI/CD |
| **SRE** | 6 | Health checks, logging, tracing, monitoring |

## License

[MIT](LICENSE)
