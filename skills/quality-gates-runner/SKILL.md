---
name: quality-gates-runner
description: Run all quality gates (lint, format, typecheck, tests) via subagents. Use after implementation is complete.
---

# Quality Gates Runner

Run quality checks via subagents to keep main context clean.

## When to Use

- After implementation is complete
- Before creating a PR
- In ComfyUI_frontend directory

## Prerequisites

1. In ComfyUI_frontend directory
2. Changes exist (unstaged or staged)

## Workflow

### 1. Verify Directory

Confirm in ComfyUI_frontend and check for changes:
```bash
pwd  # Should be in ComfyUI_frontend
git status --short  # Should show modified files
```

### 2. Dispatch Subagents in Parallel

Create tasks for each quality gate using the Task tool. Dispatch all in parallel:

**Task 1: Lint**
```
Run `pnpm lint` in ComfyUI_frontend directory.
Report: PASS or FAIL with specific errors and file:line locations.
If FAIL, suggest specific fixes for each error.
```

**Task 2: Format**
```
Run `pnpm format:check` in ComfyUI_frontend directory.
Report: PASS or FAIL.
If FAIL, run `pnpm format` to fix and report files changed.
```

**Task 3: Typecheck**
```
Run `pnpm typecheck` in ComfyUI_frontend directory.
Report: PASS or FAIL with specific type errors and locations.
For each error, suggest the fix.
```

**Task 4: Knip**
```
Run `pnpm knip` in ComfyUI_frontend directory.
Report: PASS or FAIL with unused exports/dependencies found.
Suggest removals for each finding.
```

**Task 5: Unit Tests**
```
Run `pnpm test:unit` in ComfyUI_frontend directory.
Report: PASS with test count, or FAIL with failing test names and errors.
For failures, include the assertion that failed.
```

**Task 6: Stylelint** (only if CSS changes exist)
```
Run `pnpm stylelint` in ComfyUI_frontend directory.
Report: PASS or FAIL with issues found.
```

### 3. Collect and Report Results

Wait for all subagents, then compile report:

```markdown
# Quality Gates Report

## Summary
| Gate | Status | Issues |
|------|--------|--------|
| Lint | ✅ PASS / ❌ FAIL | {count} |
| Format | ✅ PASS / ❌ FAIL | {count} |
| Typecheck | ✅ PASS / ❌ FAIL | {count} |
| Knip | ✅ PASS / ❌ FAIL | {count} |
| Unit Tests | ✅ PASS / ❌ FAIL | {count} |
| Stylelint | ✅ PASS / ❌ FAIL | {count} |

## Overall: {PASS / FAIL}

## Issues to Fix
### Lint Errors
{file:line - error message - suggested fix}

### Type Errors
{file:line - error message - suggested fix}

### Knip Findings
{unused export/dependency - removal suggestion}

### Test Failures
{test name - assertion that failed}
```

### 4. Handle Results

**All gates pass:**
- Update `status.json`: set status to "review"
- Prompt to continue to code review phase

**Any gates fail:**
- Present issues clearly
- Ask: "Fix these issues automatically?" (Y/N)
- If Y, proceed to auto-fix flow
- If N, user fixes manually

### 5. Auto-Fix Flow

For auto-fixable issues, run directly:

| Issue | Auto-Fix Command |
|-------|------------------|
| Format | `pnpm format` |
| Lint (some) | `pnpm lint:fix` |

For non-auto-fixable issues, dispatch fix subagents:

**Type Error Fix Subagent:**
```
Fix the following type error in ComfyUI_frontend:
File: {file}
Line: {line}
Error: {error message}
Context: {surrounding code}
Apply the fix and verify with `pnpm typecheck`.
```

**Test Failure Investigation Subagent:**
```
Investigate failing test in ComfyUI_frontend:
Test: {test name}
File: {test file}
Assertion: {failed assertion}
Determine root cause and fix. Re-run `pnpm test:unit` to verify.
```

### 6. Re-run Failing Gates

After fixes:
- Re-run only the gates that failed
- Loop until all pass or user stops

## Quality Gate Commands

| Command | Purpose |
|---------|---------|
| `pnpm lint` | ESLint checks |
| `pnpm lint:fix` | Auto-fix ESLint issues |
| `pnpm format:check` | oxfmt formatting check |
| `pnpm format` | Auto-fix formatting |
| `pnpm typecheck` | TypeScript type checking |
| `pnpm knip` | Unused exports/dependencies |
| `pnpm test:unit` | Vitest unit tests |
| `pnpm stylelint` | CSS/style linting |

## Key Principles

1. **Run in parallel**: All checks run simultaneously for speed
2. **Clean context**: Only summary returns to main agent
3. **Auto-fix safely**: Format issues fix automatically without asking
4. **Show before applying**: For complex fixes (type errors), show fix before applying
5. **Track passed gates**: Don't re-run gates that already passed
