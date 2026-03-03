# Standards Compliance Mode Detection

Canonical source for Standards Compliance detection logic used by all dev-team agents.

---

## ⛔ CRITICAL: Standards Compliance is always Required for Implementation

**Standards Compliance is not optional. It is MANDATORY for all implementation agents.**

| Context | Standards Compliance | Rationale |
|---------|---------------------|-----------|
| **Implementation (TDD-GREEN)** | **always REQUIRED** | Agent MUST output Standards Coverage Table |
| **Analysis (MODE: ANALYSIS only)** | **always REQUIRED** | Agent MUST output Standards Coverage Table + Findings |
| **Validation (SRE, QA)** | **always REQUIRED** | Agent MUST verify against standards |

**There is no context where an implementation agent can skip Standards Compliance.**

---

## Trigger Conditions

### always Required (Implementation Context)

**These agents MUST always output Standards Coverage Table:**

| Agent | Standards File | When |
|-------|---------------|------|
| `ring:backend-engineer-php` | php.md | any implementation task |
| `frontend-bff-engineer-typescript` | typescript.md | any implementation task |
| `ring:frontend-engineer` | frontend.md | any implementation task |
| `ring:devops-engineer` | devops.md | any artifact creation |
| `ring:sre` | sre.md | any validation task |
| `ring:qa-analyst` | php.md | any testing task |

**⛔ HARD GATE:** If agent does not output Standards Coverage Table → Output is INCOMPLETE → Orchestrator MUST re-dispatch.

### Additional Triggers (Analysis Context)

These patterns trigger **detailed findings** in addition to Standards Coverage Table:

| Detection Pattern | Examples |
|------------------|----------|
| Exact match | `**MODE: ANALYSIS only**` |
| Case variations | `MODE: Analysis Only`, `mode: analysis only`, `**mode: ANALYSIS only**` |
| Partial markers | `ANALYSIS MODE`, `analysis-only`, `analyze only`, `MODE ANALYSIS` |
| Context clues | Invoked from `ring:dev-refactor` skill |
| Explicit request | "compare against standards", "audit compliance", "check against Ring standards" |

## Detection Logic

```python
def get_standards_compliance_mode(prompt: str, context: dict) -> str:
    """
    Returns:
    - "FULL": Standards Coverage Table + Detailed Findings (analysis mode)
    - "TABLE_ONLY": Standards Coverage Table only (implementation mode)
    - "TABLE_ONLY" is the MINIMUM - never returns "NONE"
    """
    # Analysis mode patterns
    analysis_patterns = [
        "mode: analysis only",
        "analysis mode",
        "analysis-only",
        "analyze only",
        "compare against standards",
        "audit compliance",
        "check against ring"
    ]
    prompt_lower = prompt.lower()

    # Check for analysis mode
    if any(p in prompt_lower for p in analysis_patterns):
        return "FULL"

    # Check invocation context
    if context.get("invocation_source") == "ring:dev-refactor":
        return "FULL"

    # Default: TABLE_ONLY (Standards Coverage Table is always required)
    return "TABLE_ONLY"
```

## When Uncertain

If detection is ambiguous, output FULL compliance (table + findings). Better to over-report than under-report.

## When Mode is Detected, Agent MUST

1. **WebFetch** the Ring standards file for their language/domain
2. **Read** `docs/PROJECT_RULES.md` if it exists in the target codebase
3. **Include** a `## Standards Compliance` section in output with comparison table
4. **CANNOT skip** - this is a HARD GATE, not optional

## MANDATORY Output Table Format

```markdown
| Category | Current Pattern | Ring Standard | Status | File/Location |
|----------|----------------|---------------|--------|---------------|
| [category] | [what codebase does] | [what standard requires] | ✅/⚠️/❌ | [file:line] |
```

## Status Legend

- ✅ Compliant - Matches Ring standard
- ⚠️ Partial - Some compliance, needs improvement
- ❌ Non-Compliant - Does not follow standard
- N/A - Not applicable (with reason)

## Standards Coverage Table (ring:dev-refactor context)

**Detection:** This section applies when prompt contains `**MODE: ANALYSIS only**`

**Inputs (provided by ring:dev-refactor):**

