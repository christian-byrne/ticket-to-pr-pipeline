# Codebase Analysis Research Subagent

## Objective

Analyze the relevant parts of the ComfyUI_frontend codebase to understand patterns, architecture, and affected files for the given ticket.

## Input Context

```
Ticket: {{TICKET_TITLE}}
Description: {{TICKET_DESCRIPTION}}
Keywords: {{KEYWORDS}}
Repository: ComfyUI_frontend
```

## Research Tasks

### 1. Identify Affected Files

Locate the files that will need to be modified:

```bash
# Search for relevant code
grep -r "{{KEYWORD}}" src/ --include="*.ts" --include="*.vue"

# Find related components
find src -name "*{{ComponentName}}*"

# Search for related tests
find . -name "*.test.ts" | xargs grep -l "{{KEYWORD}}"
```

### 2. Understand Existing Patterns

For each affected file, understand:
- Component structure (if Vue)
- State management approach
- API interactions
- Testing patterns

### 3. Check AGENTS.md Guidelines

Read the AGENTS.md file for:
- Coding standards
- Naming conventions
- Testing requirements
- PR requirements

### 4. Related Code Patterns

Find similar features to understand established patterns:

```bash
# Find similar components
ls src/components/

# Find similar composables
ls src/composables/

# Find similar stores
ls src/stores/
```

### 5. Dependencies & Imports

Understand what the affected files depend on:

```bash
# Check imports in affected files
head -30 {{FILE_PATH}}

# Find usages of affected modules
grep -r "import.*from.*{{MODULE}}" src/
```

## Output Format

```markdown
## Codebase Analysis Report

### Summary
- X files will need modification
- Primary areas: {{AREAS}}
- Established patterns identified: {{PATTERNS}}

### Affected Files

#### {{FILE_PATH}}
- **Type:** Component/Composable/Store/Utility
- **Purpose:** What this file does
- **Key Dependencies:** What it imports/uses
- **Testing:** How it's currently tested
- **Changes Needed:** What changes are required

### Established Patterns

#### Component Pattern
```typescript
// Example of how similar components are structured
```

#### State Management Pattern
```typescript
// Example of how state is managed
```

#### API Interaction Pattern
```typescript
// Example of how API calls are made
```

### Testing Patterns

- Unit tests location: {{PATH}}
- Test framework: Vitest
- Example test structure:
```typescript
// Example test pattern
```

### Coding Standards (from AGENTS.md)

- Vue: Composition API, `<script setup lang="ts">`
- Styling: Tailwind 4, no `<style>` blocks
- Naming: PascalCase components, camelCase functions
- No `any` types
- No comments unless necessary

### Recommendations

1. **File Structure:** Where to add new files
2. **Patterns to Follow:** Which existing code to mimic
3. **Testing Approach:** How to test the changes
4. **Potential Pitfalls:** Things to avoid based on codebase patterns
```

## Success Criteria

- Identified all files that need modification
- Found similar code patterns to follow
- Understood testing approach
- Compiled relevant coding standards
