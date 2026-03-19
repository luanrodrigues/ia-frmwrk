# Standards Coverage Table Pattern

This file defines the MANDATORY output format for agents comparing codebases against Bee standards. It ensures every section in the standards is explicitly checked and reported.

---

## ⛔ CRITICAL: All Sections Are Required

**This is NON-NEGOTIABLE. Every section listed in the Agent → Standards Section Index below MUST be checked.**

| Rule                                          | Enforcement                                                                         |
| --------------------------------------------- | ----------------------------------------------------------------------------------- |
| **Every section MUST be checked**             | No exceptions. No skipping.                                                         |
| **Every section MUST appear in output table** | Missing row = INCOMPLETE output                                                     |
| **Subsections are INCLUDED**                  | If "Containers" is listed, all content (Dockerfile, Docker Compose) MUST be checked |
| **N/A requires explicit reason**              | Cannot mark N/A without justification                                               |

**If you skip any section → Your output is REJECTED. Start over.**

**If you invent section names → Your output is REJECTED. Start over.**

---

## ⛔ CRITICAL: Section Names Are Not Negotiable

**You MUST use the EXACT section names from this file. You CANNOT:**

| FORBIDDEN         | Example                                     | Why Wrong              |
| ----------------- | ------------------------------------------- | ---------------------- |
| Invent names      | "Security", "Code Quality"                  | Not in coverage table  |
| Rename sections   | "Config" instead of "Configuration Loading" | Breaks traceability    |
| Merge sections    | "Error Handling & Logging"                  | Each section = one row |
| Use abbreviations | "Bootstrap" instead of "Bootstrap Pattern"  | Must match exactly     |
| Skip sections     | Omitting "RabbitMQ Worker Pattern"          | Mark N/A instead       |

**Your output table section names MUST match the "Section to Check" column below EXACTLY.**

---

## Why This Pattern Exists

**Problem:** Agents might skip sections from standards files, either by:

- Only checking "main" sections
- Assuming some sections don't apply
- Not enumerating all sections systematically
- Skipping subsections (e.g., checking Dockerfile but skipping Docker Compose)

**Solution:** Require a completeness table that MUST list every section from the WebFetch result with explicit status. All content within each section MUST be evaluated.

---

## MANDATORY: Standards Coverage Table

### ⛔ HARD GATE: Before Outputting Findings

**You MUST output a Standards Coverage Table that enumerates every section from the WebFetch result.**

**REQUIRED: When checking a section, you MUST check all subsections and patterns within it.**

| Section                | What MUST Be Checked                                            |
| ---------------------- | --------------------------------------------------------------- |
| Containers             | Dockerfile patterns and Docker Compose patterns                 |
| Infrastructure as Code | Terraform structure and state management and modules            |
| Observability          | Logging and Tracing (structured JSON logs, OpenTelemetry spans) |
| Security               | Secrets management and Network policies                         |

### Process

1. **Parse the WebFetch result** - Extract all `## Section` headers from the standards file
2. **Count sections** - Record total number of sections found
3. **For each section** - Determine status and evidence
4. **Output table** - MUST have one row per section
5. **Verify completeness** - Table row count MUST equal section count

### Output Format

```markdown
## Standards Coverage Table

**Standards File:** {filename}.md (from WebFetch)
**Total Sections Found:** {N}
**Table Rows:** {N} (MUST match)

| #   | Section (from WebFetch) | Status       | Evidence            |
| --- | ----------------------- | ------------ | ------------------- |
| 1   | {Section 1 header}      | ✅/⚠️/❌/N/A | file:line or reason |
| 2   | {Section 2 header}      | ✅/⚠️/❌/N/A | file:line or reason |
| ... | ...                     | ...          | ...                 |
| N   | {Section N header}      | ✅/⚠️/❌/N/A | file:line or reason |

**Completeness Verification:**

- Sections in standards: {N}
- Rows in table: {N}
- Status: ✅ Complete / ❌ Incomplete
```

### Status Legend

| Status           | Meaning                            | When to Use                          |
| ---------------- | ---------------------------------- | ------------------------------------ |
| ✅ Compliant     | Codebase follows this standard     | Code matches expected pattern        |
| ⚠️ Partial       | Some compliance, needs improvement | Partially implemented or minor gaps  |
| ❌ Non-Compliant | Does not follow standard           | Missing or incorrect implementation  |
| N/A              | Not applicable to this codebase    | Standard doesn't apply (with reason) |

---

## ⛔ CRITICAL: Standards Boundary Enforcement

**You MUST check only what the standards file explicitly defines. Never invent requirements.**

See [shared-patterns/standards-boundary-enforcement.md](standards-boundary-enforcement.md) for:

- Complete list of what IS and IS not required per agent
- Agent-specific requirement boundaries
- Self-verification checklist

**⛔ HARD GATE:** Before flagging any item as non-compliant:

1. Verify the requirement EXISTS in the WebFetch result
2. Quote the EXACT standard that requires it
3. If you cannot quote it → Do not flag it

---

## Anti-Rationalization Table

| Rationalization                                | Why It's WRONG                                                      | Required Action                                   |
| ---------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------- |
| "I checked the important sections"             | You don't decide importance. All sections MUST be checked.          | **List every section in table**                   |
| "Some sections obviously don't apply"          | Report them as N/A with reason. Never skip silently.                | **Include in table with N/A status**              |
| "The table would be too long"                  | Completeness > brevity. Every section MUST be visible.              | **Output full table regardless of length**        |
| "I already mentioned these in findings"        | Findings ≠ Coverage table. Both are REQUIRED.                       | **Output table BEFORE detailed findings**         |
| "WebFetch result was unclear"                  | Parse all `## ` headers. If truly unclear, STOP and report blocker. | **Report blocker or parse all headers**           |
| "I checked Dockerfile, that covers Containers" | Containers = Dockerfile + Docker Compose. Partial ≠ Complete.       | **Check all subsections within each section**     |
| "Project doesn't use Docker Compose"           | Report as N/A with evidence. Never assume. VERIFY first.            | **Search for docker-compose.yml, report finding** |
| "Only checking what exists in codebase"        | Standards define what SHOULD exist. Missing = Non-Compliant.        | **Report missing patterns as ❌ Non-Compliant**   |
| "My section name is clearer"                   | Consistency > clarity. Coverage table names are the contract.       | **Use EXACT names from coverage table**           |
| "I combined related sections for brevity"      | Each section = one row. Merging loses traceability.                 | **One row per section, no merging**               |
| "I added a useful section like 'Security'"     | You don't decide sections. Coverage table does.                     | **Only output sections from coverage table**      |
| "'Logging' is the same as 'Logging Standards'" | Names must match EXACTLY. Variations break automation.              | **Use exact string from coverage table**          |

