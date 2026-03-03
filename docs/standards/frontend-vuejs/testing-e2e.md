# Frontend Standards (Vue.js) - E2E Testing

> **Module:** testing-e2e.md | **Sections:** 5 | **Parent:** [frontend-vuejs.md](../frontend-vuejs.md)

This module covers end-to-end testing patterns for Vue 3 / Nuxt 3 applications using Playwright. E2E tests validate complete user flows from the product-designer's specifications.

> **Gate Reference:** This module is loaded by `bee:qa-analyst-frontend` at Gate 5 (E2E Testing).

---

## Table of Contents

| # | [Section Name](#anchor-link) | Description |
|---|------------------------------|-------------|
| 1 | [User Flow Consumption](#user-flow-consumption-mandatory) | Converting product-designer flows to tests |
| 2 | [Error Path Testing](#error-path-testing-mandatory) | API failures, timeouts, invalid data |
| 3 | [Cross-Browser Testing](#cross-browser-testing-mandatory) | Chromium, Firefox, WebKit coverage |
| 4 | [Responsive E2E](#responsive-e2e-mandatory) | Mobile, tablet, desktop viewport testing |
| 5 | [Selector Strategy](#selector-strategy-mandatory) | data-testid conventions |

**Meta-sections:** [Output Format (Gate 5 - E2E Testing)](#output-format-gate-5---e2e-testing), [Anti-Rationalization Table](#anti-rationalization-table-e2e-testing)

---

## User Flow Consumption (MANDATORY)

**HARD GATE:** All user flows from `bee:product-designer` output MUST have corresponding E2E tests.

### Input Source

The `bee:product-designer` agent produces `user-flows.md` with structured user flows:

```markdown
## User Flow: Create Transaction
1. User navigates to /transactions
2. User clicks "New Transaction" button
3. User fills in amount, description, category
4. User clicks "Submit"
5. System shows success toast
6. Transaction appears in list
```

### Conversion Pattern

```typescript
import { test, expect } from '@playwright/test'

// user-flows.md → E2E test
test.describe('Create Transaction flow', () => {
    test('happy path: user creates a transaction', async ({ page }) => {
        // Step 1: User navigates to /transactions
        await page.goto('/transactions')

        // Step 2: User clicks "New Transaction" button
        await page.getByRole('button', { name: 'New Transaction' }).click()

        // Step 3: User fills in amount, description, category
        await page.getByLabel('Amount').fill('100.50')
        await page.getByLabel('Description').fill('Office supplies')
        await page.getByLabel('Category').selectOption('expenses')

        // Step 4: User clicks "Submit"
        await page.getByRole('button', { name: 'Submit' }).click()

        // Step 5: System shows success toast
        await expect(page.getByRole('alert')).toContainText('Transaction created')

        // Step 6: Transaction appears in list
        await expect(page.getByText('Office supplies')).toBeVisible()
    })
})
```

### Flow Coverage Requirements

| Requirement | Minimum |
|-------------|---------|
| All user flows from product-designer | 100% coverage |
| Each flow has happy path test | MANDATORY |
| Each flow has at least 1 error path | MANDATORY |
| Backend handoff endpoints covered | All endpoints |

### Backend Handoff Integration

When a backend dev cycle produces a handoff, use the endpoints and contracts:

```typescript
// Backend handoff provides: POST /api/transactions
// Contract: { amount: number, description: string, category_id: string }

test('MUST validate against backend contract', async ({ page }) => {
    // Intercept API call to verify contract
    const requestPromise = page.waitForRequest('**/api/transactions')

    await page.goto('/transactions/new')
    await page.getByLabel('Amount').fill('100.50')
    await page.getByLabel('Description').fill('Test')
    await page.getByRole('button', { name: 'Submit' }).click()

    const request = await requestPromise
    const body = request.postDataJSON()
    expect(body).toHaveProperty('amount')
    expect(body).toHaveProperty('description')
    expect(body).toHaveProperty('category_id')
})
```

### Nuxt-Specific: Server Route Interception

Nuxt server routes (`/server/api/`) are also interceptable with Playwright's `page.route()`:

```typescript
test('MUST intercept Nuxt server API route', async ({ page }) => {
    // Nuxt server routes are served from the same origin
    await page.route('**/api/transactions', (route) => {
        route.fulfill({
            status: 200,
            contentType: 'application/json',
            body: JSON.stringify({ data: [], total: 0 }),
        })
    })

    await page.goto('/transactions')
    await expect(page.getByText('No results')).toBeVisible()
})
```

---

## Error Path Testing (MANDATORY)

**HARD GATE:** All E2E flows MUST test error scenarios, not just happy paths.

### Required Error Scenarios

| Scenario | How to Test | What to Verify |
|----------|-------------|----------------|
| API 500 error | Mock API response | Error message shown |
| API timeout | Delay response | Loading state, timeout message |
| Validation error | Submit invalid data | Field-level error messages |
| Network offline | Simulate offline | Offline indicator, retry option |
| 404 page | Navigate to invalid URL | Nuxt `error.vue` renders |
| Unauthorized | Expired/invalid token | Redirect to login |

### Test Pattern: API Error

```typescript
test('MUST show error when API returns 500', async ({ page }) => {
    // Mock API to return 500
    await page.route('**/api/transactions', (route) => {
        route.fulfill({
            status: 500,
            body: JSON.stringify({ error: 'Internal Server Error' }),
        })
    })

    await page.goto('/transactions')
    await page.getByRole('button', { name: 'New Transaction' }).click()
    await page.getByLabel('Amount').fill('100')
    await page.getByRole('button', { name: 'Submit' }).click()

    // Verify error handling
    await expect(page.getByRole('alert')).toContainText('error')
    // Form should still be visible (not cleared)
    await expect(page.getByLabel('Amount')).toHaveValue('100')
})
```

### Test Pattern: Validation Error (VeeValidate)

```typescript
test('MUST show validation errors for empty required fields', async ({ page }) => {
    await page.goto('/transactions/new')

    // Submit without filling required fields
    await page.getByRole('button', { name: 'Submit' }).click()

    // VeeValidate renders errors below each field
    await expect(page.getByText('Amount is required')).toBeVisible()
    await expect(page.getByText('Description is required')).toBeVisible()
})
```

### Test Pattern: Network Timeout

```typescript
test('MUST handle API timeout gracefully', async ({ page }) => {
    await page.route('**/api/transactions', async (route) => {
        // Simulate slow response
        await new Promise(resolve => setTimeout(resolve, 30000))
        route.fulfill({ status: 200, body: '[]' })
    })

    await page.goto('/transactions')

    // Loading skeleton should be visible (Nuxt pending state)
    await expect(page.getByTestId('loading-skeleton')).toBeVisible()

    // After timeout, error message should appear
    await expect(page.getByText(/timeout|try again/i)).toBeVisible({ timeout: 15000 })
})
```

### Test Pattern: Nuxt 404 Page

```typescript
test('MUST render error.vue for unknown routes', async ({ page }) => {
    await page.goto('/this-page-does-not-exist')

    // Nuxt renders error.vue automatically for 404s
    await expect(page.getByText('404')).toBeVisible()
    await expect(page.getByRole('link', { name: /go home/i })).toBeVisible()
})
```

---

## Cross-Browser Testing (MANDATORY)

**HARD GATE:** E2E tests MUST pass on Chromium, Firefox, and WebKit.

### Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
    // Nuxt dev server is started automatically
    webServer: {
        command: 'npm run dev',
        url: 'http://localhost:3000',
        reuseExistingServer: !process.env.CI,
    },
    use: {
        baseURL: 'http://localhost:3000',
    },
    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
        {
            name: 'firefox',
            use: { ...devices['Desktop Firefox'] },
        },
        {
            name: 'webkit',
            use: { ...devices['Desktop Safari'] },
        },
    ],
})
```

### Browser-Specific Considerations

| Browser | Common Issues | How to Handle |
|---------|---------------|---------------|
| **Firefox** | Date input formatting differs | Use consistent date picker component |
| **WebKit** | Scroll behavior differs | Use `scrollIntoView` polyfill |
| **All** | Animation timing | Use `page.waitForSelector` not timeouts |
| **All** | Nuxt hydration | Wait for `networkidle` before assertions on dynamic content |

### Running Cross-Browser Tests

```bash
# Run all browsers
npx playwright test

# Run specific browser
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit

# Run with HTML report
npx playwright test --reporter=html
```

---

## Responsive E2E (MANDATORY)

**HARD GATE:** User flows that differ by viewport MUST be tested at mobile, tablet, and desktop sizes.

### Required Viewports

| Viewport | Device | Width x Height |
|----------|--------|---------------|
| **Mobile** | iPhone 13 | 390 x 844 |
| **Tablet** | iPad | 768 x 1024 |
| **Desktop** | Desktop Chrome | 1280 x 720 |

### Test Pattern

```typescript
const VIEWPORTS = [
    { name: 'mobile', width: 390, height: 844 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1280, height: 720 },
]

for (const viewport of VIEWPORTS) {
    test.describe(`${viewport.name} viewport`, () => {
        test.use({ viewport: { width: viewport.width, height: viewport.height } })

        test('navigation MUST be accessible', async ({ page }) => {
            await page.goto('/')

            if (viewport.name === 'mobile') {
                // Mobile: hamburger menu (Nuxt layout renders differently)
                await page.getByTestId('mobile-menu-trigger').click()
                await expect(page.getByRole('navigation')).toBeVisible()
            } else {
                // Tablet/Desktop: sidebar visible by default
                await expect(page.getByRole('navigation')).toBeVisible()
            }
        })
    })
}
```

### What to Test Responsively

| Element | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| Navigation | Hamburger menu | Collapsed sidebar | Full sidebar |
| Tables | Card view | Scrollable | Full table |
| Forms | Stacked fields | 2-column | Multi-column |
| Modals | Full-screen sheet | Centered modal | Centered modal |

### Nuxt Layout Testing

Nuxt layouts (`layouts/`) control the overall page shell. Test layout switching per viewport:

```typescript
test('MUST use mobile layout on small screens', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 })
    await page.goto('/dashboard')

    // Sidebar should be hidden on mobile
    await expect(page.getByTestId('desktop-sidebar')).toBeHidden()
    await expect(page.getByTestId('mobile-bottom-nav')).toBeVisible()
})
```

---

## Selector Strategy (MANDATORY)

**HARD GATE:** All E2E selectors MUST use `data-testid` or semantic roles. CSS class selectors are FORBIDDEN except for layout containers where no semantic role applies.

### Selector Priority

| Priority | Selector | When to Use |
|----------|----------|-------------|
| 1 (best) | `getByRole` | Buttons, links, headings, form controls |
| 2 | `getByLabel` | Form inputs with labels (VeeValidate renders labels) |
| 3 | `getByText` | Static text content |
| 4 | `getByTestId` | Complex components without semantic role |
| 5 (avoid) | CSS selectors | FORBIDDEN except for layout containers |

### data-testid Convention

| Pattern | Example |
|---------|---------|
| `{component}-{element}` | `transaction-list-item` |
| `{page}-{section}` | `dashboard-summary` |
| `{action}-trigger` | `create-transaction-trigger` |
| `{component}-{state}` | `loading-skeleton` |

### Applying data-testid in Vue Templates

```html
<!-- In Vue SFCs, add data-testid directly on elements -->
<template>
    <ul>
        <li
            v-for="transaction in transactions"
            :key="transaction.id"
            data-testid="transaction-list-item"
        >
            {{ transaction.description }}
        </li>
    </ul>

    <div data-testid="loading-skeleton" v-if="pending">
        <Skeleton v-for="i in 5" :key="i" class="h-12 w-full" />
    </div>

    <button data-testid="create-transaction-trigger" @click="openCreate">
        New Transaction
    </button>
