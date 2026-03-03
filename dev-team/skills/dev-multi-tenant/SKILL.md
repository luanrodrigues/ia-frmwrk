---
name: bee:dev-multi-tenant
slug: dev-multi-tenant
version: 2.0.0
type: skill
description: |
  Multi-tenant development cycle orchestrator following Bee Standards.
  Auto-detects the service stack (PostgreSQL, MongoDB, Redis, RabbitMQ, S3),
  then executes a gate-based implementation using tenantId from JWT
  for database-per-tenant isolation via stancl/tenancy or spatie/multitenancy packages (TenantManager, TenantService).
  MUST install and configure the tenancy package first; auth middleware depends on it. Both are required dependencies.
  Each gate dispatches bee:backend-engineer-php with context and section references.
  The agent loads multi-tenant.md via WebFetch and has all code examples.

trigger: |
  - User requests multi-tenant implementation for a PHP/Laravel service
  - User asks to add tenant isolation to an existing service
  - Task mentions "multi-tenant", "tenant isolation", "tenant-manager", "TenantService", "TenantMiddleware"

prerequisite: |
  - PHP/Laravel service with existing single-tenant functionality

NOT_skip_when: |
  - "organization_id already exists" → organization_id is NOT multi-tenant. tenantId via JWT is required.
  - "Just need to connect the wiring" → Multi-tenant requires stancl/tenancy or spatie/multitenancy packages.
  - "tenancy package upgrade is too risky" → REQUIRES stancl/tenancy or spatie/multitenancy packages. No tenancy package = no multi-tenant.

sequence:
  after: [bee:dev-devops]

related:
  complementary: [bee:dev-cycle, bee:dev-implementation, bee:dev-devops, bee:dev-unit-testing, bee:requesting-code-review, bee:dev-validation]

output_schema:
  format: markdown
  required_sections:
    - name: "Multi-Tenant Cycle Summary"
      pattern: "^## Multi-Tenant Cycle Summary"
      required: true
    - name: "Stack Detection"
      pattern: "^## Stack Detection"
      required: true
    - name: "Gate Results"
      pattern: "^## Gate Results"
      required: true
    - name: "Verification"
      pattern: "^## Verification"
      required: true
  metrics:
    - name: gates_passed
      type: integer
    - name: gates_failed
      type: integer
    - name: total_files_changed
      type: integer

examples:
  - name: "Add multi-tenant to a service"
    invocation: "/bee:dev-multi-tenant"
    expected_flow: |
      1. Gate 0: Auto-detect stack
      2. Gate 1: Analyze codebase (build implementation roadmap)
      3. Gate 1.5: Visual implementation preview (HTML report for developer approval)
      4. Gates 2-6: Implementation (agent loads multi-tenant.md, follows roadmap)
      5. Gate 7: Metrics & Backward compatibility
      6. Gate 8: Tests
      7. Gate 9: Code review
      8. Gate 10: User validation
      9. Gate 11: Activation guide
---

# Multi-Tenant Development Cycle

<cannot_skip>

## CRITICAL: This Skill ORCHESTRATES. Agents IMPLEMENT.

| Who | Responsibility |
|-----|----------------|
| **This Skill** | Detect stack, determine gates, pass context to agent, verify outputs, enforce order |
| **bee:backend-engineer-php** | Load multi-tenant.md via WebFetch, implement following the standards |
| **6 reviewers** | Review at Gate 9 |

**CANNOT change scope:** the skill defines WHAT to implement. The agent implements HOW.

**FORBIDDEN: Orchestrator MUST NOT use Edit, Write, or Bash tools to modify source code files.**
All code changes MUST go through `Task(subagent_type="bee:backend-engineer-php")`.
The orchestrator only verifies outputs (grep, composer, php artisan test) — MUST NOT write implementation code.

**MANDATORY: TDD for all implementation gates (Gates 2-6).** MUST follow RED → GREEN → REFACTOR: write a failing test first, then implement to make it pass, then refactor for clarity/performance. MUST include in every dispatch: "Follow TDD: write failing test (RED), implement to make it pass (GREEN), then refactor for clarity/performance (REFACTOR)."

</cannot_skip>

---

## Multi-Tenant Architecture

Multi-tenant isolation is 100% based on `tenantId` from JWT → Laravel tenant middleware resolution → database-per-tenant. Tenant resolution via `stancl/tenancy` (TenantManager) or custom `TenantService` resolves tenant-specific database connections. `organization_id` is NOT part of multi-tenant.

**Standards reference:** All code examples and implementation patterns are in [multi-tenant.md](../../docs/standards/php/multi-tenant.md). MUST load via WebFetch before implementing any gate.

**WebFetch URL:** `https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/php/multi-tenant.md`

### MANDATORY: Canonical Environment Variables

