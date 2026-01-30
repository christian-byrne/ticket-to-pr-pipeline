# Git History Research Subagent

## Objective

Research the git history for context relevant to implementing the given ticket.

## Input Context

```
Ticket: {{TICKET_TITLE}}
Description: {{TICKET_DESCRIPTION}}
Affected Files (estimated): {{AFFECTED_FILES}}
Keywords: {{KEYWORDS}}
```

## Research Tasks

### 1. Recent Commits (90 days)

Search for commits touching the affected files or containing relevant keywords:

```bash
# Commits touching specific files
git log --oneline --since="90 days ago" -- {{AFFECTED_FILES}}

# Commits with relevant keywords
git log --oneline --all --grep="{{KEYWORD}}" --since="90 days ago"

# Show details for relevant commits
git show --stat {{COMMIT_HASH}}
```

### 2. File History & Blame

Understand who has worked on these files and why:

```bash
# Full file history
git log --oneline --follow -- {{FILE_PATH}}

# Blame to understand authorship
git blame {{FILE_PATH}} | head -50

# Blame summary by author
git blame --line-porcelain {{FILE_PATH}} | grep "^author " | sort | uniq -c | sort -rn
```

### 3. Recent Changes Pattern

Look for patterns in how similar changes were made:

```bash
# Files changed together
git log --oneline --name-only --since="90 days ago" -- {{FILE_PATH}} | grep -E "^\w"

# Diff of specific commits for patterns
git diff {{COMMIT_HASH}}^..{{COMMIT_HASH}}
```

## Output Format

```markdown
## Git History Research Report

### Summary

- X commits found touching affected files in last 90 days
- Primary authors: [list]
- Key patterns observed: [list]

### Relevant Commits

#### Commit: {{HASH}} - {{TITLE}}

- **Author:** {{AUTHOR}}
- **Date:** {{DATE}}
- **Files:** {{FILES}}
- **Relevance:** Why this is relevant to the current ticket
- **Pattern/Lesson:** What we can learn from this change

### File Ownership

| File            | Primary Author | Recent Activity      |
| --------------- | -------------- | -------------------- |
| path/to/file.ts | @author        | 5 commits in 90 days |

### Observations

- Any patterns in how similar features were implemented
- Testing approaches used
- Review feedback from commit messages

### Recommendations

- Based on history, suggest approach for current ticket
```

## Success Criteria

- Found all commits touching affected files in last 90 days
- Identified primary authors who might be good reviewers
- Extracted relevant patterns or lessons from history
- Provided actionable recommendations
