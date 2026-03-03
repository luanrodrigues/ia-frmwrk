# PHP/Laravel Standards

> **⚠️ MAINTENANCE:** This file is indexed in `dev-team/skills/shared-patterns/standards-coverage-table.md`.
> When adding/removing `## ` sections, follow FOUR-FILE UPDATE RULE in CLAUDE.md: (1) edit standards file, (2) update TOC, (3) update standards-coverage-table.md, (4) update agent file.

This file defines the specific standards for PHP/Laravel backend development.

> **Reference**: Always consult `docs/PROJECT_RULES.md` for common project standards.

---

## Table of Contents

| #  | Section | Description |
|----|---------|-------------|
| 1  | [Version](#version) | PHP 8.2+, Laravel 11+ |
| 2  | [Core Dependencies](#core-dependencies) | Required Composer packages |
| 3  | [Frameworks & Libraries](#frameworks--libraries) | Laravel, Pest, PHPStan, etc. |
| 4  | [Configuration](#configuration) | Environment variable handling |
| 5  | [Database Naming Convention (snake_case)](#database-naming-convention-snake_case-mandatory) | Table and column naming |
| 6  | [Database Migrations](#database-migrations-mandatory) | Laravel migrations |
| 7  | [License Headers](#license-headers-mandatory) | Source file headers |
| 8  | [Eloquent Patterns](#eloquent-patterns-mandatory) | Models, scopes, relationships |
| 9  | [Dependency Management](#dependency-management-mandatory) | Version pinning, security |
| 10 | [Observability](#observability) | OpenTelemetry integration |
| 11 | [Bootstrap](#bootstrap) | Service Provider registration |
| 12 | [Graceful Shutdown Patterns](#graceful-shutdown-patterns-mandatory) | Queue worker signals |
| 13 | [Health Checks](#health-checks-mandatory) | /health vs /ready |
| 14 | [Connection Management](#connection-management-mandatory) | DB, Redis, Queue |
| 15 | [Authentication Integration](#authentication-integration-mandatory) | Sanctum, Passport, Guards |
| 16 | [Secret Redaction Patterns](#secret-redaction-patterns-mandatory) | Credential leak prevention |
| 17 | [SQL Safety](#sql-safety-mandatory) | Injection prevention |
| 18 | [HTTP Security Headers](#http-security-headers-mandatory) | CSRF, CORS, headers |
| 19 | [Data Transformation](#data-transformation-mandatory) | API Resources, DTOs |
| 20 | [Error Codes Convention](#error-codes-convention-mandatory) | Service-prefixed codes |
| 21 | [Error Handling](#error-handling) | Exception hierarchy |
| 22 | [Exit/Fatal Location Rules](#exitfatal-location-rules-mandatory) | die()/exit() FORBIDDEN |
| 23 | [Function Design](#function-design-mandatory) | Single responsibility |
| 24 | [File Organization](#file-organization-mandatory) | Max 200-300 lines |
| 25 | [JSON Naming Convention (camelCase)](#json-naming-convention-camelcase-mandatory) | API response fields |
| 26 | [Pagination Patterns](#pagination-patterns) | Cursor & offset |
| 27 | [HTTP Status Code Consistency](#http-status-code-consistency-mandatory) | 201 create, 200 update |
| 28 | [OpenAPI Documentation](#openapi-documentation-mandatory) | L5-Swagger or Scramble |
| 29 | [Controller Constructor Pattern](#controller-constructor-pattern-mandatory) | DI via constructor |
| 30 | [Input Validation](#input-validation-mandatory) | Form Requests |
| 31 | [Testing](#testing) | Pest + PHPUnit patterns |
| 32 | [Logging](#logging) | Structured JSON, Monolog |
| 33 | [Linting](#linting) | PHP CS Fixer, PHPStan |
| 34 | [Production Config Validation](#production-config-validation-mandatory) | config:cache, route:cache |
| 35 | [Container Security](#container-security-conditional) | Non-root, PHP-FPM |
| 36 | [Architecture Patterns](#architecture-patterns) | Hexagonal/Lerian |
| 37 | [Directory Structure](#directory-structure) | Laravel hexagonal |
| 38 | [N+1 Query Detection](#n1-query-detection-mandatory) | preventLazyLoading() |
| 39 | [Performance Patterns](#performance-patterns-mandatory) | Query optimization |
| 40 | [RabbitMQ Worker Pattern](#rabbitmq-worker-pattern) | php-amqplib, Queues |
| 41 | [RabbitMQ Reconnection Strategy](#rabbitmq-reconnection-strategy-mandatory) | Consumer reconnection |
| 42 | [Always-Valid Domain Model](#always-valid-domain-model-mandatory) | Constructor validation |
| 43 | [Idempotency Patterns](#idempotency-patterns-mandatory-for-transaction-apis) | Redis-based keys |
| 44 | [Multi-Tenant Patterns](#multi-tenant-patterns-conditional) | stancl/tenancy |
| 45 | [Rate Limiting](#rate-limiting-mandatory) | Laravel RateLimiter |
| 46 | [CORS Configuration](#cors-configuration-mandatory) | config/cors.php |

**Meta-sections (not checked by agents):**

- [Checklist](#checklist) - Self-verification before deploying

---

## Version

- **PHP**: 8.2+ (MANDATORY). Use `declare(strict_types=1);` in ALL files.
- **Laravel**: 11+ (MANDATORY)
- **Composer**: 2+ (MANDATORY)

```php
<?php

declare(strict_types=1);
```

**Detection:**
```bash
php -v | head -1
php artisan --version
composer --version
grep "strict_types" app/**/*.php | wc -l
```

---

## Core Dependencies

**MANDATORY Composer packages:**

| Package | Purpose | Required |
|---------|---------|----------|
| `laravel/framework` | Core framework | ✅ |
| `pestphp/pest` | Testing framework | ✅ |
| `pestphp/pest-plugin-laravel` | Laravel integration for Pest | ✅ |
| `phpstan/phpstan` | Static analysis | ✅ |
| `larastan/larastan` | PHPStan for Laravel | ✅ |
| `friendsofphp/php-cs-fixer` | Code style fixer | ✅ |
| `open-telemetry/sdk` | OpenTelemetry SDK | ✅ |
| `open-telemetry/exporter-otlp` | OTLP exporter | ✅ |
| `predis/predis` | Redis client | When Redis used |
| `php-amqplib/php-amqplib` | RabbitMQ client | When RabbitMQ used |
| `mockery/mockery` | Mocking library | ✅ |
| `roave/security-advisories` | Security vulnerability check | ✅ |

**⛔ HARD GATE:** No duplicate utility packages. Use Laravel built-in helpers first.

**Detection:**
```bash
composer show --installed | grep -E "pest|phpstan|php-cs-fixer|open-telemetry"
```

---

## Frameworks & Libraries

| Category | Library | Version |
|----------|---------|---------|
| **Framework** | Laravel | 11+ |
| **Testing** | Pest | 3+ |
| **Testing** | PHPUnit | 11+ |
| **Mocking** | Mockery | 1.6+ |
| **Static Analysis** | PHPStan + Larastan | Level 8+ |
| **Code Style** | PHP CS Fixer | 3+ |
| **ORM** | Eloquent | (bundled) |
| **Validation** | Laravel Validation + Form Requests | (bundled) |
| **Auth** | Sanctum or Passport | Latest |
| **Queue** | Laravel Queues | (bundled) |
| **Cache** | Laravel Cache (Redis/Memcached) | (bundled) |
| **HTTP Client** | Laravel HTTP | (bundled) |
| **Observability** | OpenTelemetry PHP SDK | 1+ |
| **Logging** | Monolog (via Laravel) | (bundled) |
| **API Docs** | L5-Swagger or Scramble | Latest |

---

## Configuration

**⛔ HARD GATE:** `env()` is FORBIDDEN outside of `config/` files.

```php
// ❌ FORBIDDEN - env() in application code
class UserService {
    public function getLimit(): int {
        return (int) env('USER_LIMIT', 100); // FORBIDDEN
    }
}

// ✅ CORRECT - config() in application code
class UserService {
    public function getLimit(): int {
        return (int) config('app.user_limit', 100);
    }
}

// ✅ CORRECT - env() only in config files
// config/app.php
return [
    'user_limit' => env('USER_LIMIT', 100),
];
```

**Detection:**
```bash
grep -rn "env(" app/ --include="*.php" | grep -v "config/"
```

---

## Database Naming Convention (snake_case) (MANDATORY)

| Element | Convention | Example |
|---------|-----------|---------|
| Tables | snake_case, plural | `user_accounts` |
| Columns | snake_case | `created_at`, `tenant_id` |
| Foreign keys | `{table_singular}_id` | `user_id` |
| Pivot tables | alphabetical, singular | `role_user` |
| Indexes | `{table}_{columns}_index` | `users_email_index` |

**Detection:**
```bash
grep -rn "Schema::create\|->table(" database/migrations/ --include="*.php"
```

---

## Database Migrations (MANDATORY)

```php
// ✅ CORRECT - Migration with rollback safety
public function up(): void
{
    Schema::create('transactions', function (Blueprint $table) {
        $table->uuid('id')->primary();
        $table->foreignUuid('tenant_id')->constrained()->cascadeOnDelete();
        $table->foreignUuid('user_id')->constrained();
        $table->decimal('amount', 15, 2);
        $table->string('currency', 3)->default('BRL');
        $table->string('status')->default('pending');
        $table->timestamps();
        $table->softDeletes();

        $table->index(['tenant_id', 'status']);
        $table->index(['user_id', 'created_at']);
    });
}

public function down(): void
{
    Schema::dropIfExists('transactions');
}
```

**Rules:**
- Every `up()` MUST have a corresponding `down()`
- Use UUIDs for primary keys (MANDATORY for multi-tenant)
- Always add indexes for foreign keys and frequently queried columns
- Use `$table->timestamps()` and `$table->softDeletes()` when appropriate

**Detection:**
```bash
grep -rn "function up" database/migrations/ --include="*.php" | wc -l
grep -rn "function down" database/migrations/ --include="*.php" | wc -l
```

---

## License Headers (MANDATORY)

All PHP source files MUST include a license header:

```php
<?php

declare(strict_types=1);

/**
 * Copyright (c) 2024 Your Company.
 * All rights reserved.
 */
```

**Detection:**
```bash
grep -rL "Copyright" app/ --include="*.php" | head -20
```

---

## Eloquent Patterns (MANDATORY)

### Mass Assignment Protection

```php
// ✅ CORRECT - Explicit fillable
class Transaction extends Model
{
    protected $fillable = [
        'tenant_id',
        'user_id',
        'amount',
        'currency',
        'status',
    ];

    // OR use guarded for inverse
    // protected $guarded = ['id'];
}
```

### Attribute Casting

```php
protected function casts(): array
{
    return [
        'amount' => 'decimal:2',
        'metadata' => 'array',
        'is_active' => 'boolean',
        'processed_at' => 'datetime',
        'status' => TransactionStatus::class, // Enum cast
    ];
}
```

### Query Scopes

```php
// ✅ Named scopes for reusable queries
public function scopeActive(Builder $query): Builder
{
    return $query->where('status', 'active');
}

public function scopeForTenant(Builder $query, string $tenantId): Builder
{
    return $query->where('tenant_id', $tenantId);
}

// Usage: Transaction::active()->forTenant($tenantId)->get();
```

### Relationships

```php
// ✅ Always define return types
public function user(): BelongsTo
{
    return $this->belongsTo(User::class);
}

public function items(): HasMany
{
    return $this->hasMany(TransactionItem::class);
}
```

### Soft Deletes

```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Transaction extends Model
{
    use SoftDeletes;
}
```

**Detection:**
```bash
grep -rn "protected \$fillable\|protected \$guarded" app/Models/ --include="*.php"
grep -rn "function casts" app/Models/ --include="*.php"
```

---

## Dependency Management (MANDATORY)

- **MUST** commit `composer.lock` to version control
- **MUST** use `roave/security-advisories` to block vulnerable packages
- **MUST** pin major versions in `composer.json`
- **MUST** run `composer audit` in CI/CD

```json
{
    "require": {
        "php": "^8.2",
        "laravel/framework": "^11.0",
        "predis/predis": "^2.0"
    },
    "require-dev": {
        "roave/security-advisories": "dev-latest"
    }
}
```

**Detection:**
```bash
test -f composer.lock && echo "OK" || echo "MISSING composer.lock"
composer audit
grep "roave/security-advisories" composer.json
```

---

## Observability

### OpenTelemetry Integration

```php
// app/Providers/TelemetryServiceProvider.php
class TelemetryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(TracerInterface::class, function () {
            $exporter = new OtlpHttpTransportFactory()->create(
                config('telemetry.endpoint'),
                'application/x-protobuf'
            );

            $tracerProvider = TracerProvider::builder()
                ->addSpanProcessor(
                    new BatchSpanProcessor($exporter)
                )
                ->setResource(
                    ResourceInfoFactory::defaultResource()->merge(
                        ResourceInfo::create(Attributes::create([
                            'service.name' => config('app.name'),
                            'service.version' => config('app.version'),
                        ]))
                    )
                )
                ->build();

            return $tracerProvider->getTracer('app');
        });
    }
}
```

### Span Naming Convention (MANDATORY)

Pattern: `app.{layer}.{operation}`

| Layer | Example |
|-------|---------|
| Controller | `app.controller.store_transaction` |
| Service | `app.service.process_payment` |
| Repository | `app.repository.find_by_id` |
| Queue | `app.queue.process_notification` |
| HTTP Client | `app.http.fetch_exchange_rate` |

**Detection:**
```bash
grep -rn "spanBuilder\|startSpan" app/ --include="*.php"
```

---

## Bootstrap

### Service Provider Registration Order

```php
// bootstrap/providers.php (Laravel 11+)
return [
    // 1. Infrastructure (logging, telemetry, config)
    App\Providers\TelemetryServiceProvider::class,

    // 2. Domain (repositories, services)
    App\Providers\RepositoryServiceProvider::class,

    // 3. Application (event listeners, policies)
    App\Providers\EventServiceProvider::class,

    // 4. Presentation (routes, middleware)
    App\Providers\RouteServiceProvider::class,
];
```

### Deferred Providers

```php
class HeavyServiceProvider extends ServiceProvider implements DeferrableProvider
{
    public function provides(): array
    {
        return [HeavyService::class];
    }
}
```

---

## Graceful Shutdown Patterns (MANDATORY)

```php
// For queue workers
// config/queue.php
'connections' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => env('REDIS_QUEUE', 'default'),
        'retry_after' => 90,
        'block_for' => null,
    ],
],

// Custom worker with signal handling
class CustomWorker
{
    private bool $shouldStop = false;

    public function __construct()
    {
        pcntl_signal(SIGTERM, fn () => $this->shouldStop = true);
        pcntl_signal(SIGINT, fn () => $this->shouldStop = true);
    }

    public function run(): void
    {
        while (!$this->shouldStop) {
            pcntl_signal_dispatch();
            $this->processNext();
        }

        $this->cleanup();
    }
}
```

**Detection:**
```bash
grep -rn "pcntl_signal\|SIGTERM\|SIGINT" app/ --include="*.php"
grep -rn "retry_after" config/queue.php
```

---

## Health Checks (MANDATORY)

```php
// routes/api.php
Route::get('/health', [HealthController::class, 'liveness']);
Route::get('/ready', [HealthController::class, 'readiness']);

// app/Http/Controllers/HealthController.php
class HealthController extends Controller
{
    public function liveness(): JsonResponse
    {
        return response()->json(['status' => 'ok']);
    }

    public function readiness(): JsonResponse
    {
        $checks = [
            'database' => $this->checkDatabase(),
            'redis' => $this->checkRedis(),
            'queue' => $this->checkQueue(),
        ];

        $healthy = !in_array(false, $checks, true);

        return response()->json([
            'status' => $healthy ? 'ready' : 'not_ready',
            'checks' => $checks,
        ], $healthy ? 200 : 503);
    }

    private function checkDatabase(): bool
    {
        try {
            DB::connection()->getPdo();
            return true;
        } catch (\Throwable) {
            return false;
        }
    }

    private function checkRedis(): bool
    {
        try {
            Cache::store('redis')->get('health_check');
            return true;
        } catch (\Throwable) {
            return false;
        }
    }

    private function checkQueue(): bool
    {
        try {
            Queue::size('default');
            return true;
        } catch (\Throwable) {
            return false;
        }
    }
}
```

**Detection:**
```bash
grep -rn "/health\|/ready" routes/ --include="*.php"
```

---

## Connection Management (MANDATORY)

```php
// config/database.php
'pgsql' => [
    'driver' => 'pgsql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '5432'),
    'database' => env('DB_DATABASE', 'app'),
    'username' => env('DB_USERNAME', 'app'),
    'password' => env('DB_PASSWORD', ''),
    'charset' => 'utf8',
    'prefix' => '',
    'search_path' => 'public',
    'sslmode' => env('DB_SSLMODE', 'prefer'),
    // Pool configuration
    'options' => [
        PDO::ATTR_PERSISTENT => false,
        PDO::ATTR_TIMEOUT => 5,
    ],
],

// config/database.php (Redis)
'redis' => [
    'client' => env('REDIS_CLIENT', 'predis'),
    'default' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD'),
        'port' => env('REDIS_PORT', 6379),
        'database' => env('REDIS_DB', 0),
        'read_timeout' => 5,
        'timeout' => 5,
    ],
],
```

---

## Authentication Integration (MANDATORY)

```php
// Using Laravel Sanctum
// config/auth.php
'guards' => [
    'api' => [
        'driver' => 'sanctum',
        'provider' => 'users',
    ],
],

// Middleware
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('transactions', TransactionController::class);
});

// Policies (MANDATORY for authorization)
class TransactionPolicy
{
    public function view(User $user, Transaction $transaction): bool
    {
        return $user->tenant_id === $transaction->tenant_id;
    }

    public function create(User $user): bool
    {
        return $user->hasPermission('transactions.create');
    }
}

// Gates for simple checks
Gate::define('admin', fn (User $user) => $user->role === 'admin');
```

**Detection:**
```bash
grep -rn "auth:sanctum\|auth:api\|->authorize" app/ routes/ --include="*.php"
grep -rn "class.*Policy" app/Policies/ --include="*.php"
```

---

## Secret Redaction Patterns (MANDATORY)

```php
// config/logging.php - Redact sensitive fields
'processors' => [
    App\Logging\SensitiveDataProcessor::class,
],

// app/Logging/SensitiveDataProcessor.php
class SensitiveDataProcessor
{
    private const SENSITIVE_KEYS = [
        'password', 'token', 'secret', 'authorization',
        'api_key', 'credit_card', 'ssn', 'cpf',
    ];

    public function __invoke(LogRecord $record): LogRecord
    {
        $context = $record->context;
        foreach (self::SENSITIVE_KEYS as $key) {
            if (isset($context[$key])) {
                $context[$key] = '***REDACTED***';
            }
        }
        return $record->with(context: $context);
    }
}

// ⛔ FORBIDDEN: Logging sensitive data
Log::info('User login', ['password' => $password]); // FORBIDDEN
Log::info('API call', ['token' => $token]); // FORBIDDEN

// ✅ CORRECT
Log::info('User login', ['user_id' => $user->id]);
```

**Detection:**
```bash
grep -rn "Log::\|logger()->" app/ --include="*.php" | grep -i "password\|token\|secret\|key"
```

---

## SQL Safety (MANDATORY)

```php
// ⛔ FORBIDDEN - Raw SQL without parameterization
DB::select("SELECT * FROM users WHERE email = '$email'"); // SQL INJECTION

// ✅ CORRECT - Parameterized queries
DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// ✅ CORRECT - Eloquent (safe by default)
User::where('email', $email)->first();

// ✅ CORRECT - Query Builder with bindings
DB::table('users')
    ->where('email', $email)
    ->where('status', 'active')
    ->first();

// ⚠️ CAREFUL - Raw expressions need manual escaping
DB::table('users')
    ->whereRaw('LOWER(email) = ?', [strtolower($email)]) // OK - parameterized
    ->first();
```

**Detection:**
```bash
grep -rn "DB::select\|DB::statement\|DB::unprepared\|->whereRaw\|->selectRaw" app/ --include="*.php"
```

---

## HTTP Security Headers (MANDATORY)

```php
// app/Http/Middleware/SecurityHeaders.php
class SecurityHeaders
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');

        return $response;
    }
}

// Register in bootstrap/app.php
->withMiddleware(function (Middleware $middleware) {
    $middleware->append(SecurityHeaders::class);
})
```

**Detection:**
```bash
grep -rn "X-Content-Type-Options\|X-Frame-Options" app/Http/Middleware/ --include="*.php"
```

---

## Data Transformation (MANDATORY)

```php
// ✅ CORRECT - API Resources for output transformation
class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'userId' => $this->user_id,          // camelCase for JSON
            'amount' => (string) $this->amount,
            'currency' => $this->currency,
            'status' => $this->status,
            'createdAt' => $this->created_at->toIso8601String(),
            'updatedAt' => $this->updated_at->toIso8601String(),
            'user' => new UserResource($this->whenLoaded('user')),
            'items' => TransactionItemResource::collection($this->whenLoaded('items')),
        ];
    }
}

// ✅ DTOs for input
final readonly class CreateTransactionDTO
{
    public function __construct(
        public string $userId,
        public float $amount,
        public string $currency,
        public array $metadata = [],
    ) {}

    public static function fromRequest(StoreTransactionRequest $request): self
    {
        return new self(
            userId: $request->validated('user_id'),
            amount: (float) $request->validated('amount'),
            currency: $request->validated('currency'),
            metadata: $request->validated('metadata', []),
        );
    }
}
```

---

## Error Codes Convention (MANDATORY)

Pattern: `{SERVICE}-{NUMBER}`

| Service | Prefix | Example |
|---------|--------|---------|
| Auth | `AUTH` | `AUTH-001: Invalid credentials` |
| Payment | `PAY` | `PAY-001: Insufficient balance` |
| Transaction | `TXN` | `TXN-001: Transaction not found` |
| User | `USR` | `USR-001: User not found` |
| Tenant | `TNT` | `TNT-001: Tenant not found` |

```php
enum ErrorCode: string
{
    case AUTH_INVALID_CREDENTIALS = 'AUTH-001';
    case AUTH_TOKEN_EXPIRED = 'AUTH-002';
    case PAY_INSUFFICIENT_BALANCE = 'PAY-001';
    case TXN_NOT_FOUND = 'TXN-001';
}
```

---

## Error Handling

### Exception Hierarchy

```php
// Base domain exception
abstract class DomainException extends \RuntimeException
{
    public function __construct(
        string $message,
        public readonly ErrorCode $errorCode,
        public readonly array $context = [],
        int $code = 0,
        ?\Throwable $previous = null,
    ) {
        parent::__construct($message, $code, $previous);
    }
}

// Specific exceptions
class EntityNotFoundException extends DomainException
{
    public static function forTransaction(string $id): self
    {
        return new self(
            message: "Transaction not found: {$id}",
            errorCode: ErrorCode::TXN_NOT_FOUND,
            context: ['transaction_id' => $id],
            code: 404,
        );
    }
}

class InsufficientBalanceException extends DomainException
{
    public static function forAmount(float $requested, float $available): self
    {
        return new self(
            message: "Insufficient balance: requested {$requested}, available {$available}",
            errorCode: ErrorCode::PAY_INSUFFICIENT_BALANCE,
            context: ['requested' => $requested, 'available' => $available],
            code: 422,
        );
    }
}
```

### Exception Handler

```php
// bootstrap/app.php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (DomainException $e, Request $request) {
        if ($request->expectsJson()) {
            return response()->json([
                'error' => [
                    'code' => $e->errorCode->value,
                    'message' => $e->getMessage(),
                ],
            ], $e->getCode() ?: 500);
        }
    });
})
```

---

## Exit/Fatal Location Rules (MANDATORY)

<forbidden>
- `die()` in any application code
- `exit()` in any application code
- `dd()` in committed code (dev-only, never commit)
- `dump()` in committed code
- `var_dump()` anywhere
- `print_r()` for debugging
- `echo` for logging
</forbidden>

**Detection:**
```bash
grep -rn "die(\|exit(\|dd(\|dump(\|var_dump(\|print_r(" app/ --include="*.php"
```

---

## Function Design (MANDATORY)

- **Max 4 parameters** per function/method (use DTOs for more)
- **Single responsibility** — one function does one thing
- **Early returns** — reduce nesting
- **Max 30 lines** per function (excluding docblocks)

```php
// ❌ WRONG - Too many parameters
public function createTransaction(
    string $userId, float $amount, string $currency,
    string $description, array $metadata, string $tenantId
): Transaction { ... }

// ✅ CORRECT - Use DTO
public function createTransaction(CreateTransactionDTO $dto): Transaction { ... }

// ✅ CORRECT - Early returns
public function processPayment(Payment $payment): PaymentResult
{
    if ($payment->isExpired()) {
        throw PaymentExpiredException::forPayment($payment->id);
    }

    if ($payment->amount <= 0) {
        throw InvalidAmountException::forAmount($payment->amount);
    }

    return $this->gateway->charge($payment);
}
```

---

## File Organization (MANDATORY)

- **Max 200-300 lines** per file
- **One class per file** (PSR-4)
- **Group by domain**, not by type

**Detection:**
```bash
find app/ -name "*.php" -exec wc -l {} + | sort -rn | head -20
```

---

## JSON Naming Convention (camelCase) (MANDATORY)

API responses MUST use camelCase for JSON field names:

```php
// ✅ CORRECT - API Resource with camelCase
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'firstName' => $this->first_name,    // camelCase
            'lastName' => $this->last_name,       // camelCase
            'emailAddress' => $this->email,       // camelCase
            'createdAt' => $this->created_at->toIso8601String(),
        ];
    }
}
```

---

## Pagination Patterns

### Offset Pagination

```php
// Controller
public function index(Request $request): AnonymousResourceCollection
{
    $perPage = min((int) $request->query('per_page', 15), 100);

    $transactions = Transaction::query()
        ->forTenant($request->user()->tenant_id)
        ->orderByDesc('created_at')
        ->paginate($perPage);

    return TransactionResource::collection($transactions);
}
```

### Cursor Pagination (for large datasets)

```php
public function index(Request $request): AnonymousResourceCollection
{
    $transactions = Transaction::query()
        ->forTenant($request->user()->tenant_id)
        ->orderByDesc('created_at')
        ->cursorPaginate(15);

    return TransactionResource::collection($transactions);
}
```

---

## HTTP Status Code Consistency (MANDATORY)

| Operation | Status Code | Response |
|-----------|-------------|----------|
| GET (single) | 200 | Resource |
| GET (list) | 200 | Paginated collection |
| POST (create) | 201 | Created resource |
| PUT/PATCH (update) | 200 | Updated resource |
| DELETE | 204 | No content |
| Validation error | 422 | Error details |
| Not found | 404 | Error message |
| Unauthorized | 401 | Error message |
| Forbidden | 403 | Error message |

```php
// ✅ CORRECT
public function store(StoreTransactionRequest $request): JsonResponse
{
    $transaction = $this->service->create(
        CreateTransactionDTO::fromRequest($request)
    );

    return TransactionResource::make($transaction)
        ->response()
        ->setStatusCode(201); // 201 for creation
}

public function destroy(Transaction $transaction): JsonResponse
{
    $this->authorize('delete', $transaction);
    $transaction->delete();

    return response()->json(null, 204); // 204 for deletion
}
```

---

## OpenAPI Documentation (MANDATORY)

Use **L5-Swagger** or **Scramble** for auto-documentation.

```php
// With Scramble (recommended for Laravel 11+)
// composer require dedoc/scramble

// config/scramble.php
return [
    'api_path' => 'api',
    'api_domain' => null,
];

// Or with L5-Swagger annotations
/**
 * @OA\Post(
 *     path="/api/transactions",
 *     summary="Create a transaction",
 *     tags={"Transactions"},
 *     @OA\RequestBody(required=true, @OA\JsonContent(ref="#/components/schemas/CreateTransaction")),
 *     @OA\Response(response=201, description="Created", @OA\JsonContent(ref="#/components/schemas/Transaction")),
 *     @OA\Response(response=422, description="Validation error"),
 *     security={{"sanctum": {}}}
 * )
 */
```

---

## Controller Constructor Pattern (MANDATORY)

```php
// ✅ CORRECT - DI via constructor
class TransactionController extends Controller
{
    public function __construct(
        private readonly TransactionService $service,
        private readonly TracerInterface $tracer,
    ) {}

    public function store(StoreTransactionRequest $request): JsonResponse
    {
        $span = $this->tracer->spanBuilder('app.controller.store_transaction')
            ->startSpan();
        $scope = $span->activate();

        try {
            $dto = CreateTransactionDTO::fromRequest($request);
            $transaction = $this->service->create($dto);

            $span->setStatus(StatusCode::STATUS_OK);

            return TransactionResource::make($transaction)
                ->response()
                ->setStatusCode(201);
        } catch (\Throwable $e) {
            $span->recordException($e);
            $span->setStatus(StatusCode::STATUS_ERROR, $e->getMessage());
            throw $e;
        } finally {
            $scope->detach();
            $span->end();
        }
    }
}
```

---

## Input Validation (MANDATORY)

```php
// ✅ CORRECT - Form Request with typed rules
class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Transaction::class);
    }

    public function rules(): array
    {
        return [
            'user_id' => ['required', 'uuid', 'exists:users,id'],
            'amount' => ['required', 'numeric', 'min:0.01', 'max:999999.99'],
            'currency' => ['required', 'string', 'size:3', Rule::in(['BRL', 'USD', 'EUR'])],
            'description' => ['nullable', 'string', 'max:255'],
            'metadata' => ['nullable', 'array'],
            'metadata.*' => ['string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'amount.min' => 'Transaction amount must be at least 0.01',
            'currency.in' => 'Currency must be BRL, USD, or EUR',
        ];
    }
}
```

**Detection:**
```bash
find app/Http/Requests/ -name "*.php" | wc -l
grep -rn "extends FormRequest" app/ --include="*.php"
```

---

## Testing

### Pest + PHPUnit Patterns

```php
// tests/Unit/Services/TransactionServiceTest.php
use App\Services\TransactionService;

describe('TransactionService', function () {
    beforeEach(function () {
        $this->repository = Mockery::mock(TransactionRepositoryInterface::class);
        $this->tracer = Mockery::mock(TracerInterface::class);
        $this->service = new TransactionService($this->repository, $this->tracer);
    });

    it('creates a transaction successfully', function () {
        $dto = new CreateTransactionDTO(
            userId: 'user-123',
            amount: 100.50,
            currency: 'BRL',
        );

        $this->repository
            ->shouldReceive('create')
            ->once()
            ->andReturn(Transaction::factory()->make(['id' => 'txn-1']));

        $this->tracer->shouldReceive('spanBuilder')->andReturnSelf();
        $this->tracer->shouldReceive('startSpan')->andReturn(Mockery::mock(SpanInterface::class));

        $result = $this->service->create($dto);

        expect($result)->toBeInstanceOf(Transaction::class)
            ->and($result->id)->toBe('txn-1');
    });

    it('throws exception for negative amount', function () {
        $dto = new CreateTransactionDTO(
            userId: 'user-123',
            amount: -10,
            currency: 'BRL',
        );

        $this->service->create($dto);
    })->throws(InvalidAmountException::class);
});

// Data providers with Pest datasets
dataset('currencies', ['BRL', 'USD', 'EUR']);

it('accepts valid currencies', function (string $currency) {
    $dto = new CreateTransactionDTO('user-1', 100, $currency);
    expect($dto->currency)->toBe($currency);
})->with('currencies');
```

### Feature Tests

```php
// tests/Feature/TransactionApiTest.php
use function Pest\Laravel\{postJson, getJson, actingAs};

describe('Transaction API', function () {
    beforeEach(function () {
        $this->user = User::factory()->create();
    });

    it('creates a transaction', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/transactions', [
                'user_id' => $this->user->id,
                'amount' => 150.00,
                'currency' => 'BRL',
            ])
            ->assertStatus(201)
            ->assertJsonStructure([
                'data' => ['id', 'userId', 'amount', 'currency', 'createdAt'],
            ]);

        $this->assertDatabaseHas('transactions', [
            'user_id' => $this->user->id,
            'amount' => 150.00,
        ]);
    });

    it('validates required fields', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/transactions', [])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['user_id', 'amount', 'currency']);
    });
});
```

### Coverage

```bash
# Run with coverage
php artisan test --coverage --min=85

# Or with Pest directly
./vendor/bin/pest --coverage --min=85

# HTML report
./vendor/bin/pest --coverage-html=coverage
```

**⛔ HARD GATE:** Minimum 85% code coverage.

---

## Logging

### Structured JSON Logging (MANDATORY)

```php
// config/logging.php
'channels' => [
    'structured' => [
        'driver' => 'monolog',
        'handler' => StreamHandler::class,
        'with' => [
            'stream' => 'php://stdout',
        ],
        'formatter' => JsonFormatter::class,
        'processor_handler' => true,
    ],
],

// Usage
Log::channel('structured')->info('Transaction created', [
    'transaction_id' => $transaction->id,
    'user_id' => $transaction->user_id,
    'amount' => $transaction->amount,
    'trace_id' => $span->getContext()->getTraceId(),
]);
```

<forbidden>
- `echo` for logging
- `var_dump()` anywhere
- `print_r()` for debugging
- `dd()` in committed code
- `dump()` in committed code
- `error_log()` without structured format
</forbidden>

**Detection:**
```bash
grep -rn "echo \|var_dump\|print_r\|dd(\|dump(" app/ --include="*.php"
```

---

## Linting

### PHP CS Fixer Configuration

```php
// .php-cs-fixer.dist.php
<?php

$finder = PhpCsFixer\Finder::create()
    ->in([
        __DIR__ . '/app',
        __DIR__ . '/config',
        __DIR__ . '/database',
        __DIR__ . '/routes',
        __DIR__ . '/tests',
    ])
    ->name('*.php');

return (new PhpCsFixer\Config())
    ->setRules([
        '@PSR12' => true,
        'strict_types' => true,
        'declare_strict_types' => true,
        'array_syntax' => ['syntax' => 'short'],
        'no_unused_imports' => true,
        'ordered_imports' => ['sort_algorithm' => 'alpha'],
        'single_quote' => true,
        'trailing_comma_in_multiline' => true,
        'blank_line_before_statement' => ['statements' => ['return']],
    ])
    ->setFinder($finder)
    ->setRiskyAllowed(true);
```

### PHPStan Configuration

```neon
# phpstan.neon
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    level: 8
    paths:
        - app
    excludePaths:
        - app/Console/Kernel.php
    reportUnmatchedIgnoredErrors: false
```

**Detection:**
```bash
test -f .php-cs-fixer.dist.php && echo "OK" || echo "MISSING .php-cs-fixer.dist.php"
test -f phpstan.neon && echo "OK" || echo "MISSING phpstan.neon"
grep "level:" phpstan.neon
```

---

## Production Config Validation (MANDATORY)

```bash
# MANDATORY before deployment
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Validate no env() calls outside config
php artisan config:clear
grep -rn "env(" app/ --include="*.php" | grep -v "config/" && echo "FAIL: env() found outside config" || echo "OK"
```

---

## Container Security (CONDITIONAL)

**⚠️ CONDITIONAL:** Only if Dockerfile exists in project.

```dockerfile
# Multi-stage build for PHP/Laravel
FROM composer:2 AS deps
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --prefer-dist

FROM php:8.3-fpm-alpine AS production

# Install extensions
RUN docker-php-ext-install pdo pdo_pgsql opcache

# Security: non-root user
RUN addgroup -g 1000 app && adduser -u 1000 -G app -s /bin/sh -D app

WORKDIR /app
COPY --from=deps /app/vendor ./vendor
COPY . .

RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

USER app

EXPOSE 9000

CMD ["php-fpm"]
```

**Detection:**
```bash
grep -n "USER\|nonroot\|adduser" Dockerfile
grep -n "FROM.*alpine\|FROM.*slim" Dockerfile
```

---

## Architecture Patterns

### Hexagonal/Lerian Pattern (MANDATORY)

```
app/
├── Application/           # Use cases, commands, queries
│   ├── Command/          # Write operations
│   ├── Query/            # Read operations
│   ├── DTO/              # Data Transfer Objects
│   └── Service/          # Application services (orchestration)
├── Domain/               # Business logic (framework-agnostic)
│   ├── Entity/           # Domain entities (Always-Valid)
│   ├── ValueObject/      # Value objects (immutable)
│   ├── Repository/       # Repository interfaces (ports)
│   ├── Event/            # Domain events
│   ├── Exception/        # Domain exceptions
│   └── Service/          # Domain services (pure logic)
├── Infrastructure/       # External adapters
│   ├── Persistence/      # Database implementations
│   │   └── Eloquent/     # Eloquent repositories
│   ├── Messaging/        # Queue implementations
│   ├── Http/             # HTTP client adapters
│   ├── Cache/            # Cache implementations
│   └── Observability/    # Tracing, logging config
└── Presentation/         # UI layer
    ├── Http/
    │   ├── Controller/
    │   ├── Middleware/
    │   ├── Request/       # Form Requests
    │   └── Resource/      # API Resources
    └── Console/           # Artisan commands
```

---

## Directory Structure

Standard Laravel with hexagonal overlay:

```
project/
├── app/
│   ├── Application/       # Use cases
│   ├── Domain/            # Business logic
│   ├── Infrastructure/    # Adapters
│   ├── Presentation/      # Controllers, Resources
│   ├── Models/            # Eloquent models (Laravel convention)
│   ├── Providers/         # Service Providers
│   └── Logging/           # Custom log processors
├── bootstrap/
│   ├── app.php
│   └── providers.php
├── config/
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   └── web.php
├── tests/
│   ├── Unit/
│   ├── Feature/
│   ├── Integration/
│   └── Chaos/
├── composer.json
├── phpstan.neon
├── .php-cs-fixer.dist.php
└── Makefile
```

---

## N+1 Query Detection (MANDATORY)

```php
// AppServiceProvider.php - MANDATORY
public function boot(): void
{
    // Prevent lazy loading in non-production
    Model::preventLazyLoading(!app()->isProduction());

    // Log lazy loading violations in production
    Model::handleLazyLoadingViolationUsing(function (Model $model, string $relation) {
        Log::warning('Lazy loading detected', [
            'model' => get_class($model),
            'relation' => $relation,
        ]);
    });
}

// ✅ CORRECT - Eager loading
$transactions = Transaction::with(['user', 'items'])->paginate(15);

// ❌ WRONG - N+1 query
$transactions = Transaction::all();
foreach ($transactions as $transaction) {
    echo $transaction->user->name; // N+1!
}
```

**Detection:**
```bash
grep -rn "preventLazyLoading\|handleLazyLoadingViolation" app/Providers/ --include="*.php"
grep -rn "::with\[" app/ --include="*.php"
```

---

## Performance Patterns (MANDATORY)

### Chunking for Large Datasets

```php
// ✅ Process large datasets without memory issues
Transaction::where('status', 'pending')
    ->chunkById(1000, function (Collection $transactions) {
        foreach ($transactions as $transaction) {
            $this->process($transaction);
        }
    });

// ✅ Lazy collections for streaming
Transaction::where('status', 'pending')
    ->lazy()
    ->each(fn (Transaction $txn) => $this->process($txn));
```

### Caching

```php
// ✅ Cache expensive queries
$stats = Cache::remember(
    "tenant:{$tenantId}:stats",
    now()->addMinutes(15),
    fn () => Transaction::forTenant($tenantId)
        ->selectRaw('COUNT(*) as total, SUM(amount) as sum')
        ->first()
);
```

### Queue for Heavy Operations

```php
// ✅ Offload heavy operations to queue
dispatch(new ProcessTransactionJob($transaction))
    ->onQueue('transactions')
    ->delay(now()->addSeconds(5));
```

**Detection:**
```bash
grep -rn "->chunk\|->chunkById\|->lazy\|Cache::remember" app/ --include="*.php"
```

---

## RabbitMQ Worker Pattern

```php
// Using php-amqplib with Laravel
class RabbitMQConsumer
{
    private AMQPStreamConnection $connection;
    private AMQPChannel $channel;

    public function __construct(
        private readonly TransactionService $service,
        private readonly LoggerInterface $logger,
        private readonly TracerInterface $tracer,
    ) {}

    public function consume(string $queueName): void
    {
        $this->connect();

        $this->channel->basic_qos(0, 10, false);
        $this->channel->basic_consume(
            queue: $queueName,
            callback: fn (AMQPMessage $msg) => $this->handleMessage($msg),
        );

        while ($this->channel->is_consuming()) {
            $this->channel->wait();
        }
    }

    private function handleMessage(AMQPMessage $message): void
    {
        $span = $this->tracer->spanBuilder('app.queue.process_message')
            ->startSpan();
        $scope = $span->activate();

        try {
            $data = json_decode($message->getBody(), true, 512, JSON_THROW_ON_ERROR);
            $this->service->process($data);
            $message->ack();
            $span->setStatus(StatusCode::STATUS_OK);
        } catch (\Throwable $e) {
            $this->logger->error('Message processing failed', [
                'error' => $e->getMessage(),
                'queue' => $message->getRoutingKey(),
            ]);
            $span->recordException($e);
            $span->setStatus(StatusCode::STATUS_ERROR);
            $message->nack(requeue: true);
        } finally {
            $scope->detach();
            $span->end();
        }
    }

    private function connect(): void
    {
        $this->connection = new AMQPStreamConnection(
            config('rabbitmq.host'),
            config('rabbitmq.port'),
            config('rabbitmq.user'),
            config('rabbitmq.password'),
            config('rabbitmq.vhost'),
        );
        $this->channel = $this->connection->channel();
    }
}
```

---

## RabbitMQ Reconnection Strategy (MANDATORY)

```php
class ResilientConsumer
{
    private const MAX_RECONNECT_ATTEMPTS = 10;
    private const BASE_DELAY_MS = 1000;
    private const MAX_DELAY_MS = 30000;

    public function consumeWithReconnection(string $queue): void
    {
        $attempt = 0;

        while (true) {
            try {
                $this->connect();
                $this->consume($queue);
                $attempt = 0; // Reset on successful consumption
            } catch (AMQPConnectionClosedException | AMQPIOException $e) {
                $attempt++;

                if ($attempt > self::MAX_RECONNECT_ATTEMPTS) {
                    $this->logger->critical('Max reconnection attempts reached', [
                        'queue' => $queue,
                        'attempts' => $attempt,
                    ]);
                    throw $e;
                }

                $delay = $this->calculateBackoff($attempt);
                $this->logger->warning('RabbitMQ connection lost, reconnecting', [
                    'attempt' => $attempt,
                    'delay_ms' => $delay,
                ]);

                usleep($delay * 1000);
            }
        }
    }

    private function calculateBackoff(int $attempt): int
    {
        $delay = min(
            self::BASE_DELAY_MS * (2 ** ($attempt - 1)),
            self::MAX_DELAY_MS
        );

        // Add jitter (±25%)
        $jitter = $delay * 0.25;

        return (int) ($delay + random_int((int) -$jitter, (int) $jitter));
    }
}
```

---

## Always-Valid Domain Model (MANDATORY)

```php
// ✅ Constructor validation - entity is ALWAYS valid
final class Money
{
    private function __construct(
        public readonly float $amount,
        public readonly string $currency,
    ) {}

    public static function create(float $amount, string $currency): self
    {
        if ($amount < 0) {
            throw new InvalidArgumentException('Amount cannot be negative');
        }

        if (!in_array($currency, ['BRL', 'USD', 'EUR'], true)) {
            throw new InvalidArgumentException("Invalid currency: {$currency}");
        }

        return new self($amount, $currency);
    }

    public function add(Money $other): self
    {
        if ($this->currency !== $other->currency) {
            throw new CurrencyMismatchException($this->currency, $other->currency);
        }

        return new self($this->amount + $other->amount, $this->currency);
    }
}

// ✅ Domain entity with invariant protection
final class Transaction
{
    private function __construct(
        public readonly string $id,
        public readonly string $tenantId,
        public readonly string $userId,
        public readonly Money $amount,
        private TransactionStatus $status,
    ) {}

    public static function create(
        string $tenantId,
        string $userId,
        Money $amount,
    ): self {
        if ($amount->amount <= 0) {
            throw new InvalidAmountException('Transaction amount must be positive');
        }

        return new self(
            id: (string) Str::uuid(),
            tenantId: $tenantId,
            userId: $userId,
            amount: $amount,
            status: TransactionStatus::PENDING,
        );
    }

    public function approve(): void
    {
        if ($this->status !== TransactionStatus::PENDING) {
            throw new InvalidTransitionException("Cannot approve {$this->status->value} transaction");
        }

        $this->status = TransactionStatus::APPROVED;
    }
}
```

---

## Idempotency Patterns (MANDATORY for Transaction APIs)

```php
// Middleware for idempotency
class IdempotencyMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!in_array($request->method(), ['POST', 'PUT', 'PATCH'])) {
            return $next($request);
        }

        $key = $request->header('Idempotency-Key');
        if (!$key) {
            return $next($request);
        }

        $cacheKey = "idempotency:{$key}";

        // Check for existing response
        $cached = Cache::get($cacheKey);
        if ($cached) {
            return response()->json(
                $cached['body'],
                $cached['status'],
                ['X-Idempotent-Replayed' => 'true']
            );
        }

        // Acquire lock to prevent concurrent execution
        $lock = Cache::lock("lock:{$cacheKey}", 30);

        if (!$lock->get()) {
            return response()->json(
                ['error' => 'Concurrent request with same idempotency key'],
                409
            );
        }

        try {
            $response = $next($request);

            // Cache successful responses for 24 hours
            if ($response->isSuccessful()) {
                Cache::put($cacheKey, [
                    'body' => json_decode($response->getContent(), true),
                    'status' => $response->getStatusCode(),
                ], now()->addHours(24));
            }

            return $response;
        } finally {
            $lock->release();
        }
    }
}
```

---

## Multi-Tenant Patterns (CONDITIONAL)

**⚠️ CONDITIONAL:** Only when multi-tenancy is required.

```php
// Using stancl/tenancy or custom implementation
// Tenant middleware
class TenantMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $tenantId = $request->header('X-Tenant-ID')
            ?? $request->user()?->tenant_id;

        if (!$tenantId) {
            return response()->json(['error' => 'Tenant not identified'], 403);
        }

        app()->instance('tenant_id', $tenantId);

        // Set global scope on all tenant models
        TenantScope::setTenantId($tenantId);

        return $next($request);
    }
}

// Global scope for tenant isolation
class TenantScope implements Scope
{
    private static ?string $tenantId = null;

    public static function setTenantId(string $id): void
    {
        self::$tenantId = $id;
    }

    public function apply(Builder $builder, Model $model): void
    {
        if (self::$tenantId) {
            $builder->where('tenant_id', self::$tenantId);
        }
    }
}

// Trait for tenant models
trait BelongsToTenant
{
    protected static function booted(): void
    {
        static::addGlobalScope(new TenantScope());

        static::creating(function (Model $model) {
            if (!$model->tenant_id) {
                $model->tenant_id = app('tenant_id');
            }
        });
    }
}
```

---

## Rate Limiting (MANDATORY)

```php
// app/Providers/AppServiceProvider.php
public function boot(): void
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)
            ->by($request->user()?->id ?: $request->ip())
            ->response(function (Request $request, array $headers) {
                return response()->json([
                    'error' => 'Too many requests',
                    'retry_after' => $headers['Retry-After'],
                ], 429, $headers);
            });
    });

    RateLimiter::for('auth', function (Request $request) {
        return Limit::perMinute(5)->by($request->ip());
    });
}

// routes/api.php
Route::middleware(['throttle:api'])->group(function () {
    Route::apiResource('transactions', TransactionController::class);
});

Route::middleware(['throttle:auth'])->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
});
```

---

## CORS Configuration (MANDATORY)

```php
// config/cors.php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', '')),
    'allowed_origins_patterns' => [],
    'allowed_headers' => [
        'Content-Type', 'Authorization', 'X-Requested-With',
        'X-Tenant-ID', 'Idempotency-Key', 'Accept',
    ],
    'exposed_headers' => ['X-Idempotent-Replayed', 'Retry-After'],
    'max_age' => 3600,
    'supports_credentials' => true,
];
```

**⛔ PRODUCTION VALIDATION:**
- `allowed_origins` MUST NOT contain `*` in production
- `allowed_origins` MUST NOT be empty in production

**Detection:**
```bash
grep -n "allowed_origins" config/cors.php
```

---

## Checklist

Self-verification before marking implementation complete:

```text
1. [ ] declare(strict_types=1) in all files?
2. [ ] No env() calls outside config/ files?
3. [ ] No die()/exit()/dd()/dump() in committed code?
4. [ ] No echo/var_dump/print_r for logging?
5. [ ] All models have $fillable or $guarded?
6. [ ] preventLazyLoading() enabled?
7. [ ] Form Requests for all input validation?
8. [ ] API Resources for all JSON output?
9. [ ] camelCase in JSON responses?
10. [ ] 201 for POST creation, 204 for DELETE?
11. [ ] Health check endpoints (/health, /ready)?
12. [ ] OpenTelemetry spans on service methods?
13. [ ] Structured JSON logging (no echo)?
14. [ ] PHPStan Level 8+ passes?
15. [ ] PHP CS Fixer passes?
16. [ ] Pest tests with 85%+ coverage?
17. [ ] composer.lock committed?
18. [ ] roave/security-advisories installed?
19. [ ] Dockerfile runs as non-root?
20. [ ] Exception hierarchy (no generic exceptions)?
```
