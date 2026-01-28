# CodeRabbit CLI Review Subagent

## Objective

Run CodeRabbit CLI to get AI-powered code review on the current changes.

## Prerequisites

- CodeRabbit CLI installed: `curl -fsSL https://cli.coderabbit.ai/install.sh | sh`
- Authenticated: `coderabbit auth login`

## Execution

Run the review in prompt-only mode for easy parsing:

```bash
# Review all changes (committed + uncommitted)
coderabbit --prompt-only

# Review only uncommitted changes
coderabbit --prompt-only --type uncommitted

# Review with specific base branch
coderabbit --prompt-only --base main
```

## Processing Output

CodeRabbit will output findings in a structured format. For each finding:

1. **Categorize by severity:**
   - Critical: Security issues, race conditions, data loss risks
   - Major: Logic errors, performance issues, missing error handling
   - Minor: Code style, naming, documentation
   - Nitpick: Formatting, personal preference

2. **Extract:**
   - File path and line number
   - Issue description
   - Suggested fix (if provided)
   - Category (security, performance, logic, style)

## Output Format

```markdown
## CodeRabbit Review Report

### Summary
- Critical: X issues
- Major: X issues
- Minor: X issues
- Nitpicks: X issues

### Critical Issues

#### Issue 1: {{TITLE}}
- **File:** {{FILE_PATH}}:{{LINE}}
- **Category:** Security/Race Condition/Data Loss
- **Description:** {{DESCRIPTION}}
- **Suggested Fix:**
```typescript
// CodeRabbit's suggestion
```
- **Action:** Must fix before PR

### Major Issues

#### Issue 1: {{TITLE}}
- **File:** {{FILE_PATH}}:{{LINE}}
- **Category:** Logic/Performance/Error Handling
- **Description:** {{DESCRIPTION}}
- **Suggested Fix:** {{FIX}}
- **Action:** Should fix

### Minor Issues

#### Issue 1: {{TITLE}}
- **File:** {{FILE_PATH}}:{{LINE}}
- **Description:** {{DESCRIPTION}}
- **Suggested Fix:** {{FIX}}
- **Action:** Consider fixing

### Nitpicks
- {{FILE_PATH}}:{{LINE}} - {{DESCRIPTION}}
- (grouped for easy reference)

### Patterns Detected
- Any recurring issues across files
- Suggestions for codebase-wide improvements
```

## Rate Limiting

- Free tier: 2 reviews/hour
- If rate limited, wait and retry
- For large changes, consider reviewing in batches

## Fallback

If CodeRabbit CLI is unavailable:
1. Use the agent-code-review prompt instead
2. Note that CodeRabbit was skipped in the review report
