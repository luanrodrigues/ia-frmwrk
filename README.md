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
   git clone https://github.com/luanrodrigues/ia-frmwrk.git -b dev-team
   ```

2. The plugin auto-initializes on session start via `hooks/session-start.sh`.

3. Use slash commands to start a development cycle:
   ```
   /bee:dev-cycle "Implement user authentication with Laravel Sanctum"
   ```

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
