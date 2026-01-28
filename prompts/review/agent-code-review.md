# Agent Code Review Subagent

## Objective

Perform a comprehensive code review of the changes using standard agent capabilities.

## Input Context

```
Base Branch: {{BASE_BRANCH}}
Files Changed: {{FILES_LIST}}
Ticket: {{TICKET_TITLE}}
Acceptance Criteria: {{CRITERIA}}
```

## Review Checklist

### 1. Functionality Review

- [ ] Code implements the ticket requirements
- [ ] All acceptance criteria are met
- [ ] Edge cases are handled
- [ ] Error handling is appropriate
- [ ] No obvious bugs or logic errors

### 2. Code Quality Review

Based on ComfyUI_frontend AGENTS.md:

- [ ] TypeScript: No `any` types, no `as any` assertions
- [ ] Vue: Composition API, `<script setup lang="ts">`
- [ ] Styling: Tailwind 4, no `<style>` blocks, no `dark:` variants
- [ ] Naming: PascalCase components, camelCase functions
- [ ] No unnecessary comments
- [ ] Functions are short and focused
- [ ] Minimal nesting (no arrow anti-pattern)

### 3. Architecture Review

- [ ] Changes follow existing patterns
- [ ] No over-engineering (YAGNI)
- [ ] Clean separation of concerns
- [ ] No circular dependencies
- [ ] Appropriate module boundaries

### 4. Testing Review

- [ ] Tests are added for new functionality
- [ ] Tests are behavioral, not change detectors
- [ ] Tests don't just test mocks
- [ ] Edge cases are covered
- [ ] Tests follow existing patterns

### 5. Security Review

- [ ] No secrets or keys exposed
- [ ] Input validation where needed
- [ ] No SQL injection or XSS vulnerabilities
- [ ] Proper authentication/authorization checks

### 6. Performance Review

- [ ] No unnecessary re-renders
- [ ] Efficient data structures
- [ ] No N+1 queries or loops
- [ ] Appropriate memoization

## Output Format

```markdown
## Agent Code Review Report

### Summary
- Files reviewed: X
- Issues found: X critical, X major, X minor
- Overall assessment: Ready/Needs Work/Major Revision

### Functionality

#### Acceptance Criteria Check
- [x] Criteria 1: Met
- [ ] Criteria 2: Not met - reason
- [x] Criteria 3: Met

#### Edge Cases
- Handled: {{LIST}}
- Missing: {{LIST}}

### Code Quality Issues

#### Critical

##### Issue: {{TITLE}}
- **File:** {{FILE_PATH}}:{{LINE}}
- **Problem:** {{DESCRIPTION}}
- **Violation:** {{WHICH_RULE}}
- **Fix:**
```typescript
// Before
{{BEFORE}}

// After
{{AFTER}}
```

#### Major
...

#### Minor
...

### Architecture Observations
- Patterns followed: {{LIST}}
- Suggestions: {{LIST}}

### Testing Assessment
- Test coverage: Adequate/Needs More
- Missing tests: {{LIST}}

### Security Assessment
- No issues found / Issues found: {{LIST}}

### Performance Assessment
- No concerns / Concerns: {{LIST}}

### Recommendations

1. **Must Fix:** Critical issues that block the PR
2. **Should Fix:** Important improvements
3. **Consider:** Nice-to-have suggestions
```

## Success Criteria

- All files reviewed
- Issues categorized by severity
- Specific line-by-line feedback provided
- Actionable fix suggestions included
