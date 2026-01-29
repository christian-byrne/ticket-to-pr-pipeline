---
name: implementation-runner
description: Executes implementation plan tasks using subagents. Use after plan is approved and tasking is complete. Dispatches parallel work, tracks progress, handles failures.
---

# Implementation Runner

Executes the approved plan by dispatching subagents for each task. Tracks progress, handles failures, and coordinates parallel work.

## Prerequisites

- `plan.md` exists at `runs/{ticket-id}/plan.md`
- Plan is approved (`status.json` has `planApproved: true`)
- Working directory is ComfyUI_frontend

## Workflow

### 1. Load Plan and Initialize

Read plan and prepare task execution:

```bash
RUN_DIR="runs/{ticket-id}"
cat "$RUN_DIR/plan.md"
cat "$RUN_DIR/status.json"
```

Initialize implementation tracking:

```bash
jq '.status = "implementing" | .implementationStarted = now | .tasksCompleted = 0 | .tasksFailed = 0' \
  "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

### 2. Parse Tasks from Plan

Extract actionable tasks from the plan. Each task maps to one subagent dispatch.

Tasks come from these plan sections:
- **Files to Modify**: Each file = 1 task
- **Files to Create**: Each new file = 1 task
- **Testing Strategy**: Test writing = separate tasks

Create task manifest:

```markdown
# tasks.md

## Task 1: {File to modify}
**Type:** modify
**File:** path/to/file.ts
**Description:** {what changes from plan}
**Dependencies:** none

## Task 2: {New file}
**Type:** create
**File:** path/to/new.ts
**Description:** {purpose from plan}
**Dependencies:** Task 1

## Task 3: Unit Tests
**Type:** test
**Files:** path/to/file.test.ts
**Description:** Write unit tests for new functionality
**Dependencies:** Task 1, Task 2
```

Save to run directory:
```bash
echo "$TASKS_CONTENT" > "$RUN_DIR/tasks.md"
```

### 3. Identify Parallel vs Sequential

Analyze dependencies:
- **Parallel**: Tasks with no dependencies on each other
- **Sequential**: Tasks that depend on prior tasks

Group into execution waves:

```
Wave 1: [Task 1, Task 4] - no dependencies
Wave 2: [Task 2, Task 3] - depend on Wave 1
Wave 3: [Task 5] - depends on Wave 2
```

### 4. Execute Waves

For each wave, dispatch subagents in parallel using the Task tool.

**Subagent Prompt Template:**

```
Context: Implementing ticket {ticket-id} in ComfyUI_frontend.

Plan Summary:
{goal and proposed approach from plan.md}

Your Task:
{task description}

File: {file path}
Action: {create | modify}

Specific Changes:
{extracted from plan.md for this file}

Patterns to Follow:
{reference patterns from research-report.md}

When done:
1. Verify the file compiles: `pnpm typecheck`
2. Run related tests if they exist
3. Report: SUCCESS with summary of changes, or FAILURE with blockers
```

**Execute wave:**
```
Dispatch all tasks in wave N in parallel.
Wait for all to complete.
Collect results.
```

### 5. Track Progress

Update status after each wave:

```bash
# Count completions
COMPLETED=$(jq '.tasksCompleted' "$RUN_DIR/status.json")
FAILED=$(jq '.tasksFailed' "$RUN_DIR/status.json")

jq --argjson completed "$NEW_COMPLETED" --argjson failed "$NEW_FAILED" \
  '.tasksCompleted = $completed | .tasksFailed = $failed | .lastWaveCompleted = now' \
  "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

Save wave results:
```bash
echo "$WAVE_RESULTS" >> "$RUN_DIR/implementation-log.md"
```

### 6. Handle Failures

When a subagent reports FAILURE:

1. **Log the failure** with full context
2. **Assess impact** on dependent tasks
3. **Present options** to user:
   - Retry with different approach
   - Skip and continue (mark dependent tasks blocked)
   - Pause for manual intervention
   - Abort implementation

**Failure Response Template:**

```markdown
## Task Failed: {task name}

**Error:** {error from subagent}
**File:** {file path}
**Impact:** Blocks {N} downstream tasks

**Options:**
1. Retry - I'll try a different approach
2. Skip - Continue without this task (blocks: Task X, Y)
3. Pause - Stop for you to fix manually
4. Abort - Cancel implementation

Your choice:
```

### 7. Completion Report

After all waves complete:

```markdown
# Implementation Complete

## Summary
- **Tasks Completed:** {N}/{total}
- **Tasks Failed:** {N}
- **Tasks Skipped:** {N}
- **Duration:** {time}

## Files Changed
| File | Action | Status |
|------|--------|--------|
| path/to/file.ts | modified | ✅ |
| path/to/new.ts | created | ✅ |
| path/to/problem.ts | modified | ❌ |

## Changes Made
{Brief summary of what was implemented}

## Remaining Work
{Any manual steps needed}

## Next Step
Run quality gates: `/skill quality-gates-runner`
```

Save report:
```bash
echo "$REPORT" > "$RUN_DIR/implementation-report.md"

jq '.status = "quality-check" | .implementationCompleted = now' \
  "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

## Task Sizing Guidelines

Each task should be:
- **Atomic**: One logical change
- **Verifiable**: Can check if it worked
- **Scoped**: 50-200 lines of change max

If a task is too large, split it:
- Large file modification → multiple tasks by section
- Complex new file → interface first, then implementation

## Parallel Execution Rules

**Safe to parallelize:**
- Different files with no imports between them
- Creating new files that don't depend on each other
- Test files for different modules

**Must be sequential:**
- File B imports from File A → A first
- Interface before implementation
- Types before usage

## Subagent Context

Each subagent receives:
1. **Goal**: What this specific task achieves
2. **Plan context**: Relevant excerpts from plan.md
3. **Pattern guidance**: From research-report.md
4. **Verification**: How to confirm success

Keep subagent prompts focused (<500 words) to avoid context overload.

## Recovery from Interruption

If implementation is interrupted:

```bash
# Check status
cat "$RUN_DIR/status.json"
cat "$RUN_DIR/implementation-log.md"
```

Resume from last completed wave:
- Skip already-done tasks
- Retry failed tasks if flagged for retry
- Continue with remaining waves

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| tasks.md | `runs/{ticket-id}/tasks.md` | Task breakdown from plan |
| implementation-log.md | `runs/{ticket-id}/implementation-log.md` | Wave-by-wave execution log |
| implementation-report.md | `runs/{ticket-id}/implementation-report.md` | Final summary |
| status.json | `runs/{ticket-id}/status.json` | Progress tracking |

## Integration with Pipeline

**Before:** plan-generator (approved plan)
**After:** quality-gates-runner (lint, typecheck, tests)

Status transitions:
- `tasking` → `implementing` (start)
- `implementing` → `quality-check` (success)
- `implementing` → `blocked` (failure needing intervention)