</template>
```

### Correct Pattern

```typescript
// CORRECT: Semantic roles
await page.getByRole('button', { name: 'Submit' }).click()
await page.getByLabel('Email').fill('user@example.com')
await page.getByRole('heading', { name: 'Dashboard' })

// CORRECT: data-testid for complex elements
await page.getByTestId('transaction-list-item').first().click()
await page.getByTestId('dashboard-summary')
```

### FORBIDDEN Patterns

```typescript
// FORBIDDEN: CSS class selectors
await page.locator('.btn-primary').click()
await page.locator('#submit-button').click()
await page.locator('div.transaction-card').click()

// FORBIDDEN: XPath
await page.locator('//div[@class="card"]').click()

// FORBIDDEN: Fragile text matching
await page.locator('text=Submit').click() // Use getByRole instead

// FORBIDDEN: Vue-specific class selectors (Tailwind classes change)
await page.locator('.flex.items-center').click()
```

---

## Output Format (Gate 5 - E2E Testing)

```markdown
## E2E Testing Summary

| Metric | Value |
|--------|-------|
| User flows tested | X/Y (from product-designer) |
| Happy path tests | X |
| Error path tests | Y |
| Browsers tested | Chromium, Firefox, WebKit |
| Viewports tested | Mobile, Tablet, Desktop |
| Consecutive passes | 3/3 |

