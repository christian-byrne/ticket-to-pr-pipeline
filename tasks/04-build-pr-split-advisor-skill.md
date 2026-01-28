# Task: Build `pr-split-advisor` Skill

## Objective

Create an agent skill that analyzes the implementation plan and recommends whether/how to split the work into multiple PRs.

## Prerequisites

- `plan-generator` skill completed
- Plan approved and saved at `{run-dir}/plan.md`

## Context

### PR Splitting Guidelines

From ComfyUI_frontend AGENTS.md:
> Keep PRs focused and small. If it looks like the current changes will have 300+ lines of non-test code, suggest ways it could be broken into multiple PRs.

### Splitting Strategies

Reference the existing skill:
```
/home/cbyrne/.config/agents/skills/splitting-prs/SKILL.md
```

Three options:
1. **Vertical Slices** - Independent PRs that can merge in any order
2. **Stacked PRs** - Dependent chain using Graphite CLI
3. **Single PR** - Keep as one if <200 LoC or highly coupled

### Tools Available

- **git-worktree-utils** - For vertical slices (independent worktrees)
  - Reference: `/home/cbyrne/.claude/skills/worktree-utils/SKILL.md`
  - Commands: `wt-new`, `wt-multi-new`, etc.
  
- **Graphite CLI** - For stacked PRs
  - Commands: `gt create`, `gt submit`, `gt sync`
  - Install: `npm install -g @withgraphite/graphite-cli`

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/pr-split-advisor/SKILL.md`

### Frontmatter
```yaml
---
name: pr-split-advisor
description: Analyze plan and recommend PR splitting strategy. Use after plan is approved.
---
```

### Skill Workflow

1. **Load Plan:**
   - Read `plan.md` from run directory
   - Extract: files to modify, files to create, estimated scope

2. **Analyze Scope:**
   - Count estimated lines of code
   - Identify layer boundaries (components, stores, utils, tests)
   - Check for independent vs dependent changes
   - Look for natural split points

3. **Generate Recommendation:**
   
   ```markdown
   # PR Split Analysis
   
   ## Scope Summary
   - Estimated LoC: {number}
   - Files affected: {count}
   - Layers touched: {list}
   
   ## Recommendation: {Single PR / Vertical Slices / Stacked PRs}
   
   ### Rationale
   {Why this approach is recommended}
   
   ## Proposed Split (if applicable)
   
   ### PR 1: {Title}
   - **Scope:** {description}
   - **Files:** 
     - `path/to/file1.ts`
     - `path/to/file2.ts`
   - **Dependencies:** None
   - **Estimated LoC:** {number}
   
   ### PR 2: {Title}
   - **Scope:** {description}
   - **Files:**
     - `path/to/file3.ts`
   - **Dependencies:** PR 1 (if stacked)
   - **Estimated LoC:** {number}
   
   ## Setup Commands
   
   {If vertical slices:}
   ```bash
   # Create worktrees for each PR
   wt-multi-new {branch-prefix} ComfyUI_frontend
   # Or individual:
   wt-new ComfyUI_frontend pr1-{feature}
   wt-new ComfyUI_frontend pr2-{feature}
   ```
   
   {If stacked PRs:}
   ```bash
   # Initialize Graphite stack
   gt create -m "feat: {PR 1 title}"
   # After PR 1 work:
   gt create -m "feat: {PR 2 title}"
   # Submit stack:
   gt submit
   ```
   
   {If single PR:}
   No special setup needed. Continue with single branch.
   ```

4. **Present Decision:**
   ```
   Based on analysis, I recommend: {strategy}
   
   Options:
   A) Accept recommendation and set up {strategy}
   B) Use vertical slices instead
   C) Use stacked PRs instead
   D) Keep as single PR
   
   Your choice:
   ```

5. **Execute Setup:**
   - Based on choice, run the appropriate setup commands
   - For worktrees: use wt-* commands
   - For Graphite: initialize the stack
   - For single: just note the branch name

6. **Update Plan:**
   - Add "PR Strategy" section to `plan.md`
   - Document the chosen approach
   - Update `status.json`

7. **Output:**
   - Confirm setup complete
   - Print next steps for each PR/branch
   - Prompt to continue to task generation

## Deliverables

1. `SKILL.md` file at the correct location
2. Tested with plans of varying sizes
3. Works with worktree-utils and Graphite

## Verification

```bash
# After running the skill:
# 1. Recommendation is reasonable for the scope
# 2. Setup commands execute correctly
# 3. plan.md updated with strategy
# 4. Worktrees/stack created if applicable
```

## Reference Files

- Implementation plan: `/home/cbyrne/repos/ticket-to-pr-pipeline/docs/implementation-plan.md`
- Splitting PRs skill: `/home/cbyrne/.config/agents/skills/splitting-prs/SKILL.md`
- Worktree utils: `/home/cbyrne/.claude/skills/worktree-utils/SKILL.md`
- ComfyUI_frontend AGENTS.md: Guidelines on PR size

## Notes

- Default to single PR if under 200 LoC
- Prefer vertical slices over stacked when possible (easier to manage)
- Consider review burden - even 300 LoC may be fine if changes are simple
- If Graphite isn't installed, offer to install or fall back to manual stacking
