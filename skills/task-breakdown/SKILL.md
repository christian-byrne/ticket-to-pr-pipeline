---
name: task-breakdown
description: Converts approved plan.md into atomic tasks.md with dependencies, estimates, and verification criteria. Use after plan approval, before implementation.
---

# Task Breakdown

Converts a high-level implementation plan into atomic, executable tasks with clear dependencies and verification criteria.

## Prerequisites

- `plan.md` exists at `runs/{ticket-id}/plan.md`
- Plan is approved (`status.json` has `planApproved: true`)

## Workflow

### 1. Load Plan

```bash
RUN_DIR="runs/{ticket-id}"
cat "$RUN_DIR/plan.md"
```

### 2. Extract Work Items

Parse plan.md for actionable items:

**From "Files to Modify":**
- Each file = potential task(s)
- If file has multiple changes, split by logical unit

**From "Files to Create":**
- Each new file = 1 task minimum
- Large files (>200 lines) = multiple tasks

**From "Testing Strategy":**
- Unit tests per module
- E2E tests = separate task

**From "Dependencies":**
- External library additions
- Configuration changes

### 3. Define Task Structure

Each task follows this template:

```markdown
## Task {N}: {Short Title}

**Type:** create | modify | test | config
**File(s):** path/to/file.ts
**Estimate:** XS | S | M | L
**Dependencies:** [Task N, Task M] or none

### Description
{What this task accomplishes - 1-2 sentences}

### Acceptance Criteria
- [ ] {Specific verifiable outcome}
- [ ] {Another verifiable outcome}

### Implementation Notes
{Key patterns, gotchas, or references from plan}

### Verification
```bash
{Command to verify task is complete}
```
```

### 4. Size Guidelines

| Size | Lines of Change | Time | Subagent Suitable |
|------|-----------------|------|-------------------|
| XS | < 20 | ~2 min | Yes |
| S | 20-50 | ~5 min | Yes |
| M | 50-150 | ~15 min | Yes, with focus |
| L | 150-300 | ~30 min | Consider splitting |

**Split L tasks** into M or S when possible.

### 5. Dependency Analysis

Build dependency graph:

1. **Identify imports**: File A imports B → B before A
2. **Interface first**: Types/interfaces before implementations
3. **Base before derived**: Parent classes before children
4. **Config before usage**: env/config changes before code using them

Express as DAG:

```
Task 1 (types) ─┬─► Task 3 (component A)
                │
Task 2 (utils) ─┴─► Task 4 (component B) ─► Task 5 (tests)
```

### 6. Generate tasks.md

```markdown
# Implementation Tasks

**Ticket:** {ticket-id}
**Plan Version:** {from plan.md}
**Generated:** {timestamp}

## Overview

| # | Task | Type | Size | Depends On | Status |
|---|------|------|------|------------|--------|
| 1 | Add types | create | S | - | pending |
| 2 | Utils helper | create | S | - | pending |
| 3 | Component A | modify | M | 1, 2 | pending |
| 4 | Component B | modify | M | 1, 2 | pending |
| 5 | Unit tests | test | M | 3, 4 | pending |

## Execution Waves

**Wave 1** (parallel): Task 1, Task 2
**Wave 2** (parallel): Task 3, Task 4
**Wave 3**: Task 5

---

{Full task definitions here}
```

### 7. Validate Completeness

Cross-check against plan:

```markdown
## Validation Checklist

- [ ] All files from "Files to Modify" covered
- [ ] All files from "Files to Create" covered
- [ ] All tests from "Testing Strategy" covered
- [ ] No orphan tasks (all have path to root)
- [ ] No cycles in dependency graph
- [ ] Total estimate aligns with plan scope
```

### 8. Save and Update Status

```bash
# Save tasks
echo "$TASKS_CONTENT" > "$RUN_DIR/tasks.md"

# Update status
jq '.status = "tasked" | .taskCount = {N} | .tasksGenerated = now' \
  "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

### 9. Present for Approval

```
Tasks generated: {N} tasks across {W} execution waves

## Summary
{overview table}

## Execution Order
{wave breakdown}

Estimated total: {sum of estimates}

Options:
1. Approve and start implementation
2. Adjust task breakdown
3. Return to plan for changes

Your choice:
```

## Task Types

| Type | Description | Verification |
|------|-------------|--------------|
| create | New file | File exists, compiles |
| modify | Change existing file | Typecheck passes |
| test | Write tests | Tests run and pass |
| config | Configuration change | App starts correctly |
| refactor | Restructure without behavior change | All tests still pass |

## Common Patterns

### Feature Addition
1. Types/interfaces (create)
2. Core logic/composable (create)
3. Component integration (modify)
4. Tests (test)

### Bug Fix
1. Add failing test (test)
2. Fix implementation (modify)
3. Verify test passes (test)

### Refactor
1. Add tests for current behavior (test)
2. Refactor code (modify)
3. Verify tests still pass (test)

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| tasks.md | `runs/{ticket-id}/tasks.md` | Full task breakdown |
| status.json | `runs/{ticket-id}/status.json` | Updated with task count |

## Integration

**Before:** plan-generator (approved plan)
**After:** implementation-runner (execute tasks)

Status transitions:
- `tasking` → `tasked` (tasks generated)
- `tasked` → `implementing` (execution starts)
