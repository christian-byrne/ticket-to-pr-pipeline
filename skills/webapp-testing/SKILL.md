---
name: webapp-testing
description: Visual verification of web app changes using Playwright. Takes screenshots, checks console errors, and validates UI after implementation. Use before final QA for automated visual checks.
---

# Webapp Testing

Automated visual verification of frontend changes using Playwright. Takes screenshots, checks for console errors, and validates UI elements work correctly.

## Prerequisites

- Target repository dev server running (e.g., `pnpm dev`)
- Playwright installed: `pnpm exec playwright install chromium`

## Workflow

### 1. Start Dev Server

Use tmux to run server in background:

```bash
# Navigate to your target repository and start dev server
tmux new-session -d -s dev-server "cd $TARGET_REPO && pnpm dev"
```

Where `TARGET_REPO` is the repository being tested (from ticket.json or current working directory).

Wait for server ready:
```bash
sleep 10
curl -s http://localhost:5173 | head -1
```

### 2. Define Test Scenarios

Based on the ticket and plan, identify what to verify:

```markdown
## Visual Test Plan

### Pages to Check
- [ ] Home/Editor page loads
- [ ] {Affected component} renders correctly
- [ ] {New feature} is visible and interactive

### Interactions to Test
- [ ] Click {button/element} → {expected result}
- [ ] Input {value} → {expected behavior}
- [ ] Navigate to {route} → {expected state}

### Console Checks
- [ ] No JavaScript errors on load
- [ ] No failed network requests
- [ ] No Vue warnings
```

### 3. Run Playwright Checks

**Take Screenshot:**
```bash
pnpm exec playwright screenshot http://localhost:5173 screenshot-home.png
```

**Check for Console Errors:**
```javascript
// scripts/check-console.js
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  const errors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') errors.push(msg.text());
  });
  page.on('pageerror', err => errors.push(err.message));
  
  await page.goto('http://localhost:5173');
  await page.waitForLoadState('networkidle');
  
  await browser.close();
  
  if (errors.length > 0) {
    console.log('Console errors found:');
    errors.forEach(e => console.log(`  - ${e}`));
    process.exit(1);
  }
  console.log('No console errors');
})();
```

Run: `node scripts/check-console.js`

**Click and Verify:**
```javascript
// scripts/verify-interaction.js
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  await page.goto('http://localhost:5173');
  await page.waitForLoadState('networkidle');
  
  // Example: click a button and verify result
  await page.click('[data-testid="my-button"]');
  await page.waitForSelector('[data-testid="expected-result"]');
  
  console.log('Interaction verified');
  await browser.close();
})();
```

### 4. Generate Report

```markdown
## Visual Verification Report

**URL:** http://localhost:5173
**Tested:** {timestamp}

### Screenshots
- [Home Page](screenshots/home.png)
- [{Feature} Page](screenshots/feature.png)

### Console Check
✅ No JavaScript errors
✅ No failed requests

### Interactions
✅ {Button} click works
✅ {Feature} renders correctly
⚠️ {Minor issue} - {description}

### Issues Found
1. {Issue description} - {severity}
```

### 5. Save Artifacts

```bash
mkdir -p "$RUN_DIR/screenshots"
mv screenshot-*.png "$RUN_DIR/screenshots/"
echo "$REPORT" > "$RUN_DIR/visual-verification.md"
```

### 6. Cleanup

```bash
tmux kill-session -t dev-server
```

## Quick Checks

### Page Loads Without Error
```bash
pnpm exec playwright screenshot http://localhost:5173 /tmp/check.png --wait-for-load-state networkidle
```

### Element Exists
```bash
pnpm exec playwright \
  --eval "await page.goto('http://localhost:5173'); await page.waitForSelector('.my-element');"
```

### Take Multiple Screenshots
```bash
for route in "" "settings" "workflows"; do
  pnpm exec playwright screenshot "http://localhost:5173/$route" "screenshot-$route.png"
done
```

## Common Patterns

### Test Modal Opens
```javascript
await page.click('[data-testid="open-modal"]');
await expect(page.locator('.modal')).toBeVisible();
```

### Test Form Submission
```javascript
await page.fill('input[name="title"]', 'Test Value');
await page.click('button[type="submit"]');
await expect(page.locator('.success-message')).toBeVisible();
```

### Test Navigation
```javascript
await page.click('a[href="/settings"]');
await expect(page).toHaveURL(/.*settings/);
```

## Integration with Pipeline

**Before:** quality-gates-runner (code quality)
**After:** final-qa-launcher (manual QA)

This skill provides automated visual checks before human QA.

## Output Artifacts

| File | Location | Description |
|------|----------|-------------|
| screenshots/*.png | `runs/{ticket-id}/screenshots/` | Page screenshots |
| visual-verification.md | `runs/{ticket-id}/visual-verification.md` | Test report |