These are the only valid multi-tenant environment variables. MUST NOT use any other names (e.g., `TENANT_MANAGER_ADDRESS` is WRONG — the correct name is `MULTI_TENANT_URL`).

| Env Var | Description | Default | Required |
|---------|-------------|---------|----------|
| `MULTI_TENANT_ENABLED` | Enable multi-tenant mode | `false` | Yes |
| `MULTI_TENANT_URL` | Tenant Manager service URL | - | If multi-tenant |
| `MULTI_TENANT_ENVIRONMENT` | Deployment environment for cache key segmentation (lazy consumer tenant discovery) | `staging` | Only if RabbitMQ |
| `MULTI_TENANT_MAX_TENANT_POOLS` | Soft limit for tenant connection pools (LRU eviction) | `100` | No |
| `MULTI_TENANT_IDLE_TIMEOUT_SEC` | Seconds before idle tenant connection is eviction-eligible | `300` | No |
| `MULTI_TENANT_CIRCUIT_BREAKER_THRESHOLD` | Consecutive failures before circuit breaker opens | `5` | Yes |
| `MULTI_TENANT_CIRCUIT_BREAKER_TIMEOUT_SEC` | Seconds before circuit breaker resets (half-open) | `30` | Yes |

HARD GATE: Any env var outside this table is non-compliant. Agent MUST NOT invent or accept alternative names. These are set in Laravel's `config/tenancy.php` configuration file.

### MANDATORY: Canonical Metrics

These are the only valid multi-tenant metrics. All 4 are required.

| Metric | Type | Description |
|--------|------|-------------|
| `tenant_connections_total` | Counter | Total tenant connections created |
| `tenant_connection_errors_total` | Counter | Connection failures per tenant |
| `tenant_consumers_active` | Gauge | Active message consumers |
| `tenant_messages_processed_total` | Counter | Messages processed per tenant |

When `MULTI_TENANT_ENABLED=false`, metrics MUST use no-op implementations (zero overhead in single-tenant mode).

### MANDATORY: Circuit Breaker

The Tenant Manager HTTP client MUST enable circuit breaker via a middleware or service wrapper. MUST NOT create the client without it.

| Env Var | Default | Description |
|---------|---------|-------------|
| `MULTI_TENANT_CIRCUIT_BREAKER_THRESHOLD` | `5` | Consecutive failures before circuit opens |
| `MULTI_TENANT_CIRCUIT_BREAKER_TIMEOUT_SEC` | `30` | Seconds before circuit resets (half-open) |

HARD GATE: A client without circuit breaker can cascade failures across all tenants.

### MANDATORY: Agent Instruction (include in EVERY gate dispatch)

MUST include these instructions in every dispatch to `bee:backend-engineer-php`:

> **STANDARDS: WebFetch `https://raw.githubusercontent.com/luanrodrigues/ia-frmwrk/master/dev-team/docs/standards/php/multi-tenant.md` and follow the sections referenced below. All code examples, patterns, and implementation details are in that document. Use them as-is.**
>
> **TDD: For implementation gates (2-6), follow TDD methodology — write a failing test first (RED), then implement to make it pass (GREEN). MUST have test coverage for every change.**

---

## Pressure Resistance

| User Says | This Is | Response |
|-----------|---------|----------|
| "Skip the tenancy package installation" | QUALITY_BYPASS | "CANNOT proceed without stancl/tenancy or spatie/multitenancy. Tenant resolution does not work without it." |
| "Just do the happy path, skip backward compat" | SCOPE_REDUCTION | "Backward compatibility is NON-NEGOTIABLE. Single-tenant deployments depend on it." |
| "organization_id is our tenant identifier" | AUTHORITY_OVERRIDE | "STOP. organization_id is NOT multi-tenant. tenantId from JWT is the only mechanism." |
| "Skip code review, we tested it" | QUALITY_BYPASS | "MANDATORY: 6 reviewers. One security mistake = cross-tenant data leak." |
| "We don't need RabbitMQ multi-tenant" | SCOPE_REDUCTION | "MUST execute Gate 6 if RabbitMQ was detected. CANNOT skip detected stack." |
| "I'll make a quick edit directly" | CODE_BYPASS | "FORBIDDEN: All code changes go through bee:backend-engineer-php. Dispatch the agent." |
| "It's just one line, no need for an agent" | CODE_BYPASS | "FORBIDDEN: Even single-line changes MUST be dispatched. Agent ensures standards compliance." |
| "Agent is slow, I'll edit faster" | CODE_BYPASS | "FORBIDDEN: Speed is not a justification. Agent applies TDD and standards checks." |

---

## Gate Overview

