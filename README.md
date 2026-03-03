# Bee Dev Team

> A Claude AI plugin that provides **10 specialized developer agents**, **19 development skills**, and **7 slash commands** for enterprise-grade software development workflows.

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

Bee Dev Team orchestrates a complete development team through Claude AI. It enforces quality through **gate-based development cycles** — 10 gates for backend (PHP/Laravel) and 9 gates for frontend (React/Next.js) — with mandatory standards compliance, automated testing strategies, and anti-rationalization safeguards.

## Agents

| Agent | Specialty |
|-------|-----------|
| **Backend Engineer** | PHP 8.2+ / Laravel 11+ — APIs, microservices, Eloquent, queues |
| **Frontend Engineer** | React 18+ / Next.js — components, state management, performance |
| **BFF Engineer** | TypeScript — API aggregation layer, type-safe data transformation |
| **Frontend Designer** | UX research, information architecture, visual design specs |
| **UI Engineer** | Design-to-code implementation, component libraries |
| **DevOps Engineer** | Docker, Terraform, Kubernetes, Helm, CI/CD |
| **SRE** | Observability, health checks, structured logging, tracing |
| **QA Analyst (Backend)** | Pest/PHPUnit, integration, chaos, fuzz, property testing |
| **QA Analyst (Frontend)** | Vitest, Playwright, accessibility, visual regression |
| **Prompt Quality Reviewer** | Agent quality evaluation and improvement |

## Development Cycles

### Backend — 10 Gates

```
Gate 0  Implementation     →  Code implementation (PHP/Laravel)
Gate 1  DevOps             →  Infrastructure & containerization
Gate 2  SRE                →  Observability validation
Gate 3  Unit Testing       →  Pest/PHPUnit coverage
Gate 4  Fuzz Testing       →  Input mutation testing
Gate 5  Property Testing   →  Property-based testing
Gate 6  Integration Testing →  Integration scenarios
Gate 7  Chaos Testing      →  Failure injection
Gate 8  Code Review        →  Peer review
Gate 9  Validation         →  Final quality gates
```

### Frontend — 9 Gates

```
Gate 0  Implementation       →  React/Next.js code
Gate 1  Unit Testing         →  Vitest + Testing Library
Gate 2  Accessibility        →  WCAG 2.1 AA compliance
Gate 3  Visual Testing       →  Visual regression
Gate 4  E2E Testing          →  Playwright
Gate 5  Performance          →  Core Web Vitals
Gate 6  Code Review          →  Peer review
Gate 7  Validation           →  Final quality gates
Gate 8  Deployment           →  Frontend deployment
```

## Commands

| Command | Description |
|---------|-------------|
| `/bee:dev-cycle [tasks] [prompt]` | Execute backend development cycle (10 gates) |
| `/bee:dev-cycle-frontend [tasks] [prompt]` | Execute frontend development cycle (9 gates) |
| `/bee:dev-refactor [path] [prompt]` | Analyze and refactor backend code |
| `/bee:dev-refactor-frontend [path] [prompt]` | Analyze and refactor frontend code |
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

### Frontend
- **React 18+** / **Next.js**
- **TypeScript 5+**
- **TailwindCSS** / **shadcn/ui** / **Radix UI**
- **TanStack Query** / **Zustand** — state management
- **React Hook Form + Zod** — forms & validation
- **Vitest** / **Playwright** / **axe-core** — testing

### Infrastructure
- **Docker** / **Kubernetes** / **Helm**
- **Terraform** — IaC
- **GitHub Actions** — CI/CD
- **OpenTelemetry** — observability

## Project Structure

```
bee-dev-team/
├── agents/                 # 10 specialized agent definitions
├── skills/                 # 19 development workflow skills
│   └── shared-patterns/    # Reusable patterns & anti-rationalization
├── commands/               # 7 slash command definitions
├── docs/standards/         # Standards (PHP, Frontend, DevOps, SRE)
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

Use `/bee:dev-cycle` to run a full 10-gate backend cycle. You can pass a tasks file or a direct prompt:

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

Use `/bee:dev-cycle-frontend` for the 9-gate frontend cycle. Same syntax:

```bash
# Direct prompt
/bee:dev-cycle-frontend Implement dashboard with transaction list, charts, and filters

# From a tasks file
/bee:dev-cycle-frontend docs/tasks/sprint-001-frontend.md

# Resume
/bee:dev-cycle-frontend --resume
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

For frontend refactoring, use `/bee:dev-refactor-frontend` with the same options.

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

## Standards

The plugin enforces comprehensive standards loaded at runtime:

| Domain | Sections | Covers |
|--------|----------|--------|
| **PHP/Laravel** | 46 | Versions, DB, Eloquent, HTTP, testing, architecture, multi-tenant |
| **Frontend** | 20 | React, state, forms, styling, accessibility, performance |
| **DevOps** | 8 | Cloud, Terraform, containers, Helm, security, CI/CD |
| **SRE** | 6 | Health checks, logging, tracing, monitoring |

## License

[MIT](LICENSE)
