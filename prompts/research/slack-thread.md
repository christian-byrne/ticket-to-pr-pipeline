# Slack Thread Research Subagent

## Objective

Extract context and decisions from the Slack thread linked in the ticket.

## Input Context

```
Ticket: {{TICKET_TITLE}}
Slack Thread URL: {{SLACK_URL}}
Keywords: {{KEYWORDS}}
```

## Current Limitation

⚠️ **Slack MCP is not yet generally available.** This prompt provides a manual fallback.

## Manual Process (Current)

Since Slack MCP access is limited, ask the human to:

1. **Copy Thread Content:**
   - Navigate to the Slack thread
   - Copy all messages (use "Copy link to message" or select all text)
   - Paste into a temporary file or directly share

2. **Key Information to Extract:**
   - Original request/problem statement
   - Any decisions made
   - Technical discussions
   - Alternative approaches considered
   - Action items assigned
   - People involved who might be good reviewers

## Output Format (When Content is Available)

```markdown
## Slack Thread Analysis Report

### Summary

- Thread participants: {{LIST}}
- Key decision: {{SUMMARY}}
- Open questions: {{LIST}}

### Thread Timeline

#### Initial Request

- **From:** @{{USER}}
- **Date:** {{DATE}}
- **Summary:** What was originally requested

#### Key Discussions

##### Discussion Point 1

- **Participants:** @{{USER1}}, @{{USER2}}
- **Topic:** What was discussed
- **Outcome:** What was decided or concluded

##### Discussion Point 2

...

### Decisions Made

1. **Decision:** {{DESCRIPTION}}
   - **Rationale:** Why this was decided
   - **By:** Who made the decision

### Alternative Approaches Discussed

- **Approach A:** Description
  - Pros: ...
  - Cons: ...
  - Why rejected: ...

### Open Questions

- Questions that weren't resolved in the thread

### Action Items from Thread

- [ ] Action item 1 (assigned to @{{USER}})
- [ ] Action item 2

### People to Involve

Based on the thread, consider involving:

- @{{USER1}} - Reason (e.g., "proposed the approach")
- @{{USER2}} - Reason (e.g., "raised concerns about X")

### Recommendations

- Key context to carry forward
- Constraints identified
- Preferences expressed
```

## Future: When Slack MCP is Available

When Slack MCP becomes available, use:

```
Use slack-search to find the thread
Use slack-read-thread to get full content
Use slack-get-user to identify participants
```

## Success Criteria

- All key decisions from thread are captured
- Alternative approaches are documented
- Open questions are identified
- Relevant participants are noted for potential review