---

## Completeness Check (SELF-VERIFICATION)

**Before submitting output, verify:**

```text
1. Did I extract all ## headers from WebFetch result?     [ ]
2. Does my table have exactly that many rows?             [ ]
3. Does every row have a status (✅/⚠️/❌/N/A)?           [ ]
4. Does every ⚠️/❌ have evidence (file:line)?           [ ]
5. Does every N/A have a reason?                         [ ]

If any checkbox is unchecked → FIX before submitting.
```

---

## Integration with Findings

**Order of output:**

1. **Standards Coverage Table** (this pattern) - Shows completeness
2. **Detailed Findings** - Only for ⚠️ Partial and ❌ Non-Compliant items

The Coverage Table ensures nothing is skipped. The Detailed Findings provide actionable information for gaps.

---

## Example Output

```markdown
## Standards Coverage Table

**Standards File:** php.md (from WebFetch)
**Total Sections Found:** 21
**Table Rows:** 21 (MUST match)

| #   | Section (from WebFetch)      | Status | Evidence                               |
| --- | ---------------------------- | ------ | -------------------------------------- |
| 1   | Version                      | ✅     | composer.json (PHP 8.2+)               |
| 2   | Core Dependencies            | ✅     | composer.json packages                 |
| 3   | Frameworks & Libraries       | ✅     | Laravel 11, Pest in composer.json      |
| 4   | Configuration                | ⚠️     | config/app.php:12                      |
| 5   | Observability                | ❌     | Not implemented                        |
| 6   | Bootstrap                    | ✅     | app/Providers/AppServiceProvider.php   |
| 7   | Authentication Integration   | ✅     | app/Http/Middleware/Auth.php:25        |
| 8   | Eloquent Patterns            | ✅     | app/Models/User.php:8                  |
| 9   | Data Transformation          | ✅     | app/Http/Resources/UserResource.php:8  |
| 10  | Error Codes Convention       | ⚠️     | Uses generic codes                     |
| 11  | Error Handling               | ✅     | Consistent exception pattern           |
| 12  | Function Design              | ✅     | Small functions, clear names           |
| 13  | Pagination Patterns          | N/A    | No list endpoints                      |
| 14  | Testing                      | ❌     | No tests found                         |
| 15  | Logging                      | ⚠️     | Missing structured fields              |
| 16  | Linting                      | ✅     | phpstan.neon present                   |
| 17  | Architecture Patterns        | ✅     | Hexagonal structure                    |
| 18  | Directory Structure          | ✅     | Follows Lerian pattern                 |
| 19  | N+1 Query Detection          | ✅     | preventLazyLoading() enabled           |
| 20  | RabbitMQ Worker Pattern      | N/A    | No message queue                       |

**Completeness Verification:**

- Sections in standards: 20
- Rows in table: 20
- Status: ✅ Complete
```

---

## How Agents Reference This Pattern

Agents MUST include this in their Standards Compliance section:

```markdown
## Standards Compliance Output (Conditional)

**Detection:** Prompt contains `**MODE: ANALYSIS only**`

**When triggered, you MUST:**

1. Output Standards Coverage Table per [shared-patterns/standards-coverage-table.md](../skills/shared-patterns/standards-coverage-table.md)
2. Then output detailed findings for ⚠️/❌ items

See [shared-patterns/standards-coverage-table.md](../skills/shared-patterns/standards-coverage-table.md) for:

- Table format
- Status legend
- Anti-rationalization rules
- Completeness verification checklist
```

---

## Agent → Standards Section Index

**IMPORTANT:** When updating a standards file, you MUST also update the corresponding section index below.

**Meta-sections (EXCLUDED from agent checks):**
Standards files may contain these meta-sections that are not counted in section indexes:

- `## Checklist` - Self-verification checklist for developers
- `## Standards Compliance` - Output format examples for agents
- `## Standards Compliance Output Format` - Output templates

These sections describe HOW to use the standards, not WHAT the standards are.

### bee:backend-engineer-php → php.md

