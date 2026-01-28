# Task: Build `plan-generator` Skill

## Objective

Create an agent skill that generates a high-level implementation plan from research findings, with iteration based on human feedback.

## Prerequisites

- `research-orchestrator` skill completed
- Research report exists at `{run-dir}/research-report.md`
- Human has reviewed and approved the research

## Context

### Planning Philosophy

From the original requirements:
> The prompt for how to create the plan is quite important as we want to make sure to include a bunch of pivot points, decision tree, considerations, risks, pros/cons. Basically, if at any point we made a decision where the next-best decision was almost as good, we want to flag that out and present it as a pivot point.

Key principles:
- High-level plan first, not implementation details yet
- Surface decision points and alternatives
- Include risks and mitigations
- Iterate with human before moving to tasks

### Reference Skill

Study the `writing-plans` skill for patterns:
```
/home/cbyrne/.claude/skills/writing-plans/SKILL.md
```

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/plan-generator/SKILL.md`

### Frontmatter
```yaml
---
name: plan-generator
description: Generate high-level implementation plan from research. Use after research is reviewed and approved.
---
```

### Skill Workflow

1. **Load Context:**
   - Read `ticket.json` for requirements
   - Read `research-report.md` for findings
   - Understand: what needs to be built, patterns to follow, risks identified

2. **Generate High-Level Plan:**
   
   Structure the plan as:
   ```markdown
   # Implementation Plan: {Ticket Title}
   
   ## Goal
   One sentence describing what we're building and why.
   
   ## Proposed Approach
   High-level description of the solution.
   
   ## Decision Points
   
   ### Decision 1: {Title}
   **Options:**
   - **Option A:** {description}
     - Pros: ...
     - Cons: ...
   - **Option B:** {description}
     - Pros: ...
     - Cons: ...
   
   **Recommended:** Option {X}
   **Rationale:** {why}
   **Pivot Trigger:** {when to reconsider}
   
   ### Decision 2: ...
   
   ## Architecture Overview
   How the solution fits into the existing codebase.
   
   ## Files to Modify
   - `path/to/file.ts` - {what changes}
   - `path/to/other.vue` - {what changes}
   
   ## Files to Create
   - `path/to/new.ts` - {purpose}
   
   ## Risks & Mitigations
   
   | Risk | Likelihood | Impact | Mitigation |
   |------|------------|--------|------------|
   | {risk} | Low/Med/High | Low/Med/High | {how to address} |
   
   ## Dependencies
   - External libraries needed (if any)
   - Other PRs that need to merge first
   - Backend changes required
   
   ## Testing Strategy
   - Unit tests needed
   - E2E tests needed
   - Manual testing approach
   
   ## Estimated Scope
   - Lines of code: ~{estimate}
   - Complexity: Low/Medium/High
   - PR split recommendation: Single/Vertical/Stacked
   
   ## Open Questions
   - Questions that need answers before implementation
   ```

3. **Save Plan:**
   - Save to `{run-dir}/plan.md`
   - Update `status.json`

4. **Present for Review:**
   - Print the plan
   - Ask for feedback:
     ```
     Please review the plan above.
     
     Options:
     1. Approve and continue to implementation tasks
     2. Provide feedback for revision
     3. Request more research on specific areas
     
     Your response:
     ```

5. **Iterate:**
   - If feedback provided, revise the plan
   - Continue until approved
   - Track revision history in the file

6. **On Approval:**
   - Update `status.json`: status → "tasking"
   - Prompt to continue to task generation

## Deliverables

1. `SKILL.md` file at the correct location
2. Tested with real research report
3. Plan includes all required sections

## Verification

```bash
# After running the skill:
# 1. Check runs/{ticket-id}/plan.md exists
# 2. Plan has all required sections
# 3. Decision points are clearly documented
# 4. Human can iterate before approval
```

## Reference Files

- Implementation plan: `/home/cbyrne/repos/ticket-to-pr-pipeline/docs/implementation-plan.md` (Section 6.3)
- Writing plans skill: `/home/cbyrne/.claude/skills/writing-plans/SKILL.md`
- ComfyUI_frontend AGENTS.md: `/home/cbyrne/cross-repo-tasks/ticket-to-pr-e2e-agent-pipeline/ComfyUI_frontend/AGENTS.md`

## Notes

- The plan is high-level - specific code goes in the tasks phase
- Decision points are critical - don't skip alternatives
- Be realistic about scope estimates
- Flag if scope suggests PR splitting
