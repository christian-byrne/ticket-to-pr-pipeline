# Task: Build `research-orchestrator` Skill

## Objective

Create an agent skill that orchestrates parallel research subagents to gather context for implementing a ticket.

## Prerequisites

- `ticket-intake` skill completed and working
- Pipeline run directory exists with `ticket.json`
- Notion MCP connected (for related pages research)
- `gh` CLI authenticated (for GitHub research)

## Context

### Research Subagent Prompts

Already created at `/home/cbyrne/repos/ticket-to-pr-pipeline/prompts/research/`:
- `git-history.md` - Search commits, blame, file history
- `github-prs-issues.md` - Related PRs and issues  
- `codebase-analysis.md` - Patterns and affected files
- `external-research.md` - Best practices, library docs
- `notion-related.md` - Related Notion pages
- `slack-thread.md` - Thread context extraction

### Target Repository

All research focuses on: `ComfyUI_frontend`
Local path: `/home/cbyrne/cross-repo-tasks/ticket-to-pr-e2e-agent-pipeline/ComfyUI_frontend`

### Parallel Execution Pattern

Use the `dispatching-parallel-agents` skill pattern:
```
/home/cbyrne/.claude/skills/dispatching-parallel-agents/SKILL.md
```

Key principles:
- Dispatch one agent per independent research area
- Each agent works in isolation and reports findings
- Collect and compile results when all complete

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/research-orchestrator/SKILL.md`

### Frontmatter
```yaml
---
name: research-orchestrator
description: Orchestrate parallel research subagents to gather context for a ticket. Use after ticket-intake completes.
---
```

### Skill Workflow

1. **Load Ticket Data:**
   - Read `ticket.json` from current run directory
   - Extract: title, description, keywords, affected files (if identifiable)

2. **Determine Research Scope:**
   - Always run: git-history, github-prs-issues, codebase-analysis
   - Conditional: 
     - notion-related → only if ticket has linked pages
     - slack-thread → only if Slack link exists (prompt user for content)
     - external-research → only if new patterns/libraries involved

3. **Prepare Subagent Prompts:**
   - Load prompt templates from `/prompts/research/`
   - Fill in template variables:
     - `{{TICKET_TITLE}}`
     - `{{TICKET_DESCRIPTION}}`
     - `{{KEYWORDS}}` - extracted from title/description
     - `{{AFFECTED_FILES}}` - estimated from description or "TBD"

4. **Handle Slack Content:**
   - If Slack link exists in ticket, prompt user:
     ```
     This ticket has a linked Slack thread: {URL}
     Please copy and paste the thread content, or type "skip" to continue without it.
     ```
   - If content provided, include in slack-thread subagent

5. **Dispatch Subagents:**
   - Use Task tool to dispatch each research area in parallel
   - Each subagent should:
     - Follow its prompt template
     - Return findings in the specified output format
     - Work within ComfyUI_frontend directory

6. **Compile Research Report:**
   - Wait for all subagents to complete
   - Combine all findings into single markdown document
   - Save to `{run-dir}/research-report.md`
   - Structure:
     ```markdown
     # Research Report: {Ticket Title}
     
     ## Summary
     - Key findings overview
     - Affected files identified
     - Recommended reviewers
     
     ## Git History Findings
     {git-history subagent output}
     
     ## GitHub PRs & Issues
     {github subagent output}
     
     ## Codebase Analysis
     {codebase subagent output}
     
     ## External Research
     {if applicable}
     
     ## Slack Context
     {if applicable}
     
     ## Notion Related
     {if applicable}
     
     ## Next Steps
     - Recommendations for planning phase
     ```

7. **Update Status:**
   - Update `status.json`: status → "planning"

8. **Output:**
   - Print summary of research completed
   - Print path to full report
   - Prompt for human review before continuing to planning

### Subagent Task Prompt Template

For each subagent, use this pattern:
```
You are a research subagent for the ticket-to-PR pipeline.

TICKET: {title}
DESCRIPTION: {description}

YOUR TASK: {specific research task from prompt template}

REPOSITORY: /home/cbyrne/cross-repo-tasks/ticket-to-pr-e2e-agent-pipeline/ComfyUI_frontend

OUTPUT FORMAT: {from prompt template}

When complete, return your findings in the specified format. Be thorough but concise.
```

## Deliverables

1. `SKILL.md` file at the correct location
2. Tested with a real ticket that has been through intake
3. Verified research report is comprehensive

## Verification

```bash
# After running the skill:
# 1. Check runs/{ticket-id}/research-report.md exists
# 2. Report contains sections from each subagent
# 3. Status.json updated to "planning"
# 4. Human can review report before continuing
```

## Reference Files

- Implementation plan: `/home/cbyrne/repos/ticket-to-pr-pipeline/docs/implementation-plan.md` (Section 6.2)
- Prompt templates: `/home/cbyrne/repos/ticket-to-pr-pipeline/prompts/research/`
- Parallel dispatch pattern: `/home/cbyrne/.claude/skills/dispatching-parallel-agents/SKILL.md`
- Subagent pattern: `/home/cbyrne/.claude/skills/subagent-driven-development/SKILL.md`

## Notes

- Research should be thorough but not overwhelming - focus on actionable context
- If a subagent fails, note the failure but continue with others
- The human checkpoint after research is important - don't auto-continue
