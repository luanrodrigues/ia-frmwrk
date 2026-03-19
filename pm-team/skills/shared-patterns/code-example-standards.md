# Code Example Standards Pattern

This file defines MANDATORY rules for code examples in pre-dev documents (PRDs, TRDs, task breakdowns, subtasks).

---

## ⛔ HARD GATE: Laravel Conventions (PHP Projects)

For PHP/Laravel projects, code examples in subtasks MUST follow Laravel conventions:

| Pattern | WRONG | CORRECT |
|---------|-------|---------|
| Dependencies | `new Service()` | Constructor injection via IoC container |
| Database | Raw SQL / `DB::select()` | Eloquent ORM / Query Builder |
| Config | `$_ENV['KEY']` | `config('app.key')` |
| Validation | Manual `if` checks | Form Request classes |
| Logging | `error_log()` | `Log::error()` facade |
| HTTP Client | `curl_*` functions | `Http::get()` facade |
| Queue | Direct processing | `dispatch(new ProcessJob())` |

---

## When Custom Code IS Allowed in Examples

| Scenario | Allowed? | Condition |
|----------|----------|-----------|
| Infrastructure utilities (logging, config, HTTP, DB) | ❌ NO | Use Laravel facades and helpers |
| Domain-specific business logic | ✅ YES | Business rules are project-specific |
| Service layer code | ✅ YES | Uses Laravel IoC container for injection |
| Repository implementations | ✅ YES | Uses Eloquent or Query Builder for queries |
| API handlers / controllers | ✅ YES | Uses Laravel Request/Response cycle |
| Validation logic | ✅ YES | Uses Form Request classes |
| Data transformation (toArray/fromArray) | ✅ YES | Domain mapping is project-specific |

---

## Anti-Rationalization Table

| Rationalization | Why it's wrong | Required Action |
|-----------------|----------------|-----------------|
| "Custom helper is simpler for this example" | Examples teach patterns. Teach the right pattern (Laravel). | **Use Laravel facades** in example |
| "Direct instantiation is clearer" | It bypasses IoC container and makes testing harder. | **Use constructor injection** |
| "I don't know if Laravel has this" | Check before writing. See table above. | **Verify Laravel first** |
| "The example is just pseudocode" | Pseudocode with custom helpers trains wrong patterns. | **Use real Laravel calls** |
| "Engineers will refactor later" | Later = never. Show correct pattern from start. | **Use Laravel conventions now** |
| "This is just a quick example" | Quick examples become production code. Do it right. | **Use Laravel conventions** |
| "Custom utils are easier to understand" | Understanding wrong patterns is worse than not understanding. | **Use Laravel conventions** |

---

## Integration with Subtask Creation

When creating subtasks with code examples (Gate 8), apply these rules:

1. **Step 1 (Write failing test)**: Tests can use custom test helpers
2. **Step 3 (Write implementation)**: Implementation MUST use Laravel conventions for infrastructure
3. **Dependencies**: Always show constructor injection, never `new SomeClass()` directly

**Example subtask code block:**

```php
// Step 3: Implement the service

// app/Services/UserService.php
namespace App\Services;

use App\Repositories\UserRepository;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class UserService
{
    public function __construct(
        private readonly UserRepository $userRepository,
    ) {}

    public function createUser(array $data): User
    {
        Log::info('Creating user', ['email' => $data['email']]);  // ✅ Using Laravel Log facade
        return $this->userRepository->create($data);
    }
}
```

---

## Checklist for Code Example Review

Before finalizing any document with PHP code examples:

```text
[ ] 1. No custom logger creation (use Log facade)
[ ] 2. No custom config loader (use config()/env() helpers)
[ ] 3. No custom HTTP helpers (use Http facade)
[ ] 4. No direct `new Service()` (use constructor injection)
[ ] 5. No raw SQL queries (use Eloquent ORM or Query Builder)
[ ] 6. No manual validation (use Form Request classes)
[ ] 7. All dependencies injected via constructor

If any checkbox is unchecked → Fix code example before publishing.
```
