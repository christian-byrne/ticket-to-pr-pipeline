---
name: metrics-dashboard
description: Tracks pipeline velocity, success rates, and cycle times. Use to view performance metrics, identify bottlenecks, and generate reports.
---

# Metrics Dashboard

Aggregates pipeline run data to track velocity, success rates, and identify improvement areas.

## Data Sources

Metrics are derived from:
- `runs/*/status.json` - Phase timestamps, success/failure
- `runs/*/ticket.json` - Ticket metadata
- Git history - Commit and PR data
- Notion - Ticket status transitions

## Workflow

### 1. Collect Run Data

Scan all completed runs:

```bash
# Find all status.json files
find runs/ -name "status.json" -type f | while read f; do
  jq -c '{
    id: .ticketId,
    status: .status,
    started: .intakeAt,
    completed: .completedAt,
    phases: .phaseTimestamps
  }' "$f"
done > /tmp/runs-data.jsonl
```

### 2. Calculate Metrics

#### Cycle Time
Time from ticket intake to PR merged:

```bash
jq -s '
  map(select(.completed != null)) |
  map(.cycleTime = ((.completed | fromdate) - (.started | fromdate)) / 3600) |
  {
    avgCycleTimeHours: (map(.cycleTime) | add / length),
    minCycleTimeHours: (map(.cycleTime) | min),
    maxCycleTimeHours: (map(.cycleTime) | max)
  }
' /tmp/runs-data.jsonl
```

#### Success Rate
Percentage of runs that reached PR merged:

```bash
jq -s '
  {
    total: length,
    completed: (map(select(.status == "done")) | length),
    failed: (map(select(.status == "failed")) | length),
    inProgress: (map(select(.status | test("^(implementing|review|pr-created)$"))) | length)
  } |
  .successRate = (.completed / .total * 100)
' /tmp/runs-data.jsonl
```

#### Phase Duration
Average time in each phase:

```bash
jq -s '
  map(.phases) | 
  flatten |
  group_by(.phase) |
  map({
    phase: .[0].phase,
    avgMinutes: (map(.durationSeconds) | add / length / 60)
  })
' /tmp/runs-data.jsonl
```

### 3. Identify Bottlenecks

Find phases with longest average duration:

```markdown
## Phase Performance

| Phase | Avg Duration | % of Total |
|-------|--------------|------------|
| research | 15 min | 25% |
| planning | 10 min | 17% |
| implementing | 25 min | 42% | ⚠️ Bottleneck
| review | 8 min | 13% |
| qa | 2 min | 3% |

**Insight:** Implementation phase takes 42% of total time.
Consider: More granular task breakdown, parallel subagents.
```

### 4. Generate Dashboard

```markdown
# Pipeline Metrics Dashboard

**Period:** Last 30 days
**Generated:** {timestamp}

## Summary

| Metric | Value | Trend |
|--------|-------|-------|
| Tickets Completed | 12 | ↑ +3 |
| Success Rate | 83% | ↑ +5% |
| Avg Cycle Time | 2.5 hrs | ↓ -0.5 hrs |
| PRs Merged | 15 | ↑ +4 |

## Cycle Time Breakdown

```
Intake     ████ 5 min
Research   ████████ 15 min
Planning   ██████ 10 min
Tasks      ███ 5 min
Implement  █████████████ 25 min
Quality    ████ 8 min
Review     ██████ 12 min
PR/Merge   ████ 8 min
           ─────────────────────
Total      ~90 min average
```

## Success by Ticket Type

| Type | Count | Success | Avg Time |
|------|-------|---------|----------|
| Bug Fix | 5 | 100% | 1.2 hrs |
| Feature | 4 | 75% | 3.5 hrs |
| Refactor | 3 | 67% | 2.8 hrs |

## Failure Analysis

| Failure Point | Count | % |
|---------------|-------|---|
| Quality gates | 2 | 40% |
| CI failures | 1 | 20% |
| Review rejection | 1 | 20% |
| User abort | 1 | 20% |

## Trends (Last 4 Weeks)

```
Week 1: ████████░░ 8 completed
Week 2: ██████████ 10 completed
Week 3: ████████████ 12 completed
Week 4: ██████████████ 14 completed
```

## Recommendations

1. **Reduce implementation time** - Consider more parallel subagents
2. **Improve quality gates** - 40% of failures at this stage
3. **Template common fixes** - Bug fixes are fastest
```

### 5. Save Dashboard

```bash
echo "$DASHBOARD" > "$RUN_DIR/../metrics-$(date +%Y-%m-%d).md"

# Also update summary file
cat > runs/metrics-summary.json << EOF
{
  "generatedAt": "$(date -Iseconds)",
  "period": "30d",
  "totalRuns": $TOTAL,
  "successRate": $SUCCESS_RATE,
  "avgCycleTimeHours": $AVG_CYCLE
}
EOF
```

## Historical Tracking

Append to history file for trends:

```bash
jq -c '{
  date: now | strftime("%Y-%m-%d"),
  metrics: .
}' runs/metrics-summary.json >> runs/metrics-history.jsonl
```

## Notion Integration

Optionally sync key metrics to Notion:

```markdown
⚠️ Optional: Update Notion metrics page?

This will update the pipeline metrics page with current stats.

Options:
1. Update Notion
2. Skip (local only)

Your choice:
```

## Scheduled Reports

Set up weekly digest:

```bash
# Add to crontab or use scheduled task
0 9 * * 1 cd ~/repos/ticket-to-pr-pipeline && amp -c "/skill metrics-dashboard weekly"
```

## Custom Queries

### Tickets by Assignee
```bash
jq -s 'group_by(.assignee) | map({assignee: .[0].assignee, count: length})' /tmp/runs-data.jsonl
```

### Slowest Tickets
```bash
jq -s 'sort_by(.cycleTime) | reverse | .[0:5]' /tmp/runs-data.jsonl
```

### Failed at Phase
```bash
jq -s 'map(select(.status == "failed")) | group_by(.failedAtPhase)' /tmp/runs-data.jsonl
```

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| metrics-{date}.md | `runs/metrics-{date}.md` | Point-in-time dashboard |
| metrics-summary.json | `runs/metrics-summary.json` | Latest metrics JSON |
| metrics-history.jsonl | `runs/metrics-history.jsonl` | Historical trends |
