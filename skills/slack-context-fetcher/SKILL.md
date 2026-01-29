---
name: slack-context-fetcher
description: Fetches Slack thread content using MCP or API for ticket context enrichment. Use when tickets reference Slack threads or discussions.
---

# Slack Context Fetcher

Automatically fetches Slack thread content when tickets reference Slack discussions. Enriches ticket context with the full conversation.

## MCP Setup Options

### Option 1: Composio Slack MCP (Recommended)

Composio provides a working Slack MCP that integrates with Amp:

```bash
# Install via Composio
amp mcp add slack https://mcp.composio.dev/slack

# Authenticate
amp mcp oauth login slack --server-url https://mcp.composio.dev/slack
```

After authentication, the following tools become available:
- `slack_get_channel_history` - Fetch messages from a channel
- `slack_get_thread_replies` - Fetch all replies in a thread
- `slack_search_messages` - Search for messages by keyword
- `slack_get_user_info` - Get user profile information

### Option 2: Direct Slack API

If MCP is unavailable, use the Slack API directly with a bot token:

```bash
# Set token (get from api.slack.com/apps)
export SLACK_BOT_TOKEN="xoxb-..."

# Fetch thread replies
curl -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  "https://slack.com/api/conversations.replies?channel=C0123456789&ts=1234567890.123456"
```

Required bot scopes:
- `channels:history` - Read public channel messages
- `channels:read` - List channels
- `groups:history` - Read private channel messages (if needed)
- `groups:read` - List private channels

## Workflow

### 1. Detect Slack References

Parse ticket description for Slack links:

```
Pattern: https://{workspace}.slack.com/archives/{channel_id}/p{timestamp}
Example: https://comfy-org.slack.com/archives/C07ABCD1234/p1234567890123456
```

Extract:
- `channel_id`: C07ABCD1234
- `thread_ts`: 1234567890.123456 (convert p{ts} → {ts} with decimal)

### 2. Fetch Thread Content

**With MCP:**
```
Use slack_get_thread_replies tool with:
- channel: {channel_id}
- thread_ts: {thread_ts}
```

**With API:**
```bash
curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  "https://slack.com/api/conversations.replies?channel=$CHANNEL&ts=$THREAD_TS" | \
  jq '.messages[] | {user: .user, text: .text, ts: .ts}'
```

### 3. Resolve User Names

Map user IDs to display names:

```bash
# With MCP: Use slack_get_user_info for each unique user ID

# With API:
curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  "https://slack.com/api/users.info?user=$USER_ID" | \
  jq '.user.real_name'
```

### 4. Format for Context

Create structured output:

```markdown
## Slack Thread Context

**Thread:** [Link](https://comfy-org.slack.com/archives/C07.../p1234...)
**Participants:** Alice, Bob, Charlie
**Messages:** 12
**Date Range:** 2024-01-15 to 2024-01-16

### Discussion Summary

[AI-generated summary of key points]

### Full Thread

**Alice** (2024-01-15 10:30):
> Original message about the issue...

**Bob** (2024-01-15 10:45):
> Response with context...

**Charlie** (2024-01-15 11:00):
> Follow-up with decision...
```

### 5. Attach to Ticket Context

Save to run directory:

```bash
echo "$SLACK_CONTEXT" > "$RUN_DIR/slack-context.md"

# Update ticket.json with slack references
jq '.slackThreads += [{"url": "...", "fetched": "...", "messages": N}]' \
  "$RUN_DIR/ticket.json" > tmp && mv tmp "$RUN_DIR/ticket.json"
```

## Integration with ticket-intake

Modify ticket-intake to automatically detect and fetch Slack content:

```markdown
### In ticket-intake workflow, after step 3:

3.5. Check for Slack References

If ticket description contains Slack URLs:
1. Parse each URL for channel/thread info
2. Fetch thread content using slack-context-fetcher
3. Attach slack-context.md to research context
4. Note in status.json: "slackContextFetched": true
```

## Handling Private Channels

If the bot doesn't have access:

```markdown
⚠️ Slack thread in private channel: {channel_name}

Options:
1. Add bot to channel (ask admin)
2. Copy thread content manually
3. Skip slack context (proceed without)

Your choice:
```

Log skipped threads:
```bash
jq '.skippedSlackThreads += [{"url": "...", "reason": "private_channel"}]' \
  "$RUN_DIR/status.json" > tmp && mv tmp "$RUN_DIR/status.json"
```

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| `channel_not_found` | Invalid channel ID | Verify URL is correct |
| `thread_not_found` | Thread deleted | Note as unavailable |
| `not_in_channel` | Bot not added | Request bot access or copy manually |
| `token_expired` | MCP auth expired | Re-authenticate: `amp mcp oauth login slack` |

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| slack-context.md | `runs/{ticket-id}/slack-context.md` | Formatted thread content |
| ticket.json | `runs/{ticket-id}/ticket.json` | Updated with slack references |

## Usage

Standalone:
```
/skill slack-context-fetcher
[paste Slack thread URL]
```

Or automatically triggered during ticket-intake when Slack URLs detected.

## MCP Tool Reference

If using Composio Slack MCP, filter to these tools only:

```json
{
  "includeTools": [
    "slack_get_channel_history",
    "slack_get_thread_replies", 
    "slack_search_messages",
    "slack_get_user_info"
  ]
}
```

This keeps token usage minimal while providing full thread-fetching capability.
