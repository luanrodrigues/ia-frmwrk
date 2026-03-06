# Bee-Dev-Team Changelog

## 2.1.0 (2026-03-06)

### Added

- **OpenCode external review** - Integrated OpenCode CLI as advisory reviewer in code review pipeline (Step 7.6)
- **`docs/opencode-instructions.md`** - Review instructions for external AI model (TypeScript, PHP/Laravel)
- **Code Review section in README** - Documents three review layers (Bee, CodeRabbit, OpenCode) and how to trigger
- **`bee:opencode-review` skill** in bee-default plugin (27 skills total)

### Changed

- Marketplace version: 2.0.0 to 2.1.0
- bee-default version: 2.0.0 to 2.1.0

---

## 2.0.0 (2026-03-02)

### Breaking Changes

- **Removed Go backend support** — Deleted `agents/backend-engineer-golang.md` and `docs/standards/golang/` (13 modular files)
- **Removed TypeScript backend support** — Deleted `agents/backend-engineer-typescript.md` and `docs/standards/typescript.md`
- Agent count reduced from 11 to 10

### Added

- **PHP/Laravel as exclusive backend** — `agents/backend-engineer-php.md` upgraded to v2.0.0 with full standards coverage
- **Created `docs/standards/php.md`** — Comprehensive PHP/Laravel standards with 46 sections (equivalent to golang/ 50 sections)
- PHP/Laravel standards coverage table in `standards-coverage-table.md`
- Pest + PHPUnit as testing framework (replacing Go test / Jest)
- PHPStan Level 8+ and PHP CS Fixer as linting tools
- Infection PHP for mutation testing (replacing Go fuzz)
- Laravel-specific patterns: Form Requests, API Resources, Eloquent, Service Providers

### Changed

- Updated all skills (dev-cycle, dev-implementation, testing gates, dev-devops, dev-sre, dev-validation) for PHP/Laravel
- Updated all commands (dev-cycle, dev-refactor) for PHP/Laravel
- Updated shared patterns (standards-workflow, orchestrator-principle, anti-rationalization, TDD templates)
- Updated QA analyst agent for PHP/Pest/PHPUnit routing
- Updated plugin.json metadata and keywords

### Kept Unchanged

- Frontend agents (frontend-engineer, frontend-designer, ui-engineer, qa-analyst-frontend)
- BFF TypeScript agent (frontend-bff-engineer-typescript)
- DevOps agent and standards
- SRE agent and standards
- Frontend standards and testing standards
- All frontend skills and commands