| # | Section to Check | Anchor | Key Subsections |
|---|------------------|--------|-----------------|
| 1 | Version | `#version` | PHP 8.2+, Laravel 11+ |
| 2 | Core Dependencies | `#core-dependencies` | Composer packages |
| 3 | Frameworks & Libraries | `#frameworks--libraries` | Laravel, Pest, PHPStan, Mockery |
| 4 | Configuration | `#configuration` | env() only in config files |
| 5 | Database Naming Convention (snake_case) | `#database-naming-convention-snake_case-mandatory` | Table and column naming |
| 6 | Database Migrations | `#database-migrations-mandatory` | Laravel migrations |
| 7 | License Headers | `#license-headers-mandatory` | All source files |
| 8 | Eloquent Patterns | `#eloquent-patterns-mandatory` | Mass assignment, scopes, N+1 prevention |
| 9 | Dependency Management | `#dependency-management-mandatory` | Version pinning, composer.lock |
| 10 | Observability | `#observability` | OpenTelemetry PHP, span naming |
| 11 | Bootstrap | `#bootstrap` | Service Provider registration |
| 12 | Graceful Shutdown Patterns | `#graceful-shutdown-patterns-mandatory` | Queue worker signals |
| 13 | Health Checks | `#health-checks-mandatory` | /health vs /ready |
| 14 | Connection Management | `#connection-management-mandatory` | DB pool, Redis, queue |
| 15 | Authentication Integration | `#authentication-integration-mandatory` | Sanctum/Passport, Guards, Policies |
| 16 | Secret Redaction Patterns | `#secret-redaction-patterns-mandatory` | Credential leak prevention |
| 17 | SQL Safety | `#sql-safety-mandatory` | Parameterized queries, Eloquent |
| 18 | HTTP Security Headers | `#http-security-headers-mandatory` | X-Content-Type-Options, CSRF |
| 19 | Data Transformation | `#data-transformation-mandatory` | API Resources, DTOs |
| 20 | Error Codes Convention | `#error-codes-convention-mandatory` | Service-prefixed codes |
| 21 | Error Handling | `#error-handling` | Exception hierarchy |
| 22 | Exit/Fatal Location Rules | `#exitfatal-location-rules-mandatory` | die()/exit() FORBIDDEN |
| 23 | Function Design | `#function-design-mandatory` | Single responsibility |
| 24 | File Organization | `#file-organization-mandatory` | Max 200-300 lines |
| 25 | JSON Naming Convention (camelCase) | `#json-naming-convention-camelcase-mandatory` | API Resources |
| 26 | Pagination Patterns | `#pagination-patterns` | Cursor & offset |
| 27 | HTTP Status Code Consistency | `#http-status-code-consistency-mandatory` | 201 creation, 200 update |
| 28 | OpenAPI Documentation | `#openapi-documentation-mandatory` | L5-Swagger or Scramble |
| 29 | Controller Constructor Pattern | `#controller-constructor-pattern-mandatory` | DI via constructor |
| 30 | Input Validation | `#input-validation-mandatory` | Form Requests, custom rules |
| 31 | Testing | `#testing` | Pest + PHPUnit, data providers |
| 32 | Logging | `#logging` | Structured JSON, Monolog |
| 33 | Linting | `#linting` | PHP CS Fixer, PHPStan Level 8+ |
| 34 | Production Config Validation | `#production-config-validation-mandatory` | config:cache, route:cache |
| 35 | Container Security | `#container-security-conditional` | Non-root, PHP-FPM |
| 36 | Architecture Patterns | `#architecture-patterns` | Hexagonal/Lerian |
| 37 | Directory Structure | `#directory-structure` | Laravel hexagonal |
| 38 | N+1 Query Detection | `#n1-query-detection-mandatory` | preventLazyLoading() |
| 39 | Performance Patterns | `#performance-patterns-mandatory` | Query optimization |
| 40 | RabbitMQ Worker Pattern | `#rabbitmq-worker-pattern` | php-amqplib, Laravel Queues |
| 41 | RabbitMQ Reconnection Strategy | `#rabbitmq-reconnection-strategy-mandatory` | Consumer reconnection |
| 42 | Always-Valid Domain Model | `#always-valid-domain-model-mandatory` | Constructor validation |
| 43 | Idempotency Patterns | `#idempotency-patterns-mandatory-for-transaction-apis` | Redis-based |
| 44 | Multi-Tenant Patterns | `#multi-tenant-patterns-conditional` | stancl/tenancy |
| 45 | Rate Limiting | `#rate-limiting-mandatory` | Laravel RateLimiter |
| 46 | CORS Configuration | `#cors-configuration-mandatory` | config/cors.php |

---

### bee:frontend-bff-engineer-typescript → typescript.md

**Includes all BFF-specific TypeScript sections (21 total).**

| #   | Section to Check              | Anchor                                 | Key Subsections                                                            |
| --- | ----------------------------- | -------------------------------------- | -------------------------------------------------------------------------- |
| 1   | Version                       | `#version`                             | TypeScript 5.0+, Node.js 20+                                               |
| 2   | Strict Configuration          | `#strict-configuration-mandatory`      | tsconfig.json strict mode                                                  |
| 3   | Frameworks & Libraries        | `#frameworks--libraries`               | Express, Fastify, NestJS, Prisma, Zod, Vitest                              |
| 4   | Type Safety                   | `#type-safety`                         | No any, branded types, discriminated unions                                |
| 5   | Zod Validation Patterns       | `#zod-validation-patterns`             | Schema validation                                                          |
| 6   | Dependency Injection          | `#dependency-injection`                | TSyringe/Inversify patterns                                                |
| 7   | AsyncLocalStorage for Context | `#asynclocalstorage-for-context`       | Request context propagation                                                |
| 8   | Testing                       | `#testing`                             | Type-safe mocks, fixtures, edge cases                                      |
| 9   | Error Handling                | `#error-handling`                      | Custom error classes                                                       |
| 10  | Function Design               | `#function-design-mandatory`           | Single responsibility                                                      |
| 11  | File Organization             | `#file-organization-mandatory`         | File-level SRP, max 200-300 lines                                          |
| 12  | Naming Conventions            | `#naming-conventions`                  | Files, interfaces, types                                                   |
| 13  | Directory Structure           | `#directory-structure`                 | Lerian pattern                                                             |
| 14  | RabbitMQ Worker Pattern       | `#rabbitmq-worker-pattern`             | Async message processing                                                   |
| 15  | Always-Valid Domain Model     | `#always-valid-domain-model-mandatory` | Constructor validation                                                     |
| 16  | BFF Architecture Pattern      | `#bff-architecture-pattern-mandatory`  | **HARD GATE:** Clean Architecture, dual-mode (sindarian-server vs vanilla) |
| 17  | Three-Layer DTO Mapping       | `#three-layer-dto-mapping-mandatory`   | **HARD GATE:** HTTP ↔ Domain ↔ External DTOs, mappers                      |
| 18  | HttpService Lifecycle         | `#httpservice-lifecycle`               | createDefaults, onBeforeFetch, onAfterFetch, catch hooks                   |
| 19  | API Routes Pattern            | `#api-routes-pattern-mandatory`        | **⛔ FORBIDDEN:** Server Actions. MUST use Next.js API Routes              |
| 20  | Exception Hierarchy           | `#exception-hierarchy`                 | ApiException, GlobalExceptionFilter, typed exceptions                      |
| 21  | Cross-Cutting Decorators      | `#cross-cutting-decorators`            | LogOperation, Cached, Retry decorators                                     |

