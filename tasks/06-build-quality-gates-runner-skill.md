# Task: Build `quality-gates-runner` Skill

## Objective

Create an agent skill that runs all quality checks (lint, format, typecheck, tests) via subagents to avoid context flooding.

## Prerequisites

- Implementation is complete (code written)
- In ComfyUI_frontend directory

## Context

### Quality Gates

From ComfyUI_frontend AGENTS.md, these must pass before PR:

| Command | Purpose |
|---------|---------|
| `pnpm lint` | ESLint checks |
| `pnpm format:check` | oxfmt formatting |
| `pnpm typecheck` | TypeScript type checking |
| `pnpm knip` | Unused exports/dependencies |
| `pnpm test:unit` | Vitest unit tests |
| `pnpm stylelint` | CSS/style linting |

### Why Subagents?

Running these commands produces verbose output that floods context. By dispatching subagents:
- Each check runs in isolation
- Only pass/fail + relevant errors return
- Main context stays clean

### Pattern Reference

Use Task tool to dispatch subagents:
```
/home/cbyrne/.claude/skills/subagent-driven-development/SKILL.md
```

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/quality-gates-runner/SKILL.md`

### Frontmatter
```yaml
---
name: quality-gates-runner
description: Run all quality gates (lint, format, typecheck, tests) via subagents. Use after implementation is complete.
---
```

### Skill Workflow

1. **Verify Directory:**
   - Confirm in ComfyUI_frontend directory
   - Check that changes exist (unstaged or staged)

2. **Dispatch Subagents:**
   
   Dispatch these in parallel using Task tool:
   
   **Subagent 1: Lint**
   ```
   Run `pnpm lint` in ComfyUI_frontend directory.
   Report: PASS or FAIL with specific errors and file:line locations.
   If FAIL, suggest specific fixes for each error.
   ```
   
   **Subagent 2: Format**
   ```
   Run `pnpm format:check` in ComfyUI_frontend directory.
   Report: PASS or FAIL.
   If FAIL, run `pnpm format` to fix and report files changed.
   ```
   
   **Subagent 3: Typecheck**
   ```
   Run `pnpm typecheck` in ComfyUI_frontend directory.
   Report: PASS or FAIL with specific type errors and locations.
   For each error, suggest the fix.
   ```
   
   **Subagent 4: Knip**
   ```
   Run `pnpm knip` in ComfyUI_frontend directory.
   Report: PASS or FAIL with unused exports/dependencies found.
   Suggest removals for each finding.
   ```
   
   **Subagent 5: Unit Tests**
   ```
   Run `pnpm test:unit` in ComfyUI_frontend directory.
   Report: PASS with test count, or FAIL with failing test names and errors.
   For failures, include the assertion that failed.
   ```
   
   **Subagent 6: Stylelint** (optional, if CSS changes)
   ```
   Run `pnpm stylelint` if applicable.
   Report: PASS or FAIL with issues.
   ```

3. **Collect Results:**
   
   Wait for all subagents, compile results:
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
   
   ## Overall: {PASS / FAIL}
   
   ## Issues to Fix
   
   ### Lint Errors
   {list with file:line and suggested fix}
   
   ### Type Errors
   {list with file:line and suggested fix}
   
   ...
   ```

4. **Handle Results:**
   
   **If all pass:**
   - Update `status.json`: status → "review"
   - Prompt to continue to code review phase
   
   **If any fail:**
   - Present the issues clearly
   - Ask: "Fix these issues automatically?" (Y/N)
   - If Y, dispatch fix subagent for each failing check
   - Re-run the failing checks
   - Loop until all pass or user decides to stop

5. **Auto-Fix Flow:**
   
   For auto-fixable issues:
   - `pnpm format` - run directly (auto-fixes)
   - `pnpm lint:fix` - run directly (auto-fixes some)
   - Type errors - dispatch subagent to fix specific errors
   - Test failures - dispatch subagent to investigate

## Deliverables

1. `SKILL.md` file at the correct location
2. Tested with code that has various issues
3. Properly handles both pass and fail cases

## Verification

```bash
# Test by introducing issues:
# 1. Add unused import → knip should catch
# 2. Add type error → typecheck should catch
# 3. Mess up formatting → format should catch
# 4. Break a test → unit tests should catch

# Verify:
# - Each issue is reported clearly
# - Fix suggestions are actionable
# - Auto-fix works for fixable issues
```

## Reference Files

- ComfyUI_frontend AGENTS.md: Quality gate requirements
- Implementation plan: `/home/cbyrne/repos/ticket-to-pr-pipeline/docs/implementation-plan.md` (Section 6.5)
- Subagent pattern: `/home/cbyrne/.claude/skills/subagent-driven-development/SKILL.md`

## Notes

- Run checks in parallel for speed
- Keep main context clean - only summary returns
- Auto-fix format issues without asking (they're safe)
- For complex fixes (type errors), show the fix before applying
- Track which gates passed to avoid re-running on retry
