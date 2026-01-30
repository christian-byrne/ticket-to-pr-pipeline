# Notion Related Pages Research Subagent

## Objective

Research related Notion pages and tasks for additional context relevant to the given ticket.

## Input Context

```
Ticket URL: {{NOTION_URL}}
Ticket Title: {{TICKET_TITLE}}
Linked Pages: {{LINKED_PAGES}}
Keywords: {{KEYWORDS}}
```

## Prerequisites

- Notion MCP connected and authenticated
- Access to the workspace containing the ticket

## Research Tasks

### 1. Extract Linked Pages

From the ticket, identify and fetch:

- Related tasks (linked in properties)
- Parent pages
- Referenced pages in the content

```
Use notion-fetch to get full content of linked pages
```

### 2. Search for Related Tasks

Search the workspace for related tickets:

```
Use notion-search with keywords from the ticket
Focus on:
- Similar feature requests
- Related bug reports
- Previous implementations
```

### 3. Find Example Tasks

Look for completed tasks that might serve as examples:

```
Search for tasks with similar scope that are marked "Done"
Extract implementation notes and learnings
```

## Output Format

```markdown
## Notion Related Pages Report

### Summary

- X linked pages found
- X related tasks discovered
- Key context extracted: {{SUMMARY}}

### Linked Pages

#### {{PAGE_TITLE}}

- **URL:** {{URL}}
- **Type:** Task/Doc/Spec
- **Relevance:** Why this is relevant
- **Key Information:**
  - Important detail 1
  - Important detail 2

### Related Tasks

#### {{TASK_TITLE}}

- **Status:** {{STATUS}}
- **Assignee:** {{ASSIGNEE}}
- **Relevance:** How this relates to current ticket
- **Learnings:** What we can learn from this task

### Context from Related Pages

#### Design Decisions

- Any design decisions that affect this ticket

#### Previous Discussions

- Relevant discussions found in Notion

#### Acceptance Criteria from Similar Tasks

- Patterns in how acceptance criteria are structured

### Recommendations

1. **Context to Apply:** Key context from related pages
2. **Patterns to Follow:** Patterns from similar completed tasks
3. **People to Consult:** Based on related task assignees
```

## Success Criteria

- Fetched content from all linked pages
- Found related tasks that provide useful context
- Extracted actionable information
- Identified patterns from similar work

## Fallback (If MCP Not Available)

If Notion MCP is not connected, ask the human to:

1. Copy relevant content from linked pages
2. Share any related tasks they know about
3. Provide context about previous similar work
