---
name: template-library
description: Pre-built plan templates for common ticket types. Use to quickly scaffold plans for bug fixes, features, refactors, and migrations.
---

# Template Library

Provides pre-built implementation plan templates for common ticket patterns, accelerating the planning phase.

## Available Templates

| Template | Use Case | Typical Size |
|----------|----------|--------------|
| bug-fix | Fix reported bug with test | S-M |
| feature-component | New Vue component | M-L |
| feature-composable | New composable/hook | S-M |
| feature-store | New Pinia store | M |
| refactor-extract | Extract logic to new module | M |
| refactor-rename | Rename across codebase | S |
| migration-api | Update API integration | M-L |
| test-coverage | Add tests to existing code | M |
| docs-update | Documentation changes | S |

## Workflow

### 1. Detect Template Match

During plan-generator, analyze ticket to suggest template:

```markdown
Ticket analysis suggests: **bug-fix** template

Match confidence: 85%
Indicators:
- Title contains "fix" or "bug"
- References issue report
- Mentions specific error

Use this template? (Y/N/customize)
```

### 2. Load Template

```bash
TEMPLATE="bug-fix"
cat "templates/$TEMPLATE.md"
```

### 3. Fill Template Variables

Each template has placeholders:

```markdown
# Implementation Plan: {{TICKET_TITLE}}

## Goal
Fix {{BUG_DESCRIPTION}} in {{AFFECTED_COMPONENT}}.

## Root Cause
{{ROOT_CAUSE_ANALYSIS}}

## Solution
{{PROPOSED_FIX}}
```

### 4. Customize for Ticket

Adapt template sections based on ticket specifics, then proceed to normal plan review.

---

## Template: bug-fix

```markdown
# Implementation Plan: Fix {{TICKET_TITLE}}

## Goal
Fix the reported issue: {{BUG_SUMMARY}}

## Root Cause Analysis
- **Symptom:** {{SYMPTOM}}
- **Location:** {{FILE_PATH}}:{{LINE}}
- **Cause:** {{ROOT_CAUSE}}

## Proposed Fix

### Approach
{{FIX_DESCRIPTION}}

### Code Changes
File: `{{FILE_PATH}}`
```typescript
// Before
{{BEFORE_CODE}}

// After  
{{AFTER_CODE}}
```

## Files to Modify
- `{{FILE_PATH}}` - Apply fix

## Files to Create
- `{{TEST_FILE}}` - Regression test

## Testing Strategy
1. Add failing test that reproduces bug
2. Apply fix
3. Verify test passes
4. Run existing test suite

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| Fix causes regression | Added regression test |
| Edge cases missed | Review similar code paths |

## Estimated Scope
- Lines of code: ~20-50
- Complexity: Low
- PR split: Single PR

---
*Template: bug-fix*
```

---

## Template: feature-component

```markdown
# Implementation Plan: {{COMPONENT_NAME}} Component

## Goal
Create new {{COMPONENT_NAME}} component for {{PURPOSE}}.

## Proposed Approach
Build a Vue 3 component using Composition API with:
- Props: {{PROPS_LIST}}
- Emits: {{EVENTS_LIST}}
- Slots: {{SLOTS_LIST}}

## Architecture
```
src/components/
  └── {{COMPONENT_PATH}}/
      ├── {{COMPONENT_NAME}}.vue    # Main component
      ├── {{COMPONENT_NAME}}.test.ts # Unit tests
      └── types.ts                   # Type definitions
```

## Files to Create
- `src/components/{{COMPONENT_PATH}}/{{COMPONENT_NAME}}.vue`
- `src/components/{{COMPONENT_PATH}}/types.ts`
- `src/components/{{COMPONENT_PATH}}/{{COMPONENT_NAME}}.test.ts`

## Files to Modify
- `src/components/index.ts` - Export new component

## Component Structure
```vue
<script setup lang="ts">
import { computed } from 'vue'
import type { {{PROPS_TYPE}} } from './types'

const props = defineProps<{{PROPS_TYPE}}>()
const emit = defineEmits<{
  {{EVENTS_DEFINITION}}
}>()

// Component logic
</script>

<template>
  <div class="{{COMPONENT_CLASS}}">
    <!-- Component template -->
  </div>
</template>

