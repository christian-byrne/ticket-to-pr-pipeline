# Task: Build `tdd-assessor` Skill

## Objective

Create an agent skill that evaluates whether Test-Driven Development is beneficial for the current implementation and sets up the TDD approach if appropriate.

## Prerequisites

- Plan approved and PR strategy decided
- `plan.md` exists with implementation details

## Context

### TDD Philosophy

From existing skill:
```
/home/cbyrne/.claude/skills/test-driven-development/SKILL.md
```

**Iron Law:** No production code without a failing test first.

**Red-Green-Refactor:**
1. Red: Write failing test
2. Green: Make it pass with minimum code
3. Refactor: Improve while keeping tests green

### When TDD is Beneficial

- New features with clear specifications
- Bug fixes (test reproduces the bug)
- Complex logic that benefits from incremental development
- Refactoring with safety net

### When TDD May Not Be Best

- Exploratory prototyping
- UI tweaks with unclear final state
- Simple config changes
- Highly integrated changes where tests are complex to set up

### ComfyUI_frontend Testing

From AGENTS.md:
- Unit tests: Vitest (`**/*.test.ts`)
- E2E: Playwright (`browser_tests/**/*.spec.ts`)
- Testing docs: `ComfyUI_frontend/docs/testing/*.md`

Key testing principles:
- No change detector tests
- Behavioral coverage
- Don't mock what you don't own
- Don't just test mocks

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/tdd-assessor/SKILL.md`

### Frontmatter
```yaml
---
name: tdd-assessor
description: Evaluate if TDD is beneficial for current task and set up test-first approach. Use after plan and split strategy are decided.
---
```

### Skill Workflow

1. **Load Context:**
   - Read `plan.md`
   - Identify: what's being built, complexity, type of change

2. **Evaluate TDD Fit:**
   
   Score these factors:
   - Clear specifications? (Yes = +1)
   - New feature or bug fix? (Yes = +1)
   - Complex logic? (Yes = +1)
   - Has acceptance criteria? (Yes = +1)
   - Pure functions involved? (Yes = +1)
   - Exploratory/uncertain scope? (Yes = -1)
   - Heavy UI without clear assertions? (Yes = -1)
   - Simple config/typo fix? (Yes = -2)

3. **Research Testing Patterns:**
   
   If TDD recommended, research:
   - Similar tests in the codebase: `find src -name "*.test.ts" | xargs grep -l "{relevant-keyword}"`
   - Testing docs: Read `ComfyUI_frontend/docs/testing/*.md`
   - Identify: test patterns, mocking approaches, setup helpers

4. **Generate TDD Plan:**
   
   If TDD recommended:
   ```markdown
   # TDD Approach for {Ticket}
   
   ## Assessment
   - TDD Score: {X}/5
   - Recommendation: TDD / Write tests after
   
   ## Testing Strategy
   
   ### Unit Tests
   - **Location:** `src/{path}/*.test.ts` (colocated)
   - **Framework:** Vitest
   - **Pattern:** {based on research}
   
   ### Test Cases to Write First
   
   1. **Test: {description}**
      - File: `src/{path}/{feature}.test.ts`
      - Verifies: {what behavior}
      - Setup: {any mocking needed}
      
   2. **Test: {description}**
      - ...
   
   ### Mocking Strategy
   - {What to mock and how}
   - Reference: {similar test file}
   
   ### E2E Tests (if applicable)
   - **Location:** `browser_tests/{feature}.spec.ts`
   - **Scenarios:** {list}
   
   ## TDD Workflow
   
   For each feature:
   1. Write test in `{file}.test.ts`
   2. Run: `pnpm test:unit -- {file}.test.ts`
   3. Verify test fails (RED)
   4. Implement minimum code
   5. Verify test passes (GREEN)
   6. Refactor if needed
   7. Commit: tests + implementation together
   ```

5. **Present Decision:**
   ```
   TDD Assessment Score: {X}/5
   
   Recommendation: {TDD / Write tests after}
   
   Rationale: {why}
   
   Options:
   A) Accept - Use TDD approach
   B) Skip TDD - Write tests after implementation
   C) Hybrid - TDD for core logic, tests after for UI
   
   Your choice:
   ```

6. **Update Plan:**
   - Add TDD section to `plan.md`
   - Include test cases to write first
   - Update `status.json`

7. **Output:**
   - Confirm approach
   - If TDD: Print first test to write
   - Prompt to continue to implementation

## Deliverables

1. `SKILL.md` file at the correct location
2. Tested with plans of varying types
3. Researches and references actual test patterns

## Verification

```bash
# After running the skill:
# 1. TDD assessment makes sense for the task type
# 2. Test cases are specific and actionable
# 3. References to similar tests are valid
# 4. plan.md updated with TDD approach
```

## Reference Files

- TDD skill: `/home/cbyrne/.claude/skills/test-driven-development/SKILL.md`
- Testing docs: `/home/cbyrne/cross-repo-tasks/ticket-to-pr-e2e-agent-pipeline/ComfyUI_frontend/docs/testing/`
- ComfyUI_frontend AGENTS.md: Testing guidelines section

## Notes

- Default to recommending TDD for new features
- For bug fixes, always recommend test that reproduces the bug first
- Don't force TDD if it doesn't fit - be pragmatic
- Include actual test file references from the codebase
