---
name: review-orchestrator
description: "Dispatch review subagents, compile feedback, triage for human decision. Use after quality gates pass."
---

# Review Orchestrator

Dispatches parallel review subagents, compiles and deduplicates feedback, presents triaged list for human decision.

## Prerequisites

- Quality gates passed (lint, typecheck, tests)
- CodeRabbit CLI installed and authenticated (`coderabbit auth login`)
- Pro tier: 8 reviews/hour

## Workflow

### 1. Verify Readiness

```bash
which coderabbit
git diff --stat HEAD~1
```

If no changes or CodeRabbit missing, stop and inform user.

### 2. Gather Context

- Changed files: `git diff --name-only HEAD~1`
- Run directory path
- Ticket requirements from `ticket.json`

### 3. Dispatch Review Subagents

**Subagent 1: CodeRabbit Review**
```
Run: coderabbit --prompt-only --type uncommitted
Categorize by severity: Critical/Major/Minor/Nitpick
Return: file:line, issue, suggested fix
```

**Subagent 2: Agent Code Review**
```
Review {FILES_LIST} against {TICKET_REQUIREMENTS}
Checklist: Functionality, Code Quality, Architecture, Testing, Security, Performance
Return: severity, location, fix suggestion
```

**Subagent 3: Pattern Compliance Review**
```
Check against ComfyUI_frontend patterns and AGENTS.md guidelines
Violations: Vue patterns, Tailwind (no dark:), TypeScript (no any), Testing patterns
Return: file:line and correct pattern
```

### 4. Compile and Deduplicate

1. Merge findings from all reviewers
2. Remove duplicates (note "Found by: CodeRabbit, Agent")
3. Resolve conflicts with recommendation
4. Group by file, sort by severity

### 5. Generate Review Summary

```markdown
# Code Review Summary

## Statistics
- Total: {count} | Critical: {count} | Major: {count} | Minor: {count} | Nitpicks: {count}

## Critical Issues (Must Fix)
### [C1] {Title}
- **File:** `path/to/file.ts:42`
- **Source:** {source}
- **Issue:** {description}
- **Fix:** {suggestion}

## Major Issues (Should Fix)
### [M1] {Title}
...

## Minor Issues (Consider)
### [m1] {Title}
...

## Nitpicks (Optional)
- [N1] `file.ts:10` - {description}
```

### 6. Present Triage Interface

```
Review complete. {X} findings across {Y} files.

Respond with:
- Numbers to implement: "C1, M1, M3"
- "all critical" / "all major" / "all"
- "skip N1, N2"
- "clarify M2"
```

Wait for human decision.

### 7. Save Review

Save to `{run-dir}/review-comments.md` with all findings and triage decisions.

Update `status.json`:
```json
{
  "stage": "review-complete",
  "reviewStats": {"critical": 0, "major": 2, "minor": 3, "nitpicks": 5},
  "selectedFixes": ["C1", "M1"],
  "skippedItems": ["N1", "N2"]
}
```

### 8. Handle Implementation

For selected items: dispatch fix subagents or return to implementation phase.
After fixes, re-run affected quality gates.

## Severity Definitions

| Severity | Description | Action |
|----------|-------------|--------|
| Critical | Security, race conditions, data loss | Must fix |
| Major | Logic errors, performance, missing error handling | Should fix |
| Minor | Code style, naming | Consider |
| Nitpick | Formatting preferences | Optional |

## Fallback

If CodeRabbit unavailable: skip that subagent, note in summary, continue with others.
