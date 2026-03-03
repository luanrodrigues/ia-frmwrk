---
name: bee:dev-status
description: Check the status of the current development cycle
argument-hint: ""
---

Check the status of the current development cycle.

## Usage

```
/bee:dev-status
```

## Output

Displays:
- Current cycle ID and start time
- Tasks: total, completed, in progress, pending
- Current task and gate being executed
- Assertiveness score (if tasks completed)
- Elapsed time

## Example Output

```
📊 Development Cycle Status

Cycle ID: 2024-01-15-143000
Started: 2024-01-15 14:30:00
Status: in_progress

Tasks:
  ✅ Completed: 2/5
  🔄 In Progress: 1/5 (AUTH-003)
  ⏳ Pending: 2/5

Current:
  Task: AUTH-003 - Implementar refresh token
  Gate: 3/10 (bee:dev-unit-testing)
  Iterations: 1

Metrics (completed tasks):
  Average Assertiveness: 89%
  Total Duration: 1h 45m

State file: docs/bee:dev-cycle/current-cycle.json (or docs/bee:dev-refactor/current-cycle.json)
```

## When No Cycle is Running

```
ℹ️ No development cycle in progress.

Start a new cycle with:
  /bee:dev-cycle docs/tasks/your-tasks.md

Or resume an interrupted cycle:
  /bee:dev-cycle --resume
```

## Related Commands

| Command | Description |
|---------|-------------|
| `/bee:dev-cycle` | Start or resume cycle |
| `/bee:dev-cancel` | Cancel running cycle |
| `/bee:dev-report` | View feedback report |

---

Now checking cycle status...

Read state from: `docs/bee:dev-cycle/current-cycle.json` or `docs/bee:dev-refactor/current-cycle.json`