**⛔ HARD GATES for BFF Engineer:**

- Section 16: BFF is MANDATORY for all dynamic data
- Section 17: Three-layer mapping is MANDATORY, no pass-through
- Section 19: Server Actions are FORBIDDEN, API Routes only

---

### bee:frontend-engineer → frontend.md

| #   | Section to Check                | Anchor                             | Key Subsections                                                         |
| --- | ------------------------------- | ---------------------------------- | ----------------------------------------------------------------------- |
| 1   | Framework                       | `#framework`                       | React 18+, Next.js version policy                                       |
| 2   | Libraries & Tools               | `#libraries--tools`                | Core, state, forms, UI, styling, testing                                |
| 3   | State Management Patterns       | `#state-management-patterns`       | TanStack Query, Zustand                                                 |
| 4   | Form Patterns                   | `#form-patterns`                   | React Hook Form + Zod                                                   |
| 5   | Styling Standards               | `#styling-standards`               | TailwindCSS, CSS variables                                              |
| 6   | Typography Standards            | `#typography-standards`            | Font selection and pairing                                              |
| 7   | Animation Standards             | `#animation-standards`             | CSS transitions, Framer Motion                                          |
| 8   | Component Patterns              | `#component-patterns`              | Compound components, error boundaries                                   |
| 9   | File Organization               | `#file-organization-mandatory`     | File-level SRP, max 200 lines per component                            |
| 10  | Accessibility                   | `#accessibility`                   | WCAG 2.1 AA compliance                                                  |
| 11  | Performance                     | `#performance`                     | Code splitting, image optimization                                      |
| 12  | Directory Structure             | `#directory-structure`             | Next.js App Router layout                                               |
| 13  | Forbidden Patterns              | `#forbidden-patterns`              | Anti-patterns to avoid                                                  |
| 14  | Standards Compliance Categories | `#standards-compliance-categories` | Categories for bee:dev-refactor                                        |
| 15  | Form Field Abstraction Layer    | `#form-field-abstraction-layer`    | **HARD GATE:** Field wrappers, dual-mode (sindarian-ui vs vanilla)      |
| 16  | Provider Composition Pattern    | `#provider-composition-pattern`    | Nested providers order, feature providers                               |
| 17  | Custom Hooks Patterns           | `#custom-hooks-patterns`           | **HARD GATE:** usePagination, useCursorPagination, useCreateUpdateSheet |
| 18  | Fetcher Utilities Pattern       | `#fetcher-utilities-pattern`       | getFetcher, postFetcher, patchFetcher, deleteFetcher                    |
| 19  | Client-Side Error Handling      | `#client-side-error-handling`      | **HARD GATE:** ErrorBoundary, API error helpers, toast                  |
| 20  | Data Table Pattern              | `#data-table-pattern`              | TanStack Table, server-side pagination                                  |

**⛔ HARD GATES for Frontend Engineer:**

- Section 15: Form field abstraction is MANDATORY, direct input usage FORBIDDEN
- Section 17: Custom hooks MANDATORY for pagination and CRUD sheets
- Section 19: ErrorBoundary and API error handling MANDATORY

---

### bee:frontend-designer → frontend.md

**Same sections as bee:frontend-engineer (20 sections).** See above.

---

### bee:ui-engineer → frontend.md

**Same sections as bee:frontend-engineer (20 sections).** See above.

**Additional ui-engineer requirements:**
The bee:ui-engineer MUST also validate against product-designer outputs:

| #   | Additional Check         | Source              | Required                       |
| --- | ------------------------ | ------------------- | ------------------------------ |
| 1   | UX Criteria Compliance   | `ux-criteria.md`    | All criteria satisfied         |
| 2   | User Flow Implementation | `user-flows.md`     | All flows implemented          |
| 3   | Wireframe Adherence      | `wireframes/*.yaml` | All specs implemented          |
| 4   | UI States Coverage       | `ux-criteria.md`    | Loading, error, empty, success |

**Output Format for bee:ui-engineer:**
In addition to the standard Coverage Table, bee:ui-engineer MUST output:

```markdown
## UX Criteria Compliance

| Criterion             | Status | Evidence  |
| --------------------- | ------ | --------- |
| [From ux-criteria.md] | ✅/❌  | file:line |
```

---

### bee:sre → sre.md

| #   | Section to Check                      | Anchor                                                            |
| --- | ------------------------------------- | ----------------------------------------------------------------- |
| 1   | Observability                         | `#observability`                                                  |
| 2   | Logging                               | `#logging`                                                        |
| 3   | Tracing                               | `#tracing`                                                        |
| 4   | OpenTelemetry with lib-commons        | `#opentelemetry-with-lib-commons-mandatory-for-go`                |
| 5   | Structured Logging with lib-common-js | `#structured-logging-with-lib-common-js-mandatory-for-typescript` |
| 6   | Health Checks                         | `#health-checks`                                                  |

---

### bee:qa-analyst → testing-unit.md (Unit Mode - Gate 3)

**Mode Detection:** `test_mode: unit` passed when invoking `Task(subagent_type="bee:qa-analyst", test_mode="unit")`

