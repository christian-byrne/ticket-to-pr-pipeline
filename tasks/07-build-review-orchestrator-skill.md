# Task: Build `review-orchestrator` Skill

## Objective

Create an agent skill that dispatches multiple review subagents, compiles their feedback, and presents a triaged list for human decision.

## Prerequisites

- Quality gates passed
- Code is ready for review
- CodeRabbit CLI installed and authenticated (Pro account available)

## Context

### Review Subagents

Three types of review, each as a subagent:

1. **CodeRabbit CLI** - AI-powered code review
   - Install: `curl -fsSL https://cli.coderabbit.ai/install.sh | sh`
   - Auth: `coderabbit auth login`
   - Run: `coderabbit --prompt-only --type uncommitted`
   - Pro tier: 8 reviews/hour

2. **Agent Code Review** - Standard agent review
   - Uses checklist from `/prompts/review/agent-code-review.md`
   - Focuses on functionality, architecture, security, performance

3. **Pattern Review** - AGENTS.md compliance
   - Uses checklist from `/prompts/review/pattern-review.md`
   - Checks Vue patterns, Tailwind, TypeScript conventions

### Review Prompt Templates

Located at: `/home/cbyrne/repos/ticket-to-pr-pipeline/prompts/review/`

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/review-orchestrator/SKILL.md`

### Frontmatter
```yaml
---
name: review-orchestrator
description: Dispatch review subagents, compile feedback, triage for human decision. Use after quality gates pass.
---
```

### Skill Workflow

1. **Verify Readiness:**
   - Confirm quality gates passed
   - Confirm there are changes to review
   - Check CodeRabbit is installed: `which coderabbit`

2. **Dispatch Review Subagents:**
   
   In parallel using Task tool:
   
   **Subagent 1: CodeRabbit**
   ```
   Run CodeRabbit CLI review on uncommitted changes.
   
   Commands:
   cd /home/cbyrne/cross-repo-tasks/ticket-to-pr-e2e-agent-pipeline/ComfyUI_frontend
   coderabbit --prompt-only --type uncommitted
   
   Parse output and categorize findings by severity:
   - Critical: Security, race conditions, data loss
   - Major: Logic errors, performance, missing error handling
   - Minor: Code style, naming
   - Nitpick: Formatting preferences
   
   Return structured list with file:line, issue, suggested fix.
   ```
   
   **Subagent 2: Agent Review**
   ```
   Perform code review following the checklist.
   
   Review prompt: {content of agent-code-review.md}
   
   Files to review: {list from plan.md}
   Ticket requirements: {from ticket.json}
   
   Check:
   - Functionality matches requirements
   - Code quality per AGENTS.md
   - Architecture fits existing patterns
   - Testing is adequate
   - Security is appropriate
   
   Return findings with severity, location, and fix suggestion.
   ```
   
   **Subagent 3: Pattern Review**
   ```
   Check code against ComfyUI_frontend patterns.
   
   Review prompt: {content of pattern-review.md}
   
   Check all changed files for:
   - Vue 3 Composition API patterns
   - Tailwind usage (no dark:, use cn(), etc.)
   - TypeScript (no any, proper types)
   - State management patterns
   - Testing anti-patterns
   
   Return violations with file:line and correct pattern.
   ```

3. **Compile & Deduplicate:**
   
   Merge all findings:
   - Remove duplicates (same issue from multiple reviewers)
   - Resolve conflicts (if reviewers disagree, note both perspectives)
   - Group by file
   - Sort by severity

4. **Categorize for Triage:**
   
   ```markdown
   # Code Review Summary
   
   ## Statistics
   - Total findings: {count}
   - Critical: {count}
   - Major: {count}
   - Minor: {count}
   - Nitpicks: {count}
   - Duplicates removed: {count}
   
   ## Critical Issues (Must Fix)
   
   ### [C1] {Title}
   - **File:** `path/to/file.ts:42`
   - **Source:** CodeRabbit / Agent / Pattern
   - **Issue:** {description}
   - **Fix:**
   ```typescript
   // Suggested fix
   ```
   
   ## Major Issues (Should Fix)
   
   ### [M1] {Title}
   ...
   
   ## Minor Issues (Consider)
   
   ### [m1] {Title}
   ...
   
   ## Nitpicks (Optional)
   
   - [N1] `file.ts:10` - {description}
   - [N2] ...
   
   ## Conflicting Opinions
   
   ### {Topic}
   - **CodeRabbit says:** {opinion}
   - **Agent says:** {opinion}
   - **Recommendation:** {which to follow and why}
   ```

5. **Present Triage Interface:**
   
   ```
   Review complete. {X} findings across {Y} files.
   
   For each finding, respond with:
   - Number to implement (e.g., "C1, M1, M3")
   - "all critical" - implement all critical
   - "all major" - implement all critical + major
   - "skip N1" - skip specific items
   - "clarify M2" - need more info on item
   
   Your response:
   ```

6. **Save & Update:**
   - Save full review to `{run-dir}/review-comments.md`
   - Track which items are selected for implementation
   - Update `status.json`

7. **Handle Implementation:**
   - For selected items, either:
     - Dispatch fix subagent
     - Return to implementation phase with specific fixes

## Deliverables

1. `SKILL.md` file at the correct location
2. Tested with real code changes
3. CodeRabbit integration working
4. Deduplication and conflict resolution working

## Verification

```bash
# After running:
# 1. All three review types ran
# 2. Findings are deduplicated
# 3. Triage interface is clear
# 4. Selected items can be implemented
# 5. review-comments.md is comprehensive
```

## Reference Files

- Review prompts: `/home/cbyrne/repos/ticket-to-pr-pipeline/prompts/review/`
- CodeRabbit docs: https://docs.coderabbit.ai/cli
- Implementation plan: Section 6.6
- ComfyUI_frontend AGENTS.md

## Notes

- CodeRabbit may take a few minutes - run in background
- Pro tier allows 8 reviews/hour - track usage
- Some nitpicks may not be worth fixing - let human decide
- Conflicting opinions happen - present both, recommend one
- Save the full review for reference even after implementation
