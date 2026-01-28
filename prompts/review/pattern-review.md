# Pattern Compliance Review Subagent

## Objective

Review the code changes specifically for compliance with established codebase patterns and the AGENTS.md guidelines.

## Input Context

```
Files Changed: {{FILES_LIST}}
Repository: ComfyUI_frontend
```

## Review Focus Areas

### 1. Vue Component Patterns

Check for violations:

```typescript
// ❌ Wrong: Using withDefaults
const props = withDefaults(defineProps<Props>(), { ... })

// ✅ Correct: Reactive props destructuring with defaults
const { nodes, showTotal = true } = defineProps<Props>()
```

```typescript
// ❌ Wrong: Using props variable
const props = defineProps<Props>()
return () => <div>{props.value}</div>

// ✅ Correct: Destructure props
const { value } = defineProps<Props>()
```

```typescript
// ❌ Wrong: Inline type imports
import { bar, type Foo } from './foo'

// ✅ Correct: Separate type imports
import type { Foo } from './foo'
import { bar } from './foo'
```

### 2. Tailwind Patterns

Check for violations:

```html
<!-- ❌ Wrong: Using dark: variant -->
<div class="bg-white dark:bg-black">

<!-- ✅ Correct: Use semantic theme values -->
<div class="bg-node-component-surface">
```

```html
<!-- ❌ Wrong: Using :class array -->
<div :class="['text-red', isActive && 'font-bold']">

<!-- ✅ Correct: Using cn() utility -->
<div :class="cn('text-red', isActive && 'font-bold')">
```

```html
<!-- ❌ Wrong: Using !important -->
<div class="!text-red">

<!-- ✅ Correct: Find and fix interfering classes -->
```

```html
<!-- ❌ Wrong: Arbitrary percentages -->
<div class="w-[80%]">

<!-- ✅ Correct: Tailwind fraction utilities -->
<div class="w-4/5">
```

### 3. TypeScript Patterns

Check for violations:

```typescript
// ❌ Wrong: Using any
const data: any = fetchData()

// ✅ Correct: Proper types
const data: UserData = fetchData()
```

```typescript
// ❌ Wrong: as any assertion
const result = data as any

// ✅ Correct: Fix underlying type issue
```

### 4. State Management Patterns

Check for over-complexity:

```typescript
// ❌ Wrong: Unnecessary computed when direct usage works
const value = computed(() => props.value)
// If only used once, just use props.value directly

// ❌ Wrong: Unnecessary watch when computed works
const derived = ref('')
watch(() => props.value, (v) => derived.value = v.toUpperCase())
// Use computed instead: const derived = computed(() => props.value.toUpperCase())
```

### 5. Testing Patterns

Check for anti-patterns:

```typescript
// ❌ Wrong: Change detector test
it('has default value', () => {
  expect(component.defaultValue).toBe('foo')
})

// ❌ Wrong: Testing mocks
it('calls mock', () => {
  mockFn()
  expect(mockFn).toHaveBeenCalled()
})

// ✅ Correct: Behavioral test
it('shows error when validation fails', () => {
  // Test actual behavior
})
```

## Output Format

```markdown
## Pattern Compliance Review Report

### Summary
- Files reviewed: X
- Pattern violations: X
- All patterns followed: Yes/No

### Vue Component Violations

#### {{FILE_PATH}}:{{LINE}}
- **Pattern:** {{PATTERN_NAME}}
- **Violation:** {{DESCRIPTION}}
- **Current Code:**
```typescript
// What's there
```
- **Correct Pattern:**
```typescript
// What it should be
```

### Tailwind Violations

#### {{FILE_PATH}}:{{LINE}}
- **Pattern:** {{PATTERN_NAME}}
- **Violation:** {{DESCRIPTION}}
- **Fix:** {{HOW_TO_FIX}}

### TypeScript Violations

#### {{FILE_PATH}}:{{LINE}}
- **Pattern:** {{PATTERN_NAME}}
- **Violation:** {{DESCRIPTION}}
- **Fix:** {{HOW_TO_FIX}}

### State Management Concerns

#### {{FILE_PATH}}
- **Issue:** {{DESCRIPTION}}
- **Recommendation:** {{RECOMMENDATION}}

### Testing Pattern Issues

#### {{FILE_PATH}}
- **Issue:** {{DESCRIPTION}}
- **Fix:** {{HOW_TO_FIX}}

### Good Patterns Followed
- List of patterns the code correctly follows
- Acknowledge what's done well

### Recommendations
1. Prioritized list of fixes
2. Any codebase-wide observations
```

## Success Criteria

- All AGENTS.md rules checked
- Specific violations identified with line numbers
- Fix suggestions provided
- Patterns correctly followed are acknowledged
