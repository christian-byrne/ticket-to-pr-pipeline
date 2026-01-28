# Task Context Documents

Each file in this directory is a self-contained context document for a subagent to build one skill of the pipeline.

## How to Use

1. Open a new agent session (fresh context)
2. Point the agent to the task file: "Read and execute the task in `/home/cbyrne/repos/ticket-to-pr-pipeline/tasks/XX-build-*.md`"
3. The agent has everything needed to complete the task
4. When done, verify deliverables and commit the skill

## Task Order

| # | Task | Depends On | Output |
|---|------|------------|--------|
| 01 | ticket-intake | Notion MCP | Skill that parses Notion tickets |
| 02 | research-orchestrator | 01 | Skill that dispatches research subagents |
| 03 | plan-generator | 02 | Skill that creates implementation plans |
| 04 | pr-split-advisor | 03 | Skill that recommends PR splitting |
| 05 | tdd-assessor | 03 | Skill that evaluates TDD fit |
| 06 | quality-gates-runner | Implementation | Skill that runs lint/type/test checks |
| 07 | review-orchestrator | 06 | Skill that dispatches code reviewers |
| 08 | final-qa-launcher | 07 | Skill that starts dev server + QA |
| 09 | pr-creator | 08 | Skill that creates GitHub PRs |
| 10 | ci-checker | 09 | Skill that checks CI status |
| 11 | pipeline-tracker | Any | Utility skill for status/dashboard |

## Parallelization

These can run in parallel (no dependencies on each other):
- 01, 11 (can start together)
- 04, 05 (after 03)
- 06, 07, 08, 09, 10 (can run in parallel after 05)

## Skill Output Location

All skills go to: `/home/cbyrne/.claude/skills/{skill-name}/SKILL.md`

## After Building

1. Test the skill with a real scenario
2. Fix any issues found
3. Create PR in this repo documenting the skill
4. Update implementation-plan.md if needed