**For PHP projects (Unit Mode):**
| # | Section to Check | Anchor |
|---|------------------|--------|
| UNIT-1 | Data Provider Tests (MANDATORY) | `#data-provider-tests-mandatory` |
| UNIT-2 | Test Naming Convention (MANDATORY) | `#test-naming-convention-mandatory` |
| UNIT-3 | Test Isolation with RefreshDatabase (MANDATORY) | `#test-isolation-refreshdatabase-mandatory` |
| UNIT-4 | Edge Case Coverage (MANDATORY) | `#edge-case-coverage-mandatory` |
| UNIT-5 | Assertion Requirements (MANDATORY) | `#assertion-requirements-mandatory` |
| UNIT-6 | Mock Generation with Mockery (MANDATORY) | `#mock-generation-mockery-mandatory` |
| UNIT-7 | Environment Variables in Tests (MANDATORY) | `#environment-variables-in-tests-mandatory` |
| UNIT-8 | Shared Test Utilities (MANDATORY) | `#shared-test-utilities-mandatory` |
| UNIT-9 | Unit Test Scope & Boundaries (MANDATORY) | `#unit-test-scope--boundaries-mandatory` |
| UNIT-10 | Unit Test Quality Gate (MANDATORY) | `#unit-test-quality-gate-mandatory` |

**Unit Test Quality Gate Checks (Gate 3 Exit - all REQUIRED):**
| # | Check | Detection |
|---|-------|-----------|
| 1 | Data provider pattern | Tests use `@dataProvider` or Pest `dataset()` |
| 2 | Test naming | `test_` prefix or Pest `it()` / `test()` syntax |
| 3 | RefreshDatabase trait | `grep "RefreshDatabase"` in test classes |
| 4 | Strong assertions | No empty assertion messages |
| 5 | Response type verification | `assertInstanceOf()` for success cases |
| 6 | Mockery usage | No hand-written mocks, use `Mockery::mock()` or Pest mocking |
| 7 | Config/env handling | Uses `config()` helper, not `env()` directly in tests |
| 8 | Shared utilities | No duplicate test helpers |
| 9 | Edge cases | ≥3 per acceptance criterion |
| 10 | No flaky tests | 3x consecutive pass |

---

### bee:qa-analyst → testing-fuzz.md (Fuzz/Mutation Mode - Gate 4)

**Mode Detection:** `test_mode: fuzz` passed when invoking `Task(subagent_type="bee:qa-analyst", test_mode="fuzz")`

**For PHP projects (Mutation Testing Mode):**
| # | Section to Check | Anchor |
|---|------------------|--------|
| FUZZ-1 | What Is Mutation Testing | `#what-is-mutation-testing` |
| FUZZ-2 | Infection PHP Configuration (MANDATORY) | `#infection-php-configuration-mandatory` |
| FUZZ-3 | Mutant Operators (MANDATORY) | `#mutant-operators-mandatory` |
| FUZZ-4 | MSI Threshold | `#msi-threshold` |
| FUZZ-5 | Mutation Test Quality Gate (MANDATORY) | `#mutation-test-quality-gate-mandatory` |

**Mutation Test Quality Gate Checks (Gate 4 Exit - all REQUIRED):**
| # | Check | Detection |
|---|-------|-----------|
| 1 | Infection config | `infection.json5` present in project root |
| 2 | MSI threshold | Mutation Score Indicator ≥ 80% |
| 3 | Test passes | `./vendor/bin/infection --min-msi=80` |

---

### bee:qa-analyst → testing-property.md (Property Mode - Gate 5)

**Mode Detection:** `test_mode: property` passed when invoking `Task(subagent_type="bee:qa-analyst", test_mode="property")`

**For PHP projects (Property Mode):**
| # | Section to Check | Anchor |
|---|------------------|--------|
| PROP-1 | What Is Property-Based Testing | `#what-is-property-based-testing` |
| PROP-2 | Pest Dataset Pattern (MANDATORY) | `#pest-dataset-pattern-mandatory` |
| PROP-3 | Common Properties | `#common-properties` |
| PROP-4 | Integration with Unit Tests | `#integration-with-unit-tests` |
| PROP-5 | Property Test Quality Gate (MANDATORY) | `#property-test-quality-gate-mandatory` |

**Property Test Quality Gate Checks (Gate 5 Exit - all REQUIRED):**
| # | Check | Detection |
|---|-------|-----------|
| 1 | Naming convention | `test_property_{subject}_{property}` or Pest `it()` format |
| 2 | Pest datasets / Faker usage | `dataset()` or `fake()` used for random data generation |
| 3 | Domain invariants | At least 1 property per domain entity |

---

### bee:qa-analyst → testing-integration.md (Integration Mode - Gate 6)

**Mode Detection:** `test_mode: integration` passed when invoking `Task(subagent_type="bee:qa-analyst", test_mode="integration")`

**For PHP projects (Integration Mode):**
| # | Section to Check | Anchor |
|---|------------------|--------|
| INT-1 | Test Pyramid | `#test-pyramid` |
| INT-2 | File Naming Convention (MANDATORY) | `#file-naming-convention-mandatory` |
| INT-3 | Function Naming Convention (MANDATORY) | `#function-naming-convention-mandatory` |
| INT-4 | Feature Test Group (MANDATORY) | `#feature-test-group-mandatory` |
| INT-5 | Docker Compose for Services (MANDATORY) | `#docker-compose-for-services-mandatory` |
| INT-6 | Sequential Test Execution (MANDATORY) | `#sequential-test-execution-mandatory` |
| INT-7 | Fixture / Factory Centralization (MANDATORY) | `#fixture-factory-centralization-mandatory` |
| INT-8 | Stub Centralization (MANDATORY) | `#stub-centralization-mandatory` |
| INT-9 | Guardrails (Anti-Patterns) (MANDATORY) | `#guardrails-anti-patterns-mandatory` |
| INT-10 | Test Failure Analysis (No Greenwashing) | `#test-failure-analysis-no-greenwashing` |

**Integration Test Quality Gate Checks (Gate 6 Exit - all REQUIRED):**
| # | Check | Detection |
|---|-------|-----------|
| 1 | Feature test group | Tests in `tests/Feature/` directory |
| 2 | No hardcoded ports | `grep ":5432\|:6379"` = 0 |
| 3 | Docker Compose used | `docker-compose.testing.yml` present |
| 4 | Sequential execution | No parallel test flags in integration suite |
| 5 | Cleanup present | `RefreshDatabase` trait or `tearDown()` for all tests |
| 6 | No flaky tests | 3x consecutive pass |

