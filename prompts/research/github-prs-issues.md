# GitHub PRs & Issues Research Subagent

## Objective

Research related PRs and issues on GitHub for context relevant to implementing the given ticket.

## Input Context

```
Ticket: {{TICKET_TITLE}}
Description: {{TICKET_DESCRIPTION}}
Affected Files (estimated): {{AFFECTED_FILES}}
Keywords: {{KEYWORDS}}
Repository: Comfy-Org/ComfyUI_frontend
```

## Research Tasks

### 1. Related Open PRs

Search for open PRs that might be related:

```bash
# Search PRs by keyword
gh pr list --state open --search "{{KEYWORD}}"

# PRs touching same files
gh pr list --state open --search "path:{{FILE_PATH}}"

# View specific PR details
gh pr view {{PR_NUMBER}}
```

### 2. Recent Closed/Merged PRs

Find patterns from recently completed work:

```bash
# Search merged PRs
gh pr list --state merged --limit 50 --search "{{KEYWORD}}"

# Get PR with reviews and comments
gh pr view {{PR_NUMBER}} --comments

# View PR diff
gh pr diff {{PR_NUMBER}}
```

### 3. Related Issues

Find issues that might provide context:

```bash
# Search issues by keyword
gh issue list --state all --search "{{KEYWORD}}"

# View issue details
gh issue view {{ISSUE_NUMBER}}
```

### 4. PR Review Patterns

Extract lessons from PR reviews:

```bash
# Get review comments from relevant PRs
gh pr view {{PR_NUMBER}} --comments
```

## Output Format

```markdown
## GitHub PRs & Issues Research Report

### Summary
- X open PRs potentially related
- X merged PRs with relevant patterns
- X issues with useful context

### Related Open PRs

#### PR #{{NUMBER}}: {{TITLE}}
- **Author:** @{{AUTHOR}}
- **Status:** {{STATUS}}
- **Files:** {{FILES}}
- **Relevance:** Why this PR is related
- **Coordination Needed:** Whether we need to coordinate

### Relevant Merged PRs

#### PR #{{NUMBER}}: {{TITLE}}
- **Author:** @{{AUTHOR}}
- **Merged:** {{DATE}}
- **Files:** {{FILES}}
- **Pattern/Lesson:** What we can learn from this PR
- **Review Feedback:** Key feedback from reviews

### Related Issues

#### Issue #{{NUMBER}}: {{TITLE}}
- **Status:** Open/Closed
- **Context:** What this issue tells us about the problem
- **Solution Notes:** If closed, what was the solution

### Review Patterns Observed
- Common feedback themes in related PRs
- Testing expectations
- Documentation requirements

### Recommendations
- Lessons to apply to current implementation
- Potential reviewers based on related PRs
- Things to avoid based on review feedback
```

## Success Criteria

- Identified any conflicting open PRs
- Found patterns from related merged PRs
- Extracted useful context from issues
- Compiled lessons learned from reviews