| Gate | Name | Condition | Agent |
|------|------|-----------|-------|
| 0 | Stack Detection | Always | Orchestrator |
| 1 | Codebase Analysis (multi-tenant focus) | Always | bee:codebase-explorer |
| 1.5 | Implementation Preview (visual report) | Always | Orchestrator (bee:visual-explainer) |
| 2 | stancl/tenancy + Auth Package Setup | Skip if already installed | bee:backend-engineer-php |
| 3 | Multi-Tenant Configuration | Skip if already configured | bee:backend-engineer-php |
| 4 | Tenant Middleware (Laravel Middleware) | Always (core) | bee:backend-engineer-php |
| 5 | Repository/Eloquent Adaptation | Per detected DB/storage | bee:backend-engineer-php |
| 6 | RabbitMQ Multi-Tenant | Skip if no RabbitMQ | bee:backend-engineer-php |
| 7 | Metrics & Backward Compat | Always | bee:backend-engineer-php |
| 8 | Tests | Always | bee:backend-engineer-php |
| 9 | Code Review | Always | 6 parallel reviewers |
| 10 | User Validation | Always | User |
| 11 | Activation Guide | Always | Orchestrator |

MUST execute gates sequentially. CANNOT skip or reorder.

---

## Gate 0: Stack Detection

**Orchestrator executes directly. No agent dispatch.**

```text
DETECT (run in parallel):

1. tenancy package:      grep "stancl/tenancy\|spatie/multitenancy" composer.json
1b. auth package:        grep "laravel/sanctum\|tymon/jwt-auth" composer.json
2. PostgreSQL:           grep -rn "pgsql\|PostgreSQL\|DB::connection" app/ config/database.php composer.json
3. MongoDB:              grep -rn "mongodb\|jenssegers/mongodb\|MongoClient" app/ composer.json
4. Redis:                grep -rn "Redis\|predis\|phpredis" app/ config/database.php composer.json
5. RabbitMQ:             grep -rn "rabbitmq\|amqp\|php-amqplib" app/ composer.json
6. S3/Object Storage:    grep -rn "s3\|Storage::disk\|putObject\|getObject\|upload.*storage\|download.*storage" app/ config/filesystems.php composer.json
7. Existing multi-tenant:
   - Config:     grep -rn "MULTI_TENANT_ENABLED" app/ config/
   - Middleware: grep -rn "TenantMiddleware\|InitializeTenancyByDomain\|InitializeTenancyByRequestData" app/
   - Context:    grep -rn "tenant()\|Tenancy::tenant\|TenantService" app/
   - S3 keys:    grep -rn "tenant_path\|getTenantStorageKey" app/
   - RMQ:        grep -rn "X-Tenant-ID" app/
```

MUST confirm: user explicitly approves detection results before proceeding.

---

## Gate 1: Codebase Analysis (Multi-Tenant Focus)

**Always executes. This gate builds the implementation roadmap for all subsequent gates.**

**Dispatch `bee:codebase-explorer` with multi-tenant-focused context:**

> TASK: Analyze this codebase exclusively under the multi-tenant perspective.
> DETECTED STACK: {databases and messaging from Gate 0}
>
> CRITICAL: Multi-tenant is ONLY about tenantId from JWT → tenant-manager middleware → database-per-tenant.
> IGNORE organization_id completely — it is NOT multi-tenant. A tenant can have multiple organizations inside its database. organization_id is a domain entity, not a tenant identifier.
>
> FOCUS AREAS (explore ONLY these — ignore everything else):
>
> 1. **Service name, modules, and components**: What is the service called? (Look for `config('app.name')` or `APP_NAME` in `.env`.) How many modules/domains does it have? Each module may need a service provider or dedicated namespace (e.g., `App\Modules\Manager`). Identify: service name, module/domain names per component, and whether they exist or need to be created. Hierarchy: Service -> Module -> Resource.
> 2. **Bootstrap/initialization**: Where does the service start? Where are database connections configured? Where is the middleware stack registered (`app/Http/Kernel.php` or `bootstrap/app.php`)? Identify the exact insertion point for TenantMiddleware.
> 3. **Database connections**: How do Eloquent models and repositories get their DB connection today? Default connection? Explicit `$connection` property? Query builder? List EVERY model/repository file with file:line showing where the connection is obtained.
> 4. **Middleware stack**: What middleware exists and in what order (`$middlewareGroups`, `$routeMiddleware`)? Where would TenantMiddleware fit (after auth, before handlers)?
> 5. **Config files**: Where is the tenancy config? What fields exist in `config/database.php`, `config/tenancy.php`? Where would MULTI_TENANT_ENABLED vars go?
> 6. **RabbitMQ** (if detected): Where are producers? Where are consumers? How are messages published? Where would X-Tenant-ID header be injected? Are producer and consumer in the SAME process or SEPARATE components? Is there already a config split? Are there dual constructors? Is there a queue manager pool? Does the service have both consumer types?
> 7. **Redis** (if detected): Where are Redis operations? Any Lua scripts? Where would tenant-prefixed keys be needed?
> 8. **S3/Object Storage** (if detected): Where are Upload/Download/Delete operations? How are object keys constructed? List every file:line that builds an S3 key. What disk/bucket config is used?
> 9. **Existing multi-tenant code**: Any tenancy package imports (`use Stancl\Tenancy`, `use Spatie\Multitenancy`, etc.)? TenantMiddleware? `tenant()` or `Tenancy::tenant()` calls? MULTI_TENANT_ENABLED config? (NOTE: organization_id is NOT related to multi-tenant -- ignore it completely)
>
> OUTPUT FORMAT: Structured report with file:line references for every point above.
> DO NOT write code. Analysis only.