---

### bee:qa-analyst → testing-chaos.md (Chaos Mode - Gate 7)

**Mode Detection:** `test_mode: chaos` passed when invoking `Task(subagent_type="bee:qa-analyst", test_mode="chaos")`

**For PHP projects (Chaos Mode):**
| # | Section to Check | Anchor |
|---|------------------|--------|
| CHAOS-1 | What Is Chaos Testing | `#what-is-chaos-testing` |
| CHAOS-2 | Chaos Test Pattern (MANDATORY) | `#chaos-test-pattern-mandatory` |
| CHAOS-3 | Failure Scenarios | `#failure-scenarios` |
| CHAOS-4 | Infrastructure Setup | `#infrastructure-setup` |
| CHAOS-5 | Chaos Test Quality Gate (MANDATORY) | `#chaos-test-quality-gate-mandatory` |

**Chaos Test Quality Gate Checks (Gate 7 Exit - all REQUIRED):**
| # | Check | Detection |
|---|-------|-----------|
| 1 | Dual-gate pattern | `CHAOS=1` env check + test group annotation |
| 2 | Naming convention | `test_chaos_{component}_{scenario}` or Pest `it()` |
| 3 | 5-phase structure | Normal → Inject → Verify → Restore → Recovery |
| 4 | Toxiproxy usage | `tests/Chaos/` infrastructure with Toxiproxy |
| 5 | All deps covered | Chaos test for each external dependency |

---

### bee:qa-analyst-frontend → frontend/testing-*.md

**Mode Detection:** `test_mode` parameter determines which standards to load.

| # | Section to Check | Mode | File |
|---|------------------|------|------|
| ACC-1 | axe-core Integration | accessibility | testing-accessibility.md |
| ACC-2 | Semantic HTML Verification | accessibility | testing-accessibility.md |
| ACC-3 | Keyboard Navigation | accessibility | testing-accessibility.md |
| ACC-4 | Focus Management | accessibility | testing-accessibility.md |
| ACC-5 | Color Contrast | accessibility | testing-accessibility.md |
| VIS-1 | Snapshot Testing Patterns | visual | testing-visual.md |
| VIS-2 | States Coverage | visual | testing-visual.md |
| VIS-3 | Responsive Snapshots | visual | testing-visual.md |
| VIS-4 | Component Duplication Check | visual | testing-visual.md |
| E2E-1 | User Flow Consumption | e2e | testing-e2e.md |
| E2E-2 | Error Path Testing | e2e | testing-e2e.md |
| E2E-3 | Cross-Browser Testing | e2e | testing-e2e.md |
| E2E-4 | Responsive E2E | e2e | testing-e2e.md |
| E2E-5 | Selector Strategy | e2e | testing-e2e.md |
| PERF-1 | Core Web Vitals | performance | testing-performance.md |
| PERF-2 | Lighthouse Score | performance | testing-performance.md |
| PERF-3 | Bundle Analysis | performance | testing-performance.md |
| PERF-4 | Server Component Audit | performance | testing-performance.md |
| PERF-5 | Anti-Pattern Detection | performance | testing-performance.md |

---

### bee:frontend-engineer-vuejs → frontend-vuejs.md

| #   | Section to Check                | Anchor                             | Key Subsections                                                         |
| --- | ------------------------------- | ---------------------------------- | ----------------------------------------------------------------------- |
| 1   | Framework                       | `#framework`                       | Vue 3 + Nuxt 3 (version policy)                                         |
| 2   | Libraries & Tools               | `#libraries--tools`                | Core, state (Pinia), forms, UI (shadcn-vue), styling, testing           |
| 3   | State Management Patterns       | `#state-management-patterns`       | Pinia (`defineStore`, `storeToRefs`), `useAsyncData`, `useFetch`        |
| 4   | Form Patterns                   | `#form-patterns`                   | VeeValidate (`useForm`, `useField`) + Zod (`toTypedSchema`)             |
| 5   | Styling Standards               | `#styling-standards`               | TailwindCSS, CSS variables, scoped `<style>`                            |
| 6   | Typography Standards            | `#typography-standards`            | Font selection and pairing                                              |
| 7   | Animation Standards             | `#animation-standards`             | CSS transitions, `<Transition>`, GSAP / Motion One                     |
| 8   | Component Patterns              | `#component-patterns`              | Composables, `<NuxtErrorBoundary>`, `<script setup>`                    |
| 9   | File Organization               | `#file-organization-mandatory`     | File-level SRP, max 200 lines per component                            |
| 10  | Accessibility                   | `#accessibility`                   | WCAG 2.1 AA compliance, Radix Vue primitives                            |
| 11  | Performance                     | `#performance`                     | Nuxt lazy loading, `<NuxtImg>`, code splitting                          |
| 12  | Directory Structure             | `#directory-structure`             | Nuxt 3 file-based routing layout                                        |
| 13  | Forbidden Patterns              | `#forbidden-patterns`              | Anti-patterns to avoid (Options API, `v-html`, etc.)                   |
| 14  | Standards Compliance Categories | `#standards-compliance-categories` | Categories for bee:dev-refactor-frontend-vuejs                          |
| 15  | Form Field Abstraction Layer    | `#form-field-abstraction-layer`    | **HARD GATE:** Field wrappers, dual-mode (sindarian-vue vs vanilla)     |
| 16  | Plugin Composition Pattern      | `#plugin-composition-pattern`      | Nuxt plugins, app-level provide/inject                                  |
| 17  | Composable Patterns             | `#composable-patterns`             | **HARD GATE:** usePagination, useCursorPagination, useSheet, useStepper |
| 18  | Fetcher Utilities Pattern       | `#fetcher-utilities-pattern`       | `$fetch` wrappers, `useFetch`, `useAsyncData`                           |
| 19  | Client-Side Error Handling      | `#client-side-error-handling`      | **HARD GATE:** NuxtErrorBoundary, error.vue, API error helpers, toast   |
| 20  | Data Table Pattern              | `#data-table-pattern`              | TanStack Table (Vue adapter), server-side pagination, column definitions |

