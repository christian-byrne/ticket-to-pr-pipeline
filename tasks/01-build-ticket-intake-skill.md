# Task: Build `ticket-intake` Skill

## Objective

Create an agent skill that parses a Notion ticket URL and extracts all relevant information to initialize a pipeline run.

## Prerequisites

- Notion MCP is connected and authenticated
- Run `claude mcp add --transport http notion https://mcp.notion.com/mcp` if not already done
- Authenticate via `/mcp` command

## Context

### Notion Database Details

**Database Name:** "Comfy Tasks"

**Filtering Criteria:**
- Assigned to current user → "active" tickets
- Assigned to "Frontend Team" → "up for grabs" tickets

**Note:** Filtering by "Team" in Notion may have quirks - handle gracefully.

**First Step - Discover Structure:**
Before building the skill, query Notion to discover the actual database structure:
1. Use `notion-search` to find "Comfy Tasks"
2. Use `notion-fetch` on a sample ticket to see all properties
3. Document the property names and types

Expected properties (verify these):
- Title/Name
- Status (Not Started, In Progress, In Review, Done)
- Assignee (Person)
- Slack Link (URL)
- GitHub PR (URL)
- Description (Rich text)
- Related Tasks (Relation)
- Priority
- Area/Category

### Pipeline Run Artifacts Location

Create artifacts in a git-tracked location within the pipeline repo:
```
/home/cbyrne/repos/ticket-to-pr-pipeline/runs/{ticket-id}/
├── status.json          # Current pipeline status
├── ticket.json          # Extracted ticket data
├── research-report.md   # Compiled research
├── plan.md              # High-level plan
├── tasks.md             # Implementation tasks
└── review-comments.md   # Review feedback
```

The `runs/` directory is gitignored for artifacts, but we may want to selectively commit important docs.

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/ticket-intake/SKILL.md`

### Frontmatter
```yaml
---
name: ticket-intake
description: Parse Notion ticket URL, extract all data, initialize pipeline run. Use when starting work on a new ticket.
---
```

### Skill Workflow

1. **Input:** Notion ticket URL from user
2. **Parse URL:** Extract page ID from URL
3. **Fetch Ticket:** Use `notion-fetch` to get full page content
4. **Extract Data:**
   - Title
   - Description / acceptance criteria
   - Linked Slack thread URL (if exists)
   - Related tasks (if any)
   - Current status
   - Assignee
   - Any other relevant properties
5. **Create Run Directory:**
   - Create `/home/cbyrne/repos/ticket-to-pr-pipeline/runs/{ticket-id}/`
   - Initialize `status.json`:
     ```json
     {
       "ticketId": "xxx",
       "ticketUrl": "https://notion.so/...",
       "status": "research",
       "startedAt": "ISO-timestamp",
       "lastUpdated": "ISO-timestamp"
     }
     ```
   - Save `ticket.json` with extracted data
6. **Update Notion:** 
   - Set Status → "In Progress"
   - Assign to current user (if not already)
7. **Output:** 
   - Print ticket summary
   - Print extracted Slack link (if any) for manual copy
   - Prompt to continue to research phase

### Error Handling

- Invalid URL → helpful error message
- Notion auth expired → prompt to re-authenticate
- Missing properties → note what's missing, continue with available data

## Deliverables

1. `SKILL.md` file at the correct location
2. Tested with a real ticket URL
3. Verified Notion update works

## Verification

```bash
# Test the skill by loading it and providing a ticket URL
# Verify:
# 1. Run directory is created
# 2. ticket.json contains expected data
# 3. Notion ticket status is updated
# 4. Output is clear and actionable
```

## Reference Files

- Implementation plan: `/home/cbyrne/repos/ticket-to-pr-pipeline/docs/implementation-plan.md` (Section 6.1)
- Existing skills for patterns: `/home/cbyrne/.claude/skills/`

## Notes

- Keep the skill focused - it only does intake, not research
- The skill should clearly indicate the next step (research phase)
- If Slack link exists, tell user to copy the thread content manually (Slack MCP not available)
