---
name: pipeline-tracker
description: "Syncs pipeline status to Notion and views dashboard. Use to check pipeline status, sync to Notion, resume runs, or archive completed work."
---

# Pipeline Tracker

Tracks ticket-to-PR pipeline runs, syncs status to Notion, and provides a dashboard view.

## Commands

Parse the user's request to determine which command to run:
- `status` (default) - Show dashboard of all runs
- `sync` - Update Notion with current status
- `resume {ticket-id}` - Resume a paused run
- `archive` - Clean up completed runs

## Configuration

```
RUNS_DIR=/home/cbyrne/repos/ticket-to-pr-pipeline/runs
NOTION_DATABASE=Comfy Tasks
```

## Command: status (default)

1. **Scan runs directory:**
   ```bash
   ls /home/cbyrne/repos/ticket-to-pr-pipeline/runs/
   ```

2. **For each run directory**, read `status.json`:
   ```bash
   cat /home/cbyrne/repos/ticket-to-pr-pipeline/runs/{ticket-id}/status.json
   ```

3. **Present dashboard:**
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
   - **Notion:** {ticketUrl}
   - **Status:** {status}
   - **Started:** {startedAt}
   - **Last Updated:** {lastUpdated}
   - **PR:** {prUrl or "not created"}
   - **Blockers:** {blockers array or "none"}
   ```

4. **Offer options:**
   ```
   Options:
   A) Sync all to Notion
   B) View details for specific run
   C) Resume a run
   D) Archive completed runs
   ```

### Status Icons
- 🟢 Active: research, planning, tasking, implementation
- 🟡 Review: review, qa, pr-ready, pr-created
- 🔴 Blocked: blocked
- ✅ Done: done

## Command: sync

Update Notion with current pipeline status.

1. **For each active run:**
   - Read `ticket.json` for Notion page ID
   - Read `status.json` for current phase

2. **Map phase to Notion Status:**
   | Pipeline Phase | Notion Status |
   |---------------|---------------|
   | research, planning, tasking, implementation | In Progress |
   | review, qa, pr-ready, pr-created | In Review |
   | done | Done |
   | blocked | (keep current) |

3. **Update Notion using MCP:**
   - Update Status property
   - Update GitHub PR property if prUrl exists
   - Ensure Assignee is set

4. **Report results:**
   ```
   Synced {X} runs to Notion:
   - {Ticket 1}: Status → In Progress
   - {Ticket 2}: Status → In Review, PR → #123
   ```

## Command: resume {ticket-id}

Resume a paused or stale pipeline run.

1. **Load status:**
   ```bash
   cat /home/cbyrne/repos/ticket-to-pr-pipeline/runs/{ticket-id}/status.json
   ```

2. **Determine next skill based on phase:**
   | Phase | Next Skill |
   |-------|------------|
   | research | research-orchestrator |
   | planning | plan-generator |
   | tasking | task-breakdown |
   | implementation | implementation-runner |
   | review | code-review |
   | qa | qa-runner |
   | pr-ready | pr-creator |
   | pr-created | (wait for merge) |
   | blocked | (show blockers, ask user) |

3. **Prompt user:**
   ```
   Resuming: {ticketTitle}
   
   Current phase: {status}
   Last updated: {lastUpdated}
   Blockers: {blockers or "none"}
   
   Next step: Load {skill-name} skill
   
   Continue? (Y/n)
   ```

4. **If confirmed**, load the appropriate skill.

## Command: archive

Clean up completed runs.

1. **Find completed runs** (status = "done"):
   ```bash
   for dir in /home/cbyrne/repos/ticket-to-pr-pipeline/runs/*/; do
     if [ -f "$dir/status.json" ]; then
       status=$(cat "$dir/status.json" | jq -r '.status')
       if [ "$status" = "done" ]; then
         echo "$dir"
       fi
     fi
   done
   ```

2. **List candidates and confirm:**
   ```
   Found {X} completed runs:
   - {ticket-id}: {title}
   
   Archive these? (Y/n)
   ```

3. **Archive (move to archive/):**
   ```bash
   mkdir -p /home/cbyrne/repos/ticket-to-pr-pipeline/runs/archive
   mv /home/cbyrne/repos/ticket-to-pr-pipeline/runs/{ticket-id} \
      /home/cbyrne/repos/ticket-to-pr-pipeline/runs/archive/
   ```

4. **Report:**
   ```
   Archived {X} completed runs.
   ```

## status.json Schema

```json
{
  "ticketId": "xxx",
  "ticketTitle": "Feature name",
  "ticketUrl": "https://notion.so/...",
  "status": "research|planning|tasking|implementation|review|qa|pr-ready|pr-created|done|blocked",
  "prNumber": 123,
  "prUrl": "https://github.com/...",
  "startedAt": "2024-01-15T10:00:00Z",
  "lastUpdated": "2024-01-15T14:30:00Z",
  "blockers": ["Waiting for design feedback"],
  "notes": ["Slack thread context included"]
}
```

## ticket.json Schema

```json
{
  "pageId": "notion-page-id",
  "title": "Ticket title",
  "url": "https://notion.so/...",
  "team": "frontend|backend|ml"
}
```

## Empty State

If no runs exist:
```
# Pipeline Dashboard

No active pipeline runs.

To start a new run, use the ticket-picker skill.
```

## Notion Properties

Update these properties in "Comfy Tasks" database:
- **Status**: Select property (Not Started, In Progress, In Review, Done)
- **GitHub PR**: URL property
- **Assignee**: Person property