**⛔ HARD GATES for Frontend Engineer (Vue.js):**

- Section 15: Form field abstraction is MANDATORY, direct input usage FORBIDDEN
- Section 17: Composable patterns MANDATORY for pagination and CRUD sheets
- Section 19: NuxtErrorBoundary and API error handling MANDATORY

---

### bee:frontend-designer → frontend-vuejs.md (Vue.js projects)

**Same sections as bee:frontend-engineer-vuejs (20 sections).** See above.

---

### bee:ui-engineer-vuejs → frontend-vuejs.md

**Same sections as bee:frontend-engineer-vuejs (20 sections).** See above.

**Additional ui-engineer-vuejs requirements:**
The bee:ui-engineer-vuejs MUST also validate against product-designer outputs:

| #   | Additional Check         | Source              | Required                       |
| --- | ------------------------ | ------------------- | ------------------------------ |
| 1   | UX Criteria Compliance   | `ux-criteria.md`    | All criteria satisfied         |
| 2   | User Flow Implementation | `user-flows.md`     | All flows implemented          |
| 3   | Wireframe Adherence      | `wireframes/*.yaml` | All specs implemented          |
| 4   | UI States Coverage       | `ux-criteria.md`    | Loading, error, empty, success |

**Output Format for bee:ui-engineer-vuejs:**
In addition to the standard Coverage Table, bee:ui-engineer-vuejs MUST output:

```markdown
## UX Criteria Compliance

| Criterion             | Status | Evidence  |
| --------------------- | ------ | --------- |
| [From ux-criteria.md] | ✅/❌  | file:line |
```

---

### bee:qa-analyst-frontend-vuejs → frontend-vuejs/testing-*.md

**Mode Detection:** `test_mode` parameter determines which standards to load.

| # | Section to Check | Mode | File |
|---|------------------|------|------|
| ACC-1 | axe-core Integration | accessibility | testing-accessibility.md |
| ACC-2 | Semantic HTML Verification | accessibility | testing-accessibility.md |
| ACC-3 | Keyboard Navigation | accessibility | testing-accessibility.md |
| ACC-4 | Focus Management | accessibility | testing-accessibility.md |
| ACC-5 | Color Contrast | accessibility | testing-accessibility.md |
| VIS-1 | Snapshot Testing Patterns | visual | testing-visual.md |
| VIS-2 | States Coverage | visual | testing-visual.md |
| VIS-3 | Responsive Snapshots | visual | testing-visual.md |
| VIS-4 | Component Duplication Check | visual | testing-visual.md |
| E2E-1 | User Flow Consumption | e2e | testing-e2e.md |
| E2E-2 | Error Path Testing | e2e | testing-e2e.md |
| E2E-3 | Cross-Browser Testing | e2e | testing-e2e.md |
| E2E-4 | Responsive E2E | e2e | testing-e2e.md |
| E2E-5 | Selector Strategy | e2e | testing-e2e.md |
| PERF-1 | Core Web Vitals | performance | testing-performance.md |
| PERF-2 | Lighthouse Score | performance | testing-performance.md |
| PERF-3 | Bundle Analysis | performance | testing-performance.md |
| PERF-4 | Server Component Audit | performance | testing-performance.md |
| PERF-5 | Anti-Pattern Detection | performance | testing-performance.md |

---

### bee:frontend-engineer-react-native → frontend-react-native.md

| #   | Section to Check                | Anchor                             | Key Subsections                                                              |
| --- | ------------------------------- | ---------------------------------- | ---------------------------------------------------------------------------- |
| 1   | Framework                       | `#framework`                       | React Native + Expo (version policy)                                         |
| 2   | Libraries & Tools               | `#libraries--tools`                | Core, state, forms, UI, styling (NativeWind), testing                        |
| 3   | State Management Patterns       | `#state-management-patterns`       | Zustand, TanStack Query, AsyncStorage                                        |
| 4   | Form Patterns                   | `#form-patterns`                   | React Hook Form + Zod                                                        |
| 5   | Styling Standards               | `#styling-standards`               | NativeWind, StyleSheet, platform-aware styles                                |
| 6   | Typography Standards            | `#typography-standards`            | Font selection, scaling, platform defaults                                   |
| 7   | Animation Standards             | `#animation-standards`             | Reanimated 3, Animated API, Moti                                             |
| 8   | Component Patterns              | `#component-patterns`              | Compound components, error boundaries, platform splitting                    |
| 9   | File Organization               | `#file-organization-mandatory`     | File-level SRP, max 200 lines per component                                  |
| 10  | Accessibility                   | `#accessibility`                   | WCAG 2.1 AA, accessible labels, focus management                             |
| 11  | Performance                     | `#performance`                     | JS thread, FlatList optimization, image caching, bundle size                 |
| 12  | Directory Structure             | `#directory-structure`             | Expo Router / React Navigation layout                                        |
| 13  | Forbidden Patterns              | `#forbidden-patterns`              | Anti-patterns to avoid                                                       |
| 14  | Standards Compliance Categories | `#standards-compliance-categories` | Categories for bee:dev-refactor-frontend-react-native                        |
| 15  | Navigation Patterns             | `#navigation-patterns`             | Expo Router / React Navigation, deep linking, typed routes                   |
| 16  | Native Module Integration       | `#native-module-integration`       | Expo modules, bare workflow bridging, community modules                      |
| 17  | Platform-Specific Code          | `#platform-specific-code`          | `Platform.select`, `.ios.tsx` / `.android.tsx` splits, web fallbacks         |
| 18  | Testing Standards               | `#testing-standards`               | Jest + React Native Testing Library, Detox/Maestro E2E, ≥85% coverage       |
| 19  | Security Standards              | `#security-standards`              | Secure storage (expo-secure-store), certificate pinning, deep link validation |
| 20  | Build & Deploy                  | `#build--deploy`                   | EAS Build, OTA updates (expo-updates), environment channels                  |