**The explorer produces a gap summary.** For the full checklist of required items, see [multi-tenant.md § Checklist](../../docs/standards/php/multi-tenant.md).

**This report becomes the CONTEXT for all subsequent gates.**

<block_condition>
HARD GATE: MUST complete the analysis report before proceeding. All subsequent gates use this report to know exactly what to change.
</block_condition>

MUST ensure backward compatibility context: the analysis MUST identify how the service works today in single-tenant mode, so subsequent gates preserve this behavior when `MULTI_TENANT_ENABLED=false`.

---

## Gate 1.5: Implementation Preview (Visual Report)

**Always executes. This gate generates a visual HTML report showing exactly what will change before any code is written.**

**Uses the `bee:visual-explainer` skill to produce a self-contained HTML page.**

The report is built from Gate 0 (stack detection) and Gate 1 (codebase analysis). It shows the developer a complete preview of every change that will be made across all subsequent gates, with backward compatibility analysis.

**Orchestrator generates the report using `bee:visual-explainer` with this content:**

The HTML page MUST include these sections:

### 1. Current Architecture (Before)
- Mermaid diagram showing current request flow (how connections work today in single-tenant mode)
- Table of all files that will be modified, with current line counts
- How Eloquent models/repositories get DB connections today (default connection, explicit `$connection`, etc.)

### 2. Target Architecture (After)
- Mermaid diagram showing the multi-tenant request flow (JWT → middleware → tenant pool → handler)
- Which middleware will be used: `TenantMiddleware` with `stancl/tenancy` or custom `TenantService`
- How Eloquent models/repositories will get DB connections (tenant scope-based: `BelongsToTenant` trait or dynamic `$connection`)

### 3. Change Map (per gate)
Table with columns: Gate, File, Current Code, New Code, Lines Changed. One row per file that will be modified. Example:

| Gate | File | What Changes | Impact |
|------|------|-------------|--------|
| 2 | `composer.json` | Add stancl/tenancy + auth package, update namespaces | All files |
| 3 | `config/tenancy.php` | Add the 7 canonical MULTI_TENANT_* env vars (see "Canonical Environment Variables" table above) to config | ~20 lines added |
| 4 | `app/Http/Middleware/TenantMiddleware.php` | Add TenantMiddleware for tenant resolution from JWT | ~30 lines added |
| 4 | `app/Http/Kernel.php` | Register middleware in middleware stack | ~5 lines added |
| 5 | `app/Models/Organization.php` | Add `BelongsToTenant` trait or tenant scope with `tenant_id` | ~3 lines per model |
| 5 | `app/Models/Metadata.php` | Dynamic MongoDB connection via tenant context | ~2 lines per model |
| 5 | `app/Services/CacheService.php` | Key prefixing with `tenant()->getTenantKey() . ':' . $key` | ~1 line per operation |
| 5 | `app/Services/StorageService.php` | S3 key prefixing with `tenant()->getTenantKey() . '/' . $key` | ~1 line per operation |
| 6 | `app/Services/RabbitMQProducer.php` | Dual constructor (single-tenant + multi-tenant) | ~20 lines added |
| 6 | `app/Services/RabbitMQConsumer.php` | MultiTenantConsumer setup with lazy mode | ~40 lines added |
| 7 | `config/tenancy.php` | Backward compat validation | ~10 lines added |

**MANDATORY: Below the summary table, show per-file code diff panels for every file that will be modified.**

For each file in the change map, generate a before/after diff panel showing:
- **Before:** The exact current code from the codebase (sourced from the Gate 1 analysis)
- **After:** The exact code that will be written (following multi-tenant.md patterns)
- Use syntax highlighting and line numbers (read `default/skills/visual-explainer/templates/code-diff.html` for patterns)

Example diff panel for a repository/model file:

```php
// BEFORE: app/Models/Organization.php
class Organization extends Model
{
    protected $connection = 'pgsql';

    public function create(array $data): Organization
    {
        return static::query()->create($data);
    }
}

// AFTER: app/Models/Organization.php
use App\Traits\BelongsToTenant;

class Organization extends Model
{
    use BelongsToTenant;

    protected $connection = 'pgsql';

    public function create(array $data): Organization
    {
        $data['tenant_id'] = tenant()->getTenantKey();
        return static::query()->create($data);
    }
}
```

