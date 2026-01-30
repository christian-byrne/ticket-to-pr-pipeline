---
name: research-orchestrator
description: Orchestrates parallel research subagents to gather context for a ticket. Use after ticket-intake completes and ticket.json exists.
---

# Research Orchestrator

Dispatches parallel research subagents, compiles findings into research report.

## Prerequisites

- `runs/{ticket-id}/ticket.json` exists (from ticket-intake)
- `gh` CLI authenticated
- Notion MCP connected (for related pages)

## Workflow

### 1. Load Ticket Data

From `runs/{ticket-id}/ticket.json` extract: title, description, slackLink, relatedTasks, area.
Generate keywords from title/description for search queries.

### 2. Determine Research Scope

**Always dispatch:**
- `git-history` - Commits, blame, file history
- `github-prs-issues` - Related PRs and issues
- `codebase-analysis` - Patterns and affected files

**Conditional:**
- `notion-related` → If `relatedTasks` has entries
- `slack-thread` → If `slackLink` exists
- `external-research` → If new patterns/libraries involved

### 3. Handle Slack Content

If `slackLink` exists:
```
📋 This ticket has a linked Slack thread: {slackLink}
Please paste the thread content, or type "skip".
```

### 4. Dispatch Subagents

**Target repo:** `/home/cbyrne/cross-repo-tasks/ticket-to-pr-e2e-agent-pipeline/ComfyUI_frontend`
**Prompt templates:** `/home/cbyrne/repos/ticket-to-pr-pipeline/prompts/research/`

Template variables: `{{TICKET_TITLE}}`, `{{TICKET_DESCRIPTION}}`, `{{KEYWORDS}}`, `{{AFFECTED_FILES}}`

### 5. Compile Research Report

Create `research-report.md`:

```markdown
# Research Report: {Ticket Title}

**Ticket ID:** {id} | **Generated:** {timestamp}

## Summary
- **Key findings:** {overview}
- **Affected files:** {list}
- **Recommended reviewers:** {based on git blame}
- **Risk areas:** {potential challenges}

## Git History Findings
{output}

## GitHub PRs & Issues
{output}

## Codebase Analysis
{output}

## External Research
{output or "N/A"}

## Slack Context
{output or "N/A"}

## Notion Related Pages
{output or "N/A"}

## Research Failures
{failures or "None"}

## Next Steps
1. {recommendation}
2. {recommendation}
```

### 6. Update Status

```json
{"status": "planning", "lastUpdated": "{timestamp}", "researchCompletedAt": "{timestamp}"}
```

### 7. Output Summary

```markdown
## Research Complete

**Ticket:** {title}
**Report:** {path}

### Key Findings
- {finding 1}
- {finding 2}

### Affected Files
- {file 1}

---
📋 **Human Review Required**
Review research report before continuing. When ready, load `plan-generator`.
```

## Subagent Reference

| Subagent | Purpose |
|----------|---------|
| git-history | Recent commits, blame, file ownership |
| github-prs-issues | Related PRs, issues, review patterns (uses `gh` CLI) |
| codebase-analysis | Affected files, patterns, AGENTS.md guidelines |
| external-research | Vue 3, VueUse, Tailwind, reka-ui docs (only when needed) |
| notion-related | Linked Notion pages (requires MCP) |
| slack-thread | Thread content (manual paste) |

## Error Handling

**Subagent failure:** Note in report, continue with others.
**Missing ticket.json:** Stop, instruct to run ticket-intake first.
**No dispatch possible:** Check prerequisites and run directory.

## Notes

- Focus on actionable context, not exhaustive documentation
- Human checkpoint after research is critical—do not auto-continue
- Failed subagents should not block overall process