<style scoped>
.{{COMPONENT_CLASS}} {
  /* Component styles */
}
</style>
```

## Testing Strategy
- Unit tests with Vitest
- Test prop variations
- Test event emissions
- Test slot rendering

## Estimated Scope
- Lines of code: ~100-200
- Complexity: Medium
- PR split: Single PR

---
*Template: feature-component*
```

---

## Template: feature-composable

```markdown
# Implementation Plan: use{{COMPOSABLE_NAME}} Composable

## Goal
Create reusable composable for {{PURPOSE}}.

## API Design
```typescript
interface Use{{COMPOSABLE_NAME}}Options {
  {{OPTIONS}}
}

interface Use{{COMPOSABLE_NAME}}Return {
  {{RETURN_VALUES}}
}

function use{{COMPOSABLE_NAME}}(options?: Use{{COMPOSABLE_NAME}}Options): Use{{COMPOSABLE_NAME}}Return
```

## Files to Create
- `src/composables/use{{COMPOSABLE_NAME}}.ts`
- `src/composables/use{{COMPOSABLE_NAME}}.test.ts`

## Files to Modify
- `src/composables/index.ts` - Export composable

## Implementation Pattern
```typescript
import { ref, computed, onMounted, onUnmounted } from 'vue'

export function use{{COMPOSABLE_NAME}}(options?: Use{{COMPOSABLE_NAME}}Options) {
  // Reactive state
  const state = ref({{INITIAL_STATE}})
  
  // Computed properties
  const derived = computed(() => {{COMPUTATION}})
  
  // Methods
  function action() {
    {{ACTION_LOGIC}}
  }
  
  // Lifecycle
  onMounted(() => {{MOUNT_LOGIC}})
  onUnmounted(() => {{CLEANUP_LOGIC}})
  
  return {
    state,
    derived,
    action
  }
}
```

## Testing Strategy
- Test reactive updates
- Test computed values
- Test cleanup on unmount
- Test edge cases

## Estimated Scope
- Lines of code: ~50-100
- Complexity: Low-Medium
- PR split: Single PR

---
*Template: feature-composable*
```

---

## Template: refactor-extract

```markdown
# Implementation Plan: Extract {{MODULE_NAME}}

## Goal
Extract {{FUNCTIONALITY}} from {{SOURCE_FILE}} into dedicated module.

## Motivation
- Current location: {{SOURCE_FILE}}
- Problem: {{PROBLEM}}
- Benefit: {{BENEFIT}}

## Files to Create
- `src/{{NEW_PATH}}/{{MODULE_NAME}}.ts` - Extracted logic
- `src/{{NEW_PATH}}/{{MODULE_NAME}}.test.ts` - Tests
- `src/{{NEW_PATH}}/types.ts` - Type definitions

## Files to Modify
- `{{SOURCE_FILE}}` - Remove extracted code, add import
- `src/{{NEW_PATH}}/index.ts` - Export module

## Refactoring Steps

### Step 1: Create New Module
Create `{{MODULE_NAME}}.ts` with extracted logic.

### Step 2: Add Types
Define interfaces in `types.ts`.

### Step 3: Add Tests
Copy/adapt existing tests to new location.

### Step 4: Update Source
Replace inline code with import.

### Step 5: Verify
Run full test suite.

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| Break existing functionality | Comprehensive tests first |
| Import cycles | Check dependency graph |

## Estimated Scope
- Lines of code: ~100-200
- Complexity: Medium
- PR split: Single PR

---
*Template: refactor-extract*
```

---

## Adding Custom Templates

Create new template in `templates/` directory:

```bash
mkdir -p templates
cat > templates/custom-template.md << 'EOF'
# Implementation Plan: {{TITLE}}

## Goal
{{GOAL}}

## Proposed Approach
{{APPROACH}}

## Files to Modify
- {{FILES}}

## Testing Strategy
{{TESTING}}

## Estimated Scope
- Lines of code: {{LOC}}
- Complexity: {{COMPLEXITY}}

---
*Template: custom-template*
EOF
```

## Template Selection Heuristics

| Indicator | Suggested Template |
|-----------|-------------------|
| "fix", "bug", "error" in title | bug-fix |
| "add component", "create UI" | feature-component |
| "add hook", "composable" | feature-composable |
| "extract", "move", "split" | refactor-extract |
| "rename", "naming" | refactor-rename |
| "update API", "migrate" | migration-api |
| "add tests", "coverage" | test-coverage |

## Output

Templates are filled and saved as `plan.md` in the run directory, then proceed through normal plan-generator review flow.