The developer MUST be able to see the exact code that will be implemented to approve it. High-level descriptions alone are not sufficient for approval.

**When many files have identical changes** (e.g., 10+ model files all adding the `BelongsToTenant` trait and tenant scope): show one representative diff panel, then list the remaining files with "Same pattern applied to: [file list]."

### 4. Backward Compatibility Analysis

**MANDATORY: Show complete conditional initialization code, not just the if/else skeleton.**

For each component (PostgreSQL, MongoDB, Redis, RabbitMQ, S3), show:
1. **Current initialization code** (exact lines from codebase, sourced from Gate 1)
2. **New initialization code** with the `if cfg.MultiTenantEnabled` branch
3. **Explicit callout:** "When MULTI_TENANT_ENABLED=false, execution follows the ELSE branch which is IDENTICAL to current behavior"

Side-by-side comparison showing:
- **MULTI_TENANT_ENABLED=false (default):** Exact current behavior preserved. No JWT parsing, no Tenant Manager calls, no pool routing. Middleware calls `$next($request)` immediately.
- **MULTI_TENANT_ENABLED=true:** New behavior with tenant isolation.

Code diff showing the complete conditional initialization (not skeleton):
```php
// In AppServiceProvider or TenancyServiceProvider
if (config('tenancy.multi_tenant_enabled') && config('tenancy.multi_tenant_url')) {
    // Multi-tenant path (NEW)
    $this->app->singleton(TenantService::class, function ($app) {
        return new TenantService(
            config('tenancy.multi_tenant_url'),
            $app->make(LoggerInterface::class)
        );
    });
    // ... show complete initialization
} else {
    // Single-tenant path (UNCHANGED — exactly how it works today)
    // Show the exact same service bindings that exist in the current codebase
    Log::info('Running in SINGLE-TENANT MODE');
}
```

Show the middleware bypass explicitly:
```php
// When MULTI_TENANT_ENABLED=false, TenantMiddleware is NOT registered in the middleware stack.
// Requests flow directly to controllers without any JWT parsing or tenant resolution.
```

The developer MUST understand that:
- No new code paths execute in single-tenant mode
- The `else` branch preserves the exact current constructor calls
- No additional dependencies are loaded when disabled
- No performance impact when disabled (middleware calls $next($request) immediately)

### 5. New Dependencies
Table showing what gets added to `composer.json` and which classes/namespaces are used:
- `stancl/tenancy` — core tenancy package (tenant resolution, lifecycle, events)
- `App\Http\Middleware\TenantMiddleware` — Laravel middleware for tenant resolution from JWT
- `App\Services\TenantService` — custom Tenant Manager HTTP client wrapper
- `App\Traits\BelongsToTenant` — Eloquent trait for automatic tenant scoping
- `App\Scopes\TenantScope` — global scope for tenant_id filtering (if PG/MySQL detected)
- `App\Services\TenantMongoService` — MongoDB tenant connection resolver (if Mongo detected)
- etc.

### 6. Environment Variables
The exact 7 canonical env vars from the "Canonical Environment Variables" table (MULTI_TENANT_ENABLED, MULTI_TENANT_URL, MULTI_TENANT_ENVIRONMENT, MULTI_TENANT_MAX_TENANT_POOLS, MULTI_TENANT_IDLE_TIMEOUT_SEC, MULTI_TENANT_CIRCUIT_BREAKER_THRESHOLD, MULTI_TENANT_CIRCUIT_BREAKER_TIMEOUT_SEC). MUST NOT use alternative names.

### 7. Risk Assessment
Table with: Risk, Mitigation, Verification. Examples:
- Single-tenant regression → Backward compat gate (Gate 7) → `MULTI_TENANT_ENABLED=false php artisan test`
- Cross-tenant data leak → Context-based isolation → Tenant isolation integration tests (Gate 8)
- Startup performance → Lazy consumer mode → `consumer.Run(ctx)` returns in <1s

### 8. Retro Compatibility Guarantee

Explicit explanation of backward compatibility strategy:

**Method:** Feature flag with `MULTI_TENANT_ENABLED` environment variable (default: `false`).

**Guarantee:** When `MULTI_TENANT_ENABLED=false`:
- No tenant middleware is registered in the HTTP chain
- No JWT parsing or tenant resolution occurs
- All database connections use the original static constructors
- All Redis keys are unprefixed (original behavior)
- All S3 keys are unprefixed (original behavior)
- RabbitMQ connects directly at startup (original behavior)
- `php artisan test` passes with zero changes to existing tests

**Verification (Gate 7):** The agent MUST run `MULTI_TENANT_ENABLED=false php artisan test` and verify all existing tests pass unchanged.

**Output:** Save the HTML report to `docs/multi-tenant-preview.html` in the project root.

**Open in browser** for the developer to review.

