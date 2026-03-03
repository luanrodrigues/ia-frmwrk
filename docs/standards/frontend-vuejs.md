# Frontend Standards (Vue.js / Nuxt 3)

> **MAINTENANCE:** This file is indexed in `dev-team/skills/shared-patterns/standards-coverage-table.md`.
> When adding/removing `## ` sections, follow FOUR-FILE UPDATE RULE in CLAUDE.md: (1) edit standards file, (2) update TOC, (3) update standards-coverage-table.md, (4) update agent file.

This file defines the specific standards for frontend development using Vue 3 and Nuxt 3.

> **Reference**: Always consult `docs/PROJECT_RULES.md` for common project standards.

---

## Table of Contents

| # | Section | Description |
|---|---------|-------------|
| 1 | [Framework](#framework) | Vue 3, Nuxt 3 (version policy) |
| 2 | [Libraries & Tools](#libraries--tools) | Core, state, forms, UI, styling, testing |
| 3 | [State Management Patterns](#state-management-patterns) | Pinia stores, `useAsyncData`, `useFetch` |
| 4 | [Form Patterns](#form-patterns) | VeeValidate + Zod |
| 5 | [Styling Standards](#styling-standards) | TailwindCSS, CSS variables |
| 6 | [Typography Standards](#typography-standards) | Font selection and pairing |
| 7 | [Animation Standards](#animation-standards) | CSS transitions, `<Transition>`, GSAP |
| 8 | [Component Patterns](#component-patterns) | Composables, `<NuxtErrorBoundary>` |
| 9 | [File Organization](#file-organization-mandatory) | File-level single responsibility |
| 10 | [Accessibility](#accessibility) | WCAG 2.1 AA compliance |
| 11 | [Performance](#performance) | Nuxt lazy loading, image optimization |
| 12 | [Directory Structure](#directory-structure) | Nuxt 3 file-based routing layout |
| 13 | [Forbidden Patterns](#forbidden-patterns) | Anti-patterns to avoid |
| 14 | [Standards Compliance Categories](#standards-compliance-categories) | Categories for bee:dev-refactor |
| 15 | [Form Field Abstraction Layer](#form-field-abstraction-layer) | **HARD GATE:** Field wrappers, dual-mode (sindarian-vue vs vanilla) |
| 16 | [Plugin Composition Pattern](#plugin-composition-pattern) | Nuxt plugins, app-level provide/inject |
| 17 | [Composable Patterns](#composable-patterns) | **HARD GATE:** usePagination, useCursorPagination, useSheet, useStepper, useDebounce |
| 18 | [Fetcher Utilities Pattern](#fetcher-utilities-pattern) | $fetch wrappers, useFetch, useAsyncData |
| 19 | [Client-Side Error Handling](#client-side-error-handling) | **HARD GATE:** NuxtErrorBoundary, error.vue, API error helpers, toast integration |
| 20 | [Data Table Pattern](#data-table-pattern) | TanStack Table (Vue adapter), server-side pagination, column definitions |

**Meta-sections (not checked by agents):**
- [Checklist](#checklist) - Self-verification before submitting code

---

## Framework

- Vue 3 with Composition API (`<script setup>`)
- Nuxt 3 (see version policy below)
- TypeScript strict mode (see `typescript.md`)

### Framework Version Policy

| Scenario | Rule |
|----------|------|
| **New project** | Use **latest stable version** (verify at nuxt.com before starting) |
| **Existing codebase** | **Maintain project's current version** (read package.json) |

**Before starting any project:**
1. For NEW projects: Check https://nuxt.com for latest stable version
2. For EXISTING projects: Read `package.json` to determine current version
3. NEVER hardcode a specific version in implementation - use project's version

---

## Libraries & Tools

### Core

| Library | Use Case |
|---------|----------|
| Vue 3 | UI framework |
| Nuxt 3 (latest stable) | Full-stack framework with SSR and file-based routing (see version policy above) |
| TypeScript 5+ | Type safety |

### State Management

| Library | Use Case |
|---------|----------|
| Pinia | Client state and server state (replaces Zustand + TanStack Query) |
| `useAsyncData` / `useFetch` | SSR-aware server data fetching (built into Nuxt) |
| `provide` / `inject` | Simple shared state within component trees |
| Pinia ORM | Complex relational state (optional) |

### Forms

| Library | Use Case |
|---------|----------|
| VeeValidate | Form state management (`useForm`, `useField`) |
| Zod | Schema validation |
| `@vee-validate/zod` | VeeValidate + Zod integration |

### UI Components

| Library | Use Case |
|---------|----------|
| Radix Vue | Headless primitives |
| shadcn-vue | Pre-styled Radix Vue components |
| Headless UI (Vue) | Tailwind-native primitives |

### Styling

| Library | Use Case |
|---------|----------|
| TailwindCSS | Utility-first CSS |
| CSS Modules | Scoped CSS (Vue `<style module>`) |
| CSS Variables | Theming |

### Testing

| Library | Use Case |
|---------|----------|
| Vitest | Unit tests |
| `@testing-library/vue` | Component tests |
| Playwright | E2E tests |
| MSW | API mocking |

---

## State Management Patterns

### Server State with Pinia + useAsyncData

In Nuxt 3, server data fetching is handled through `useAsyncData` and `useFetch` composables. Pinia manages client-side state that persists across navigations.

```typescript
// stores/users.ts
import { defineStore } from 'pinia'
import type { User, UserFilters } from '~/types/user'

export const useUsersStore = defineStore('users', () => {
    // State
    const filters = ref<UserFilters>({})
    const selectedUserId = ref<string | null>(null)

    // Actions
    function setFilters(newFilters: UserFilters) {
        filters.value = newFilters
    }

    function selectUser(id: string | null) {
        selectedUserId.value = id
    }

    return { filters, selectedUserId, setFilters, selectUser }
})

// composables/useUsers.ts
export function useUsers(filters?: Ref<UserFilters>) {
    const { data, pending, error, refresh } = useAsyncData(
        // Cache key reacts to filter changes
        () => `users-${JSON.stringify(filters?.value ?? {})}`,
        () => $fetch<{ data: User[]; total: number }>('/api/users', {
            params: filters?.value,
        }),
        {
            watch: filters ? [filters] : undefined,
        }
    )

    return { data, pending, error, refresh }
}

// composables/useUser.ts
export function useUser(id: string) {
    return useAsyncData(
        `user-${id}`,
        () => $fetch<User>(`/api/users/${id}`),
        { immediate: !!id }
    )
}
```

### Client State with Pinia

```typescript
// stores/ui.ts
import { defineStore } from 'pinia'

export const useUIStore = defineStore('ui', () => {
    // State as refs
    const theme = ref<'light' | 'dark'>('light')
    const sidebarOpen = ref(true)

    // Actions
    function setTheme(newTheme: 'light' | 'dark') {
        theme.value = newTheme
    }

    function toggleSidebar() {
        sidebarOpen.value = !sidebarOpen.value
    }

    return { theme, sidebarOpen, setTheme, toggleSidebar }
}, {
    persist: true, // Persists to localStorage via pinia-plugin-persistedstate
})

// Usage in component
// <script setup>
import { storeToRefs } from 'pinia'

const uiStore = useUIStore()
// storeToRefs preserves reactivity when destructuring
const { theme, sidebarOpen } = storeToRefs(uiStore)
const { setTheme, toggleSidebar } = uiStore
```

### Mutations with useFetch

```typescript
// composables/useCreateUser.ts
export function useCreateUser() {
    const usersStore = useUsersStore()
    const pending = ref(false)
    const error = ref<Error | null>(null)

    async function createUser(data: CreateUserInput): Promise<User> {
        pending.value = true
        error.value = null

        try {
            const user = await $fetch<User>('/api/users', {
                method: 'POST',
                body: data,
            })
            // Refresh the list
            await refreshNuxtData('users')
            return user
        } catch (e) {
            error.value = e as Error
            throw e
        } finally {
            pending.value = false
        }
    }

    return { createUser, pending, error }
}
```

---

## Form Patterns

### VeeValidate + Zod

```typescript
// <script setup lang="ts">
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

// Schema
const createUserSchema = z.object({
    name: z.string().min(1, 'Name is required').max(100),
    email: z.string().email('Invalid email'),
    role: z.enum(['admin', 'user', 'guest']),
    notifications: z.boolean().default(true),
})

type CreateUserInput = z.infer<typeof createUserSchema>

const { handleSubmit, errors, isSubmitting, defineField } = useForm<CreateUserInput>({
    validationSchema: toTypedSchema(createUserSchema),
    initialValues: {
        notifications: true,
    },
})

// Define fields — returns [modelValue, attrs] tuple
const [name, nameAttrs] = defineField('name')
const [email, emailAttrs] = defineField('email')
const [role, roleAttrs] = defineField('role')

const { createUser } = useCreateUser()
const { toast } = useToast()

const onSubmit = handleSubmit(async (values) => {
    await createUser(values)
    toast({ title: 'User created successfully' })
})
```

```html
<template>
    <form @submit="onSubmit">
        <InputField
            v-model="name"
            v-bind="nameAttrs"
            label="Name"
            :error="errors.name"
        />
        <InputField
            v-model="email"
            v-bind="emailAttrs"
            label="Email"
            type="email"
            :error="errors.email"
        />
        <SelectField
            v-model="role"
            v-bind="roleAttrs"
            label="Role"
            :options="[
                { value: 'admin', label: 'Administrator' },
                { value: 'user', label: 'User' },
                { value: 'guest', label: 'Guest' },
            ]"
        />
        <Button type="submit" :loading="isSubmitting">Create User</Button>
    </form>
</template>
```

---

## Styling Standards

### TailwindCSS Best Practices

```html
<!-- Use semantic class groupings -->
<div class="
    flex items-center justify-between
    p-4 gap-4
    bg-white dark:bg-gray-900
    border border-gray-200 rounded-lg
    hover:shadow-md transition-shadow
">

<!-- Extract repeated patterns to components -->
```

```typescript
// components/ui/Card.vue
// <script setup lang="ts">
interface Props {
    class?: string
}
const props = defineProps<Props>()
```

```html
<!-- components/ui/Card.vue template -->
<template>
    <div :class="cn(
        'bg-white dark:bg-gray-900',
        'border border-gray-200 rounded-lg',
        'p-4 shadow-sm',
        props.class
    )">
        <slot />
    </div>
</template>
```

### CSS Variables for Theming

```css
:root {
    --color-primary: 220 90% 56%;
    --color-secondary: 262 83% 58%;
    --color-background: 0 0% 100%;
    --color-foreground: 222 47% 11%;
    --color-muted: 210 40% 96%;
    --color-border: 214 32% 91%;
    --radius: 0.5rem;
}

.dark {
    --color-background: 222 47% 11%;
    --color-foreground: 210 40% 98%;
    --color-muted: 217 33% 17%;
    --color-border: 217 33% 17%;
}
```

### Mobile-First Responsive Design

```html
<!-- Always start mobile, scale up -->
<div class="
    grid grid-cols-1
    sm:grid-cols-2
    lg:grid-cols-3
    xl:grid-cols-4
    gap-4
">

<!-- Responsive text -->
<h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold">

<!-- Hide/show based on breakpoint -->
<div class="hidden md:block">Desktop only</div>
<div class="md:hidden">Mobile only</div>
```

---

## Typography Standards

### Font Selection (AVOID GENERIC)

```css
/* FORBIDDEN - Generic AI fonts */
font-family: 'Inter', sans-serif;      /* Too common */
font-family: 'Roboto', sans-serif;     /* Too common */
font-family: 'Arial', sans-serif;      /* System font */
font-family: system-ui, sans-serif;    /* System stack */

/* RECOMMENDED - Distinctive fonts */
font-family: 'Geist', sans-serif;      /* Modern, tech */
font-family: 'Satoshi', sans-serif;    /* Contemporary */
font-family: 'Cabinet Grotesk', sans-serif; /* Bold, editorial */
font-family: 'Clash Display', sans-serif;   /* Display headings */
font-family: 'General Sans', sans-serif;    /* Clean, versatile */
```

### Font Pairing

In Nuxt 3, load fonts via `@nuxtjs/google-fonts` or `nuxt/fonts` module:

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
    modules: ['@nuxtjs/google-fonts'],
    googleFonts: {
        families: {
            'Clash Display': [400, 700],
            Satoshi: [400, 500, 700],
        },
    },
})
```

```css
/* Display + Body pairing */
--font-display: 'Clash Display', sans-serif;
--font-body: 'Satoshi', sans-serif;

/* Heading uses display */
h1, h2, h3 {
    font-family: var(--font-display);
}

/* Body uses readable font */
body, p, span {
    font-family: var(--font-body);
}
```

---

## Animation Standards

### CSS Transitions (Simple Effects)

```css
/* Standard transition */
.button {
    transition: all 150ms ease;
}

/* Specific properties for performance */
.card {
    transition: transform 200ms ease, box-shadow 200ms ease;
}

/* Hover states */
.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}
```

### Vue Transitions (Built-in)

```html
<!-- Page transitions via Nuxt -->
<template>
    <NuxtPage :transition="{ name: 'page', mode: 'out-in' }" />
</template>

<style>
.page-enter-active,
.page-leave-active {
    transition: opacity 0.3s ease, transform 0.3s ease;
}
.page-enter-from {
    opacity: 0;
    transform: translateY(20px);
}
.page-leave-to {
    opacity: 0;
    transform: translateY(-20px);
}
</style>
```

```html
<!-- Staggered list animation -->
<template>
    <TransitionGroup name="list" tag="ul">
        <li
            v-for="(item, i) in items"
            :key="item.id"
            :style="{ transitionDelay: `${i * 100}ms` }"
        >
            {{ item.name }}
        </li>
    </TransitionGroup>
</template>

<style>
.list-enter-active { transition: all 0.3s ease; }
.list-enter-from { opacity: 0; transform: translateX(-20px); }
</style>
```

### Animation Guidelines

1. **Focus on high-impact moments** - Page loads, modal opens, state changes
2. **One orchestrated animation > scattered micro-interactions**
3. **Keep durations short** - 150-300ms for UI, 300-500ms for page transitions
4. **Use easing** - `ease`, `ease-out` for exits, `ease-in-out` for continuous

---

## Component Patterns

### Composables (Vue equivalent of compound components)

Vue 3 uses composables and `provide`/`inject` for complex component trees:

```typescript
// composables/useTabs.ts
interface TabsContext {
    activeTab: Ref<string>
    setTab: (value: string) => void
}

const TabsKey = Symbol('Tabs') as InjectionKey<TabsContext>

export function provideTabs(defaultValue: string) {
    const activeTab = ref(defaultValue)
    const context: TabsContext = {
        activeTab,
        setTab: (value: string) => { activeTab.value = value },
    }
    provide(TabsKey, context)
    return context
}

export function useTabs() {
    const context = inject(TabsKey)
    if (!context) throw new Error('useTabs must be used inside <Tabs>')
    return context
}
```

```html
<!-- components/Tabs.vue -->
<script setup lang="ts">
const props = defineProps<{ defaultValue: string }>()
provideTabs(props.defaultValue)
</script>
<template><div class="tabs"><slot /></div></template>

<!-- components/TabsTrigger.vue -->
<script setup lang="ts">
const props = defineProps<{ value: string }>()
const { activeTab, setTab } = useTabs()
</script>
<template>
    <button
        :class="cn('tab', activeTab === props.value && 'active')"
        @click="setTab(props.value)"
    >
        <slot />
    </button>
</template>
```

### Error Boundaries with NuxtErrorBoundary

```html
<!-- Wrapping a section that may throw -->
<template>
    <NuxtErrorBoundary @error="onError">
        <UserProfile :user-id="userId" />

        <template #error="{ error, clearError }">
            <div class="flex flex-col items-center p-8 text-center">
                <AlertTriangleIcon class="h-12 w-12 text-destructive mb-4" />
                <h2 class="text-lg font-semibold mb-2">Something went wrong</h2>
                <p class="text-muted-foreground mb-4">{{ error.message }}</p>
                <Button variant="outline" @click="clearError">Try again</Button>
            </div>
        </template>
    </NuxtErrorBoundary>
</template>

<script setup lang="ts">
function onError(error: Error) {
    console.error('Component error:', error)
    // Report to error tracking service (e.g., Sentry)
}
</script>
```

### Global error.vue (Nuxt route-level errors)

```html
<!-- error.vue -->
<script setup lang="ts">
const props = defineProps<{ error: { statusCode: number; message: string } }>()

const handleError = () => clearError({ redirect: '/' })
</script>

<template>
    <div class="flex flex-col items-center justify-center min-h-screen">
        <h1 class="text-4xl font-bold">{{ props.error.statusCode }}</h1>
        <p class="text-muted-foreground mt-2">{{ props.error.message }}</p>
        <Button class="mt-6" @click="handleError">Go home</Button>
    </div>
</template>
```

---

## File Organization (MANDATORY)

**Single Responsibility per File:** Each component file MUST represent ONE UI concern.

### Rules

| Rule | Description |
|------|-------------|
| **One component per file** | A file exports ONE primary component (`.vue` file) |
| **Max 200 lines per component file** | If longer, extract sub-components or composables |
| **Co-locate related files** | Component, composable, types, test in same feature folder |
| **Composables in separate files** | Custom composables that exceed 20 lines get their own file |
| **Separate data from presentation** | Container (data-fetching) and presentational components split |

### Examples

```html
<!-- WRONG: UserDashboard.vue (400 lines, mixed concerns) -->
<script setup lang="ts">
// 30 lines of state
const users = ref<User[]>([])
const filters = ref<UserFilters>({})
const sortConfig = ref<SortConfig>({})
const isExportModalOpen = ref(false)

// 40 lines of data fetching
const { data } = await useAsyncData('users', () => fetchUsers(filters.value))

// 50 lines of handlers
function handleSort(column: string) { /* ... */ }
function handleFilter(key: string, value: unknown) { /* ... */ }
function handleExport(format: string) { /* ... */ }

// 280 lines of mixed template
</script>
```

```html
<!-- CORRECT: Split by concern -->

<!-- UserDashboard.vue (~50 lines) — Composition root -->
<script setup lang="ts">
const { users, pagination, pending } = useUsers()
const { filters, updateFilter, resetFilters } = useUserFilters()
</script>
<template>
    <div>
        <UserFilters :filters="filters" @change="updateFilter" @reset="resetFilters" />
        <UserTable :users="users" :loading="pending" />
        <Pagination v-bind="pagination" />
    </div>
</template>
```

```typescript
// composables/useUsers.ts (~60 lines) — Data fetching composable
export function useUsers(filters?: Ref<UserFilters>) {
    const { data, pending, error } = useAsyncData(
        () => `users-${JSON.stringify(filters?.value ?? {})}`,
        () => $fetch<{ data: User[]; total: number }>('/api/users', {
            params: filters?.value,
        }),
        { watch: filters ? [filters] : undefined }
    )
    return { users: data, pending, error }
}

// composables/useUserFilters.ts (~40 lines) — Filter state composable
export function useUserFilters() {
    const filters = ref<UserFilters>({})

    function updateFilter(key: string, value: unknown) {
        filters.value = { ...filters.value, [key]: value }
    }

    function resetFilters() {
        filters.value = {}
    }

    return { filters, updateFilter, resetFilters }
}
```

### Signs a File Needs Splitting

| Sign | Action |
|------|--------|
| Component file exceeds 200 lines | Extract sub-components or composables |
| More than 3 `ref`/`watch` at top-level | Extract to composable |
| Template exceeds 100 lines | Extract child components |
| File mixes data fetching and presentation | Split container and presentational components |
| Multiple `useAsyncData` calls in one file | Extract to dedicated composable files |
| Component accepts more than 5 props | Consider composition or slot pattern |

---

## Accessibility

### Required Practices

```html
<!-- Always use semantic HTML -->
<button @click="handleClick">Click me</button>  <!-- not <div @click=""> -->

<!-- Images need alt text -->
<NuxtImg :src="user.avatar" :alt="`${user.name}'s avatar`" />

<!-- Form inputs need labels -->
<label for="email">Email</label>
<input id="email" type="email" />

<!-- Use ARIA when needed -->
<button
    :aria-label="isOpen ? 'Close dialog' : 'Open dialog'"
    :aria-expanded="isOpen"
>
    <XIcon />
</button>

<!-- Keyboard navigation -->
<div
    role="button"
    :tabindex="0"
    @keydown.enter="onClick"
    @click="onClick"
>
```

### Focus Management

```html
<script setup lang="ts">
import { onMounted, useTemplateRef } from 'vue'

// Auto-focus on mount
const inputRef = useTemplateRef('searchInput')
onMounted(() => {
    inputRef.value?.focus()
})
</script>

<!-- Focus trap for modals — Radix Vue Dialog handles this automatically -->
<template>
    <DialogRoot v-model:open="isOpen">
        <DialogContent>
            <!-- Focus is automatically trapped inside -->
            <slot />
        </DialogContent>
    </DialogRoot>
</template>
```

---

## Performance

### Lazy Loading with defineAsyncComponent

```typescript
// Lazy load heavy components
const Dashboard = defineAsyncComponent(() => import('~/components/Dashboard.vue'))
const Analytics = defineAsyncComponent(() => import('~/components/Analytics.vue'))
```

```html
<!-- Use with Suspense -->
<template>
    <Suspense>
        <Dashboard />
        <template #fallback>
            <LoadingSpinner />
        </template>
    </Suspense>
</template>
```

### Image Optimization with NuxtImg

```html
<!-- Always use NuxtImg (requires @nuxt/image module) -->
<NuxtImg
    :src="user.avatar"
    :alt="user.name"
    width="48"
    height="48"
    :loading="isAboveFold ? 'eager' : 'lazy'"
    format="webp"
/>
```

### Memoization with computed

```typescript
// computed() is automatically cached and only re-evaluates when dependencies change
const sortedItems = computed(() =>
    [...items.value].sort((a, b) => b.score - a.score)
)

// For expensive renders, use v-memo directive
// <li v-for="item in items" :key="item.id" v-memo="[item.id, item.selected]">

// Lazy async data
const { data } = useLazyAsyncData('heavy-data', () => $fetch('/api/heavy'))
```

### useLazyFetch for Non-Critical Data

```typescript
// Defers loading until after hydration — does not block navigation
const { data, pending } = useLazyFetch('/api/recommendations')
```

---

## Directory Structure

```text
/
  /pages                 # Nuxt file-based routing
    index.vue            # /
    /dashboard
      index.vue          # /dashboard
    /users
      index.vue          # /users
      [id].vue           # /users/:id
  /layouts               # Nuxt layouts
    default.vue
    auth.vue
  /components
    /ui                  # Primitive UI components (shadcn-vue / Radix Vue)
      Button.vue
      Input.vue
      Card.vue
    /features            # Feature-specific components
      /user
        UserProfile.vue
        UserList.vue
      /order
        OrderForm.vue
  /composables           # Auto-imported composables
    useUsers.ts
    useDebounce.ts
  /stores                # Pinia stores (auto-imported)
    users.ts
    ui.ts
  /server                # Nuxt server routes
    /api
      /users
        index.get.ts     # GET /api/users
        index.post.ts    # POST /api/users
        [id].get.ts      # GET /api/users/:id
  /plugins               # Nuxt plugins
    toast.client.ts
  /middleware            # Route middleware
    auth.ts
  /utils                 # Utility functions
    cn.ts
    api-error.ts
  /types                 # TypeScript types
    user.ts
    api.ts
/public                  # Static assets
/assets                  # Processed assets (Vite)
```

---

## Forbidden Patterns

**The following patterns are never allowed. Agents MUST refuse to implement these:**

### TypeScript Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `any` type | Defeats TypeScript purpose | Use proper types, `unknown`, or generics |
| Type assertions without validation | Runtime errors | Use type guards or Zod parsing |
| `// @ts-ignore` or `// @ts-expect-error` | Hides real errors | Fix the type issue properly |
| Non-strict mode | Allows unsafe code | Enable `"strict": true` in tsconfig |

### Accessibility Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `<div @click="...">` for buttons | Not keyboard accessible | Use `<button>` element |
| `<span @click="...">` for links | Not keyboard accessible | Use `<NuxtLink>` or `<a href="">` |
| Missing `alt` on images | Screen readers can't describe | Always provide descriptive alt on `<NuxtImg>` |
| Missing form labels | Inputs not associated | Use `<label :for="id">` |
| `tabindex > 0` | Breaks natural tab order | Use `tabindex="0"` or semantic HTML |
| `outline: none` without alternative | Removes focus visibility | Provide custom focus styles |

### State Management Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `watch` for data fetching side effects | Race conditions, no caching | Use `useAsyncData` or `useFetch` |
| Props drilling > 3 levels | Unmaintainable | Use `provide`/`inject` or Pinia |
| Storing server state in Pinia manually | Stale data, duplicates Nuxt cache | Use `useAsyncData` / `useFetch` for server state |
| `ref` for form state without VeeValidate | No validation, verbose | Use VeeValidate `useForm` |

### Security Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `v-html` without sanitization | XSS vulnerability | Use DOMPurify or avoid entirely |
| Storing tokens in localStorage | XSS can steal tokens | Use httpOnly cookies (Nuxt handles via `useAuth`) |
| Hardcoded API keys in frontend | Exposed in bundle | Use `runtimeConfig` with private keys |
| Unvalidated URL redirects | Open redirect vulnerability | Whitelist allowed domains |

### Font Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `font-family: 'Inter'` | Generic AI aesthetic | Use Geist, Satoshi, Cabinet Grotesk |
| `font-family: 'Roboto'` | Generic, overused | Use General Sans, Clash Display |
| `font-family: 'Arial'` | System font, no character | Use distinctive web fonts |
| `font-family: system-ui` | No brand identity | Define specific font stack |

### Performance Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `<img>` without `<NuxtImg>` | No optimization | Use `<NuxtImg>` with `@nuxt/image` |
| Inline styles in `v-for` loops | Creates new objects each render | Use static `class` or CSS Modules |
| Missing `:key` in `v-for` | Vue can't optimize | Always provide stable keys |
| `computed`/`watchEffect` everywhere | Premature optimization | Only when actually needed |

**If existing code uses FORBIDDEN patterns → Report as blocker, DO NOT extend.**

---

## Standards Compliance Categories

**When invoked from bee:dev-refactor, check all categories:**

| Category | Bee Standard | What to Verify |
|----------|--------------|----------------|
| **TypeScript** | Strict mode, no `any` | tsconfig.json, *.vue files |
| **Accessibility** | WCAG 2.1 AA | Semantic HTML, ARIA, keyboard nav |
| **State Management** | Pinia + useAsyncData/useFetch | No `watch` for fetching |
| **Forms** | VeeValidate + Zod | Validation schemas present |
| **Styling** | Tailwind, CSS variables | No inline styles in logic |
| **Fonts** | Distinctive fonts | No Inter, Roboto, Arial |
| **Performance** | NuxtImg, lazy loading | `useLazyFetch`, defineAsyncComponent |
| **Security** | No XSS vectors | `v-html` usage, runtimeConfig |

---

## Form Field Abstraction Layer

### Dual-Mode UI Library Support

**HARD GATE:** All forms MUST use field abstraction wrappers. Direct input usage is FORBIDDEN.

| Mode | Detection | Components |
|------|-----------|------------|
| **sindarian-vue** (primary) | `@lerianstudio/sindarian-vue` in package.json | FormField, FormItem, FormLabel, FormControl, FormMessage, FormTooltip |
| **shadcn-vue/radix** (fallback) | Components not available in sindarian-vue | Place in project `components/ui/` using shadcn-vue + Radix Vue primitives |

### Field Wrapper Components (MANDATORY)

| Component | Purpose | Required Props |
|-----------|---------|----------------|
| `InputField` | Text, number, email, password inputs | name, label, description?, placeholder?, tooltip? |
| `SelectField` | Single select dropdown | name, label, options, placeholder? |
| `ComboBoxField` | Searchable select with filtering | name, label, options, onSearch?, placeholder? |
| `MultiSelectField` | Multiple selection | name, label, options, maxItems? |
| `TextAreaField` | Multi-line text input | name, label, rows?, maxLength? |
| `CheckboxField` | Boolean checkbox | name, label, description? |
| `SwitchField` | Toggle switch | name, label, description? |
| `DatePickerField` | Date selection | name, label, minDate?, maxDate? |

### sindarian-vue Mode Implementation

```html
<!-- components/fields/InputField.vue -->
<script setup lang="ts">
import {
    FormField,
    FormItem,
    FormLabel,
    FormControl,
    FormDescription,
    FormMessage,
    FormTooltip,
    Input,
} from '@lerianstudio/sindarian-vue'
import { useFormContext } from 'vee-validate'

interface Props {
    name: string
    label: string
    description?: string
    placeholder?: string
    tooltip?: string
    type?: 'text' | 'email' | 'password' | 'number'
}

const props = withDefaults(defineProps<Props>(), { type: 'text' })

// VeeValidate field binding via useField within FormField slot
</script>

<template>
    <FormField :name="props.name">
        <FormItem>
            <FormLabel>
                {{ props.label }}
                <FormTooltip v-if="props.tooltip">{{ props.tooltip }}</FormTooltip>
            </FormLabel>
            <FormControl>
                <Input
                    :type="props.type"
                    :placeholder="props.placeholder"
                />
            </FormControl>
            <FormDescription v-if="props.description">{{ props.description }}</FormDescription>
            <FormMessage />
        </FormItem>
    </FormField>
</template>
```

### Vanilla Mode Implementation (shadcn-vue)

```html
<!-- components/fields/InputField.vue (shadcn-vue fallback) -->
<script setup lang="ts">
import {
    FormField,
    FormItem,
    FormLabel,
    FormControl,
    FormMessage,
    FormDescription,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import {
    Tooltip,
    TooltipContent,
    TooltipTrigger,
} from '@/components/ui/tooltip'
import { HelpCircleIcon } from 'lucide-vue-next'

interface Props {
    name: string
    label: string
    description?: string
    placeholder?: string
    tooltip?: string
    type?: 'text' | 'email' | 'password' | 'number'
}

const props = withDefaults(defineProps<Props>(), { type: 'text' })
</script>

<template>
    <FormField :name="props.name">
        <FormItem>
            <FormLabel class="flex items-center gap-1">
                {{ props.label }}
                <Tooltip v-if="props.tooltip">
                    <TooltipTrigger as-child>
                        <HelpCircleIcon class="h-4 w-4 text-muted-foreground" />
                    </TooltipTrigger>
                    <TooltipContent>{{ props.tooltip }}</TooltipContent>
                </Tooltip>
            </FormLabel>
            <FormControl>
                <Input
                    :type="props.type"
                    :placeholder="props.placeholder"
                />
            </FormControl>
            <FormDescription v-if="props.description">{{ props.description }}</FormDescription>
            <FormMessage />
        </FormItem>
    </FormField>
</template>
```

### Form Usage Pattern

```html
<!-- pages/users/create.vue -->
<script setup lang="ts">
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

const schema = z.object({
    name: z.string().min(1, 'Name is required'),
    email: z.string().email('Invalid email'),
    role: z.enum(['admin', 'user', 'guest']),
})

type FormData = z.infer<typeof schema>

const form = useForm<FormData>({
    validationSchema: toTypedSchema(schema),
    initialValues: { name: '', email: '', role: 'user' },
})

const onSubmit = form.handleSubmit(async (values) => {
    // Submit logic
})
</script>

<template>
    <form @submit="onSubmit">
        <InputField
            name="name"
            label="Name"
            placeholder="Enter your name"
            tooltip="Your full legal name"
        />
        <InputField
            name="email"
            label="Email"
            type="email"
            placeholder="you@example.com"
        />
        <SelectField
            name="role"
            label="Role"
            :options="[
                { value: 'admin', label: 'Administrator' },
                { value: 'user', label: 'User' },
                { value: 'guest', label: 'Guest' },
            ]"
        />
        <Button type="submit">Create User</Button>
    </form>
</template>
```

### Anti-Patterns (FORBIDDEN)

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `<Input v-model="name" />` directly | No label, no error display, no accessibility | Use `<InputField name="name" label="Name" />` |
| Inline error handling | Inconsistent UX | Use FormMessage from wrapper |
| Manual FormField for each input | Code duplication | Use pre-built field wrappers |
| Different field patterns per form | Inconsistent UX | Use shared field components |

---

## Plugin Composition Pattern

### Plugin Order (MANDATORY)

Nuxt plugins run in order. Ensure proper dependency chain.

```typescript
// plugins/01.api.ts — Base API configuration (runs first)
export default defineNuxtPlugin(() => {
    const config = useRuntimeConfig()
    const { token } = useAuth()

    // Configure global $fetch defaults
    const apiFetch = $fetch.create({
        baseURL: config.public.apiBase,
        onRequest({ options }) {
            if (token.value) {
                options.headers = {
                    ...options.headers,
                    Authorization: `Bearer ${token.value}`,
                }
            }
        },
        onResponseError({ response }) {
            if (response.status === 401) {
                navigateTo('/login')
            }
        },
    })

    return { provide: { apiFetch } }
})

// plugins/02.toast.client.ts — Toast (client-only, runs second)
import { toast } from 'vue-sonner'

export default defineNuxtPlugin(() => {
    return { provide: { toast } }
})
```

### Plugin Order Rules

| Order | Plugin | Reason |
|-------|--------|--------|
| 01 | API / $fetch setup | Must be configured before any data fetching |
| 02 | Auth plugin | Session must be available for API calls |
| 03 | Toast / notification | UI feedback after auth is ready |
| 04 | Analytics | After auth for user identification |
| 05+ | Feature-specific | After all infrastructure is ready |

### app.vue Integration

```html
<!-- app.vue -->
<script setup lang="ts">
// Global providers and head configuration
useHead({
    htmlAttrs: { lang: 'en' },
    titleTemplate: (title) => title ? `${title} | App Name` : 'App Name',
})
</script>

<template>
    <!-- TooltipProvider wraps the entire app for Radix Vue tooltips -->
    <TooltipProvider>
        <NuxtLayout>
            <NuxtPage />
        </NuxtLayout>
        <Toaster />
    </TooltipProvider>
</template>
```

### Feature-Specific Provide/Inject

```typescript
// composables/useOrganization.ts
interface OrganizationContext {
    organizationId: Ref<string | null>
    setOrganizationId: (id: string | null) => void
}

const OrganizationKey = Symbol('Organization') as InjectionKey<OrganizationContext>

export function provideOrganization() {
    const organizationId = ref<string | null>(null)
    const context: OrganizationContext = {
        organizationId,
        setOrganizationId: (id) => { organizationId.value = id },
    }
    provide(OrganizationKey, context)
    return context
}

export function useOrganization() {
    const context = inject(OrganizationKey)
    if (!context) {
        throw new Error('useOrganization must be used within a component that calls provideOrganization()')
    }
    return context
}
```

---

## Composable Patterns

### Pagination Composables (MANDATORY for lists)

#### usePagination (Offset-based)

```typescript
// composables/usePagination.ts

interface UsePaginationOptions {
    initialPage?: number
    initialPageSize?: number
    pageSizeOptions?: number[]
}

export function usePagination({
    initialPage = 1,
    initialPageSize = 10,
    pageSizeOptions = [10, 20, 50, 100],
}: UsePaginationOptions = {}) {
    const page = ref(initialPage)
    const pageSize = ref(initialPageSize)

    const offset = computed(() => (page.value - 1) * pageSize.value)
    const canPrevPage = computed(() => page.value > 1)

    function nextPage() { page.value++ }
    function prevPage() { page.value = Math.max(1, page.value - 1) }
    function canNextPage(totalItems: number) {
        return page.value * pageSize.value < totalItems
    }
    function totalPages(totalItems: number) {
        return Math.ceil(totalItems / pageSize.value)
    }
    function setPageSize(size: number) {
        pageSize.value = size
        page.value = 1 // Reset to first page on size change
    }

    return {
        page: readonly(page),
        pageSize: readonly(pageSize),
        offset,
        canPrevPage,
        pageSizeOptions,
        setPage: (p: number) => { page.value = p },
        setPageSize,
        nextPage,
        prevPage,
        canNextPage,
        totalPages,
    }
}
```

#### useCursorPagination (Cursor-based)

```typescript
// composables/useCursorPagination.ts

interface CursorPaginationState {
    cursor: string | null
    direction: 'next' | 'prev'
}

export function useCursorPagination({ initialPageSize = 10 } = {}) {
    const state = ref<CursorPaginationState>({ cursor: null, direction: 'next' })
    const pageSize = ref(initialPageSize)
    const hasNext = ref(false)
    const hasPrev = ref(false)

    function goToNext(nextCursor: string) {
        state.value = { cursor: nextCursor, direction: 'next' }
    }

    function goToPrev(prevCursor: string) {
        state.value = { cursor: prevCursor, direction: 'prev' }
    }

    function reset() {
        state.value = { cursor: null, direction: 'next' }
    }

    return {
        cursor: computed(() => state.value.cursor),
        pageSize: readonly(pageSize),
        setPageSize: (size: number) => { pageSize.value = size },
        hasNext: readonly(hasNext),
        hasPrev: readonly(hasPrev),
        setHasNext: (v: boolean) => { hasNext.value = v },
        setHasPrev: (v: boolean) => { hasPrev.value = v },
        goToNext,
        goToPrev,
        reset,
    }
}
```

### CRUD Sheet Composable Pattern

```typescript
// composables/useSheet.ts

type SheetMode = 'create' | 'edit' | 'view' | 'closed'

export function useSheet<T>() {
    const mode = ref<SheetMode>('closed')
    const data = ref<T | null>(null)

    const isOpen = computed(() => mode.value !== 'closed')
    const isCreateMode = computed(() => mode.value === 'create')
    const isEditMode = computed(() => mode.value === 'edit')
    const isViewMode = computed(() => mode.value === 'view')

    function openCreate() {
        data.value = null
        mode.value = 'create'
    }

    function openEdit(item: T) {
        data.value = item as any
        mode.value = 'edit'
    }

    function openView(item: T) {
        data.value = item as any
        mode.value = 'view'
    }

    function close() {
        mode.value = 'closed'
        data.value = null
    }

    return {
        isOpen,
        mode: readonly(mode),
        data: readonly(data),
        isCreateMode,
        isEditMode,
        isViewMode,
        openCreate,
        openEdit,
        openView,
        close,
    }
}
```

### Utility Composables

#### useDebounce

```typescript
// composables/useDebounce.ts
export function useDebounce<T>(value: Ref<T>, delay: number = 300): Readonly<Ref<T>> {
    const debouncedValue = ref<T>(value.value) as Ref<T>

    let timer: ReturnType<typeof setTimeout>

    watch(value, (newValue) => {
        clearTimeout(timer)
        timer = setTimeout(() => {
            debouncedValue.value = newValue
        }, delay)
    })

    return readonly(debouncedValue)
}
```

#### useStepper

```typescript
// composables/useStepper.ts

interface UseStepperOptions {
    initialStep?: number
    totalSteps: number
}

export function useStepper({ initialStep = 0, totalSteps }: UseStepperOptions) {
    const currentStep = ref(initialStep)

    const isFirstStep = computed(() => currentStep.value === 0)
    const isLastStep = computed(() => currentStep.value === totalSteps - 1)
    const progress = computed(() => ((currentStep.value + 1) / totalSteps) * 100)

    function nextStep() {
        currentStep.value = Math.min(currentStep.value + 1, totalSteps - 1)
    }

    function prevStep() {
        currentStep.value = Math.max(currentStep.value - 1, 0)
    }

    function goToStep(step: number) {
        if (step >= 0 && step < totalSteps) {
            currentStep.value = step
        }
    }

    function reset() {
        currentStep.value = initialStep
    }

    return {
        currentStep: readonly(currentStep),
        totalSteps,
        isFirstStep,
        isLastStep,
        progress,
        nextStep,
        prevStep,
        goToStep,
        reset,
    }
}
```

---

## Fetcher Utilities Pattern

### Base Fetcher Functions

In Nuxt 3, `$fetch` (from `ofetch`) is the recommended HTTP client. Wrap it with typed helpers:

```typescript
// utils/fetcher/index.ts

export interface FetcherOptions extends RequestInit {
    params?: Record<string, string | number | boolean | undefined>
}

function buildUrl(url: string, params?: FetcherOptions['params']): string {
    if (!params) return url

    const searchParams = new URLSearchParams()
    Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined) {
            searchParams.append(key, String(value))
        }
    })

    const queryString = searchParams.toString()
    return queryString ? `${url}?${queryString}` : url
}

export async function getFetcher<T>(
    url: string,
    options: FetcherOptions = {}
): Promise<T> {
    const { params, ...fetchOptions } = options
    return $fetch<T>(buildUrl(url, params), {
        method: 'GET',
        ...fetchOptions,
    })
}

export async function postFetcher<T, D = unknown>(
    url: string,
    data: D,
    options: FetcherOptions = {}
): Promise<T> {
    const { params, ...fetchOptions } = options
    return $fetch<T>(buildUrl(url, params), {
        method: 'POST',
        body: data,
        ...fetchOptions,
    })
}

export async function patchFetcher<T, D = unknown>(
    url: string,
    data: D,
    options: FetcherOptions = {}
): Promise<T> {
    const { params, ...fetchOptions } = options
    return $fetch<T>(buildUrl(url, params), {
        method: 'PATCH',
        body: data,
        ...fetchOptions,
    })
}

export async function deleteFetcher<T = void>(
    url: string,
    options: FetcherOptions = {}
): Promise<T> {
    const { params, ...fetchOptions } = options
    return $fetch<T>(buildUrl(url, params), {
        method: 'DELETE',
        ...fetchOptions,
    })
}
```

### ApiError Class

```typescript
// utils/fetcher/api-error.ts

export class ApiError extends Error {
    constructor(
        message: string,
        public readonly status: number,
        public readonly code?: string
    ) {
        super(message)
        this.name = 'ApiError'
    }

    get isNotFound() { return this.status === 404 }
    get isUnauthorized() { return this.status === 401 }
    get isForbidden() { return this.status === 403 }
    get isValidationError() { return this.status === 400 || this.status === 422 }
    get isServerError() { return this.status >= 500 }
}
```

### Integration with useAsyncData

```typescript
// composables/useUsers.ts
import { getFetcher, postFetcher, patchFetcher, deleteFetcher } from '~/utils/fetcher'
import type { User, CreateUserInput, UpdateUserInput } from '~/types/user'

export function useUsers(filters: Ref<{ page?: number; pageSize?: number }> = ref({})) {
    return useAsyncData(
        () => `users-${JSON.stringify(filters.value)}`,
        () => getFetcher<{ data: User[]; total: number }>('/api/users', { params: filters.value }),
        { watch: [filters] }
    )
}

export function useUser(id: string) {
    return useAsyncData(
        `user-${id}`,
        () => getFetcher<User>(`/api/users/${id}`),
        { immediate: !!id }
    )
}

export function useCreateUser() {
    const pending = ref(false)
    const error = ref<Error | null>(null)

    async function createUser(data: CreateUserInput): Promise<User> {
        pending.value = true
        error.value = null
        try {
            const user = await postFetcher<User, CreateUserInput>('/api/users', data)
            await refreshNuxtData(/^users/)
            return user
        } catch (e) {
            error.value = e as Error
            throw e
        } finally {
            pending.value = false
        }
    }

    return { createUser, pending: readonly(pending), error: readonly(error) }
}

export function useUpdateUser(id: string) {
    const pending = ref(false)

    async function updateUser(data: UpdateUserInput): Promise<User> {
        pending.value = true
        try {
            const user = await patchFetcher<User, UpdateUserInput>(`/api/users/${id}`, data)
            await refreshNuxtData([`user-${id}`, /^users/])
            return user
        } finally {
            pending.value = false
        }
    }

    return { updateUser, pending: readonly(pending) }
}

export function useDeleteUser() {
    const pending = ref(false)

    async function deleteUser(id: string): Promise<void> {
        pending.value = true
        try {
            await deleteFetcher(`/api/users/${id}`)
            await refreshNuxtData(/^users/)
        } finally {
            pending.value = false
        }
    }

    return { deleteUser, pending: readonly(pending) }
}
```

---

## Client-Side Error Handling

### NuxtErrorBoundary Component

```html
<!-- components/ErrorBoundary.vue — Wraps NuxtErrorBoundary with consistent UI -->
<script setup lang="ts">
import { AlertTriangleIcon } from 'lucide-vue-next'

interface Props {
    onReset?: () => void
}
const props = defineProps<Props>()

function onError(error: Error) {
    console.error('ErrorBoundary caught an error:', error)
    // Report to error tracking service (e.g., Sentry)
}
</script>

<template>
    <NuxtErrorBoundary @error="onError">
        <slot />
        <template #error="{ error, clearError }">
            <div class="flex flex-col items-center justify-center p-8 text-center">
                <AlertTriangleIcon class="h-12 w-12 text-destructive mb-4" />
                <h2 class="text-lg font-semibold mb-2">Something went wrong</h2>
                <p class="text-muted-foreground mb-4">
                    {{ error.message || 'An unexpected error occurred' }}
                </p>
                <Button
                    variant="outline"
                    @click="() => { clearError(); props.onReset?.() }"
                >
                    Try again
                </Button>
            </div>
        </template>
    </NuxtErrorBoundary>
</template>
```

### API Error Helpers

```typescript
// utils/error-helpers.ts
import { ApiError } from '~/utils/fetcher/api-error'

export function handleApiError(error: unknown): void {
    const { $toast } = useNuxtApp()

    if (error instanceof ApiError) {
        if (error.isUnauthorized) {
            $toast.error('Session Expired', { description: 'Please log in again.' })
            navigateTo('/login')
            return
        }

        if (error.isForbidden) {
            $toast.error('Access Denied', {
                description: 'You do not have permission to perform this action.',
            })
            return
        }

        if (error.isValidationError) {
            $toast.error('Validation Error', { description: error.message })
            return
        }

        if (error.isServerError) {
            $toast.error('Server Error', {
                description: 'Something went wrong. Please try again later.',
            })
            return
        }

        $toast.error('Error', { description: error.message })
        return
    }

    $toast.error('Error', { description: 'An unexpected error occurred.' })
}
```

### Error Recovery Patterns

```html
<!-- Usage with submit handlers -->
<script setup lang="ts">
import { handleApiError } from '~/utils/error-helpers'

const { createUser, pending, error } = useCreateUser()
const { $toast } = useNuxtApp()

const form = useForm({ validationSchema: toTypedSchema(createUserSchema) })

const onSubmit = form.handleSubmit(async (values) => {
    try {
        await createUser(values)
        $toast.success('User created successfully.')
    } catch (err) {
        handleApiError(err)
    }
})
</script>

<template>
    <form @submit="onSubmit">
        <!-- form fields -->
        <Alert v-if="error" variant="destructive">
            <AlertDescription>Failed to create user. Please try again.</AlertDescription>
        </Alert>
    </form>
</template>
```

### Global Error Handler via Nuxt Plugin

```typescript
// plugins/01.error-handler.ts
export default defineNuxtPlugin((nuxtApp) => {
    nuxtApp.hook('vue:error', (error, instance, info) => {
        console.error('Vue error:', error, info)
        // Report to error tracking service
    })

    // Configure $fetch error handling globally
    nuxtApp.hook('app:error', (error) => {
        if ((error as any).statusCode === 401) {
            navigateTo('/login')
        }
    })
})
```

---

## Data Table Pattern

### TanStack Table (Vue adapter) with Pagination

```html
<!-- components/DataTable.vue -->
<script setup lang="ts" generic="TData, TValue">
import {
    type ColumnDef,
    type SortingState,
    FlexRender,
    getCoreRowModel,
    getSortedRowModel,
    useVueTable,
} from '@tanstack/vue-table'
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

interface Props {
    columns: ColumnDef<TData, TValue>[]
    data: TData[]
    pageCount?: number
    pagination?: {
        page: number
        pageSize: number
        onPageChange: (page: number) => void
        onPageSizeChange: (size: number) => void
    }
    isLoading?: boolean
}

const props = defineProps<Props>()

const sorting = ref<SortingState>([])

const table = useVueTable({
    get data() { return props.data },
    get columns() { return props.columns },
    get pageCount() { return props.pageCount },
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: (updater) => {
        sorting.value = typeof updater === 'function' ? updater(sorting.value) : updater
    },
    state: {
        get sorting() { return sorting.value },
    },
    manualPagination: !!props.pagination,
})
</script>

<template>
    <div class="space-y-4">
        <div class="rounded-md border">
            <Table>
                <TableHeader>
                    <TableRow
                        v-for="headerGroup in table.getHeaderGroups()"
                        :key="headerGroup.id"
                    >
                        <TableHead
                            v-for="header in headerGroup.headers"
                            :key="header.id"
                        >
                            <FlexRender
                                v-if="!header.isPlaceholder"
                                :render="header.column.columnDef.header"
                                :props="header.getContext()"
                            />
                        </TableHead>
                    </TableRow>
                </TableHeader>
                <TableBody>
                    <template v-if="isLoading">
                        <TableRow>
                            <TableCell :colspan="columns.length" class="h-24 text-center">
                                Loading...
                            </TableCell>
                        </TableRow>
                    </template>
                    <template v-else-if="table.getRowModel().rows.length">
                        <TableRow
                            v-for="row in table.getRowModel().rows"
                            :key="row.id"
                            :data-state="row.getIsSelected() ? 'selected' : undefined"
                        >
                            <TableCell
                                v-for="cell in row.getVisibleCells()"
                                :key="cell.id"
                            >
                                <FlexRender
                                    :render="cell.column.columnDef.cell"
                                    :props="cell.getContext()"
                                />
                            </TableCell>
                        </TableRow>
                    </template>
                    <template v-else>
                        <TableRow>
                            <TableCell :colspan="columns.length" class="h-24 text-center">
                                No results.
                            </TableCell>
                        </TableRow>
                    </template>
                </TableBody>
            </Table>
        </div>

        <div v-if="pagination" class="flex items-center justify-between px-2">
            <div class="flex items-center space-x-2">
                <p class="text-sm text-muted-foreground">Rows per page</p>
                <Select
                    :model-value="String(pagination.pageSize)"
                    @update:model-value="(v) => pagination!.onPageSizeChange(Number(v))"
                >
                    <SelectTrigger class="h-8 w-[70px]">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem v-for="size in [10, 20, 50, 100]" :key="size" :value="String(size)">
                            {{ size }}
                        </SelectItem>
                    </SelectContent>
                </Select>
            </div>
            <div class="flex items-center space-x-2">
                <Button
                    variant="outline"
                    size="sm"
                    :disabled="pagination.page <= 1"
                    @click="pagination.onPageChange(pagination.page - 1)"
                >
                    Previous
                </Button>
                <span class="text-sm text-muted-foreground">
                    Page {{ pagination.page }} of {{ pageCount || 1 }}
                </span>
                <Button
                    variant="outline"
                    size="sm"
                    :disabled="pagination.page >= (pageCount || 1)"
                    @click="pagination.onPageChange(pagination.page + 1)"
                >
                    Next
                </Button>
            </div>
        </div>
    </div>
</template>
```

### Usage with Server-Side Pagination

```html
<!-- pages/users/index.vue -->
<script setup lang="ts">
import { columns } from './columns'

const pagination = usePagination({ initialPageSize: 20 })
const filters = computed(() => ({
    page: pagination.page.value,
    pageSize: pagination.pageSize.value,
}))
const { data, pending } = useUsers(filters)
</script>

<template>
    <DataTable
        :columns="columns"
        :data="data?.data ?? []"
        :page-count="data ? pagination.totalPages(data.total) : 0"
        :pagination="{
            page: pagination.page,
            pageSize: pagination.pageSize,
            onPageChange: pagination.setPage,
            onPageSizeChange: pagination.setPageSize,
        }"
        :is-loading="pending"
    />
</template>
```

### Column Definitions Pattern

```typescript
// pages/users/columns.ts
import type { ColumnDef } from '@tanstack/vue-table'
import type { User } from '~/types/user'
import { h } from 'vue'
import UserActionsCell from './UserActionsCell.vue'

export const columns: ColumnDef<User>[] = [
    {
        accessorKey: 'name',
        header: 'Name',
    },
    {
        accessorKey: 'email',
        header: 'Email',
    },
    {
        accessorKey: 'role',
        header: 'Role',
        cell: ({ row }) => h('span', { class: 'capitalize' }, row.getValue('role')),
    },
    {
        accessorKey: 'createdAt',
        header: 'Created',
        cell: ({ row }) => new Date(row.getValue<string>('createdAt')).toLocaleDateString(),
    },
    {
        id: 'actions',
        cell: ({ row }) => h(UserActionsCell, { user: row.original }),
    },
]
```

---

## Checklist

Before submitting frontend code, verify:

- [ ] TypeScript strict mode (no `any`)
- [ ] Components use semantic HTML
- [ ] Forms validated with Zod via VeeValidate
- [ ] `useAsyncData` / `useFetch` for server state
- [ ] Pinia for client state (if needed)
- [ ] Mobile-first responsive design
- [ ] Keyboard accessible (tabindex, @keydown handlers)
- [ ] ARIA labels where needed
- [ ] Images use `<NuxtImg>` with alt text
- [ ] No generic fonts (Inter, Roboto, Arial)
- [ ] Animations are purposeful, not decorative
- [ ] No FORBIDDEN patterns present
