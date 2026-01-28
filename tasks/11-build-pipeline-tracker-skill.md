# Task: Build `pipeline-tracker` Skill

## Objective

Create an agent skill that syncs pipeline status to Notion and provides a dashboard view of active pipeline runs.

## Prerequisites

- Notion MCP connected and authenticated
- "Comfy Tasks" database accessible

## Context

### Notion Database

**Name:** "Comfy Tasks"

**Properties to Update:**
- Status: Not Started → In Progress → In Review → Done
- GitHub PR: URL property
- Assignee: Person property

**Note:** Team assignment filtering may have quirks.

### Pipeline Status Locations

Each run stores state in:
```
/home/cbyrne/repos/ticket-to-pr-pipeline/runs/{ticket-id}/status.json
```

Status values:
- `research` - Gathering context
- `planning` - Creating plan
- `tasking` - Breaking into tasks
- `implementation` - Writing code
- `review` - Code review phase
- `qa` - Final QA
- `pr-ready` - Ready to create PR
- `pr-created` - PR exists
- `done` - Merged/complete
- `blocked` - Waiting on something

### Dashboard View

User should be able to see:
- All active pipeline runs
- Current phase of each
- Any blockers
- Links to PR and Notion ticket

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/pipeline-tracker/SKILL.md`

### Frontmatter
```yaml
---
name: pipeline-tracker
description: Sync pipeline status to Notion and view dashboard. Use anytime to check pipeline status or update Notion.
---
```

### Skill Workflow

#### Command: `status` (default)

Show dashboard of all active runs:

1. **Scan Runs Directory:**
   ```bash
   ls /home/cbyrne/repos/ticket-to-pr-pipeline/runs/
   ```

2. **Load Each Status:**
   Read `status.json` from each run directory.

3. **Present Dashboard:**
   ```markdown
   # Pipeline Dashboard
   
   ## Active Runs
   
   | Ticket | Status | Phase | PR | Last Updated |
   |--------|--------|-------|-----|--------------|
   | {title} | 🟢 Active | research | - | 2h ago |
   | {title} | 🟡 Review | pr-created | #123 | 1d ago |
   | {title} | 🔴 Blocked | implementation | - | 3d ago |
   
   ## Details
   
   ### {Ticket Title}
   - **Notion:** {url}
   - **Status:** {phase}
   - **Started:** {date}
   - **Last Updated:** {date}
   - **PR:** {url or "not created"}
   - **Blockers:** {any noted blockers}
   ```

4. **Options:**
   ```
   Options:
   A) Sync all to Notion
   B) View details for specific run
   C) Resume a run
   D) Archive completed runs
   ```

#### Command: `sync`

Update Notion with current status:

1. **For Each Active Run:**
   - Load `ticket.json` for Notion page ID
   - Load `status.json` for current phase
   
2. **Map Phase to Notion Status:**
   - research, planning, tasking, implementation → "In Progress"
   - review, qa, pr-ready, pr-created → "In Review"
   - done → "Done"
   - blocked → Keep current (add comment?)

3. **Update Notion:**
   Using Notion MCP:
   - Update Status property
   - Update PR link if exists
   - Ensure Assignee is set

4. **Report:**
   ```
   Synced {X} runs to Notion:
   - {Ticket 1}: Status → In Progress
   - {Ticket 2}: Status → In Review, PR → #123
   ```

#### Command: `resume {ticket-id}`

Resume a paused/stale run:

1. **Load Status:**
   Read `status.json` for the run.

2. **Determine Next Step:**
   Based on current phase:
   - research → load research-orchestrator skill
   - planning → load plan-generator skill
   - etc.

3. **Prompt:**
   ```
   Resuming: {Ticket Title}
   
   Current phase: {phase}
   Last updated: {date}
   
   Next step: {what skill to load}
   
   Continue? (Y/n)
   ```

#### Command: `archive`

Clean up completed runs:

1. **Find Completed:**
   Runs with status = "done"

2. **Archive:**
   - Move to `runs/archive/{ticket-id}/`
   - Or delete if confirmed

3. **Report:**
   ```
   Archived {X} completed runs.
   ```

## Status.json Schema

```json
{
  "ticketId": "xxx",
  "ticketTitle": "Feature name",
  "ticketUrl": "https://notion.so/...",
  "status": "research|planning|...|done|blocked",
  "prNumber": 123,
  "prUrl": "https://github.com/...",
  "startedAt": "2024-01-15T10:00:00Z",
  "lastUpdated": "2024-01-15T14:30:00Z",
  "blockers": ["Waiting for design feedback"],
  "notes": ["Slack thread context included"]
}
```

## Deliverables

1. `SKILL.md` file at the correct location
2. Dashboard view works
3. Notion sync works
4. Resume functionality works

## Verification

```bash
# Test scenarios:
# 1. Multiple active runs - dashboard shows all
# 2. Sync to Notion - status updates correctly
# 3. Resume a run - loads correct skill
# 4. Archive completed - moves/deletes properly
```

## Reference Files

- Implementation plan: Dashboard section
- Notion MCP docs: https://developers.notion.com/guides/mcp/

## Notes

- This is a utility skill - can be invoked anytime
- Keep dashboard concise - don't overwhelm
- Notion sync is optional but recommended
- Track blockers explicitly - helps prioritization
- Archive regularly to keep runs/ clean