<block_condition>
HARD GATE: Developer MUST explicitly approve the implementation preview before any code changes begin. This prevents wasted effort on misunderstood requirements or incorrect architectural decisions.
</block_condition>

**If the developer requests changes to the preview, regenerate the report and re-confirm.**

---

## Gate 2: stancl/tenancy + Auth Package Setup

**SKIP IF:** stancl/tenancy already installed AND auth package configured.

**Dispatch `bee:backend-engineer-php` with context:**

> TASK: Install stancl/tenancy package first, then configure the auth package (auth depends on tenancy being set up).
> Run in order:
> 1. `composer require stancl/tenancy`
> 2. `php artisan tenancy:install`
> 3. `php artisan migrate`
> Update `config/tenancy.php` and all namespace imports (`use Stancl\Tenancy\...`).
> Follow multi-tenant.md section "Required Tenancy Package".
> DO NOT implement multi-tenant code yet — only install and configure the dependencies.
> Verify: `php artisan test` MUST pass.

**Verification:** `grep "stancl/tenancy" composer.json` + `php artisan test`

<block_condition>
HARD GATE: MUST pass tests before proceeding.
</block_condition>

---

## Gate 3: Multi-Tenant Configuration

**SKIP IF:** config already has `MULTI_TENANT_ENABLED`.

**Dispatch `bee:backend-engineer-php` with context from Gate 1 analysis:**

> TASK: Add the 7 canonical multi-tenant environment variables to `config/tenancy.php`.
> CONTEXT FROM GATE 1: {Config file location and current fields from analysis report}
> Follow multi-tenant.md sections "Environment Variables", "Configuration", and "Conditional Initialization".
>
> The EXACT env vars to add (no alternatives allowed):
> - MULTI_TENANT_ENABLED (bool, default false)
> - MULTI_TENANT_URL (string, required when enabled)
> - MULTI_TENANT_ENVIRONMENT (string, default "staging", only if RabbitMQ)
> - MULTI_TENANT_MAX_TENANT_POOLS (int, default 100)
> - MULTI_TENANT_IDLE_TIMEOUT_SEC (int, default 300)
> - MULTI_TENANT_CIRCUIT_BREAKER_THRESHOLD (int, default 5)
> - MULTI_TENANT_CIRCUIT_BREAKER_TIMEOUT_SEC (int, default 30)
>
> MUST NOT use alternative names (e.g., TENANT_MANAGER_ADDRESS, TENANT_MANAGER_URL are WRONG).
> Add conditional log in `AppServiceProvider::boot()`: "Multi-tenant mode enabled" vs "Running in SINGLE-TENANT MODE".
> DO NOT implement TenantMiddleware yet — only configuration.

**Verification:** `grep "MULTI_TENANT_ENABLED" config/tenancy.php` + `php artisan test`

---

## Gate 4: TenantMiddleware (Core)

**SKIP IF:** middleware already exists.

**This is the CORE gate. Without TenantMiddleware, there is no tenant isolation.**

**Dispatch `bee:backend-engineer-php` with context from Gate 1 analysis:**

> TASK: Implement tenant middleware using stancl/tenancy or custom TenantMiddleware.
> DETECTED DATABASES: {postgresql: Y/N, mongodb: Y/N} (from Gate 0)
> SERVICE ARCHITECTURE: {single-module OR multi-module} (from Gate 1)
> CONTEXT FROM GATE 1: {ServiceProvider location, middleware stack insertion point, service init from analysis report}
>
> **For single-module services:** Follow multi-tenant.md § "Generic TenantMiddleware (Standard Pattern)" — create `app/Http/Middleware/TenantMiddleware.php`.
> **For multi-module services:** Follow multi-tenant.md § "Multi-module middleware" for route-based tenant resolution with middleware groups.
> **For use statements:** See multi-tenant.md § package import table.
>
> Follow multi-tenant.md § "JWT Tenant Extraction" for tenantId claim handling via `auth()->payload()->get('tenantId')`.
> Follow multi-tenant.md § "Conditional Initialization" for the service provider bootstrap pattern.
>
> MUST define constants for service name and module names in a dedicated config or constants class — never pass raw strings.
> Create tenant database connections ONLY for detected databases.
> Public endpoints (/health, /version, /api/documentation) MUST bypass tenant middleware via `$except` or route grouping.
> When MULTI_TENANT_ENABLED=false, middleware calls `$next($request)` immediately (single-tenant passthrough).
>
> **IF RabbitMQ DETECTED:** Follow multi-tenant.md § "ConsumerTrigger interface" for the wiring pattern.

**Verification:** `grep -rn "TenantMiddleware" app/Http/Middleware/` + `php artisan test`

<block_condition>
HARD GATE: CANNOT proceed without TenantMiddleware.
</block_condition>

---

## Gate 5: Repository/Eloquent Adaptation

**SKIP IF:** models/repositories already use tenant-scoped connections.