### Flow Coverage

| User Flow | Happy Path | Error Paths | Browsers | Viewports | Status |
|-----------|------------|-------------|----------|-----------|--------|
| Create Transaction | PASS | API 500, Validation | 3/3 | 3/3 | PASS |
| View Dashboard | PASS | Empty state, Timeout | 3/3 | 3/3 | PASS |
| User Login | PASS | Invalid creds, Lockout | 3/3 | 3/3 | PASS |

### Backend Handoff Verification

| Endpoint | Method | Contract Verified | Status |
|----------|--------|-------------------|--------|
| /api/transactions | POST | amount, description, category_id | PASS |
| /api/transactions | GET | pagination, filters | PASS |

### Standards Compliance

| Standard | Status | Evidence |
|----------|--------|----------|
| All user-flows covered | PASS | X/Y flows |
| Error paths tested | PASS | Y error tests |
| Cross-browser | PASS | 3/3 browsers |
| Responsive | PASS | 3 viewports |
| 3x consecutive pass | PASS | Run 3 times |
```

---

## Anti-Rationalization Table (E2E Testing)

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Unit tests cover the user flow" | Unit tests don't test real browser + API interaction. | **Write E2E tests** |
| "We only need Chromium" | Users use Firefox and Safari too. Cross-browser bugs are common. | **Test all 3 browsers** |
| "Mobile is just a smaller screen" | Navigation, layout, and interactions change. Nuxt layouts differ per breakpoint. | **Test all viewports** |
| "Happy path is enough" | Users encounter errors. Error handling MUST be tested. | **Add error path tests** |
| "CSS selectors are fine" | CSS classes change with refactors. Semantic selectors are stable. | **Use roles and test IDs** |
| "Product-designer flows are just suggestions" | Flows define acceptance criteria. MUST cover all. | **Test all flows** |

---
