---
name: plan-generator
description: Generates high-level implementation plan from research findings. Use after research is reviewed and approved. Iterates with human before moving to tasks.
---

# Plan Generator

Generates a high-level implementation plan from ticket requirements and research findings. Surfaces decision points, alternatives, risks, and pivot triggers. Iterates with human feedback until approved.

## Prerequisites

- `ticket.json` exists at `runs/{ticket-id}/ticket.json`
- `research-report.md` exists at `runs/{ticket-id}/research-report.md`
- Human has reviewed and approved the research

## Workflow

### 1. Load Context

Read the inputs from the run directory:

```bash
# Find the run directory (passed as argument or use most recent)
RUN_DIR="runs/{ticket-id}"

# Read inputs
cat "$RUN_DIR/ticket.json"
cat "$RUN_DIR/research-report.md"
```

Extract from ticket.json:

- Title and description
- Acceptance criteria
- Affected files/areas

Extract from research-report.md:

- Recommended patterns
- Similar implementations found
- Risks identified
- Open questions

### 2. Generate High-Level Plan

Create the plan following this structure:

```markdown
# Implementation Plan: {Ticket Title}

## Goal

One sentence describing what we're building and why.

## Proposed Approach

High-level description of the solution (2-3 paragraphs max).

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
**Rationale:** {why this option}
**Pivot Trigger:** {when to reconsider this decision}

### Decision 2: ...

## Architecture Overview

How the solution fits into the existing codebase. Reference patterns from research.

## Files to Modify

- `path/to/file.ts` - {what changes}
- `path/to/other.vue` - {what changes}

## Files to Create

- `path/to/new.ts` - {purpose}

## Risks & Mitigations

| Risk   | Likelihood   | Impact       | Mitigation       |
| ------ | ------------ | ------------ | ---------------- |
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

---

_Revision: 1_
_Generated: {timestamp}_
```

### 3. Save Plan

Save to the run directory:

```bash
# Save plan
echo "$PLAN_CONTENT" > "$RUN_DIR/plan.md"

# Update status.json
jq '.status = "planning" | .planVersion = 1 | .lastUpdated = now' \
  "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

### 4. Present for Review

Print the full plan, then prompt:

```
Please review the plan above.

Options:
1. Approve and continue to implementation tasks
2. Provide feedback for revision
3. Request more research on specific areas

Your response:
```

### 5. Handle Feedback

**If feedback provided:**

- Revise the plan addressing the feedback
- Increment revision number
- Append revision history to the plan
- Re-present for review

**If more research requested:**

- Note which areas need research
- Update status to "research-needed"
- Return to research-orchestrator

**If approved:**

- Update status.json: `status → "tasking"`
- Prompt to continue to task generation

```bash
# On approval
jq '.status = "tasking" | .planApproved = true | .planApprovedAt = now' \
  "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

## Decision Point Guidelines

Decision points are critical. For each significant choice:

1. **Identify alternatives** - What else could we do?
2. **Evaluate trade-offs** - Pros/cons of each
3. **Recommend with rationale** - Why this choice?
4. **Define pivot triggers** - When would we switch?

Examples of decision points:

- Which component pattern to use (composable vs. store vs. props)
- Where to place new code (new file vs. extend existing)
- API design choices
- State management approach
- Testing strategy (unit vs. E2E focus)

## Scope Assessment

When estimating scope:

- **Small (< 200 LOC)**: Single PR, straightforward
- **Medium (200-500 LOC)**: Single PR, may need careful review
- **Large (500+ LOC)**: Consider splitting into multiple PRs

If scope suggests splitting, recommend:

- **Vertical slices**: Each PR delivers working feature subset
- **Stacked PRs**: Layered changes building on each other

## Revision History Format

When revising, append to the plan:

```markdown
---

## Revision History

### Revision 2 - {timestamp}

**Feedback:** {summary of feedback}
**Changes:**

- Changed X to Y because...
- Added consideration for Z...
```

## Output Artifacts

| File        | Location                       | Description                  |
| ----------- | ------------------------------ | ---------------------------- |
| plan.md     | `runs/{ticket-id}/plan.md`     | The implementation plan      |
| status.json | `runs/{ticket-id}/status.json` | Updated with planning status |

## Next Step

After plan approval, invoke `plan-to-tasks` to convert the plan into implementation tasks.