**Dispatch `bee:backend-engineer-php` with context from Gate 1 analysis:**

> TASK: Adapt all Eloquent models and repository implementations to use tenant-scoped database connections instead of static connections. Also adapt S3/object storage operations to prefix keys with tenant ID.
> DETECTED STACK: {postgresql: Y/N, mongodb: Y/N, redis: Y/N, s3: Y/N} (from Gate 0)
> CONTEXT FROM GATE 1: {List of ALL model/repository files and storage operations with file:line from analysis report}
>
> Follow multi-tenant.md sections:
> - "Eloquent Tenant Scoping" (PostgreSQL/MySQL) — add `BelongsToTenant` trait and `TenantScope` global scope with `tenant_id`
> - "MongoDB Multi-Tenant Repository" (MongoDB) — dynamic connection via `tenant()->mongodb_connection`
> - "Redis Key Prefixing" and "Redis Key Prefixing for Lua Scripts" (Redis) — prefix keys with `tenant()->getTenantKey()`
> - "S3/Object Storage Key Prefixing" (S3) — prefix keys with `tenant()->getTenantKey() . '/'`
>
> MUST work in both modes: multi-tenant (prefixed keys / tenant-scoped connections) and single-tenant (unchanged keys / default connections).

**Verification:** grep for `BelongsToTenant` / `TenantScope` / `tenant()->getTenantKey()` in `app/` + `php artisan test`

---

## Gate 6: RabbitMQ Multi-Tenant

**SKIP IF:** no RabbitMQ detected.

**Dispatch `bee:backend-engineer-php` with context from Gate 1 analysis:**

> TASK: Implement RabbitMQ multi-tenant patterns with lazy initialization.
> CONTEXT FROM GATE 1: {Producer and consumer file:line locations from analysis report}
> DETECTED ARCHITECTURE: {Are producer and consumer in the same process or separate components?}
>
> Follow multi-tenant.md sections:
> - "RabbitMQ Multi-Tenant Producer" for dual constructor and X-Tenant-ID header
> - "Multi-Tenant Message Queue Consumers (Lazy Mode)" for lazy initialization
> - "ConsumerTrigger Interface" for the trigger wiring
>
> Gate-specific constraints:
> 1. CONFIG SPLIT (MANDATORY): Branch on `config('tenancy.multi_tenant_enabled')` for both producer and consumer in service provider
> 2. MUST keep the existing single-tenant code path untouched
> 3. MUST NOT connect directly to RabbitMQ at startup in multi-tenant mode
> 4. X-Tenant-ID goes in AMQP headers, NOT in message body

**Verification:** `grep -rn "RabbitMQMultiTenantProducer\|TenantConsumer\|X-Tenant-ID" app/` + `php artisan test`

<block_condition>
HARD GATE: MUST NOT connect directly to RabbitMQ at startup in multi-tenant mode.
</block_condition>

---

## Gate 7: Metrics & Backward Compatibility

**Dispatch `bee:backend-engineer-php` with context:**

> TASK: Add multi-tenant metrics and validate backward compatibility.
>
> Follow multi-tenant.md sections "Multi-Tenant Metrics" and "Single-Tenant Backward Compatibility Validation (MANDATORY)".
>
> The EXACT metrics to implement (no alternatives allowed):
> - `tenant_connections_total` (Counter) — Total tenant connections created
> - `tenant_connection_errors_total` (Counter) — Connection failures per tenant
> - `tenant_consumers_active` (Gauge) — Active message consumers
> - `tenant_messages_processed_total` (Counter) — Messages processed per tenant
>
> All 4 metrics are MANDATORY. When MULTI_TENANT_ENABLED=false, metrics MUST use no-op implementations (zero overhead).
>
> BACKWARD COMPATIBILITY IS NON-NEGOTIABLE:
> - MUST start without any MULTI_TENANT_* env vars
> - MUST start without Tenant Manager running
> - MUST pass all existing tests with MULTI_TENANT_ENABLED=false
> - Health/version endpoints MUST work without tenant context
>
> Write `MultiTenantBackwardCompatibilityTest.php` integration test.

**Verification:** `MULTI_TENANT_ENABLED=false php artisan test` MUST pass.

<block_condition>
HARD GATE: Backward compatibility MUST pass.
</block_condition>

---

## Gate 8: Tests

**Dispatch `bee:backend-engineer-php` with context:**

> TASK: Write multi-tenant tests.
> DETECTED STACK: {postgresql: Y/N, mongodb: Y/N, redis: Y/N, s3: Y/N, rabbitmq: Y/N} (from Gate 0)
>
> Follow multi-tenant.md section "Testing Multi-Tenant Code" (all subsections).
>
> Required tests: unit tests with mock tenant context, tenant isolation tests (two tenants, data separation), error case tests (missing JWT, tenant not found), plus RabbitMQ, Redis, and S3 tests if detected.

