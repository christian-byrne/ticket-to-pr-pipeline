# Task: Build `ci-checker` Skill

## Objective

Create an agent skill that checks GitHub CI status and guides fixing any failures.

## Prerequisites

- PR created
- CI checks are running or complete

## Context

### CI Checks on ComfyUI_frontend

Typical GitHub Actions workflows:
- Lint check
- Type check
- Unit tests
- E2E tests (Playwright)
- Build verification

### GitHub CLI for CI

```bash
# List check runs for a PR
gh pr checks {pr-number}

# View specific workflow run
gh run view {run-id}

# View logs
gh run view {run-id} --log
```

### Common CI Failures

1. **E2E test flakes** - May need retry
2. **Lint/format differences** - CI environment vs local
3. **Type errors** - Stricter in CI
4. **Missing dependencies** - Not committed

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/ci-checker/SKILL.md`

### Frontmatter
```yaml
---
name: ci-checker
description: Check GitHub CI status and guide fixing failures. Use when human says "check CI" after PR creation.
---
```

### Skill Workflow

1. **Get PR Info:**
   
   Load from `status.json` or ask:
   ```
   PR number? (or paste URL)
   ```

2. **Check CI Status:**
   ```bash
   gh pr checks {pr-number}
   ```
   
   Parse output for each check:
   - ✅ pass
   - ❌ fail
   - 🔄 pending

3. **Report Status:**
   ```markdown
   # CI Status for PR #{number}
   
   | Check | Status | Duration |
   |-------|--------|----------|
   | lint | ✅ pass | 2m |
   | typecheck | ✅ pass | 3m |
   | test-unit | ❌ fail | 5m |
   | test-e2e | 🔄 pending | - |
   | build | ✅ pass | 4m |
   
   ## Overall: {Passing / Failing / Pending}
   ```

4. **If Pending:**
   ```
   CI checks still running. Estimated time: {X} minutes.
   
   Options:
   A) Wait and check again in 5 minutes
   B) Check specific workflow status
   C) Continue anyway (not recommended)
   ```

5. **If Failing:**
   
   For each failing check:
   ```bash
   # Get the run ID
   gh pr checks {pr-number} --json name,status,conclusion,detailsUrl
   
   # Get logs for failing run
   gh run view {run-id} --log-failed
   ```
   
   Parse and present:
   ```markdown
   ## Failed: test-unit
   
   ### Error Summary
   {extracted error message}
   
   ### Failed Tests
   - `src/components/Foo.test.ts` - "expected true, got false"
   
   ### Suggested Fix
   {analysis of what might be wrong}
   ```

6. **Guide Fixes:**
   ```
   Found {X} failing checks.
   
   Options:
   A) Investigate and fix locally
   B) Re-run failed checks (if flaky)
   C) View full logs for {check}
   D) Ignore and proceed (not recommended)
   
   Choice:
   ```
   
   **If A (fix locally):**
   - Provide specific commands to reproduce locally
   - Dispatch subagent to investigate
   - After fix, commit and push
   - Re-check CI
   
   **If B (re-run):**
   ```bash
   gh run rerun {run-id} --failed
   ```
   Wait and check again.
   
   **If C (view logs):**
   ```bash
   gh run view {run-id} --log
   ```
   Present relevant log sections.

7. **If All Passing:**
   ```
   ✅ All CI checks passing!
   
   PR is ready for review.
   
   Options:
   A) Update Notion status to "Done"
   B) Request specific reviewers
   C) Done for now
   ```

8. **Update Notion (if requested):**
   - Status → "Done"
   - Or keep at "In Review" until actually merged

9. **Final State:**
   - Update `status.json`: ciStatus → "passing"
   - Print success message
   - Note that PR is ready for human review

## Common CI Issues & Solutions

### E2E Test Flakes
- Cause: Timing issues, async operations
- Solution: Re-run with `gh run rerun --failed`
- If persists: Add explicit waits or fix the flaky test

### Lint Differences
- Cause: Different eslint/prettier versions
- Solution: Run `pnpm install` and `pnpm lint:fix` locally

### Type Errors in CI Only
- Cause: Stricter tsconfig in CI or different TS version
- Solution: Run exact same typecheck command as CI

### Build Failures
- Cause: Missing files, import errors
- Solution: Run `pnpm build` locally to reproduce

## Deliverables

1. `SKILL.md` file at the correct location
2. Can check and report CI status
3. Can investigate failures
4. Can trigger re-runs

## Verification

```bash
# Test with:
# 1. PR with all checks passing
# 2. PR with a failing check
# 3. PR with pending checks

# Verify:
# - Status is correctly reported
# - Failed check logs are accessible
# - Re-run command works
# - Fix guidance is actionable
```

## Reference Files

- Implementation plan: Section 6.9
- GitHub CLI docs: https://cli.github.com/manual/gh_pr_checks

## Notes

- E2E tests can take 10-20 minutes - don't poll too frequently
- Flaky tests are common - one re-run is acceptable
- If same test fails twice, it's a real issue
- Some checks may be required for merge, some optional
- Don't force merge with failing required checks