**⛔ HARD GATES for Frontend Engineer (React Native):**

- Section 15: Navigation MUST use Expo Router or React Navigation — direct linking FORBIDDEN
- Section 17: Platform-specific code MUST use `Platform.select` or file extensions — `if (Platform.OS === ...)` inline FORBIDDEN for complex branching
- Section 19: Sensitive data MUST use `expo-secure-store` — AsyncStorage for secrets FORBIDDEN

---

### bee:ui-engineer-react-native → frontend-react-native.md

**Same sections as bee:frontend-engineer-react-native (20 sections).** See above.

**Additional ui-engineer-react-native requirements:**
The bee:ui-engineer-react-native MUST also validate against product-designer outputs:

| #   | Additional Check         | Source              | Required                       |
| --- | ------------------------ | ------------------- | ------------------------------ |
| 1   | UX Criteria Compliance   | `ux-criteria.md`    | All criteria satisfied         |
| 2   | User Flow Implementation | `user-flows.md`     | All flows implemented          |
| 3   | Wireframe Adherence      | `wireframes/*.yaml` | All specs implemented          |
| 4   | UI States Coverage       | `ux-criteria.md`    | Loading, error, empty, success |

**Output Format for bee:ui-engineer-react-native:**
In addition to the standard Coverage Table, bee:ui-engineer-react-native MUST output:

```markdown
## UX Criteria Compliance

| Criterion             | Status | Evidence  |
| --------------------- | ------ | --------- |
| [From ux-criteria.md] | ✅/❌  | file:line |
```

---

### bee:qa-analyst-frontend-react-native → frontend-react-native/testing-*.md

**Mode Detection:** `test_mode` parameter determines which standards to load.

| # | Section to Check | Mode | File |
|---|------------------|------|------|
| ACC-1 | Accessible Labels & Roles | accessibility | testing-accessibility.md |
| ACC-2 | Focus Management | accessibility | testing-accessibility.md |
| ACC-3 | Color Contrast | accessibility | testing-accessibility.md |
| ACC-4 | Screen Reader Compatibility | accessibility | testing-accessibility.md |
| ACC-5 | Touch Target Size | accessibility | testing-accessibility.md |
| VIS-1 | Snapshot Testing Patterns | visual | testing-visual.md |
| VIS-2 | States Coverage | visual | testing-visual.md |
| VIS-3 | Platform Snapshots (iOS/Android) | visual | testing-visual.md |
| VIS-4 | Component Duplication Check | visual | testing-visual.md |
| E2E-1 | User Flow Consumption | e2e | testing-e2e.md |
| E2E-2 | Error Path Testing | e2e | testing-e2e.md |
| E2E-3 | Device Coverage (iOS/Android) | e2e | testing-e2e.md |
| E2E-4 | Deep Link Testing | e2e | testing-e2e.md |
| E2E-5 | Selector Strategy | e2e | testing-e2e.md |
| PERF-1 | JS Thread Performance | performance | testing-performance.md |
| PERF-2 | App Startup Time | performance | testing-performance.md |
| PERF-3 | Bundle Size Analysis | performance | testing-performance.md |
| PERF-4 | FlatList / Scroll Performance | performance | testing-performance.md |
| PERF-5 | Anti-Pattern Detection | performance | testing-performance.md |

---

### bee:database-engineer → database.md

| #   | Section to Check                      | Anchor                                     |
| --- | ------------------------------------- | ------------------------------------------ |
| 1   | Schema Design Principles              | `#schema-design-principles`                |
| 2   | Data Types and Constraints            | `#data-types-and-constraints`              |
| 3   | Primary Key Strategy                  | `#primary-key-strategy`                    |
| 4   | Foreign Key and Referential Integrity | `#foreign-key-and-referential-integrity`   |
| 5   | Indexing Strategy                     | `#indexing-strategy`                       |
| 6   | Migration Safety                      | `#migration-safety`                        |
| 7   | Query Optimization                    | `#query-optimization`                      |
| 8   | Connection Pooling                    | `#connection-pooling`                      |
| 9   | Transaction Isolation and Concurrency | `#transaction-isolation-and-concurrency`   |
| 10  | Replication Topology                  | `#replication-topology`                    |
| 11  | Sharding and Partitioning             | `#sharding-and-partitioning`               |
| 12  | Performance Tuning                    | `#performance-tuning`                      |
| 13  | Database Security                     | `#database-security`                       |
| 14  | Backup and Recovery                   | `#backup-and-recovery`                     |
| 15  | Monitoring and Alerting               | `#monitoring-and-alerting`                 |
| 16  | MongoDB Patterns                      | `#mongodb-patterns`                        |
| 17  | Redis Patterns                        | `#redis-patterns`                          |
| 18  | Multi-Tenant Data Isolation           | `#multi-tenant-data-isolation`             |
| 19  | Data Migration and ETL                | `#data-migration-and-etl`                  |
| 20  | Anti-Patterns                         | `#anti-patterns`                           |

---

## Maintenance Instructions

**When you add/modify a section in a standards file:**

1. Edit `dev-team/docs/standards/{file}.md` - Add your new `## Section Name`
2. Edit THIS file - Add the section to the corresponding agent table above
3. Verify row count matches section count

**Anti-Rationalization:**

| Rationalization                   | Why It's WRONG                                     | Required Action                      |
| --------------------------------- | -------------------------------------------------- | ------------------------------------ |
| "I'll update the index later"     | Later = never. Sync drift causes missed checks.    | **Update BOTH files in same commit** |
| "The section is minor"            | Minor ≠ optional. All sections must be indexed.    | **Add to index regardless of size**  |
| "Agents parse dynamically anyway" | Index is the explicit contract. Dynamic is backup. | **Index is source of truth**         |
