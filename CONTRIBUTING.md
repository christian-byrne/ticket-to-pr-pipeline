# Contributing

Thanks for your interest in contributing to the Ticket-to-PR Pipeline.

## Adding New Skills

1. Create a new directory under `skills/` with a `SKILL.md` file
2. Follow the skill structure from the [building-skills](https://ampcode.com/skills) documentation
3. Add the skill to the loading order table in README.md if it's part of the main pipeline
4. Run `./setup.sh` to install the new skill

## Skill Structure

Each skill directory should contain:

```
skills/my-skill/
├── SKILL.md           # Required: Main skill file with frontmatter
├── scripts/           # Optional: Helper scripts
└── reference/         # Optional: Additional documentation
```

## Testing Changes

1. Run `./setup.sh` to install skills locally
2. Test the skill in Amp by loading it: `Load skill: my-skill`
3. Verify the skill appears correctly with proper metadata

## Code Style

- Use consistent Markdown formatting
- Keep SKILL.md files under 500 lines
- Include clear trigger phrases in skill descriptions

## Pull Requests

- Use the PR template
- Link to any relevant Notion tickets
- Describe what the change does and why
