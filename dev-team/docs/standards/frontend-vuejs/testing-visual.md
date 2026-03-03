# Frontend Standards (Vue.js) - Visual/Snapshot Testing

> **Module:** testing-visual.md | **Sections:** 4 | **Parent:** [frontend-vuejs.md](../frontend-vuejs.md)

This module covers visual and snapshot testing patterns for Vue 3 / Nuxt 3 applications. Ensures UI consistency through snapshot testing with Vitest and Vue Testing Library, responsive coverage, and component state verification.

> **Gate Reference:** This module is loaded by `bee:qa-analyst-frontend` at Gate 4 (Visual Testing).

---

## Table of Contents

| # | [Section Name](#anchor-link) | Description |
|---|------------------------------|-------------|
| 1 | [Snapshot Testing Patterns](#snapshot-testing-patterns-mandatory) | toMatchSnapshot usage with Vitest + Vue Testing Library |
| 2 | [States Coverage](#states-coverage-mandatory) | All component states must be captured |
| 3 | [Responsive Snapshots](#responsive-snapshots-mandatory) | Mobile, tablet, desktop viewports |
| 4 | [Component Duplication Check](#component-duplication-check-mandatory) | Prevent recreating sindarian-vue components |

**Meta-sections:** [Output Format (Gate 4 - Visual Testing)](#output-format-gate-4---visual-testing), [Anti-Rationalization Table](#anti-rationalization-table-visual-testing)

---

## Snapshot Testing Patterns (MANDATORY)

**HARD GATE:** All UI components MUST have snapshot tests covering all states and viewports.

### Required Tool Setup

| Tool | Purpose | Config |
|------|---------|--------|
| Vitest | Test runner | `vitest.config.ts` |
| `@testing-library/vue` | Vue component rendering | Standard setup |
| `toMatchSnapshot()` | Snapshot comparison | Built into Vitest |

### Vitest Configuration for Vue

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath } from 'url'

export default defineConfig({
    plugins: [vue()],
    test: {
        environment: 'happy-dom', // or 'jsdom'
        globals: true,
        setupFiles: ['./test/setup.ts'],
    },
    resolve: {
        alias: {
            '~': fileURLToPath(new URL('./src', import.meta.url)),
            '@': fileURLToPath(new URL('./src', import.meta.url)),
        },
    },
})
```

### Basic Snapshot Pattern

```typescript
// TransactionCard.snapshot.test.ts
import { render } from '@testing-library/vue'
import TransactionCard from '~/components/TransactionCard.vue'

const mockTransaction = {
    id: '1',
    amount: 100.50,
    description: 'Office supplies',
    status: 'completed',
    createdAt: '2024-01-15T10:00:00Z',
}

describe('TransactionCard snapshots', () => {
    it('MUST match snapshot for default state', () => {
        const { container } = render(TransactionCard, {
            props: { transaction: mockTransaction },
        })
        expect(container).toMatchSnapshot()
    })

    it('MUST match snapshot for pending state', () => {
        const { container } = render(TransactionCard, {
            props: { transaction: { ...mockTransaction, status: 'pending' } },
        })
        expect(container).toMatchSnapshot()
    })
})
```

### Snapshot with Global Plugins (Pinia, Router)

Many Vue components require Pinia stores or Vue Router. Provide them in the render options:

```typescript
// TransactionList.snapshot.test.ts
import { render } from '@testing-library/vue'
import { createTestingPinia } from '@pinia/testing'
import { createRouter, createWebHistory } from 'vue-router'
import TransactionList from '~/components/TransactionList.vue'

const router = createRouter({
    history: createWebHistory(),
    routes: [{ path: '/', component: { template: '<div />' } }],
})

describe('TransactionList snapshots', () => {
    it('MUST match snapshot for default state', () => {
        const { container } = render(TransactionList, {
            props: { transactions: [mockTransaction] },
            global: {
                plugins: [
                    createTestingPinia({ initialState: {} }),
                    router,
                ],
            },
        })
        expect(container).toMatchSnapshot()
    })
})
```

### Naming Convention

| Pattern | Example |
|---------|---------|
| `{Component}.snapshot.test.ts` | `TransactionCard.snapshot.test.ts` |
| `{Page}.snapshot.test.ts` | `DashboardPage.snapshot.test.ts` |

### Snapshot Update Protocol

When snapshots change intentionally:

1. Review the diff carefully - MUST verify change is intentional
2. Update with `vitest --update` only after review
3. Commit updated snapshots with descriptive message

### FORBIDDEN Patterns

```typescript
// FORBIDDEN: Snapshot of entire document without isolation
expect(document.body).toMatchSnapshot() // Too broad, too brittle

// FORBIDDEN: Skipping snapshot update review
// Running vitest --update without reviewing diffs

// FORBIDDEN: Snapshot without component states
describe('Button', () => {
    it('snapshot', () => {
        // WRONG: Only default state
        const { container } = render(Button)
        expect(container).toMatchSnapshot()
    })
})

// FORBIDDEN: Snapshot with non-deterministic data (timestamps, random IDs)
// Always mock Date.now() and Math.random() in test setup
```

---

## States Coverage (MANDATORY)

**HARD GATE:** Every component MUST have snapshots for all applicable states.

### Required States

| State | When Applicable | What to Verify |
|-------|----------------|----------------|
| **Default** | All components | Normal render |
| **Empty** | Lists, tables, dashboards | Empty state message |
| **Loading** | Async components (pending) | Skeleton/spinner render |
| **Error** | Components with data fetch | Error message display |
| **Success** | Forms, mutations | Success feedback |
| **Disabled** | Interactive components | Visual disabled state |

### Edge Case States

| State | When Applicable | What to Verify |
|-------|----------------|----------------|
| **Long text** | Text displays | Overflow handling (truncation, wrapping) |
| **0 items** | Lists, tables | Empty state vs zero count |
| **1 item** | Lists, tables | Singular rendering |
| **1000+ items** | Lists, tables | Virtualization, pagination |
| **Special characters** | Text inputs | Unicode, emoji, RTL text |

### Test Pattern

```typescript
// TransactionList.snapshot.test.ts
import { render } from '@testing-library/vue'
import { createTestingPinia } from '@pinia/testing'
import TransactionList from '~/components/TransactionList.vue'

const globalPlugins = {
    global: {
        plugins: [createTestingPinia()],
    },
}

describe('TransactionList snapshots', () => {
    // Required states
    it('MUST match snapshot for default state', () => {
        const { container } = render(TransactionList, {
            props: { transactions: mockTransactions },
            ...globalPlugins,
        })
        expect(container).toMatchSnapshot()
    })

    it('MUST match snapshot for empty state', () => {
        const { container } = render(TransactionList, {
            props: { transactions: [] },
            ...globalPlugins,
        })
        expect(container).toMatchSnapshot()
    })

    it('MUST match snapshot for loading state', () => {
        const { container } = render(TransactionList, {
            props: { transactions: [], loading: true },
            ...globalPlugins,
        })
        expect(container).toMatchSnapshot()
    })

    it('MUST match snapshot for error state', () => {
        const { container } = render(TransactionList, {
            props: { transactions: [], error: 'Failed to load' },
            ...globalPlugins,
        })
        expect(container).toMatchSnapshot()
    })

    // Edge cases
    it('MUST match snapshot with long transaction description', () => {
        const longTransaction = {
            ...mockTransactions[0],
            description: 'A'.repeat(500),
        }
        const { container } = render(TransactionList, {
            props: { transactions: [longTransaction] },
            ...globalPlugins,
        })
        expect(container).toMatchSnapshot()
    })

    it('MUST match snapshot with single item', () => {
        const { container } = render(TransactionList, {
            props: { transactions: [mockTransactions[0]] },
            ...globalPlugins,
        })
        expect(container).toMatchSnapshot()
    })
})
```

### Async Component State Testing

Vue components using `useAsyncData` or `useFetch` have a `pending` state. Test both:

```typescript
// UserProfile.snapshot.test.ts
import { render } from '@testing-library/vue'
import { createTestingPinia } from '@pinia/testing'
import UserProfile from '~/components/UserProfile.vue'

describe('UserProfile snapshots', () => {
    it('MUST match snapshot while loading (pending: true)', () => {
        const { container } = render(UserProfile, {
            props: { userId: '1', pending: true, user: null },
            global: { plugins: [createTestingPinia()] },
        })
        expect(container).toMatchSnapshot()
    })

    it('MUST match snapshot when loaded', () => {
        const { container } = render(UserProfile, {
            props: { userId: '1', pending: false, user: mockUser },
            global: { plugins: [createTestingPinia()] },
        })
        expect(container).toMatchSnapshot()
    })
})
```

### State Coverage Checklist

Before marking visual tests complete:

- [ ] Default state snapshot exists
- [ ] Empty state snapshot exists (if applicable)
- [ ] Loading state snapshot exists (if applicable)
- [ ] Error state snapshot exists (if applicable)
- [ ] Disabled state snapshot exists (if applicable)
- [ ] Long text overflow snapshot exists (if applicable)
- [ ] All snapshots pass without updates needed

---

## Responsive Snapshots (MANDATORY)

**HARD GATE:** Components that render differently across viewports MUST have responsive snapshots.

### Required Viewports

| Viewport | Width | Use For |
|----------|-------|---------|
| **Mobile** | 375px | Phone layout |
| **Tablet** | 768px | Tablet layout |
| **Desktop** | 1280px | Desktop layout |

### Test Pattern with Viewport Simulation

```typescript
// Dashboard.snapshot.test.ts
import { render } from '@testing-library/vue'
import { createTestingPinia } from '@pinia/testing'
import Dashboard from '~/pages/dashboard.vue'

const VIEWPORTS = {
    mobile: 375,
    tablet: 768,
    desktop: 1280,
} as const

describe('Dashboard responsive snapshots', () => {
    Object.entries(VIEWPORTS).forEach(([name, width]) => {
        it(`MUST match snapshot at ${name} (${width}px)`, () => {
            // Set viewport width — affects CSS media query evaluation in jsdom
            Object.defineProperty(window, 'innerWidth', {
                writable: true,
                configurable: true,
                value: width,
            })
            window.dispatchEvent(new Event('resize'))

            const { container } = render(Dashboard, {
                global: { plugins: [createTestingPinia()] },
            })
            expect(container).toMatchSnapshot()
        })
    })
})
```

### E2E Responsive Snapshots (Playwright)

For pixel-perfect visual regression, use Playwright screenshot comparison:

```typescript
// tests/visual/dashboard.spec.ts
import { test, expect } from '@playwright/test'

const VIEWPORTS = [
    { name: 'mobile', width: 375, height: 812 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1280, height: 720 },
]

for (const viewport of VIEWPORTS) {
    test(`Dashboard MUST render correctly at ${viewport.name}`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height })
        await page.goto('/dashboard')
        // Wait for Nuxt hydration
        await page.waitForLoadState('networkidle')
        await expect(page).toHaveScreenshot(`dashboard-${viewport.name}.png`)
    })
}
```

### When Responsive Snapshots Are Required

| Applies To | Example |
|------------|---------|
| Page layouts | Dashboard, Settings, Profile |
| Navigation | Sidebar → hamburger menu (Nuxt layouts) |
| Tables | Full table → card view |
| Grids | Multi-column → single column |

### When NOT Required

| Does Not Apply To | Why |
|-------------------|-----|
| Icons | Same at all sizes |
| Simple buttons | No layout change |
| Inline text | Flows naturally |

---

## Component Duplication Check (MANDATORY)

**HARD GATE:** MUST NOT recreate components that exist in `@luanrodrigues/sindarian-vue`.

### Detection Pattern

Before creating any component in `components/ui/`:

```bash
# Check if component exists in sindarian-vue
grep -r "export.*{ComponentName}" node_modules/@luanrodrigues/sindarian-vue/

# If found → Import from sindarian-vue
# If NOT found → Create as shadcn-vue/radix fallback in components/ui/
```

### Test Pattern

```typescript
// ComponentDuplication.test.ts
describe('Component duplication check', () => {
    it('MUST NOT duplicate sindarian-vue components', () => {
        // List of components available in sindarian-vue
        const sindarianComponents = [
            'Button', 'Input', 'Select', 'FormField', 'FormItem',
            'FormLabel', 'FormControl', 'FormMessage', 'FormTooltip',
            'Dialog', 'Sheet', 'Popover', 'Tooltip', 'Toast',
            'Table', 'Card', 'Badge', 'Avatar', 'Tabs',
            'Accordion', 'Separator', 'ScrollArea', 'Skeleton',
        ]

        // Check that project components/ui/ doesn't duplicate sindarian-vue
        // This is a documentation/review check, not a runtime test
    })
})
```

### Review Checklist

| Check | How to Verify |
|-------|---------------|
| No duplicated components | `ls components/ui/` vs sindarian-vue exports |
| Fallback components documented | Each shadcn-vue component has comment: "Fallback: not in sindarian-vue" |
| Import paths correct | sindarian-vue → `@luanrodrigues/sindarian-vue`, fallback → `@/components/ui/` |

### Fallback Component Annotation

```html
<!-- components/ui/DateRangePicker.vue -->
<!--
    Fallback: not in @luanrodrigues/sindarian-vue
    Source: shadcn-vue (https://www.shadcn-vue.com/docs/components/date-range-picker)
    Review: Check sindarian-vue before updating this component
-->
<script setup lang="ts">
// ...
</script>
```

---

## Output Format (Gate 4 - Visual Testing)

```markdown
## Visual Testing Summary

| Metric | Value |
|--------|-------|
| Components with snapshots | X |
| Total snapshots | Y |
| States covered | Default, Empty, Loading, Error, Disabled |
| Viewports tested | 375px, 768px, 1280px |
| Snapshot failures | 0 |

### Snapshot Coverage by Component

| Component | States | Viewports | Edge Cases | Status |
|-----------|--------|-----------|------------|--------|
| TransactionList | 4/4 | 3/3 | Long text, 0 items | PASS |
| UserCard | 3/3 | N/A | Special chars | PASS |
| Dashboard | 4/4 | 3/3 | Empty state | PASS |

### Component Duplication Check

| Component in components/ui/ | In sindarian-vue? | Status |
|-----------------------------|------------------|--------|
| DateRangePicker | No | PASS (valid fallback) |
| Button | Yes | FAIL (duplicate!) |

### Standards Compliance

| Standard | Status | Evidence |
|----------|--------|----------|
| All snapshots pass | PASS | 0 failures |
| States coverage | PASS | All applicable states |
| Responsive coverage | PASS | 3 viewports |
| No sindarian-vue duplication | PASS | 0 duplicates |
```

---

## Anti-Rationalization Table (Visual Testing)

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Snapshot tests are brittle" | Brittle snapshots catch unintended changes. | **Write snapshots** |
| "We'll test visually in the browser" | Manual testing doesn't catch regressions. | **Add snapshot tests** |
| "Only default state matters" | Error and loading states are user-facing too. | **Test all states** |
| "Mobile layout is the same" | Responsive issues are common and subtle. Nuxt layouts differ per breakpoint. | **Test all viewports** |
| "This shadcn-vue component is better" | sindarian-vue is PRIMARY. Don't duplicate. | **Check sindarian-vue first** |
| "Snapshot diffs are too noisy" | Noisy diffs indicate untested refactors. | **Review and update snapshots** |

---
