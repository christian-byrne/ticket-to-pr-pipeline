# External Research Subagent

## Objective

Research external sources for best practices, library documentation, and patterns relevant to implementing the given ticket.

## Input Context

```
Ticket: {{TICKET_TITLE}}
Description: {{TICKET_DESCRIPTION}}
Technologies: {{TECHNOLOGIES}}
Research Topics: {{TOPICS}}
```

## When to Use

Only dispatch this subagent when:

- New library or dependency is being introduced
- Complex pattern that benefits from external research
- UI/UX best practices needed
- Performance optimization techniques required
- Security considerations needed

## Research Sources

### 1. Vue 3 Documentation

- <https://vuejs.org/api/>
- Composition API patterns
- Reactivity system

### 2. VueUse Functions

- <https://vueuse.org/functions.html>
- Performance-enhancing composables
- Utility functions

### 3. Tailwind CSS

- <https://tailwindcss.com/docs/>
- Utility class patterns
- Responsive design

### 4. UI Component Libraries

- <https://reka-ui.com/> (preferred)
- <https://www.shadcn-vue.com/>
- <https://primevue.org> (avoid new usage)

### 5. ComfyUI Documentation

- <https://docs.comfy.org>
- <https://deepwiki.com/Comfy-Org/ComfyUI_frontend>
- Node behavior and API

### 6. Testing Best Practices

- <https://martinfowler.com/articles/practical-test-pyramid.html>
- Playwright best practices
- Vue Test Utils

## Research Tasks

### 1. Library Documentation

If using a new library or API:

```
Use web_search to find official documentation for {{LIBRARY}}
Use read_web_page to extract relevant usage patterns
```

### 2. Best Practices

For patterns and approaches:

```
Use web_search for "{{TECHNOLOGY}} best practices {{USE_CASE}}"
Focus on authoritative sources (official docs, reputable blogs)
```

### 3. Similar Implementations

Find examples of similar features:

```
Search for "{{FEATURE}} implementation {{FRAMEWORK}}"
Look for open-source examples
```

## Output Format

````markdown
## External Research Report

### Summary

- Key sources consulted: {{COUNT}}
- Relevant patterns found: {{COUNT}}
- Recommended approach: {{SUMMARY}}

### Library Documentation

#### {{LIBRARY_NAME}}

- **Official Docs:** {{URL}}
- **Key API:** {{API_METHODS}}
- **Usage Pattern:**

```typescript
// Example from docs
```
````

- **Gotchas:** Things to watch out for

### Best Practices

#### {{PRACTICE_NAME}}

- **Source:** {{URL}}
- **Recommendation:** What to do
- **Rationale:** Why this is recommended
- **Example:**

```typescript
// Example code
```

### Similar Implementations

#### {{EXAMPLE_NAME}}

- **Source:** {{URL}}
- **Pattern:** How they solved similar problem
- **Applicability:** How this applies to our ticket

### UI/UX Considerations

- Accessibility requirements
- Responsive design patterns
- User interaction patterns

### Security Considerations

- Data handling best practices
- Input validation patterns
- Common vulnerabilities to avoid

### Recommendations

1. **Approach:** Recommended implementation approach
2. **Libraries:** Any libraries to use/avoid
3. **Patterns:** Patterns to follow
4. **Testing:** How to verify the implementation

```

## Success Criteria

- Found authoritative documentation for relevant technologies
- Identified applicable best practices
- Provided concrete examples
- Made actionable recommendations
```
