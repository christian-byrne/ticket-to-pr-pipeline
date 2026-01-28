# Task: Build `pr-creator` Skill

## Objective

Create an agent skill that generates a PR description, adds appropriate labels, creates the PR, and updates Notion.

## Prerequisites

- Final QA approved
- All changes committed
- Branch pushed to remote

## Context

### PR Template

From ComfyUI_frontend `.github/pull_request_template.md`:

```markdown
## Summary

<!-- One sentence describing what changed and why. -->

## Changes

- **What**: <!-- Core functionality added/modified -->
- **Breaking**: <!-- Any breaking changes (if none, remove this line) -->
- **Dependencies**: <!-- New dependencies (if none, remove this line) -->

## Review Focus

<!-- Critical design decisions or edge cases that need attention -->

<!-- If this PR fixes an issue, uncomment and update the line below -->
<!-- Fixes #ISSUE_NUMBER -->

## Screenshots (if applicable)

<!-- Add screenshots or video recording to help explain your changes -->
```

### PR Guidelines

From AGENTS.md:
- Keep it extremely concise and information-dense
- Don't use emojis or add excessive headers/sections
- Reference linked issues (e.g., `- Fixes #123`)

### Labels

ComfyUI_frontend uses `area:*` labels:
- `area:components`
- `area:stores`
- `area:api`
- `area:litegraph`
- `area:testing`
- etc.

Determine from files changed.

### GitHub CLI

```bash
gh pr create \
  --title "feat: {title}" \
  --body-file /path/to/body.md \
  --label "area:components" \
  --assignee "@me"
```

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/pr-creator/SKILL.md`

### Frontmatter
```yaml
---
name: pr-creator
description: Generate PR description, create PR with labels, update Notion. Use after final QA is approved.
---
```

### Skill Workflow

1. **Verify Ready:**
   - Confirm branch is not main
   - Confirm changes are committed
   - Check for conflicts with main:
     ```bash
     git fetch origin main
     git merge-base --is-ancestor origin/main HEAD || echo "may have conflicts"
     ```

2. **Handle Conflicts:**
   
   If conflicts detected:
   ```
   ⚠️ Branch may have conflicts with main.
   
   Options:
   A) Rebase onto main now
   B) Continue anyway (resolve later)
   C) Stop and investigate
   
   Choice:
   ```
   
   If rebase:
   ```bash
   git rebase origin/main
   # Handle conflicts if any
   ```

3. **Determine Commit Prefix:**
   
   From changes:
   - New feature → `feat:`
   - Bug fix → `fix:`
   - Tests only → `test:`
   - Refactor → `refactor:`
   - Docs → `docs:`

4. **Generate PR Title:**
   
   Format: `{prefix}: {concise description}`
   - Max ~60 characters
   - No period at end
   - Lowercase after prefix

5. **Generate PR Body:**
   
   Load from ticket and plan:
   ```markdown
   ## Summary
   
   {One sentence from ticket description}
   
   ## Changes
   
   - **What**: {Core functionality from plan.md}
   
   ## Review Focus
   
   {Key decisions or edge cases from plan.md}
   
   Fixes #{issue_number if exists}
   ```
   
   Remove Breaking/Dependencies sections if not applicable.

6. **Determine Labels:**
   
   From files changed:
   ```bash
   git diff --name-only origin/main...HEAD
   ```
   
   Map to labels:
   - `src/components/` → `area:components`
   - `src/stores/` → `area:stores`
   - `src/composables/` → `area:composables`
   - `browser_tests/` → `area:testing`
   - etc.

7. **Push Branch:**
   ```bash
   git push -u origin {branch-name}
   ```

8. **Create PR:**
   
   Save body to temp file, then:
   ```bash
   gh pr create \
     --title "{title}" \
     --body-file /tmp/pr-body.md \
     --label "{labels}" \
     --assignee "@me"
   ```

9. **Update Notion:**
   
   Using Notion MCP:
   - Add PR URL to ticket's "GitHub PR" property
   - Update Status → "In Review"

10. **Output:**
    ```
    ✅ PR Created
    
    URL: https://github.com/Comfy-Org/ComfyUI_frontend/pull/{number}
    
    Title: {title}
    Labels: {labels}
    
    Notion updated: Status → "In Review", PR linked
    
    Next: Wait for CI checks. Say "check CI" when ready to verify.
    ```

11. **Save State:**
    - Update `status.json`: status → "pr-created", prUrl → {url}
    - Save PR number for CI checking

## Deliverables

1. `SKILL.md` file at the correct location
2. PR description follows template exactly
3. Labels are correctly determined
4. Notion update works

## Verification

```bash
# After running:
# 1. PR exists on GitHub
# 2. Description follows template
# 3. Labels are appropriate
# 4. Notion ticket has PR link
# 5. Status updated to "In Review"
```

## Reference Files

- PR template: `ComfyUI_frontend/.github/pull_request_template.md`
- AGENTS.md: PR guidelines
- Implementation plan: Section 6.8

## Notes

- Keep description SHORT - no essays
- One sentence summary is key
- Only include Breaking/Dependencies if actually applicable
- Multiple area labels are fine
- Assignee should be @me (current user)
- Don't add reviewers automatically - let maintainers assign
