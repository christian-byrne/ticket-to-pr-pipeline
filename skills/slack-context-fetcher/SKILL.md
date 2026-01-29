---
name: slack-context-fetcher
description: Fetches Slack thread content using a Slack bot for ticket context enrichment. Use when tickets reference Slack threads or discussions.
---

# Slack Context Fetcher

Automatically fetches Slack thread content when tickets reference Slack discussions. Uses a Slack bot with API access.

## Bot Setup (One-Time)

### Step 1: Create Slack App

1. Go to https://api.slack.com/apps
2. Click **Create New App** → **From scratch**
3. Name: `Pipeline Context Bot`
4. Workspace: Select your workspace
5. Click **Create App**

### Step 2: Add Bot Permissions

1. In left sidebar, click **OAuth & Permissions**
2. Scroll to **Scopes** → **Bot Token Scopes**
3. Add these scopes:
   - `channels:history` - Read public channel messages
   - `channels:read` - List public channels
   - `groups:history` - Read private channel messages
   - `groups:read` - List private channels
   - `users:read` - Get user display names

### Step 3: Install to Workspace

1. Scroll up to **OAuth Tokens for Your Workspace**
2. Click **Install to Workspace**
3. Review permissions and click **Allow**
4. Copy the **Bot User OAuth Token** (starts with `xoxb-`)

### Step 4: Store Token

```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export SLACK_BOT_TOKEN="xoxb-your-token-here"

# Or store in a secure location
echo "xoxb-your-token-here" > ~/.slack-bot-token
chmod 600 ~/.slack-bot-token
```

### Step 5: Add Bot to Channels

For each channel you want to read:
1. Open the channel in Slack
2. Click channel name → **Integrations** → **Add apps**
3. Add `Pipeline Context Bot`

## Workflow

### 1. Detect Slack References

Parse ticket description for Slack links:

```
Pattern: https://{workspace}.slack.com/archives/{channel_id}/p{timestamp}
Example: https://comfy-org.slack.com/archives/C07ABCD1234/p1234567890123456
```

Extract:
- `channel_id`: C07ABCD1234
- `thread_ts`: 1234567890.123456 (convert `p{ts}` → insert decimal before last 6 digits)

### 2. Fetch Thread Content

```bash
CHANNEL="C07ABCD1234"
THREAD_TS="1234567890.123456"
TOKEN="${SLACK_BOT_TOKEN:-$(cat ~/.slack-bot-token)}"

curl -s -H "Authorization: Bearer $TOKEN" \
  "https://slack.com/api/conversations.replies?channel=$CHANNEL&ts=$THREAD_TS" | \
  jq '.messages[] | {user: .user, text: .text, ts: .ts}'
```

### 3. Resolve User Names

Map user IDs to display names:

```bash
USER_ID="U0123456789"

curl -s -H "Authorization: Bearer $TOKEN" \
  "https://slack.com/api/users.info?user=$USER_ID" | \
  jq -r '.user.real_name'
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

During ticket-intake, after parsing Notion:

1. Check if ticket description contains Slack URLs
2. For each Slack URL:
   - Parse channel ID and thread timestamp
   - Fetch thread content
   - Save to slack-context.md
3. Include slack-context.md in research context

## Handling Private Channels

If bot doesn't have access:

```
⚠️ Cannot access Slack thread: {url}

The bot is not in this channel.

Options:
1. Add bot to channel (you or admin)
2. Copy thread content manually
3. Skip slack context

Your choice:
```

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| `channel_not_found` | Invalid channel ID | Verify URL is correct |
| `thread_not_found` | Thread deleted | Note as unavailable |
| `not_in_channel` | Bot not added | Add bot to channel |
| `invalid_auth` | Bad token | Regenerate token at api.slack.com |
| `missing_scope` | Permissions missing | Add required scopes |

## Helper Script

Save as `scripts/fetch-slack-thread.sh`:

```bash
#!/bin/bash
set -e

URL="$1"
TOKEN="${SLACK_BOT_TOKEN:-$(cat ~/.slack-bot-token 2>/dev/null)}"

if [ -z "$TOKEN" ]; then
  echo "Error: SLACK_BOT_TOKEN not set" >&2
  exit 1
fi

# Parse URL: https://workspace.slack.com/archives/CHANNEL/pTIMESTAMP
CHANNEL=$(echo "$URL" | sed -n 's|.*/archives/\([^/]*\)/.*|\1|p')
TS_RAW=$(echo "$URL" | sed -n 's|.*/p\([0-9]*\).*|\1|p')
THREAD_TS="${TS_RAW:0:10}.${TS_RAW:10}"

# Fetch thread
RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://slack.com/api/conversations.replies?channel=$CHANNEL&ts=$THREAD_TS")

if [ "$(echo "$RESPONSE" | jq -r '.ok')" != "true" ]; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.error')" >&2
  exit 1
fi

# Output messages
echo "$RESPONSE" | jq -r '.messages[] | "[\(.ts)] \(.user): \(.text)"'
```

Usage:
```bash
./scripts/fetch-slack-thread.sh "https://comfy-org.slack.com/archives/C07.../p1234..."
```

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| slack-context.md | `runs/{ticket-id}/slack-context.md` | Formatted thread content |
| ticket.json | `runs/{ticket-id}/ticket.json` | Updated with slack references |
