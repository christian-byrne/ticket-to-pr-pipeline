# Task: Build `final-qa-launcher` Skill

## Objective

Create an agent skill that starts the dev server, generates a QA checklist, and guides human through final manual verification.

## Prerequisites

- Code review complete
- All review items addressed
- Ready for final human verification

## Context

### Dev Server Commands

From ComfyUI_frontend:
- `pnpm dev` - Standard dev server
- `pnpm dev:cloud` - Dev server with cloud features
- `pnpm dev:electron` - Dev server with Electron mocks

### tmux for Background Processes

Reference skill:
```
/home/cbyrne/.claude/skills/tmux/SKILL.md
```

Pattern:
```bash
# Create window
tmux new-window -n "dev-server" -d

# Start server
tmux send-keys -t "dev-server" "pnpm dev:cloud" C-m

# Check output
tmux capture-pane -p -t "dev-server"
```

### QA Checklist Sources

- Ticket acceptance criteria (from `ticket.json`)
- Implementation plan verification points
- Standard checks (responsive, no console errors, etc.)

## Skill Specification

### Location
Create at: `/home/cbyrne/.claude/skills/final-qa-launcher/SKILL.md`

### Frontmatter
```yaml
---
name: final-qa-launcher
description: Start dev server, generate QA checklist, guide manual verification. Use before creating PR.
---
```

### Skill Workflow

1. **Determine Server Type:**
   ```
   Which dev server should I start?
   
   A) pnpm dev - Standard (default)
   B) pnpm dev:cloud - Cloud features
   C) pnpm dev:electron - Electron features
   
   (or specify custom command)
   ```

2. **Start Dev Server:**
   
   Using tmux:
   ```bash
   # Check if already running
   tmux list-windows | grep dev-server && tmux kill-window -t dev-server
   
   # Start fresh
   tmux new-window -n "dev-server" -d
   tmux send-keys -t "dev-server" "cd /path/to/ComfyUI_frontend && pnpm dev:cloud" C-m
   ```

3. **Wait for Ready:**
   
   Poll for server ready:
   ```bash
   # Check for "ready" or URL in output
   for i in {1..30}; do
     output=$(tmux capture-pane -p -t "dev-server")
     if echo "$output" | grep -q "localhost:"; then
       break
     fi
     sleep 2
   done
   ```

4. **Print Server Info:**
   ```
   ✅ Dev server started
   
   URL: http://localhost:5173 (or detected URL)
   
   To view logs: tmux capture-pane -p -t "dev-server"
   To stop: tmux kill-window -t "dev-server"
   ```

5. **Generate QA Checklist:**
   
   Load from ticket and plan:
   ```markdown
   # QA Checklist: {Ticket Title}
   
   ## Acceptance Criteria
   (from ticket.json)
   - [ ] {Criterion 1}
   - [ ] {Criterion 2}
   - [ ] ...
   
   ## Implementation Verification
   (from plan.md)
   - [ ] {Feature 1} works as expected
   - [ ] {Feature 2} works as expected
   
   ## Standard Checks
   - [ ] No console errors in browser DevTools
   - [ ] No network errors in DevTools Network tab
   - [ ] Responsive: works on desktop width
   - [ ] Responsive: works on mobile width (if applicable)
   - [ ] Keyboard navigation works (if applicable)
   - [ ] Loading states display correctly
   - [ ] Error states display correctly
   - [ ] No visual regressions in related areas
   
   ## Edge Cases
   - [ ] Empty state handled
   - [ ] Error state handled
   - [ ] Large data handled (if applicable)
   - [ ] Concurrent actions handled (if applicable)
   
   ## Integration
   - [ ] Feature works with rest of application
   - [ ] No breaks in related features
   ```

6. **Save & Present:**
   - Save checklist to `{run-dir}/qa-checklist.md`
   - Print checklist to user
   
   ```
   Please verify each item manually in the browser.
   
   When complete:
   - "approved" - Continue to PR creation
   - "issue: {description}" - Report an issue found
   - "stop" - Stop for now, will continue later
   ```

7. **Handle Response:**
   
   **If approved:**
   - Update `status.json`: status → "pr-ready"
   - Prompt to continue to PR creation
   
   **If issue reported:**
   - Log the issue
   - Ask: "Fix now or note for later?"
   - If fix now: return to implementation
   - If note: add to known issues list
   
   **If stop:**
   - Save state
   - Note how to resume

8. **Cleanup Option:**
   ```
   Keep dev server running? (Y/n)
   ```
   If no, kill the tmux window.

## Deliverables

1. `SKILL.md` file at the correct location
2. tmux integration working
3. QA checklist is comprehensive
4. Handles all response types

## Verification

```bash
# After running:
# 1. Dev server starts in tmux
# 2. URL is detected and printed
# 3. QA checklist covers acceptance criteria
# 4. Can approve or report issues
# 5. Server cleanup works
```

## Reference Files

- tmux skill: `/home/cbyrne/.claude/skills/tmux/SKILL.md`
- Implementation plan: Section 6.7
- ComfyUI_frontend AGENTS.md: dev commands

## Notes

- Dev server startup can take 10-30 seconds
- Vite prints the URL when ready
- Keep checklist focused - don't overwhelm with items
- Standard checks apply to all tickets
- Accept criteria should come directly from ticket
- Server should persist across the QA session
