# SRE Standards

> **⚠️ MAINTENANCE:** This file is indexed in `dev-team/skills/shared-patterns/standards-coverage-table.md`.
> When adding/removing `## ` sections, follow FOUR-FILE UPDATE RULE in CLAUDE.md: (1) edit standards file, (2) update TOC, (3) update standards-coverage-table.md, (4) update agent file.

This file defines the specific standards for Site Reliability Engineering and observability.

> **Reference**: Always consult `docs/PROJECT_RULES.md` for common project standards.

---

## Table of Contents

| # | Section | Description |
|---|---------|-------------|
| 1 | [Observability](#observability) | Logs, traces, APM tools |
| 2 | [Logging](#logging) | Structured JSON format, log levels |
| 3 | [Tracing](#tracing) | OpenTelemetry configuration |
| 4 | [OpenTelemetry with Laravel](#opentelemetry-with-laravel-mandatory-for-php) | PHP service integration |
| 5 | [Structured Logging with lib-common-js](#structured-logging-with-lib-common-js-mandatory-for-typescript) | TypeScript service integration |
| 6 | [Structured Logging with Monolog](#structured-logging-with-monolog-mandatory-for-php) | PHP service integration |
| 7 | [Health Checks](#health-checks) | Liveness and readiness probes |

**Meta-sections (not checked by agents):**
- [Checklist](#checklist) - Self-verification before deploying

---

## Observability

| Component | Primary | Alternatives |
|-----------|---------|--------------|
| Logs | Loki | ELK Stack, Splunk, CloudWatch Logs |
| Traces | Jaeger/Tempo | Zipkin, X-Ray, Honeycomb |
| APM | OpenTelemetry | DataDog APM, New Relic APM |

---

## Logging

### Structured Log Format

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "error",
  "logger": "api.handler",
  "message": "Failed to process request",
  "service": "api",
  "version": "1.2.3",
  "environment": "production",
  "trace_id": "abc123def456",
  "span_id": "789xyz",
  "request_id": "req-001",
  "user_id": "usr_456",
  "error": {
    "type": "ConnectionError",
    "message": "connection timeout after 30s",
    "stack": "..."
  },
  "context": {
    "method": "POST",
    "path": "/api/v1/users",
    "status": 500,
    "duration_ms": 30045
  }
}
```

### Log Levels

| Level | Usage | Examples |
|-------|-------|----------|
| **ERROR** | Failures requiring attention | Database connection failed, API error |
| **WARN** | Potential issues | Retry attempt, connection pool low |
| **INFO** | Normal operations | Request completed, user logged in |
| **DEBUG** | Detailed debugging | Query parameters, internal state |
| **TRACE** | Very detailed (rarely used) | Full request/response bodies |

### What to Log

```yaml
# DO log
- Request start/end with duration
- Error details with stack traces
- Authentication events (login, logout, failed attempts)
- Authorization failures
- External service calls (start, end, duration)
- Business events (order placed, payment processed)
- Configuration changes
- Deployment events

# DO not log
- Passwords or API keys
- Credit card numbers (full)
- Personal identifiable information (PII)
- Session tokens
- Internal security mechanisms
- Health check requests (too noisy)
```

### Log Aggregation (Loki)

```yaml
# loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    bee:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2024-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/cache
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

---

## Tracing

### OpenTelemetry Configuration

```go
// Go - OpenTelemetry setup
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/sdk/resource"
    "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
)

func initTracer(ctx context.Context) (*trace.TracerProvider, error) {
    exporter, err := otlptracegrpc.New(ctx,
        otlptracegrpc.WithEndpoint("otel-collector:4317"),
        otlptracegrpc.WithInsecure(),
    )
    if err != nil {
        return nil, err
    }

    res, err := resource.New(ctx,
        resource.WithAttributes(
            semconv.ServiceName("api"),
            semconv.ServiceVersion("1.0.0"),
            semconv.DeploymentEnvironment("production"),
        ),
    )
    if err != nil {
        return nil, err
    }

    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(res),
        trace.WithSampler(trace.TraceIDRatioBased(0.1)), // Sample 10%
    )

    otel.SetTracerProvider(tp)
    return tp, nil
}

// Usage
tracer := otel.Tracer("api")
ctx, span := tracer.Start(ctx, "processOrder")
defer span.End()

span.SetAttributes(
    attribute.String("order.id", orderID),
    attribute.Int("order.items", len(items)),
)
```

### Span Naming Conventions

```
# Format: <operation>.<entity>

# HTTP handlers
GET /api/users         -> http.request
POST /api/orders       -> http.request

# Database
SELECT users           -> db.query
INSERT orders          -> db.query

# External calls
Payment API call       -> http.client.payment
Email service call     -> http.client.email

# Internal operations
Process order          -> order.process
Validate input         -> input.validate
```

### Trace Context Propagation

```go
// Propagate trace context in HTTP headers
import (
    "go.opentelemetry.io/otel/propagation"
)

// Client - inject context
req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
otel.GetTextMapPropagator().Inject(ctx, propagation.HeaderCarrier(req.Header))

// Server - extract context
ctx := otel.GetTextMapPropagator().Extract(
    r.Context(),
    propagation.HeaderCarrier(r.Header),
)
```

---

## OpenTelemetry with Laravel (MANDATORY for PHP)

All PHP/Laravel services **MUST** integrate OpenTelemetry for distributed tracing. This ensures consistent observability patterns across all Lerian Studio services.

> **Reference**: See the opentelemetry-php and open-telemetry/opentelemetry-auto-laravel documentation for complete integration patterns.

### Required Packages

```bash
composer require open-telemetry/opentelemetry-auto-laravel
composer require open-telemetry/exporter-otlp
composer require open-telemetry/transport-grpc
```

### Telemetry Flow (MANDATORY)

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. BOOTSTRAP (bootstrap/app.php or AppServiceProvider)          │
│    SDK initialized via env vars (auto-instrumentation)          │
│    → Creates OpenTelemetry provider once at startup             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. MIDDLEWARE (app/Http/Kernel.php)                              │
│    OpenTelemetry auto-instrumentation injects trace context     │
│    into incoming requests automatically                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. any layer (controllers, services, repositories)              │
│    $tracer = \OpenTelemetry\API\Globals::tracerProvider()       │
│              ->getTracer('service-name');                       │
│    $span = $tracer->spanBuilder('operation')->startSpan();      │
│    $scope = $span->activate();                                  │
│    Log::info("Processing...");  ← Laravel Log with trace ctx   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. SERVER LIFECYCLE (managed by PHP-FPM / Octane / Horizon)     │
│    Laravel Telescope / Horizon for queue telemetry              │
│    → Handles graceful shutdown via PHP signal handling          │
└─────────────────────────────────────────────────────────────────┘
```

### 1. Bootstrap Initialization (MANDATORY)

```php
// config/opentelemetry.php or .env configuration
// Auto-instrumentation is configured via environment variables:
// OTEL_PHP_AUTOLOAD_ENABLED=true
// OTEL_SERVICE_NAME=service-name
// OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
```

### 2. Service/Controller Instrumentation (MANDATORY)

```php
// app/Services/OrderService.php
use OpenTelemetry\API\Globals;

class OrderService
{
    public function processOrder(string $orderId): Order
    {
        $tracer = Globals::tracerProvider()->getTracer('order-service');
        $span = $tracer->spanBuilder('order.process')->startSpan();
        $scope = $span->activate();

        try {
            Log::info('Processing order', ['order_id' => $orderId]);
            return $this->repository->findAndProcess($orderId);
        } catch (\Throwable $e) {
            $span->recordException($e);
            $span->setStatus(\OpenTelemetry\API\Trace\StatusCode::STATUS_ERROR, $e->getMessage());
            throw $e;
        } finally {
            $scope->detach();
            $span->end();
        }
    }
}
```

### 3. Error Handling with Spans (MANDATORY)

```php
// For technical errors (unexpected failures)
try {
    $result = $this->db->query($sql);
} catch (\Exception $e) {
    $span->recordException($e);
    $span->setStatus(\OpenTelemetry\API\Trace\StatusCode::STATUS_ERROR, 'Database error');
    Log::error('Database error', ['exception' => $e->getMessage()]);
    throw $e;
}

// For business errors (expected validation failures)
if (!$this->validator->isValid($data)) {
    $span->addEvent('validation.failed', ['reason' => 'Invalid input']);
    Log::warning('Validation error', ['data' => $data]);
    throw new ValidationException('Invalid input');
}
```

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `OTEL_SERVICE_NAME` | Service name in traces | `service-name` |
| `OTEL_SERVICE_VERSION` | Service version | `1.0.0` |
| `OTEL_DEPLOYMENT_ENVIRONMENT` | Environment | `production` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://otel-collector:4317` |
| `OTEL_PHP_AUTOLOAD_ENABLED` | Enable auto-instrumentation | `true` |

### Laravel OpenTelemetry Checklist

| Check | What to Verify | Status |
|-------|----------------|--------|
| Package Installed | `open-telemetry/opentelemetry-auto-laravel` in composer.json | Required |
| Env Variables | All OTEL_* variables configured | Required |
| Span Creation | Operations create spans for significant work | Required |
| Error Recording | Exceptions recorded on spans | Required |
| Scope Detachment | `$scope->detach()` in finally block | Required |
| Span End | `$span->end()` in finally block | Required |

### What not to Do

```php
// FORBIDDEN: Manual tracing without proper scope management
$span = $tracer->spanBuilder('op')->startSpan();
// Missing $scope = $span->activate() and $scope->detach()

// FORBIDDEN: Not ending spans
$span = $tracer->spanBuilder('op')->startSpan();
$result = doWork();
return $result;  // Span never ends - memory leak

// CORRECT: Always use try/finally for span lifecycle
$span = $tracer->spanBuilder('op')->startSpan();
$scope = $span->activate();
try {
    return doWork();
} finally {
    $scope->detach();
    $span->end();
}
```

### Standards Compliance Categories

When evaluating a codebase for Laravel telemetry compliance, check these categories:

| Category | Expected Pattern | Evidence Location |
|----------|------------------|-------------------|
| Package Installed | `open-telemetry/opentelemetry-auto-laravel` | `composer.json` |
| Env Config | `OTEL_*` variables present | `.env.example` |
| Span Creation | `spanBuilder()->startSpan()` | Services, repositories |
| Scope Management | `$span->activate()` with `$scope->detach()` | All span usages |
| Error Recording | `$span->recordException($e)` | Exception catch blocks |
| Span Termination | `$span->end()` in finally | All span usages |

---

## Structured Logging with lib-common-js (MANDATORY for TypeScript)

All TypeScript services **MUST** integrate structured logging using `@LerianStudio/lib-common-js`. This ensures consistent observability patterns across all Lerian Studio services.

> **Note**: lib-common-js currently provides logging infrastructure. Telemetry will be added in future versions.

### Required Dependencies

```json
{
  "dependencies": {
    "@LerianStudio/lib-common-js": "^1.0.0"
  }
}
```

### Required Imports

```typescript
import { initializeLogger, Logger } from '@LerianStudio/lib-common-js/logger';
import { loadConfigFromEnv } from '@LerianStudio/lib-common-js/config';
import { createLoggingMiddleware } from '@LerianStudio/lib-common-js/http';
```

### Logging Flow (MANDATORY)

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. BOOTSTRAP (config.ts)                                        │
│    const logger = initializeLogger()                            │
│    → Creates structured logger once at startup                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. ROUTER (routes.ts)                                           │
│    const logMid = createLoggingMiddleware(logger)               │
│    app.use(logMid)            ← Injects logger into request     │
│    ...routes...                                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. any layer (handlers, services, repositories)                 │
│    const logger = req.logger || parentLogger                    │
│    logger.info('Processing...', { entityId, requestId })        │
│    → Structured JSON logs with correlation IDs                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1. Bootstrap Initialization (MANDATORY)

```typescript
// bootstrap/config.ts
import { initializeLogger } from '@LerianStudio/lib-common-js/logger';
import { loadConfigFromEnv } from '@LerianStudio/lib-common-js/config';

export async function initServers(): Promise<Service> {
    // Load configuration from environment
    const config = loadConfigFromEnv<Config>();

    // Initialize logger
    const logger = initializeLogger({
        level: config.logLevel,
        serviceName: config.serviceName,
        serviceVersion: config.serviceVersion,
    });

    logger.info('Service starting', {
        service: config.serviceName,
        version: config.serviceVersion,
        environment: config.envName,
    });

    // Pass logger to router...
}
```

### 2. Router Middleware Setup (MANDATORY)

```typescript
// adapters/http/routes.ts
import { createLoggingMiddleware } from '@LerianStudio/lib-common-js/http';
import express from 'express';

export function createRouter(
    logger: Logger,
    handlers: Handlers
): express.Application {
    const app = express();

    // Create logging middleware - injects logger into request
    const logMid = createLoggingMiddleware(logger);
    app.use(logMid);
    app.use(express.json());

    // ... define routes ...

    return app;
}
```

### 3. Using Logger in Handlers/Services (MANDATORY)

```typescript
// handlers/user-handler.ts
async function createUser(req: Request, res: Response): Promise<void> {
    const logger = req.logger;
    const requestId = req.headers['x-request-id'] as string;

    logger.info('Creating user', {
        requestId,
        email: req.body.email,
    });

    try {
        const user = await userService.create(req.body, logger);
        logger.info('User created successfully', {
            requestId,
            userId: user.id,
        });
        res.status(201).json(user);
    } catch (error) {
        logger.error('Failed to create user', {
            requestId,
            error: error.message,
            stack: error.stack,
        });
        throw error;
    }
}
```

### Required Structured Log Format

All logs **MUST** be JSON formatted with these fields:

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "info",
  "message": "Processing request",
  "service": "api-service",
  "version": "1.2.3",
  "environment": "production",
  "requestId": "req-001",
  "context": {
    "method": "POST",
    "path": "/api/v1/users",
    "userId": "usr_456"
  }
}
```

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `LOG_LEVEL` | Logging level | `info` |
| `SERVICE_NAME` | Service identifier | `api-service` |
| `SERVICE_VERSION` | Service version | `1.0.0` |
| `ENV_NAME` | Environment name | `production` |

### lib-common-js Logging Checklist

| Check | What to Verify | Status |
|-------|----------------|--------|
| Logger Init | `initializeLogger()` called in bootstrap | Required |
| Middleware | `createLoggingMiddleware(logger)` configured | Required |
| Request Correlation | Logs include `requestId` from headers | Required |
| Structured Format | All logs are JSON formatted | Required |
| Error Logging | Errors include message, stack, and context | Required |
| No Sensitive Data | Passwords, tokens, PII not logged | Required |
| Log Levels | Appropriate levels used (info, warn, error) | Required |

### What not to Do

```typescript
// FORBIDDEN: Using console.log
console.log('Processing user'); // DON'T do this

// FORBIDDEN: Logging sensitive data
logger.info('User login', { password: user.password }); // never

// FORBIDDEN: Unstructured log messages
logger.info(`Processing user ${userId}`); // DON'T use string interpolation

// CORRECT: Always use lib-common-js structured logging
const logger = initializeLogger(config);
logger.info('Processing user', { userId, requestId }); // Structured fields
```

### Standards Compliance Categories (TypeScript Logging)

When evaluating a codebase for lib-common-js logging compliance, check these categories:

| Category | Expected Pattern | Evidence Location |
|----------|------------------|-------------------|
| Logger Init | `initializeLogger()` | `src/bootstrap/config.ts` |
| Middleware Setup | `createLoggingMiddleware(logger)` | `src/adapters/http/routes.ts` |
| Request Correlation | `requestId` in all logs | Handlers, services |
| JSON Format | Structured JSON output | All log statements |
| Error Logging | Error object with stack trace | Error handlers |
| No console.log | No direct console usage | Entire codebase |
| No Sensitive Data | Passwords, tokens excluded | All log statements |

---

## Structured Logging with Monolog (MANDATORY for PHP)

All PHP services **MUST** integrate structured logging using Monolog (included with Laravel). This ensures consistent observability patterns across all Lerian Studio services.

> **Reference**: See `dev-team/docs/standards/php.md` for complete PHP integration patterns.

### Required Dependencies

```json
{
  "require": {
    "monolog/monolog": "^3.0"
  }
}
```

> **Note**: Laravel includes Monolog out of the box via `illuminate/log`.

### Logging Flow (MANDATORY)

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. BOOTSTRAP (config/logging.php)                                │
│    'channels' => ['stack' => ['driver' => 'stack', ...]]        │
│    → Configures structured JSON logging at startup               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. MIDDLEWARE (app/Http/Middleware/RequestLogging.php)           │
│    Log::channel('stack')->info('Request started', $context)     │
│    → Injects request context (request_id, trace_id)             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. any layer (controllers, services, repositories)               │
│    Log::info('Processing...', ['entity_id' => $id])             │
│    → Structured JSON logs with correlation IDs                   │
└─────────────────────────────────────────────────────────────────┘
```

### 1. Logging Configuration (MANDATORY)

```php
// config/logging.php
return [
    'default' => env('LOG_CHANNEL', 'stack'),
    'channels' => [
        'stack' => [
            'driver' => 'stack',
            'channels' => ['stderr'],
        ],
        'stderr' => [
            'driver' => 'monolog',
            'level' => env('LOG_LEVEL', 'info'),
            'handler' => StreamHandler::class,
            'formatter' => JsonFormatter::class,
            'with' => [
                'stream' => 'php://stderr',
            ],
        ],
    ],
];
```

### 2. Request Logging Middleware (MANDATORY)

```php
// app/Http/Middleware/RequestLogging.php
namespace App\Http\Middleware;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class RequestLogging
{
    public function handle($request, $next)
    {
        $requestId = $request->header('X-Request-ID', Str::uuid()->toString());
        $request->headers->set('X-Request-ID', $requestId);

        Log::withContext([
            'request_id' => $requestId,
            'method' => $request->method(),
            'path' => $request->path(),
        ]);

        Log::info('Request started');

        $response = $next($request);

        Log::info('Request completed', [
            'status' => $response->getStatusCode(),
        ]);

        return $response;
    }
}
```

### 3. Using Logger in Services (MANDATORY)

```php
// app/Services/UserService.php
use Illuminate\Support\Facades\Log;

class UserService
{
    public function create(array $data): User
    {
        Log::info('Creating user', ['email' => $data['email']]);

        try {
            $user = User::create($data);
            Log::info('User created successfully', ['user_id' => $user->id]);
            return $user;
        } catch (\Throwable $e) {
            Log::error('Failed to create user', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            throw $e;
        }
    }
}
```

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `LOG_CHANNEL` | Logging channel | `stack` |
| `LOG_LEVEL` | Logging level | `info` |
| `APP_NAME` | Service identifier | `api-service` |
| `APP_ENV` | Environment name | `production` |

### Monolog Logging Checklist

| Check | What to Verify | Status |
|-------|----------------|--------|
| JSON Formatter | `JsonFormatter` configured in logging.php | Required |
| Request Correlation | Logs include `request_id` from headers | Required |
| Structured Format | All logs are JSON formatted via Monolog | Required |
| Error Logging | Errors include message, stack, and context | Required |
| No Sensitive Data | Passwords, tokens, PII not logged | Required |
| Log Levels | Appropriate levels used (info, warning, error) | Required |
| Stderr Output | Logs written to stderr for container compatibility | Required |

### What not to Do

```php
// FORBIDDEN: Using error_log or echo
error_log('Processing user'); // DON'T do this
echo "Debug: $userId";       // DON'T do this

// FORBIDDEN: Logging sensitive data
Log::info('User login', ['password' => $user->password]); // never

// FORBIDDEN: Unstructured log messages
Log::info("Processing user $userId"); // DON'T use string interpolation without context

// CORRECT: Always use structured logging
Log::info('Processing user', ['user_id' => $userId, 'request_id' => $requestId]);
```

---

## Health Checks

### Required Endpoints

### Implementation

```go
// Go implementation for observability
type ObservabilityChecker struct {
    db    *sql.DB
    redis *redis.Client
}

// Liveness - is the process alive?
func (h *HealthChecker) LivenessHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))
}

// Readiness - can we serve traffic?
func (h *HealthChecker) ReadinessHandler(w http.ResponseWriter, r *http.Request) {
    ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
    defer cancel()

    checks := []struct {
        name string
        fn   func(context.Context) error
    }{
        {"database", func(ctx context.Context) error { return h.db.PingContext(ctx) }},
        {"redis", func(ctx context.Context) error { return h.redis.Ping(ctx).Err() }},
    }

    var failures []string
    for _, check := range checks {
        if err := check.fn(ctx); err != nil {
            failures = append(failures, fmt.Sprintf("%s: %v", check.name, err))
        }
    }

    if len(failures) > 0 {
        w.WriteHeader(http.StatusServiceUnavailable)
        json.NewEncoder(w).Encode(map[string]interface{}{
            "status":  "unhealthy",
            "checks":  failures,
        })
        return
    }

    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(map[string]interface{}{
        "status": "healthy",
    })
}
```

### Kubernetes Configuration

```yaml
# Observability configuration
# JSON structured logging required
# OpenTelemetry tracing recommended for distributed systems
```

---

## Checklist

Before deploying to production:

- [ ] **Logging**: Structured JSON logs with trace correlation
- [ ] **Tracing**: OpenTelemetry instrumentation (Go with lib-commons)
- [ ] **Structured Logging**: lib-common-js integration (TypeScript)
- [ ] **Structured Logging**: Monolog JSON integration (PHP)
