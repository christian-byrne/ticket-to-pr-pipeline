---
name: stacked-pr-manager
description: Manages stacked PRs for large changes. Creates, tracks, and coordinates dependent PR chains. Use when pr-split-advisor recommends stacked approach.
---

# Stacked PR Manager

Manages chains of dependent PRs that build on each other, coordinating merges and rebases.

## When to Use

- pr-split-advisor recommends "Stacked PRs"
- Change is too large for single PR (500+ LOC)
- Logical layers that must merge in sequence
- Want early review of foundational changes

## Concepts

### Stack Structure

```
main
  └── PR #1: Base types and interfaces
        └── PR #2: Core implementation
              └── PR #3: UI integration
                    └── PR #4: Tests
```

Each PR targets the previous PR's branch, not main.

### Naming Convention

```
feature/ticket-id/01-types
feature/ticket-id/02-core
feature/ticket-id/03-ui
feature/ticket-id/04-tests
```

## Workflow

### 1. Initialize Stack

From approved plan with multiple PRs:

```bash
TICKET_ID="ABC-123"
STACK_NAME="feature/$TICKET_ID"

# Create base branch from main
git checkout main
git pull origin main
git checkout -b "$STACK_NAME/01-types"
```

Create stack manifest:

```bash
cat > "$RUN_DIR/stack.json" << 'EOF'
{
  "ticketId": "ABC-123",
  "baseBranch": "main",
  "branches": [
    {"order": 1, "branch": "feature/ABC-123/01-types", "title": "Add type definitions", "status": "pending"},
    {"order": 2, "branch": "feature/ABC-123/02-core", "title": "Implement core logic", "status": "pending"},
    {"order": 3, "branch": "feature/ABC-123/03-ui", "title": "Add UI components", "status": "pending"},
    {"order": 4, "branch": "feature/ABC-123/04-tests", "title": "Add test coverage", "status": "pending"}
  ],
  "currentBranch": 1
}
EOF
```

### 2. Implement Each Layer

For each branch in sequence:

```bash
# Work on current branch
git checkout "$STACK_NAME/01-types"

# ... implement changes ...

# Commit and push
git add -A
git commit -m "feat: add type definitions for feature X"
git push -u origin "$STACK_NAME/01-types"
```

### 3. Create Stacked PRs

Create PRs targeting previous branch:

```bash
# First PR targets main
gh pr create \
  --base main \
  --head "$STACK_NAME/01-types" \
  --title "feat: add type definitions [1/4]" \
  --body "Part 1 of 4: Type definitions

## Stack
- **→ PR #1: Types** (this PR)
- PR #2: Core implementation
- PR #3: UI integration  
- PR #4: Tests

## Changes
- Added interfaces for...
"

# Subsequent PRs target previous branch
gh pr create \
  --base "$STACK_NAME/01-types" \
  --head "$STACK_NAME/02-core" \
  --title "feat: implement core logic [2/4]" \
  --body "Part 2 of 4: Core implementation

## Stack
- PR #1: Types ✓
- **→ PR #2: Core** (this PR)
- PR #3: UI integration
- PR #4: Tests

Depends on: #PR_NUMBER_1
"
```

### 4. Track Stack State

Update manifest after each PR:

```bash
jq '.branches[0].status = "pr-created" | .branches[0].prNumber = 123' \
  "$RUN_DIR/stack.json" > tmp && mv tmp "$RUN_DIR/stack.json"
```

### 5. Handle Reviews

When PR #1 gets review feedback:

1. Fix issues on branch 01-types
2. Push fixes
3. Rebase all downstream branches:

```bash
# After fixing PR #1
git checkout "$STACK_NAME/02-core"
git rebase "$STACK_NAME/01-types"
git push --force-with-lease

git checkout "$STACK_NAME/03-ui"
git rebase "$STACK_NAME/02-core"
git push --force-with-lease

# Continue for all downstream branches
```

### 6. Merge Sequence

PRs must merge in order:

```bash
# Merge PR #1 (into main)
gh pr merge PR_1 --squash

# Update PR #2 base to main
gh pr edit PR_2 --base main

# Merge PR #2
gh pr merge PR_2 --squash

# Continue...
```

### 7. Rebase Helper Script

For complex stacks, use rebase cascade:

```bash
#!/bin/bash
# rebase-stack.sh

STACK_PREFIX="feature/ABC-123"
BRANCHES=("01-types" "02-core" "03-ui" "04-tests")

for i in "${!BRANCHES[@]}"; do
  branch="$STACK_PREFIX/${BRANCHES[$i]}"
  
  if [ $i -eq 0 ]; then
    base="main"
  else
    base="$STACK_PREFIX/${BRANCHES[$((i-1))]}"
  fi
  
  echo "Rebasing $branch onto $base"
  git checkout "$branch"
  git rebase "$base"
  git push --force-with-lease
done
```

## Stack Status Dashboard

```markdown
# Stack Status: ABC-123

| # | Branch | PR | Status | CI |
|---|--------|-----|--------|-----|
| 1 | 01-types | #123 | ✅ Merged | ✅ |
| 2 | 02-core | #124 | 🔄 In Review | ✅ |
| 3 | 03-ui | #125 | ⏳ Waiting | ⏳ |
| 4 | 04-tests | #126 | ⏳ Waiting | ⏳ |

**Current:** PR #124 awaiting approval
**Blocked:** PRs #125, #126 waiting on #124
```

## Conflict Resolution

When rebasing causes conflicts:

```markdown
⚠️ Conflict in stack rebase

Branch: feature/ABC-123/03-ui
Conflicting files:
- src/components/Feature.vue

Options:
1. Resolve conflicts interactively
2. Show conflict details
3. Abort rebase and investigate

Your choice:
```

## Best Practices

1. **Keep PRs small** - Each should be 100-300 LOC
2. **Independent where possible** - Minimize cross-PR dependencies
3. **Clear boundaries** - Each PR should have a clear purpose
4. **Test each layer** - Don't defer all tests to final PR
5. **Communicate in PR** - Reference full stack in description

## Stack Templates

### Feature Stack (typical)
1. Types/interfaces
2. Core logic
3. UI components
4. Tests

### Refactor Stack
1. Add deprecation warnings
2. Introduce new implementation
3. Migrate usages
4. Remove deprecated code

### Migration Stack
1. Add new schema
2. Dual-write to old and new
3. Backfill data
4. Remove old schema

## Integration with Pipeline

**Before:** pr-split-advisor (recommends stacked approach)
**After:** pr-creator (for each PR in stack)

Status transitions per PR:
- `pending` → `implementing` → `pr-created` → `in-review` → `merged`

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| stack.json | `runs/{ticket-id}/stack.json` | Stack manifest and state |
| status.json | `runs/{ticket-id}/status.json` | Overall pipeline status |
