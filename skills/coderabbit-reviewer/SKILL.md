---
name: coderabbit-reviewer
description: Integrates CodeRabbit for automated PR code review. Use after PR creation to get AI-powered review feedback before human review.
---

# CodeRabbit Reviewer

Triggers CodeRabbit automated review on PRs and processes the feedback for actionable fixes.

## Prerequisites

- PR created and pushed to GitHub
- CodeRabbit installed on the repository (github.com/apps/coderabbitai)
- `gh` CLI authenticated

## Setup

### Install CodeRabbit on Repository

1. Go to https://github.com/apps/coderabbitai
2. Install on Comfy-Org/ComfyUI_frontend
3. CodeRabbit will automatically review new PRs

### Optional: CodeRabbit CLI

```bash
# Install CLI for local reviews
npm install -g coderabbit

# Authenticate
coderabbit auth
```

## Workflow

### 1. Verify PR Exists

```bash
PR_NUMBER=$(gh pr view --json number -q '.number')
echo "PR #$PR_NUMBER"
```

### 2. Trigger Review (if not auto)

CodeRabbit reviews automatically on PR creation. To manually trigger:

```bash
# Comment to trigger review
gh pr comment $PR_NUMBER --body "@coderabbitai review"
```

Or for specific files:
```bash
gh pr comment $PR_NUMBER --body "@coderabbitai review src/components/NewFeature.vue"
```

### 3. Wait for Review

Poll for CodeRabbit comment:

```bash
# Check for CodeRabbit review comment
gh pr view $PR_NUMBER --json comments --jq '.comments[] | select(.author.login == "coderabbitai")'
```

Typical wait time: 2-5 minutes for small PRs.

### 4. Parse Review Feedback

Extract actionable items from CodeRabbit's review:

```markdown
## CodeRabbit Review Summary

### Critical Issues
- [ ] {file:line} - {issue description}

### Suggestions  
- [ ] {file:line} - {suggestion}

### Nitpicks
- [ ] {file:line} - {minor improvement}

### Praise
- ✓ {positive feedback}
```

### 5. Categorize by Severity

| Category | Action Required | Auto-fixable |
|----------|----------------|--------------|
| Critical | Must fix before merge | Sometimes |
| Suggestion | Should consider | Often |
| Nitpick | Nice to have | Usually |
| Praise | No action | N/A |

### 6. Present to User

```
CodeRabbit Review Complete

## Summary
- Critical: 2 issues
- Suggestions: 5 items
- Nitpicks: 3 items

## Critical Issues (must fix)
1. src/components/Feature.vue:45 - Potential null reference
2. src/stores/data.ts:23 - Missing error handling

## Top Suggestions
1. src/utils/helper.ts:12 - Consider using computed property
2. ...

Options:
1. Auto-fix critical issues
2. Show all feedback details
3. Dismiss and proceed to human review
4. Request re-review after changes

Your choice:
```

### 7. Auto-Fix Flow

For fixable issues, dispatch subagents:

**Critical Fix Subagent:**
```
Fix CodeRabbit critical issue in ComfyUI_frontend:

File: {file}
Line: {line}
Issue: {description}
Suggestion: {CodeRabbit's suggestion}

Apply fix and verify with `pnpm typecheck`.
```

### 8. Request Re-Review

After fixes:

```bash
# Commit fixes
git add -A
git commit -m "fix: address CodeRabbit review feedback"
git push

# Request re-review
gh pr comment $PR_NUMBER --body "@coderabbitai review"
```

### 9. Update Status

```bash
jq '.coderabbitReview = {
  "reviewedAt": now,
  "critical": N,
  "suggestions": N,
  "fixed": N,
  "dismissed": N
}' "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

## CodeRabbit Commands

Trigger via PR comments:

| Command | Purpose |
|---------|---------|
| `@coderabbitai review` | Full review |
| `@coderabbitai review <file>` | Review specific file |
| `@coderabbitai summary` | Generate PR summary |
| `@coderabbitai resolve` | Mark threads resolved |
| `@coderabbitai configuration` | Show current config |

## Configuration

Create `.coderabbit.yaml` in repo root for custom rules:

```yaml
reviews:
  auto_review:
    enabled: true
  path_filters:
    - "!**/*.test.ts"  # Skip test files
  
language_settings:
  typescript:
    enabled: true
  vue:
    enabled: true

tone: professional
```

## Integration with Pipeline

**Before:** pr-creator (PR exists)
**After:** review-orchestrator (human review)

Recommended flow:
1. PR created → CodeRabbit auto-reviews
2. Fix critical issues
3. Human review with CodeRabbit context
4. Merge

## Handling Review Conflicts

If CodeRabbit suggestions conflict with project patterns:

```markdown
CodeRabbit suggests: Use optional chaining
Project pattern: Explicit null checks preferred

Options:
1. Follow CodeRabbit (modern JS)
2. Follow project pattern (consistency)
3. Ask maintainer preference

Your choice:
```

Log decision for future reference.

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| coderabbit-review.md | `runs/{ticket-id}/coderabbit-review.md` | Parsed review feedback |
| status.json | `runs/{ticket-id}/status.json` | Review stats |