| Input | Source | Contains |
|-------|--------|----------|
| Ring Standards | WebFetch | Sections to check (## headers) |
| codebase-report.md | Provided path | Current architecture, patterns, code snippets |
| PROJECT_RULES.md | Provided path | Project-specific conventions |

**Outputs (expected by ring:dev-refactor):**
1. Standards Coverage Table (every section enumerated)
2. Detailed findings in FINDING-XXX format for ⚠️/❌ items

**HARD GATE:** When invoked from ring:dev-refactor skill, before outputting detailed findings, you MUST output a Standards Coverage Table.

**Process:**
1. **Parse the WebFetch result** - Extract all `## Section` headers from standards file
2. **Count total sections found** - Record the number
3. **For each section** - Determine status (✅ Compliant, ⚠️ Partial, ❌ Non-Compliant, or N/A with reason)
4. **Output table** - MUST have one row per section
5. **Verify completeness** - Table rows MUST equal sections found

---

## ⛔ CRITICAL: Section Names MUST Match Coverage Table EXACTLY

**You MUST use section names from `standards-coverage-table.md`. You CANNOT invent your own.**

### FORBIDDEN Actions

```
❌ Inventing section names ("Security", "Go Version", "Code Quality")
❌ Merging sections ("Error Handling & Logging" instead of separate rows)
❌ Renaming sections ("Config" instead of "Configuration Loading")
❌ Skipping sections not found in codebase
❌ Adding sections not in coverage table
```

### REQUIRED Actions

```
✅ Use EXACT section names from standards-coverage-table.md
✅ Output all sections listed in coverage table for your agent type
✅ Mark missing/not-applicable sections as "N/A" with reason
✅ One row per section - no merging
```

### Section Name Validation

**For php.md, section names MUST be:**
- Version, Core Dependencies, Frameworks & Libraries, Configuration, Database Naming Convention (snake_case), Database Migrations, License Headers, Eloquent Patterns, Dependency Management, Observability, Bootstrap, Graceful Shutdown Patterns, Health Checks, Connection Management, Authentication Integration, Secret Redaction Patterns, SQL Safety, HTTP Security Headers, Data Transformation, Error Codes Convention, Error Handling, Exit/Fatal Location Rules, Function Design, File Organization, JSON Naming Convention (camelCase), Pagination Patterns, HTTP Status Code Consistency, OpenAPI Documentation, Controller Constructor Pattern, Input Validation, Testing, Logging, Linting, Production Config Validation, Container Security, Architecture Patterns, Directory Structure, N+1 Query Detection, Performance Patterns, RabbitMQ Worker Pattern, RabbitMQ Reconnection Strategy, Always-Valid Domain Model, Idempotency Patterns, Multi-Tenant Patterns, Rate Limiting, CORS Configuration

**not:**
- ❌ "Error Handling" (missing "Error Codes Convention" as separate row)
- ❌ "Logging Standards" (should be "Logging")
- ❌ "Configuration Loading" (should be "Configuration")
- ❌ "Security" (not a section in php.md)
- ❌ "Bootstrap Pattern" (should be "Bootstrap")

### Anti-Rationalization for Section Names

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "My section name is clearer" | Consistency > clarity. Coverage table is the contract. | **Use EXACT names from coverage table** |
| "I combined related sections" | Each section = one row. Merging loses traceability. | **One row per section, no merging** |
| "This section doesn't apply" | Report as N/A with reason. Never skip silently. | **Include row with N/A status** |
| "I added a useful section" | You don't decide sections. Coverage table does. | **Only sections from coverage table** |
| "The codebase uses different terminology" | Standards use Ring terminology. Map codebase terms to standard terms. | **Use standard section names** |

## MANDATORY: Quote Standards from WebFetch in Findings

**For every ⚠️ Partial or ❌ Non-Compliant finding, you MUST:**

1. **Quote the codebase pattern** from codebase-report.md (what exists)
2. **Quote the Ring standard** from WebFetch result (what's expected)
3. **Explain the gap** (what needs improvement)

**Output Format for Non-Compliant Findings:**

```markdown
### FINDING: [Category Name]

**Status:** ⚠️ Partial / ❌ Non-Compliant
**Location:** [file:line from codebase-report.md]
**Severity:** CRITICAL / HIGH / MEDIUM / LOW

**Current (from codebase-report.md):**
[Quote the actual code/pattern from codebase-report.md]

**Expected (from Ring Standard):**
[Quote the relevant code/pattern from WebFetch result]

**Gap Analysis:**
- What is different
- What needs to be improved
- Standard reference: {standards-file}.md → [Section Name]
```

**⛔ HARD GATE: You MUST quote from BOTH sources (codebase-report.md and WebFetch result).**

## Anti-Rationalization

See [shared-anti-rationalization.md](shared-anti-rationalization.md) for universal agent anti-rationalizations.

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Detection wasn't exact match" | Partial matches and context clues count. | **Include Standards Compliance section** |
| "Codebase already compliant" | Assumption ≠ verification. Check every section. | **Output full Standards Coverage Table** |
| "Only relevant sections matter" | You don't decide relevance. Standards file does. | **Check all ## sections from WebFetch** |
| "Summary is enough" | Detailed quotes are MANDATORY for findings. | **Quote from BOTH sources** |
| "WebFetch failed, skip compliance" | STOP and report blocker. Cannot proceed without standards. | **Report blocker, DO NOT skip** |

## How to Reference This File

Agents should include:

```markdown
## Standards Compliance (always REQUIRED)

See [shared-patterns/standards-compliance-detection.md](../skills/shared-patterns/standards-compliance-detection.md) for:
- Standards Compliance is MANDATORY for all implementation agents
- MANDATORY output table format (Standards Coverage Table)
- Additional findings format for analysis mode
- Anti-rationalization rules

**Agent-Specific Standards:**
- WebFetch URL: `https://raw.githubusercontent.com/LerianStudio/ring/main/dev-team/docs/standards/{file}.md`
- Sections to check: See [standards-coverage-table.md](../skills/shared-patterns/standards-coverage-table.md)

**⛔ Standards Coverage Table is always required. No exceptions.**
- Implementation mode: Output Standards Coverage Table
- Analysis mode: Output Standards Coverage Table + Detailed Findings
```
