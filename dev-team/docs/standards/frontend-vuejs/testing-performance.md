# Frontend Standards (Vue.js) - Performance Testing

> **Module:** testing-performance.md | **Sections:** 5 | **Parent:** [frontend-vuejs.md](../frontend-vuejs.md)

This module covers frontend performance testing patterns for Vue 3 / Nuxt 3 applications. Ensures Core Web Vitals compliance, Lighthouse scores, bundle size control, and Nuxt SSR optimization.

> **Gate Reference:** This module is loaded by `bee:qa-analyst-frontend` at Gate 6 (Performance Testing).

---

## Table of Contents

| # | [Section Name](#anchor-link) | Description |
|---|------------------------------|-------------|
| 1 | [Core Web Vitals](#core-web-vitals-mandatory) | LCP, CLS, INP thresholds |
| 2 | [Lighthouse Score](#lighthouse-score-mandatory) | Performance score requirements |
| 3 | [Bundle Analysis](#bundle-analysis-mandatory) | Bundle size monitoring |
| 4 | [Nuxt Rendering Audit](#nuxt-rendering-audit-mandatory) | SSR vs CSR, useLazyFetch, useAsyncData optimization |
| 5 | [Anti-Pattern Detection](#anti-pattern-detection-mandatory) | Performance anti-patterns from frontend-vuejs.md |

**Meta-sections:** [Output Format (Gate 6 - Performance Testing)](#output-format-gate-6---performance-testing), [Anti-Rationalization Table](#anti-rationalization-table-performance-testing)

---

## Core Web Vitals (MANDATORY)

**HARD GATE:** All pages MUST meet Core Web Vitals thresholds. Failure to meet any threshold = FAIL.

### Required Thresholds

| Metric | Threshold | Description |
|--------|-----------|-------------|
| **LCP** (Largest Contentful Paint) | < 2.5s | Time to render largest visible element |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Visual stability of the page |
| **INP** (Interaction to Next Paint) | < 200ms | Responsiveness to user interaction |

### Measurement with web-vitals

```typescript
import { onLCP, onCLS, onINP, type Metric } from 'web-vitals'

// Integration in Nuxt plugin: plugins/web-vitals.client.ts
export default defineNuxtPlugin(() => {
    function measureWebVitals(): Promise<Record<string, number>> {
        return new Promise((resolve) => {
            const metrics: Record<string, number> = {}

            onLCP((metric: Metric) => { metrics.LCP = metric.value })
            onCLS((metric: Metric) => { metrics.CLS = metric.value })
            onINP((metric: Metric) => { metrics.INP = metric.value })

            // Resolve after page interaction
            setTimeout(() => resolve(metrics), 5000)
        })
    }

    return { provide: { measureWebVitals } }
})
```

### E2E Measurement with Playwright

```typescript
import { test, expect } from '@playwright/test'

test('Dashboard MUST meet Core Web Vitals', async ({ page }) => {
    await page.goto('/dashboard')

    // Wait for Nuxt hydration and full load
    await page.waitForLoadState('networkidle')

    // Measure LCP
    const lcp = await page.evaluate(() => {
        return new Promise<number>((resolve) => {
            new PerformanceObserver((list) => {
                const entries = list.getEntries()
                resolve(entries[entries.length - 1].startTime)
            }).observe({ type: 'largest-contentful-paint', buffered: true })
        })
    })
    expect(lcp).toBeLessThan(2500) // < 2.5s

    // Measure CLS
    const cls = await page.evaluate(() => {
        return new Promise<number>((resolve) => {
            let clsValue = 0
            new PerformanceObserver((list) => {
                for (const entry of list.getEntries()) {
                    if (!(entry as any).hadRecentInput) {
                        clsValue += (entry as any).value
                    }
                }
                resolve(clsValue)
            }).observe({ type: 'layout-shift', buffered: true })
            setTimeout(() => resolve(clsValue), 3000)
        })
    })
    expect(cls).toBeLessThan(0.1)
})
```

### Nuxt-Specific: SSR Impact on LCP

Nuxt 3 SSR significantly improves LCP by delivering pre-rendered HTML. Verify SSR is active on critical pages:

```typescript
test('MUST serve SSR HTML (not empty shell)', async ({ page }) => {
    const response = await page.goto('/dashboard')
    const html = await response!.text()

    // SSR page should contain actual content, not just Vue app mount point
    expect(html).toContain('data-v-app')
    expect(html).not.toMatch(/<div id="__nuxt"><\/div>/) // Empty shell = CSR failure
})
```

### Pages to Test

| Page Type | Why | Example |
|-----------|-----|---------|
| Landing/Home | First user impression | `/` |
| Dashboard | Heaviest data page | `/dashboard` |
| List pages | Data-heavy | `/transactions` |
| Form pages | Interactive | `/transactions/new` |
| Detail pages | Dynamic content | `/transactions/:id` |

---

## Lighthouse Score (MANDATORY)

**HARD GATE:** Lighthouse Performance score MUST be > 90 for all pages.

### Required Scores

| Category | Minimum Score |
|----------|---------------|
| **Performance** | > 90 |
| **Accessibility** | > 90 (also covered by Gate 2) |
| **Best Practices** | > 90 |
| **SEO** | > 80 (if applicable) |

### Running Lighthouse in CI

```bash
# Install
npm i -D @lhci/cli

# Run against local Nuxt dev/preview server
npx lhci autorun --config=lighthouserc.json

# Quick single-page check
npx lighthouse http://localhost:3000/dashboard --output=json --output-path=./lighthouse-report.json
```

### Lighthouse Configuration

```json
{
    "ci": {
        "collect": {
            "url": [
                "http://localhost:3000/",
                "http://localhost:3000/dashboard",
                "http://localhost:3000/transactions"
            ],
            "numberOfRuns": 3
        },
        "assert": {
            "assertions": {
                "categories:performance": ["error", { "minScore": 0.9 }],
                "categories:accessibility": ["error", { "minScore": 0.9 }],
                "categories:best-practices": ["error", { "minScore": 0.9 }]
            }
        }
    }
}
```

### Common Lighthouse Failures and Fixes

| Issue | Impact | Fix |
|-------|--------|-----|
| Unoptimized images | LCP, Performance | Use `<NuxtImg>` with `@nuxt/image` |
| No font preloading | LCP | Configure `nuxt/fonts` module or add `<link rel="preload">` |
| Unused CSS/JS | Performance | Tree-shake, use `defineAsyncComponent` |
| No text compression | Transfer size | Enable in Nuxt server config (gzip/brotli) |
| Third-party scripts | LCP, TBT | Use `useScript` composable with `defer` mode |
| Layout shifts | CLS | Set explicit `width`/`height` on `<NuxtImg>` |

---

## Bundle Analysis (MANDATORY)

**HARD GATE:** Bundle size increase MUST NOT exceed 10% vs baseline without justification.

### Measurement Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `rollup-plugin-visualizer` | Nuxt/Vite bundle visualization | `ANALYZE=true nuxt build` |
| `nuxt analyze` | Built-in Nuxt bundle analyzer | `nuxt analyze` |
| `bundlephobia` | Package size check | Check before adding dependency |

### Nuxt Bundle Analyzer Setup

```typescript
// nuxt.config.ts
import { visualizer } from 'rollup-plugin-visualizer'

export default defineNuxtConfig({
    vite: {
        plugins: [
            process.env.ANALYZE === 'true'
                ? visualizer({ open: true, filename: '.nuxt/analyze/bundle.html' })
                : undefined,
        ].filter(Boolean),
    },
})
```

```bash
# Run analyzer
ANALYZE=true nuxt build

# Or use built-in Nuxt analyzer
npx nuxt analyze
```

### Size Budget

| Budget | Threshold | What to Check |
|--------|-----------|---------------|
| **Total JS** | < 200KB (gzipped) | First load JS (Nuxt includes runtime) |
| **Per-page JS** | < 50KB (gzipped) | Page-specific chunk |
| **Single dependency** | < 50KB (gzipped) | Any single package |
| **Increase vs baseline** | < 10% | Compared to previous build |

### Verification Pattern

```bash
# Build and capture sizes
nuxt build 2>&1 | grep -E "\.js|\.css" | grep -v ".map"

# Compare with baseline
# Store baseline in: .nuxt-size-baseline.json
# Compare after build
```

### Tree-Shaking Verification for sindarian-vue

```typescript
// CORRECT: Named imports (tree-shakeable)
import { Button, Input } from '@luanrodrigues/sindarian-vue'

// FORBIDDEN: Wildcard import (imports everything)
import * as SindarianVue from '@luanrodrigues/sindarian-vue'

// FORBIDDEN: Default import of entire library
import SindarianVue from '@luanrodrigues/sindarian-vue'
```

---

## Nuxt Rendering Audit (MANDATORY)

**HARD GATE:** Pages MUST use the appropriate Nuxt rendering strategy. Unnecessary client-only rendering defeats SSR benefits.

### Nuxt Rendering Modes

| Rendering Mode | When to Use | How |
|----------------|-------------|-----|
| **SSR (default)** | All pages needing SEO or fast LCP | Default — no config needed |
| **SSG (prerendering)** | Static pages (marketing, docs) | `routeRules: { '/about': { prerender: true } }` |
| **CSR (SPA mode)** | Protected dashboards behind auth | `routeRules: { '/dashboard/**': { ssr: false } }` |
| **ISR** | High-traffic pages with stale-while-revalidate | `routeRules: { '/blog/**': { isr: 3600 } }` |

### useLazyFetch vs useFetch

Prefer `useLazyFetch` for non-critical data to avoid blocking navigation:

```typescript
// CORRECT: useLazyFetch for below-the-fold / non-critical data
// Does NOT block the page render — shows loading state instead
const { data: recommendations, pending } = useLazyFetch('/api/recommendations')

// CORRECT: useFetch for critical above-the-fold data
// Blocks render until data is ready (better LCP for critical content)
const { data: user } = await useFetch('/api/me')

// FORBIDDEN: useEffect-style watch for data fetching
// (anti-pattern from React, no direct equivalent is needed in Nuxt)
watch(userId, async (id) => {
    // WRONG: manual fetch in watch
    const data = await fetch(`/api/users/${id}`)
})
// CORRECT: Pass reactive param to useFetch/useAsyncData
const { data } = useFetch(() => `/api/users/${userId.value}`)
```

### useAsyncData Key Strategy

```typescript
// CORRECT: Unique, deterministic keys prevent cache collisions
const { data } = await useAsyncData(
    `user-${route.params.id}`,
    () => $fetch(`/api/users/${route.params.id}`)
)

// FORBIDDEN: Generic keys that collide across pages
const { data } = await useAsyncData('user', () => $fetch('/api/users/123'))
// This key "user" will be reused across all pages — stale data risk
```

### Audit Pattern

```bash
# Find any bare fetch() calls that bypass Nuxt data layer
grep -rn "await fetch\|axios\." --include="*.vue" --include="*.ts" pages/ composables/

# Check for watch-based data fetching (should use useFetch reactive URL instead)
grep -rn "watch.*fetch\|watch.*axios" --include="*.vue" --include="*.ts" composables/ pages/

# Percentage of pages using SSR (should be default for most)
grep -rn "ssr: false" nuxt.config.ts
```

### Common Violations

| Pattern | Why It's Wrong | Fix |
|---------|----------------|-----|
| `onMounted(() => fetch(...))` | Bypasses SSR — content not in initial HTML | Use `useFetch` or `useAsyncData` |
| `ssr: false` on public pages | Hurts LCP and SEO | Remove and use SSR (default) |
| `useFetch` without unique key | Cache collisions across routes | Always pass a unique cache key |
| Blocking `useAsyncData` for non-critical data | Delays navigation | Switch to `useLazyAsyncData` |

### Test Pattern

```typescript
describe('Nuxt rendering audit', () => {
    it('MUST NOT have onMounted data fetching on SSR pages', () => {
        // Detected via static analysis / grep in CI
        // onMounted fetch calls bypass SSR
    })

    it('MUST use unique useAsyncData keys per route', () => {
        // Verified via code review and grep
        // Duplicate keys cause cache collisions
    })
})
```

---

## Anti-Pattern Detection (MANDATORY)

**HARD GATE:** All performance anti-patterns from [frontend-vuejs.md Section 13](../frontend-vuejs.md#forbidden-patterns) MUST be detected and reported.

### Performance Anti-Patterns to Detect

| Pattern | Detection | Fix |
|---------|-----------|-----|
| Bare `<img>` without `<NuxtImg>` | `grep -rn '<img ' --include="*.vue"` | Replace with `<NuxtImg>` |
| Inline styles in `v-for` loops | Manual review | Use static `class` or CSS Modules |
| Missing `:key` in `v-for` | ESLint rule `vue/require-v-for-key` | Add stable `:key` |
| `onMounted` for data fetching | `grep -rn 'onMounted.*fetch'` | Use `useFetch` / `useAsyncData` |
| Unoptimized re-renders | Vue DevTools Performance tab | Add `v-memo`, `computed`, `shallowRef` |

### Automated Detection

```bash
# Bare <img> tags (should use NuxtImg)
grep -rn '<img ' --include="*.vue" pages/ components/ | grep -v '<!--'

# onMounted with fetch (should use useFetch)
grep -rn 'onMounted.*fetch\|onMounted.*axios\|onMounted.*\$fetch' --include="*.vue" pages/ components/

# Watch-based data fetching (should use reactive useFetch URL)
grep -rn 'watch.*fetch\|watchEffect.*fetch' --include="*.ts" composables/

# Wildcard sindarian-vue imports (not tree-shakeable)
grep -rn "import \* as.*sindarian" --include="*.vue" --include="*.ts" pages/ components/

# Missing NuxtImg import where <img> is used
grep -rln '<img ' --include="*.vue" pages/ components/ | while read f; do
    grep -q "NuxtImg\|nuxt/image" "$f" || echo "VIOLATION: $f uses <img> without NuxtImg"
done
```

### Quality Gate Checklist

Before marking performance tests complete:

- [ ] All pages meet LCP < 2.5s
- [ ] All pages meet CLS < 0.1
- [ ] All pages meet INP < 200ms
- [ ] Lighthouse Performance score > 90
- [ ] Bundle size within 10% of baseline
- [ ] No bare `<img>` tags (all use `<NuxtImg>`)
- [ ] No `onMounted` for data fetching (use `useFetch` / `useAsyncData`)
- [ ] `useLazyFetch` used for non-critical below-the-fold data
- [ ] `useAsyncData` keys are unique and deterministic
- [ ] sindarian-vue imports are tree-shakeable (named imports only)
- [ ] SSR disabled only for pages that genuinely require CSR

---

## Output Format (Gate 6 - Performance Testing)

```markdown
## Performance Testing Summary

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| LCP | X.Xs | < 2.5s | PASS/FAIL |
| CLS | X.XX | < 0.1 | PASS/FAIL |
| INP | Xms | < 200ms | PASS/FAIL |
| Lighthouse Performance | XX | > 90 | PASS/FAIL |
| Bundle size change | +X% | < 10% | PASS/FAIL |

### Core Web Vitals by Page

| Page | LCP | CLS | INP | SSR | Status |
|------|-----|-----|-----|-----|--------|
| / | 1.2s | 0.02 | 85ms | Yes | PASS |
| /dashboard | 2.1s | 0.05 | 120ms | Yes | PASS |
| /transactions | 1.8s | 0.01 | 95ms | Yes | PASS |

### Bundle Analysis

| Metric | Current | Baseline | Change | Status |
|--------|---------|----------|--------|--------|
| Total JS (gzipped) | 180KB | 175KB | +2.8% | PASS |
| Largest page chunk | 45KB | 42KB | +7.1% | PASS |

### Nuxt Rendering Audit

| Metric | Value |
|--------|-------|
| Total pages | X |
| SSR pages | Y |
| CSR-only pages (justified) | Z |
| Pages using useLazyFetch | W |

### Anti-Pattern Detection

| Pattern | Occurrences | Status |
|---------|-------------|--------|
| Bare <img> | 0 | PASS |
| onMounted data fetching | 0 | PASS |
| Watch-based fetching | 0 | PASS |
| Wildcard sindarian imports | 0 | PASS |

### Standards Compliance

| Standard | Status | Evidence |
|----------|--------|----------|
| Core Web Vitals | PASS | All pages within thresholds |
| Lighthouse > 90 | PASS | Score: XX |
| Bundle size | PASS | +X% (< 10%) |
| Nuxt rendering | PASS | SSR active, lazy fetch for non-critical |
| Anti-patterns | PASS | 0 violations |
```

---

## Anti-Rationalization Table (Performance Testing)

| Rationalization | Why It's WRONG | Required Action |
|-----------------|----------------|-----------------|
| "Performance is fine on my machine" | Users have slower devices and connections. | **Measure with Lighthouse** |
| "We'll optimize later" | Performance debt compounds. Fix during development. | **Meet thresholds now** |
| "Bundle size doesn't matter with fast internet" | Mobile users on 3G exist. Bundle size matters. | **Stay within budget** |
| "Everything can be CSR, SSR is complex" | SSR improves LCP and SEO dramatically. Nuxt handles it automatically. | **Use SSR (the default)** |
| "One extra dependency won't hurt" | Dependencies compound. 50KB x 10 = 500KB. | **Check bundlephobia first** |
| "NuxtImg is too complex" | NuxtImg provides free optimization (WebP, lazy load, responsive sizes). | **Always use NuxtImg** |
| "useFetch blocks the page, I'll use onMounted" | useLazyFetch exists for non-blocking fetching. onMounted bypasses SSR. | **Use useLazyFetch** |

---
