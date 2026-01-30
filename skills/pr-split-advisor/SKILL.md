---
name: pr-split-advisor
description: "Analyzes implementation plans and recommends PR splitting strategy. Use after a plan.md is approved to determine single PR, vertical slices, or stacked PRs approach."
---

# PR Split Advisor

Analyzes approved implementation plans and recommends single PR, vertical slices, or stacked PRs.

## When to Use

- After `plan-generator` produces approved `plan.md`
- When starting implementation of multi-file change
- Before creating branches/worktrees

## Workflow

### 1. Load and Parse Plan

```bash
cat runs/{ticket-id}/plan.md
```

Extract: files to modify/create (with LoC estimates), layers touched, dependencies between changes.

### 2. Apply Decision Rules

```
LoC < 200                              → Single PR
LoC 200-400 AND tightly coupled        → Single PR  
LoC > 300 AND spans multiple layers    → Consider splitting
Changes have no dependencies           → Vertical Slices
Changes have logical dependencies      → Stacked PRs
```

### 3. Generate Recommendation

```markdown
# PR Split Analysis

## Scope Summary
- **Estimated LoC:** {number}
- **Files affected:** {count}
- **Layers touched:** {list}

## Recommendation: {Single PR / Vertical Slices / Stacked PRs}

### Rationale
{Why this approach fits}

## Proposed Split

### PR 1: {Title}
- **Files:** `path/to/file1.ts`, `path/to/file2.ts`
- **Dependencies:** None
- **Estimated LoC:** {number}

### PR 2: {Title}
- **Files:** `path/to/file3.ts`
- **Dependencies:** PR 1 (if stacked) / None (if vertical)
```

### 4. Present Decision

```
Based on analysis, I recommend: {strategy}

Options:
A) Accept and set up {strategy}
B) Use vertical slices instead
C) Use stacked PRs instead  
D) Keep as single PR
```

### 5. Execute Setup

**Single PR:**
```bash
git checkout -b feat/{ticket-id}-{feature-name}
```

**Vertical Slices:**
```bash
wt-new {repo} pr1-{feature}
wt-new {repo} pr2-{feature}
```

**Stacked PRs:**
```bash
which gt || npm install -g @withgraphite/graphite-cli
gt init
gt create -m "feat: {PR 1 title}"
# After PR 1 work:
gt create -m "feat: {PR 2 title}"
gt submit
```

### 6. Update Plan

Add to `plan.md`:
```markdown
## PR Strategy
**Approach:** {strategy}
### PRs
1. **{PR 1 title}** - {files}
2. **{PR 2 title}** - {files}
```

Update `status.json` with strategy and PR branches.

## Split Strategies

| Strategy | Best For | Tools |
|----------|----------|-------|
| Vertical Slices | Independent changes, unrelated features | `wt-new`, `wt-multi-new` |
| Stacked PRs | Dependent changes (types→utils→components) | Graphite CLI |
| Single PR | <200 LoC, tightly coupled, simple fixes | Standard git |

## Graphite Fallback

If Graphite unavailable:
- Install: `npm install -g @withgraphite/graphite-cli`
- Manual stacking: `git checkout -b pr-2 pr-1`, rebase when pr-1 changes
- Or restructure to use vertical slices

## Best Practices

- Default to single PR for small changes
- Prefer vertical slices over stacked when possible
- Consider reviewer context—don't split so much that reviews lose coherence
- Label stacked PRs: "[1/3] Schema changes", "[2/3] API layer"
