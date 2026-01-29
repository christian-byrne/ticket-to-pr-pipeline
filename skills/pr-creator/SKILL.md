---
name: pr-creator
description: Generate PR description, create PR with labels, update Notion. Use after final QA is approved and changes are committed.
---

# PR Creator

Creates a GitHub PR from committed changes with proper description, labels, and Notion integration.

## Prerequisites

- Branch is not `main`
- All changes committed
- Branch pushed to remote

## Workflow

### 1. Verify Ready

```bash
# Confirm not on main
git branch --show-current | grep -v '^main$'

# Confirm clean working tree
git status --porcelain

# Check for conflicts with main
git fetch origin main
git merge-base --is-ancestor origin/main HEAD || echo "CONFLICTS_POSSIBLE"
```

### 2. Handle Conflicts

If conflicts detected, present options:

```
⚠️ Branch may have conflicts with main.

Options:
A) Rebase onto main now
B) Continue anyway (resolve later)
C) Stop and investigate

Choice:
```

If rebase selected: `git rebase origin/main`

### 3. Determine Commit Prefix

From changes, select one:
- New feature → `feat:`
- Bug fix → `fix:`
- Tests only → `test:`
- Refactor → `refactor:`
- Docs → `docs:`

### 4. Generate PR Title

Format: `{prefix}: {concise description}`
- Max ~60 characters
- No period at end
- Lowercase after prefix

### 5. Generate PR Body

Use this template:

```markdown
## Summary

{One sentence from ticket description}

## Changes

- **What**: {Core functionality from plan.md}

## Review Focus

{Key decisions or edge cases from plan.md}

Fixes #{issue_number}
```

Remove Breaking/Dependencies sections if not applicable. Keep it SHORT.

### 6. Determine Labels

Get changed files:
```bash
git diff --name-only origin/main...HEAD
```

Map to `area:*` labels:
- `src/components/` → `area:components`
- `src/stores/` → `area:stores`
- `src/composables/` → `area:composables`
- `src/api/` → `area:api`
- `src/scripts/` → `area:litegraph`
- `browser_tests/` → `area:testing`

Multiple labels are fine.

### 7. Push Branch

```bash
git push -u origin $(git branch --show-current)
```

### 8. Create PR

```bash
# Save body to temp file first
cat > /tmp/pr-body.md << 'EOF'
{generated body}
EOF

gh pr create \
  --title "{title}" \
  --body-file /tmp/pr-body.md \
  --label "{labels}" \
  --assignee "@me"
```

### 9. Update Notion

**⚠️ Follow [Notion Write Safety](/home/cbyrne/repos/ticket-to-pr-pipeline/docs/notion-write-safety.md) rules.**

Using Notion MCP:
- Add PR URL to ticket's "GitHub PR" property
- Update Status → "In Review" (only valid from "In Progress")

**Pre-write validation:**
- Verify page ID exists in ticket.json
- Validate PR URL matches `^https://github\.com/[^/]+/[^/]+/pull/\d+$`
- Confirm transition In Progress → In Review is valid

**Log each write** to `status.json`:
```json
{
  "notionWrites": [
    {"field": "GitHub PR", "value": "{url}", "previousValue": null, "at": "...", "skill": "pr-creator", "success": true},
    {"field": "Status", "value": "In Review", "previousValue": "In Progress", "at": "...", "skill": "pr-creator", "success": true}
  ]
}
```

If updates fail, log with `success: false` and continue.

### 10. Output

```
✅ PR Created

URL: https://github.com/Comfy-Org/ComfyUI_frontend/pull/{number}

Title: {title}
Labels: {labels}

Notion updated: Status → "In Review", PR linked

Next: Wait for CI checks. Say "check CI" when ready to verify.
```

### 11. Save State

Update `status.json`:
```json
{
  "status": "pr-created",
  "prUrl": "{url}",
  "prNumber": "{number}"
}
```

## Guidelines

- Keep description SHORT - no essays
- One sentence summary is key
- Only include Breaking/Dependencies if actually applicable
- Don't add reviewers - let maintainers assign
- Assignee should always be `@me`
