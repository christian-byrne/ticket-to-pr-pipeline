---
name: ticket-intake
description: "Parse Notion ticket URL, extract all data, initialize pipeline run. Use when starting work on a new ticket or when asked to pick up a ticket."
---

# Ticket Intake

Parses a Notion ticket URL, extracts all relevant information, and initializes a pipeline run directory for tracking work.

## Quick Start

When given a Notion ticket URL:

1. Parse the URL to extract page ID
2. Fetch ticket content via Notion MCP
3. Extract all relevant properties
4. Create pipeline run directory with artifacts
5. Update Notion ticket status
6. Output summary and next steps

## Prerequisites

- Notion MCP connected and authenticated
- If not setup: `claude mcp add --transport http notion https://mcp.notion.com/mcp`
- Authenticate via `/mcp` command if prompted

## Workflow

### Step 1: Parse Notion URL

Extract page ID from URL formats:

```
https://www.notion.so/workspace/Page-Title-abc123def456...
https://notion.so/Page-Title-abc123def456...
https://www.notion.so/abc123def456...
```

Page ID is the 32-character hex string (with or without hyphens).

### Step 2: Fetch Ticket Content

Use `Notion:notion-fetch` with the page URL or ID:

```
Fetch the full page content including all properties
```

### Step 3: Extract Ticket Data

Extract these properties (names may vary):

| Property | Expected Name | Type |
|----------|--------------|------|
| Title | Name / Title | Title |
| Status | Status | Select |
| Assignee | Assignee / Assigned To | Person |
| Description | - | Page content |
| Slack Link | Slack Link / Slack Thread | URL |
| GitHub PR | GitHub PR / PR Link | URL |
| Priority | Priority | Select |
| Area | Area / Category | Select |
| Related Tasks | Related Tasks | Relation |

**If properties are missing**: Note what's unavailable and continue with available data.

### Step 4: Create Pipeline Run Directory

Create directory structure at:

```
/home/cbyrne/repos/ticket-to-pr-pipeline/runs/{ticket-id}/
├── status.json          # Current pipeline status
├── ticket.json          # Extracted ticket data
├── research-report.md   # (created later)
├── plan.md              # (created later)
├── tasks.md             # (created later)
└── review-comments.md   # (created later)
```

**Generate ticket-id**: Use short form of page ID (first 8 characters) or sanitized title.

**Initialize status.json**:

```json
{
  "ticketId": "abc12345",
  "ticketUrl": "https://notion.so/...",
  "status": "research",
  "startedAt": "2024-01-15T10:30:00Z",
  "lastUpdated": "2024-01-15T10:30:00Z"
}
```

**Initialize ticket.json**:

```json
{
  "id": "abc12345",
  "url": "https://notion.so/...",
  "title": "Ticket title",
  "status": "Not Started",
  "assignee": "Name",
  "priority": "High",
  "area": "UI",
  "description": "Full description text",
  "acceptanceCriteria": ["Criterion 1", "Criterion 2"],
  "slackLink": "https://slack.com/...",
  "githubPR": null,
  "relatedTasks": [],
  "fetchedAt": "2024-01-15T10:30:00Z"
}
```

### Step 5: Update Notion Ticket

Use `Notion:notion-update-page` to update the ticket:

1. **Status**: Set to "In Progress"
2. **Assignee**: Assign to current user (if not already assigned)

If update fails, note the error but continue - this is not blocking.

### Step 6: Output Summary

Print a clear summary:

```markdown
## Ticket Intake Complete

**Title:** [Ticket title]
**ID:** abc12345
**Status:** In Progress (updated)
**Priority:** High
**Area:** UI

### Description
[Brief description or first 200 chars]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

### Links
- **Ticket:** [Notion link]
- **Slack:** [Slack link] ← Copy thread content manually if needed

### Pipeline Run
- **Directory:** /home/cbyrne/repos/ticket-to-pr-pipeline/runs/abc12345/
- **Status:** Research phase initialized

---

**Next Step:** Load the `research-orchestrator` skill to begin research phase.
```

## Error Handling

### Invalid URL

```
❌ Invalid Notion URL format.
Expected: https://notion.so/... or https://www.notion.so/...
Received: [provided URL]
```

### Authentication Error

```
⚠️ Notion authentication required.
Run: claude mcp add --transport http notion https://mcp.notion.com/mcp
Then authenticate via /mcp command.
```

### Missing Properties

Continue with available data and note what's missing:

```
⚠️ Some properties unavailable:
- Slack Link: not found
- Related Tasks: not found

Proceeding with available data...
```

### Page Not Found

```
❌ Notion page not found or inaccessible.
- Check the URL is correct
- Ensure you have access to this page
- Try re-authenticating via /mcp
```

## Database Reference: Comfy Tasks

The "Comfy Tasks" database may have these properties (verify via `notion-search`):

- **Status values**: Not Started, In Progress, In Review, Done
- **Team assignment**: "Frontend Team" for unassigned tickets
- **Filtering note**: Team filtering in Notion may have quirks - handle gracefully

### Finding Active Tickets

To list your active tickets:

```
Use Notion:notion-search for "Comfy Tasks"
Filter by Assignee = current user OR Team = "Frontend Team"
```

## Slack Thread Handling

If a Slack link exists:

1. Print the link prominently
2. Instruct user to manually copy thread content
3. Thread content can be pasted into research phase

```
📋 **Manual Action Required:**
Slack MCP not available. Please copy the thread content from:
[Slack URL]

Paste into the research phase when prompted.
```

## Notes

- This skill focuses ONLY on intake - it does not do research
- Always create the run directory even if some data is missing
- Pipeline status tracks progress through phases: research → planning → implementation → review → QA → done
- The `runs/` directory is gitignored - artifacts stay local