**Verification:** `php artisan test --verbose` + `php artisan test --coverage`

---

## Gate 9: Code Review

**Dispatch 6 parallel reviewers (same pattern as bee:requesting-code-review).**

MUST include this context in ALL 6 reviewer dispatches:

> **MULTI-TENANT REVIEW CONTEXT:**
> - Multi-tenant isolation is based on `tenantId` from JWT → tenant-manager middleware (TenantMiddleware or MultiPoolMiddleware) → database-per-tenant.
> - `organization_id` is NOT a tenant identifier. It is a business filter within the tenant's database. A single tenant can have multiple organizations. Do NOT flag organization_id as a multi-tenant issue.
> - Backward compatibility is required: when `MULTI_TENANT_ENABLED=false`, the service MUST work exactly as before (single-tenant mode, no tenant context needed).

| Reviewer | Focus |
|----------|-------|
| bee:code-reviewer | Architecture, stancl/tenancy usage, TenantMiddleware placement, package usage |
| bee:business-logic-reviewer | Tenant context propagation via tenantId (NOT organization_id) |
| bee:security-reviewer | Cross-tenant DB isolation, JWT tenantId validation, no data leaks between tenant databases |
| bee:test-reviewer | Coverage, isolation tests between two tenants, backward compat tests |
| bee:nil-safety-reviewer | Null risks in tenant context extraction from JWT and service resolution |
| bee:consequences-reviewer | Impact on single-tenant paths, backward compat when MULTI_TENANT_ENABLED=false |

MUST pass all 6 reviewers. Critical findings → fix and re-review.

---

## Gate 10: User Validation

MUST approve: present checklist for explicit user approval.

```markdown
## Multi-Tenant Implementation Complete

- [ ] stancl/tenancy installed and configured
- [ ] MULTI_TENANT_ENABLED config
- [ ] Tenant middleware (TenantMiddleware registered in Kernel)
- [ ] Models/Repositories use tenant-scoped connections (BelongsToTenant trait)
- [ ] S3 keys prefixed with tenantId (if applicable)
- [ ] RabbitMQ X-Tenant-ID (if applicable)
- [ ] Backward compat (MULTI_TENANT_ENABLED=false works)
- [ ] Tests pass
- [ ] Code review passed
```

---

## Gate 11: Activation Guide

**MUST generate `docs/multi-tenant-guide.md` in the project root.** Direct, concise, no filler text.

The file is built from Gate 0 (stack) and Gate 1 (analysis). See [multi-tenant.md § Checklist](../../docs/standards/php/multi-tenant.md) for the canonical env var list and requirements.

<!-- Template: values filled from Gate 0/1 results. Canonical source: multi-tenant.md -->

The guide MUST include:
1. **Components table**: Component name, Service const, Module const, Resources, what was adapted
2. **Environment variables**: the 7 canonical MULTI_TENANT_* vars (MULTI_TENANT_ENABLED, MULTI_TENANT_URL, MULTI_TENANT_ENVIRONMENT, MULTI_TENANT_MAX_TENANT_POOLS, MULTI_TENANT_IDLE_TIMEOUT_SEC, MULTI_TENANT_CIRCUIT_BREAKER_THRESHOLD, MULTI_TENANT_CIRCUIT_BREAKER_TIMEOUT_SEC) with required/default/description
3. **How to activate**: set envs + start alongside Tenant Manager
4. **How to verify**: check logs, test with JWT tenantId
5. **How to deactivate**: set MULTI_TENANT_ENABLED=false
6. **Common errors**: see [multi-tenant.md § Error Handling](../../docs/standards/php/multi-tenant.md)

---

## State Persistence

Save to `docs/bee-dev-multi-tenant/current-cycle.json` for resume support:

```json
{
  "cycle": "multi-tenant",
  "stack": {"postgresql": false, "mongodb": true, "redis": true, "rabbitmq": true, "s3": true},
  "gates": {"0": "PASS", "1": "PASS", "1.5": "PASS", "2": "IN_PROGRESS", "3": "PENDING"},
  "current_gate": 2
}
```

---

## Anti-Rationalization Table

See [multi-tenant.md](../../docs/standards/php/multi-tenant.md) for the canonical anti-rationalization tables on tenantId vs organization_id.

**Skill-specific rationalizations:**

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Agent says out of scope" | Skill defines scope, not agent. | **Re-dispatch with gate context** |
| "Skip tests" | Gate 8 proves isolation works. | **MANDATORY** |
| "Skip review" | Security implications. One mistake = data leak. | **MANDATORY** |
| "Using TENANT_MANAGER_ADDRESS instead" | Non-standard name. Only the 7 canonical MULTI_TENANT_* vars are valid. | **STOP. Use MULTI_TENANT_URL** |
| "The service already uses a different env name" | Legacy names are non-compliant. Rename to canonical names. | **Replace with canonical env vars** |
