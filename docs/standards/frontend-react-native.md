# Frontend Standards (React Native / Expo)

> **MAINTENANCE:** This file is indexed in `dev-team/skills/shared-patterns/standards-coverage-table.md`.
> When adding/removing `## ` sections, follow FOUR-FILE UPDATE RULE in CLAUDE.md: (1) edit standards file, (2) update TOC, (3) update standards-coverage-table.md, (4) update agent file.

This file defines the specific standards for mobile development using React Native and Expo SDK.

> **Reference**: Always consult `docs/PROJECT_RULES.md` for common project standards.

---

## Table of Contents

| # | Section | Description |
|---|---------|-------------|
| 1 | [Framework](#framework) | React Native, Expo SDK (version policy) |
| 2 | [Libraries & Tools](#libraries--tools) | Core deps, state, forms, UI, styling, testing |
| 3 | [State Management Patterns](#state-management-patterns) | Zustand stores, TanStack Query, MMKV |
| 4 | [Form Patterns](#form-patterns) | React Hook Form + Zod |
| 5 | [Styling Standards](#styling-standards) | NativeWind, StyleSheet, design tokens |
| 6 | [Typography Standards](#typography-standards) | expo-font loading, scaling, font pairing |
| 7 | [Animation Standards](#animation-standards) | react-native-reanimated, Animated API, gesture handler |
| 8 | [Component Patterns](#component-patterns) | Custom hooks, ErrorBoundary, Platform.select |
| 9 | [File Organization](#file-organization-mandatory) | Feature-based, co-location |
| 10 | [Accessibility](#accessibility) | React Native a11y props, VoiceOver, TalkBack |
| 11 | [Performance](#performance) | FlatList, memo, Hermes, bundle size, image optimization |
| 12 | [Directory Structure](#directory-structure) | Expo Router file-based layout |
| 13 | [Forbidden Patterns](#forbidden-patterns) | Anti-patterns to avoid |
| 14 | [Standards Compliance Categories](#standards-compliance-categories) | Categories for bee:dev-refactor |
| 15 | [Navigation Patterns](#navigation-patterns) | Expo Router, deep linking, type-safe routes |
| 16 | [Native Module Integration](#native-module-integration) | Expo modules, native bridging |
| 17 | [Platform-Specific Code](#platform-specific-code) | Platform.select, .ios.tsx/.android.tsx |
| 18 | [Testing Standards](#testing-standards) | RNTL, Jest, Detox, snapshot testing |
| 19 | [Security Standards](#security-standards) | Secure storage, certificate pinning, code obfuscation |
| 20 | [Build & Deploy](#build--deploy) | EAS Build, OTA updates, app store submission |

**Meta-sections (not checked by agents):**
- [Checklist](#checklist) - Self-verification before submitting code

---

## Framework

- React Native (latest stable) with Expo SDK
- Expo Router for file-based navigation
- TypeScript strict mode (see `typescript.md`)

### Framework Version Policy

| Scenario | Rule |
|----------|------|
| **New project** | Use **latest stable Expo SDK** (verify at expo.dev/changelog before starting) |
| **Existing codebase** | **Maintain project's current Expo SDK version** (read package.json and app.json) |

**Before starting any project:**
1. For NEW projects: Check https://expo.dev/changelog for latest stable SDK
2. For EXISTING projects: Read `package.json` and `app.json` to determine current SDK version
3. NEVER hardcode a specific SDK version in implementation — use the project's version
4. Check for known SDK incompatibilities with target React Native version before upgrading
5. Managed workflow (Expo Go compatible) is preferred over bare workflow unless native code is required

### Managed vs Bare Workflow

| Scenario | Workflow | Reason |
|----------|----------|--------|
| Most apps, standard device APIs | Managed (Expo SDK modules) | Faster iteration, OTA updates, no native build required |
| Custom native modules not in Expo SDK | Bare + `expo-modules-core` | Access to arbitrary native code |
| Bridgeless/New Architecture | Bare + `react-native-new-architecture` | Required for JSI-based modules |

---

## Libraries & Tools

### Core

| Library | Use Case |
|---------|----------|
| React Native (latest stable) | Mobile UI framework |
| Expo SDK (latest stable) | Managed workflow, device APIs, build toolchain |
| Expo Router | File-based navigation (wraps React Navigation v6+) |
| TypeScript 5+ | Type safety |

### State Management

| Library | Use Case |
|---------|----------|
| Zustand | Client-side UI and global state |
| TanStack Query (React Query) | Server state, caching, background refetch |
| MMKV (`react-native-mmkv`) | Fast persistent key-value store (replaces AsyncStorage) |
| Zustand + MMKV persist | Persistent global state (auth tokens, preferences) |

### Forms

| Library | Use Case |
|---------|----------|
| React Hook Form | Form state management (`useForm`, `Controller`) |
| Zod | Schema validation |
| `@hookform/resolvers/zod` | React Hook Form + Zod integration |

### UI Components

| Library | Use Case |
|---------|----------|
| NativeWind | TailwindCSS utility classes for React Native |
| `react-native-reusables` | Headless accessible RN primitives (shadcn-style) |
| Expo Vector Icons | Icon sets (`@expo/vector-icons`) |
| expo-image | Optimized image loading with blurhash placeholders |

### Styling

| Library | Use Case |
|---------|----------|
| NativeWind v4 | Utility-first styling via className prop |
| `StyleSheet.create` | Performance-critical or dynamic styles |
| Design tokens (constants) | Shared colors, spacing, radii in `constants/theme.ts` |

### Testing

| Library | Use Case |
|---------|----------|
| Jest + `jest-expo` | Test runner and preset |
| React Native Testing Library | Component tests |
| Detox | E2E tests on real device/simulator |
| MSW (mock service worker) | API mocking in tests |

---

## State Management Patterns

### Server State with TanStack Query

TanStack Query handles all server state: fetching, caching, background refetch, and mutations.

```typescript
// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import type { User, CreateUserInput, UserFilters } from '@/types/user'
import { getUsers, createUser, updateUser, deleteUser } from '@/api/users'

// Query keys factory — ensures consistent cache invalidation
export const userKeys = {
    all: ['users'] as const,
    lists: () => [...userKeys.all, 'list'] as const,
    list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
    details: () => [...userKeys.all, 'detail'] as const,
    detail: (id: string) => [...userKeys.details(), id] as const,
}

export function useUsers(filters: UserFilters = {}) {
    return useQuery({
        queryKey: userKeys.list(filters),
        queryFn: () => getUsers(filters),
        staleTime: 1000 * 60 * 5, // 5 minutes
    })
}

export function useUser(id: string) {
    return useQuery({
        queryKey: userKeys.detail(id),
        queryFn: () => getUserById(id),
        enabled: !!id,
    })
}

export function useCreateUser() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: CreateUserInput) => createUser(data),
        onSuccess: () => {
            // Invalidate all user lists after creation
            queryClient.invalidateQueries({ queryKey: userKeys.lists() })
        },
    })
}

export function useDeleteUser() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: string) => deleteUser(id),
        onSuccess: (_data, id) => {
            queryClient.removeQueries({ queryKey: userKeys.detail(id) })
            queryClient.invalidateQueries({ queryKey: userKeys.lists() })
        },
    })
}
```

### Client State with Zustand

```typescript
// stores/useUIStore.ts
import { create } from 'zustand'

interface UIState {
    theme: 'light' | 'dark'
    isDrawerOpen: boolean
    setTheme: (theme: 'light' | 'dark') => void
    toggleDrawer: () => void
}

export const useUIStore = create<UIState>((set) => ({
    theme: 'light',
    isDrawerOpen: false,
    setTheme: (theme) => set({ theme }),
    toggleDrawer: () => set((state) => ({ isDrawerOpen: !state.isDrawerOpen })),
}))
```

### Persistent State with Zustand + MMKV

```typescript
// stores/useAuthStore.ts
import { create } from 'zustand'
import { createJSONStorage, persist } from 'zustand/middleware'
import { MMKV } from 'react-native-mmkv'

const storage = new MMKV({ id: 'auth-store' })

// MMKV adapter for Zustand persist
const mmkvStorage = {
    getItem: (name: string) => storage.getString(name) ?? null,
    setItem: (name: string, value: string) => storage.set(name, value),
    removeItem: (name: string) => storage.delete(name),
}

interface AuthState {
    token: string | null
    userId: string | null
    setAuth: (token: string, userId: string) => void
    clearAuth: () => void
}

export const useAuthStore = create<AuthState>()(
    persist(
        (set) => ({
            token: null,
            userId: null,
            setAuth: (token, userId) => set({ token, userId }),
            clearAuth: () => set({ token: null, userId: null }),
        }),
        {
            name: 'auth-storage',
            storage: createJSONStorage(() => mmkvStorage),
        }
    )
)
```

### Optimistic Updates with TanStack Query

```typescript
// hooks/useUpdateUser.ts
export function useUpdateUser() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: ({ id, data }: { id: string; data: UpdateUserInput }) =>
            updateUser(id, data),
        // Optimistically update the cache before the server responds
        onMutate: async ({ id, data }) => {
            await queryClient.cancelQueries({ queryKey: userKeys.detail(id) })
            const previousUser = queryClient.getQueryData<User>(userKeys.detail(id))

            queryClient.setQueryData<User>(userKeys.detail(id), (old) =>
                old ? { ...old, ...data } : old
            )

            return { previousUser }
        },
        // Roll back on error
        onError: (_err, { id }, context) => {
            if (context?.previousUser) {
                queryClient.setQueryData(userKeys.detail(id), context.previousUser)
            }
        },
        onSettled: (_data, _err, { id }) => {
            queryClient.invalidateQueries({ queryKey: userKeys.detail(id) })
        },
    })
}
```

---

## Form Patterns

### React Hook Form + Zod

```typescript
// screens/users/CreateUserScreen.tsx
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

// Schema definition
const createUserSchema = z.object({
    name: z.string().min(1, 'Name is required').max(100),
    email: z.string().email('Invalid email address'),
    role: z.enum(['admin', 'user', 'guest']),
    notificationsEnabled: z.boolean().default(true),
})

type CreateUserInput = z.infer<typeof createUserSchema>

export function CreateUserScreen() {
    const { mutate: createUser, isPending } = useCreateUser()

    const {
        control,
        handleSubmit,
        formState: { errors },
    } = useForm<CreateUserInput>({
        resolver: zodResolver(createUserSchema),
        defaultValues: {
            name: '',
            email: '',
            role: 'user',
            notificationsEnabled: true,
        },
    })

    const onSubmit = handleSubmit((values) => {
        createUser(values)
    })

    return (
        <View className="flex-1 p-4 gap-4">
            <Controller
                control={control}
                name="name"
                render={({ field: { onChange, onBlur, value } }) => (
                    <InputField
                        label="Name"
                        placeholder="Enter your name"
                        value={value}
                        onChangeText={onChange}
                        onBlur={onBlur}
                        error={errors.name?.message}
                    />
                )}
            />
            <Controller
                control={control}
                name="email"
                render={({ field: { onChange, onBlur, value } }) => (
                    <InputField
                        label="Email"
                        placeholder="you@example.com"
                        keyboardType="email-address"
                        autoCapitalize="none"
                        value={value}
                        onChangeText={onChange}
                        onBlur={onBlur}
                        error={errors.email?.message}
                    />
                )}
            />
            <Button onPress={onSubmit} loading={isPending}>
                Create User
            </Button>
        </View>
    )
}
```

### Field Abstraction Components (MANDATORY)

**HARD GATE:** All forms MUST use field abstraction wrappers. Direct `TextInput` usage without label/error display is FORBIDDEN in form contexts.

```typescript
// components/fields/InputField.tsx
import { View, TextInput, Text, TextInputProps } from 'react-native'

interface InputFieldProps extends TextInputProps {
    label: string
    error?: string
    description?: string
}

export function InputField({
    label,
    error,
    description,
    ...inputProps
}: InputFieldProps) {
    const inputId = useId()

    return (
        <View className="gap-1">
            <Text
                className="text-sm font-medium text-foreground"
                nativeID={inputId}
            >
                {label}
            </Text>
            <TextInput
                className={cn(
                    'h-10 rounded-md border border-input bg-background px-3 py-2',
                    'text-base text-foreground',
                    error && 'border-destructive'
                )}
                accessibilityLabel={label}
                accessibilityLabelledBy={inputId}
                accessibilityInvalid={!!error}
                accessibilityHint={description}
                {...inputProps}
            />
            {description && !error && (
                <Text className="text-xs text-muted-foreground">{description}</Text>
            )}
            {error && (
                <Text
                    className="text-xs text-destructive"
                    accessibilityRole="alert"
                >
                    {error}
                </Text>
            )}
        </View>
    )
}
```

| Component | Purpose | Required Props |
|-----------|---------|----------------|
| `InputField` | Text, number, email, password inputs | label, value, onChangeText, error? |
| `SelectField` | Single select (bottom sheet or modal) | label, value, options, onChange, error? |
| `TextAreaField` | Multi-line text input | label, value, onChangeText, numberOfLines?, error? |
| `CheckboxField` | Boolean checkbox | label, value, onChange, description? |
| `SwitchField` | Toggle switch | label, value, onChange, description? |
| `DatePickerField` | Date selection (native picker) | label, value, onChange, minimumDate?, maximumDate? |

---

## Styling Standards

### NativeWind Best Practices

```typescript
// Use semantic class groupings with className prop
<View className="
    flex-row items-center justify-between
    p-4 gap-4
    bg-white dark:bg-gray-900
    border border-gray-200 rounded-lg
">

// Extract repeated patterns to components
// components/ui/Card.tsx
import { View, type ViewProps } from 'react-native'
import { cn } from '@/lib/utils'

interface CardProps extends ViewProps {
    className?: string
}

export function Card({ className, children, ...props }: CardProps) {
    return (
        <View
            className={cn(
                'bg-white dark:bg-gray-900',
                'border border-gray-200 rounded-xl',
                'p-4 shadow-sm',
                className
            )}
            {...props}
        >
            {children}
        </View>
    )
}
```

### StyleSheet for Performance-Critical Styles

```typescript
// Use StyleSheet.create for frequently-rendered components or animated styles
import { StyleSheet } from 'react-native'

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
    },
    // Animated styles MUST use StyleSheet or inline (not NativeWind)
    animatedCard: {
        borderRadius: 12,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
    },
})
```

### Design Tokens (MANDATORY)

All colors, spacing, and radii MUST reference design tokens, never hardcoded values.

```typescript
// constants/theme.ts
export const colors = {
    primary: '#6366F1',
    primaryForeground: '#FFFFFF',
    secondary: '#8B5CF6',
    background: '#FFFFFF',
    foreground: '#111827',
    muted: '#F3F4F6',
    mutedForeground: '#6B7280',
    border: '#E5E7EB',
    destructive: '#EF4444',
    // Dark mode variants
    dark: {
        background: '#111827',
        foreground: '#F9FAFB',
        muted: '#1F2937',
        border: '#374151',
    },
} as const

export const spacing = {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    '2xl': 48,
} as const

export const radii = {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 16,
    full: 9999,
} as const

// tailwind.config.js — mirror design tokens in NativeWind
module.exports = {
    theme: {
        extend: {
            colors: {
                primary: '#6366F1',
                secondary: '#8B5CF6',
                background: '#FFFFFF',
                foreground: '#111827',
                muted: '#F3F4F6',
                'muted-foreground': '#6B7280',
                border: '#E5E7EB',
                destructive: '#EF4444',
            },
        },
    },
}
```

---

## Typography Standards

### Font Loading with expo-font (MANDATORY)

All custom fonts MUST be loaded via `expo-font` using `useFonts` or the `expo-font` plugin in `app.json`.

```typescript
// app/_layout.tsx
import { useFonts } from 'expo-font'
import * as SplashScreen from 'expo-splash-screen'
import { useEffect } from 'react'

SplashScreen.preventAutoHideAsync()

export default function RootLayout() {
    const [fontsLoaded, fontError] = useFonts({
        'Satoshi-Regular': require('../assets/fonts/Satoshi-Regular.ttf'),
        'Satoshi-Medium': require('../assets/fonts/Satoshi-Medium.ttf'),
        'Satoshi-Bold': require('../assets/fonts/Satoshi-Bold.ttf'),
        'ClashDisplay-Semibold': require('../assets/fonts/ClashDisplay-Semibold.ttf'),
        'ClashDisplay-Bold': require('../assets/fonts/ClashDisplay-Bold.ttf'),
    })

    useEffect(() => {
        if (fontsLoaded || fontError) {
            SplashScreen.hideAsync()
        }
    }, [fontsLoaded, fontError])

    if (!fontsLoaded && !fontError) return null

    return <Stack />
}
```

### Font Selection (AVOID GENERIC)

```typescript
// FORBIDDEN - Generic AI fonts
fontFamily: 'System'          // No character, default system
fontFamily: 'Roboto'          // Android default, overused
fontFamily: 'San Francisco'   // iOS default, no distinction
fontFamily: 'Inter'           // Web staple, no mobile character

// RECOMMENDED - Distinctive fonts
fontFamily: 'Satoshi-Regular'        // Contemporary, clean body text
fontFamily: 'ClashDisplay-Bold'      // Display headings, editorial
fontFamily: 'CabinetGrotesk-Medium'  // Bold, versatile
fontFamily: 'GeneralSans-Regular'    // Clean, versatile body
```

### Responsive Font Scaling

```typescript
// utils/typography.ts
import { PixelRatio, Dimensions } from 'react-native'

const { width: SCREEN_WIDTH } = Dimensions.get('window')
const BASE_WIDTH = 390 // iPhone 14 baseline

// Scale font size proportionally to screen width
export function scaleFontSize(size: number): number {
    const scale = SCREEN_WIDTH / BASE_WIDTH
    return Math.round(PixelRatio.roundToNearestPixel(size * scale))
}

// Font scale constants
export const fontSize = {
    xs: scaleFontSize(11),
    sm: scaleFontSize(13),
    base: scaleFontSize(15),
    md: scaleFontSize(17),
    lg: scaleFontSize(20),
    xl: scaleFontSize(24),
    '2xl': scaleFontSize(30),
    '3xl': scaleFontSize(36),
} as const

// constants/theme.ts — text styles
export const textStyles = {
    displayLarge: {
        fontFamily: 'ClashDisplay-Bold',
        fontSize: fontSize['3xl'],
        lineHeight: fontSize['3xl'] * 1.2,
    },
    heading: {
        fontFamily: 'ClashDisplay-Semibold',
        fontSize: fontSize.xl,
        lineHeight: fontSize.xl * 1.3,
    },
    body: {
        fontFamily: 'Satoshi-Regular',
        fontSize: fontSize.base,
        lineHeight: fontSize.base * 1.5,
    },
    caption: {
        fontFamily: 'Satoshi-Regular',
        fontSize: fontSize.xs,
        lineHeight: fontSize.xs * 1.4,
    },
} as const
```

### Text Component (MANDATORY)

Always use the project's `Text` wrapper — never bare `<Text>` from React Native — so font scaling and theming are applied consistently.

```typescript
// components/ui/Text.tsx
import { Text as RNText, type TextProps } from 'react-native'
import { cn } from '@/lib/utils'

interface AppTextProps extends TextProps {
    variant?: 'displayLarge' | 'heading' | 'body' | 'caption'
    className?: string
}

export function Text({
    variant = 'body',
    className,
    style,
    ...props
}: AppTextProps) {
    return (
        <RNText
            className={cn('text-foreground', className)}
            style={[textStyles[variant], style]}
            allowFontScaling
            maxFontSizeMultiplier={1.5}
            {...props}
        />
    )
}
```

---

## Animation Standards

### react-native-reanimated (Primary)

Use `react-native-reanimated` for all UI animations that require smooth, 60fps native-thread performance.

```typescript
import Animated, {
    useSharedValue,
    useAnimatedStyle,
    withSpring,
    withTiming,
    interpolate,
    Extrapolation,
    FadeIn,
    FadeOut,
    SlideInRight,
} from 'react-native-reanimated'

// Card press interaction
export function PressableCard({ children }: { children: React.ReactNode }) {
    const scale = useSharedValue(1)

    const animatedStyle = useAnimatedStyle(() => ({
        transform: [{ scale: scale.value }],
    }))

    return (
        <Animated.View style={animatedStyle}>
            <Pressable
                onPressIn={() => { scale.value = withSpring(0.97) }}
                onPressOut={() => { scale.value = withSpring(1) }}
            >
                {children}
            </Pressable>
        </Animated.View>
    )
}

// Screen transition
export function AnimatedScreen({ children }: { children: React.ReactNode }) {
    return (
        <Animated.View entering={FadeIn.duration(200)} exiting={FadeOut.duration(150)}>
            {children}
        </Animated.View>
    )
}
```

### Gesture Handler Integration

```typescript
import { Gesture, GestureDetector } from 'react-native-gesture-handler'
import Animated, {
    useSharedValue,
    useAnimatedStyle,
    withSpring,
    runOnJS,
} from 'react-native-reanimated'

export function SwipeToDelete({ onDelete, children }: SwipeToDeleteProps) {
    const translateX = useSharedValue(0)
    const SWIPE_THRESHOLD = -80

    const panGesture = Gesture.Pan()
        .onChange((e) => {
            translateX.value = Math.min(0, translateX.value + e.changeX)
        })
        .onEnd(() => {
            if (translateX.value < SWIPE_THRESHOLD) {
                runOnJS(onDelete)()
            } else {
                translateX.value = withSpring(0)
            }
        })

    const animatedStyle = useAnimatedStyle(() => ({
        transform: [{ translateX: translateX.value }],
    }))

    return (
        <GestureDetector gesture={panGesture}>
            <Animated.View style={animatedStyle}>{children}</Animated.View>
        </GestureDetector>
    )
}
```

### Animation Guidelines

1. **Run animations on UI thread** — use `useSharedValue` + `useAnimatedStyle`, never `setState` in animation loops
2. **Respect reduced motion** — check `AccessibilityInfo.isReduceMotionEnabled()` and reduce/skip animations
3. **Keep durations short** — 150-250ms for micro-interactions, 300-400ms for transitions
4. **Spring physics over linear timing** — use `withSpring` for natural feel, `withTiming` when precision matters
5. **Avoid `Animated.Value` (legacy)** — migrate to `react-native-reanimated` for all new animations

```typescript
// Respect accessibility reduce motion setting
import { AccessibilityInfo, useEffect, useState } from 'react'

export function useReduceMotion() {
    const [reduceMotion, setReduceMotion] = useState(false)

    useEffect(() => {
        AccessibilityInfo.isReduceMotionEnabled().then(setReduceMotion)
        const sub = AccessibilityInfo.addEventListener(
            'reduceMotionChanged',
            setReduceMotion
        )
        return () => sub.remove()
    }, [])

    return reduceMotion
}
```

---

## Component Patterns

### Custom Hooks (RN equivalent of composables)

```typescript
// hooks/useTabs.ts
import { createContext, useContext, useState } from 'react'

interface TabsContextValue {
    activeTab: string
    setActiveTab: (value: string) => void
}

const TabsContext = createContext<TabsContextValue | null>(null)

export function TabsProvider({
    defaultValue,
    children,
}: {
    defaultValue: string
    children: React.ReactNode
}) {
    const [activeTab, setActiveTab] = useState(defaultValue)

    return (
        <TabsContext.Provider value={{ activeTab, setActiveTab }}>
            {children}
        </TabsContext.Provider>
    )
}

export function useTabs() {
    const ctx = useContext(TabsContext)
    if (!ctx) throw new Error('useTabs must be used inside <TabsProvider>')
    return ctx
}
```

### Error Boundaries

```typescript
// components/ErrorBoundary.tsx
import React from 'react'
import { View, Text, Pressable } from 'react-native'

interface ErrorBoundaryProps {
    children: React.ReactNode
    fallback?: React.ComponentType<{ error: Error; retry: () => void }>
    onError?: (error: Error) => void
}

interface ErrorBoundaryState {
    hasError: boolean
    error: Error | null
}

export class ErrorBoundary extends React.Component<
    ErrorBoundaryProps,
    ErrorBoundaryState
> {
    constructor(props: ErrorBoundaryProps) {
        super(props)
        this.state = { hasError: false, error: null }
    }

    static getDerivedStateFromError(error: Error): ErrorBoundaryState {
        return { hasError: true, error }
    }

    componentDidCatch(error: Error) {
        this.props.onError?.(error)
        // Report to crash analytics (e.g., Sentry)
        console.error('ErrorBoundary caught:', error)
    }

    retry = () => {
        this.setState({ hasError: false, error: null })
    }

    render() {
        if (this.state.hasError && this.state.error) {
            const Fallback = this.props.fallback ?? DefaultErrorFallback
            return <Fallback error={this.state.error} retry={this.retry} />
        }
        return this.props.children
    }
}

function DefaultErrorFallback({
    error,
    retry,
}: {
    error: Error
    retry: () => void
}) {
    return (
        <View className="flex-1 items-center justify-center p-8">
            <Text className="text-2xl mb-2">Something went wrong</Text>
            <Text className="text-muted-foreground text-center mb-6">
                {error.message}
            </Text>
            <Pressable
                className="border border-border rounded-lg px-4 py-2"
                onPress={retry}
                accessibilityRole="button"
            >
                <Text>Try again</Text>
            </Pressable>
        </View>
    )
}
```

### Platform.select Usage

```typescript
// Use Platform.select for cross-platform style differences
import { Platform, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
    card: {
        ...Platform.select({
            ios: {
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.1,
                shadowRadius: 4,
            },
            android: {
                elevation: 4,
            },
        }),
    },
    header: {
        paddingTop: Platform.select({ ios: 0, android: 8, default: 0 }),
    },
})

// Use Platform.select for behavioral differences
const hitSlop = Platform.select({
    ios: { top: 10, bottom: 10, left: 10, right: 10 },
    android: { top: 8, bottom: 8, left: 8, right: 8 },
    default: { top: 10, bottom: 10, left: 10, right: 10 },
})
```

---

## File Organization (MANDATORY)

**Single Responsibility per File:** Each component file MUST represent ONE UI concern.

### Rules

| Rule | Description |
|------|-------------|
| **One component per file** | A file exports ONE primary component |
| **Max 250 lines per component file** | If longer, extract sub-components or custom hooks |
| **Co-locate related files** | Component, hook, types, test in same feature folder |
| **Custom hooks in separate files** | Hooks exceeding 20 lines get their own file |
| **Separate data from presentation** | Container (data-fetching) and presentational components split |
| **Screens vs components** | Screens live in `app/` (Expo Router); reusable components in `components/` |

### Examples

```typescript
// WRONG: UserDashboardScreen.tsx (400 lines, mixed concerns)
export function UserDashboardScreen() {
    // 30 lines of state
    const [users, setUsers] = useState<User[]>([])
    const [filters, setFilters] = useState({})
    const [isLoading, setIsLoading] = useState(false)

    // 50 lines of data fetching
    useEffect(() => {
        fetchUsers(filters).then(setUsers).finally(() => setIsLoading(false))
    }, [filters])

    // 320 lines of mixed render
}
```

```typescript
// CORRECT: Split by concern

// app/(tabs)/users/index.tsx (~40 lines) — Screen composition root
export default function UsersScreen() {
    const { filters, updateFilter, resetFilters } = useUserFilters()
    const { data, isLoading } = useUsers(filters)
    const { page, setPage, pageSize, setPageSize } = usePagination()

    return (
        <View className="flex-1">
            <UserFilters filters={filters} onChange={updateFilter} onReset={resetFilters} />
            <UserList users={data?.users ?? []} isLoading={isLoading} />
        </View>
    )
}

// hooks/useUsers.ts (~40 lines) — Data fetching hook
export function useUsers(filters: UserFilters) {
    return useQuery({
        queryKey: userKeys.list(filters),
        queryFn: () => getUsers(filters),
    })
}

// hooks/useUserFilters.ts (~30 lines) — Filter state hook
export function useUserFilters() {
    const [filters, setFilters] = useState<UserFilters>({})

    const updateFilter = useCallback((key: string, value: unknown) => {
        setFilters((prev) => ({ ...prev, [key]: value }))
    }, [])

    const resetFilters = useCallback(() => setFilters({}), [])

    return { filters, updateFilter, resetFilters }
}
```

### Signs a File Needs Splitting

| Sign | Action |
|------|--------|
| Component file exceeds 250 lines | Extract sub-components or hooks |
| More than 4 `useState` / `useReducer` at top level | Extract to custom hook |
| JSX render exceeds 100 lines | Extract child components |
| File mixes data fetching and presentation | Split screen and component |
| Multiple `useQuery` calls in one component | Extract to dedicated hook files |
| Component accepts more than 6 props | Consider composition or context pattern |

---

## Accessibility

### Required Practices

```typescript
// ALWAYS use accessibilityRole instead of semantic HTML (RN has no HTML)
<Pressable
    accessibilityRole="button"
    accessibilityLabel="Delete user John Doe"
    accessibilityHint="Removes this user from the list"
    onPress={handleDelete}
>
    <TrashIcon />
</Pressable>

// Images need accessibilityLabel
<Image
    source={{ uri: user.avatar }}
    accessibilityLabel={`${user.name}'s profile photo`}
    accessibilityRole="image"
/>

// Decorative images must be hidden from screen readers
<Image
    source={require('../assets/decoration.png')}
    accessible={false}
    importantForAccessibility="no-hide-descendants"  // Android
    aria-hidden  // iOS (RN 0.72+)
/>

// Form inputs must have labels linked to inputs
<Text nativeID="email-label">Email</Text>
<TextInput
    accessibilityLabelledBy="email-label"
    accessibilityLabel="Email address"
    keyboardType="email-address"
/>
```

### Focus Management

```typescript
import { useRef } from 'react'
import { AccessibilityInfo, findNodeHandle, View } from 'react-native'

// Move screen reader focus to a specific element
export function useAccessibilityFocus() {
    const ref = useRef<View>(null)

    const setFocus = () => {
        const node = findNodeHandle(ref.current)
        if (node) {
            AccessibilityInfo.setAccessibilityFocus(node)
        }
    }

    return { ref, setFocus }
}

// Focus heading when modal opens
export function Modal({ isVisible, title, children }: ModalProps) {
    const { ref: headingRef, setFocus } = useAccessibilityFocus()

    useEffect(() => {
        if (isVisible) {
            // Delay to allow layout
            requestAnimationFrame(setFocus)
        }
    }, [isVisible])

    return (
        <RNModal visible={isVisible} accessibilityViewIsModal>
            <Text ref={headingRef} accessibilityRole="header">
                {title}
            </Text>
            {children}
        </RNModal>
    )
}
```

### Minimum Touch Targets (WCAG 2.5.5)

```typescript
// All interactive elements must meet 44x44pt minimum
<Pressable
    style={{ minWidth: 44, minHeight: 44, justifyContent: 'center', alignItems: 'center' }}
    // OR use hitSlop to expand touch area without changing layout
    hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
    accessibilityRole="button"
>
    <Icon size={20} />
</Pressable>
```

### VoiceOver / TalkBack Labels

```typescript
// Group related elements for screen readers
<View
    accessible
    accessibilityLabel={`${user.name}, ${user.role}, joined ${user.joinDate}`}
>
    <Text>{user.name}</Text>
    <Text>{user.role}</Text>
    <Text>{user.joinDate}</Text>
</View>

// Live regions for dynamic content
<Text
    accessibilityLiveRegion="polite"  // Android
    aria-live="polite"                 // iOS RN 0.72+
>
    {statusMessage}
</Text>
```

---

## Performance

### FlatList Optimization (MANDATORY for lists > 20 items)

```typescript
import { FlatList, type ListRenderItem } from 'react-native'
import { memo, useCallback } from 'react'

// Item component MUST be memoized
const UserListItem = memo(({ user, onPress }: UserListItemProps) => (
    <Pressable onPress={() => onPress(user.id)}>
        <Text>{user.name}</Text>
    </Pressable>
))
UserListItem.displayName = 'UserListItem'

export function UserList({ users, onSelectUser }: UserListProps) {
    // Stable callback reference
    const renderItem: ListRenderItem<User> = useCallback(
        ({ item }) => <UserListItem user={item} onPress={onSelectUser} />,
        [onSelectUser]
    )

    // Stable key extractor
    const keyExtractor = useCallback((item: User) => item.id, [])

    // Item layout for fixed-height items (critical performance win)
    const ITEM_HEIGHT = 72
    const getItemLayout = useCallback(
        (_data: unknown, index: number) => ({
            length: ITEM_HEIGHT,
            offset: ITEM_HEIGHT * index,
            index,
        }),
        []
    )

    return (
        <FlatList
            data={users}
            renderItem={renderItem}
            keyExtractor={keyExtractor}
            getItemLayout={getItemLayout}
            removeClippedSubviews
            maxToRenderPerBatch={10}
            windowSize={10}
            initialNumToRender={15}
            ListEmptyComponent={<EmptyState />}
            ListFooterComponent={<ListFooter />}
        />
    )
}
```

### React.memo and useMemo

```typescript
// Memoize expensive computations
const sortedUsers = useMemo(
    () => [...users].sort((a, b) => a.name.localeCompare(b.name)),
    [users]
)

// Memoize callback props passed to memoized children
const handleSelectUser = useCallback((id: string) => {
    router.push(`/users/${id}`)
}, [router])

// Memo for pure presentational components
const UserCard = memo(({ name, role }: UserCardProps) => (
    <View>
        <Text>{name}</Text>
        <Text>{role}</Text>
    </View>
))
```

### Image Optimization with expo-image

```typescript
import { Image } from 'expo-image'

// Always use expo-image for network images
<Image
    source={{ uri: user.avatar }}
    style={{ width: 48, height: 48, borderRadius: 24 }}
    placeholder={user.blurhash}     // Show blurhash while loading
    contentFit="cover"
    transition={200}
    cachePolicy="memory-disk"       // Aggressive caching
    accessibilityLabel={`${user.name}'s avatar`}
/>
```

### Hermes Engine (MANDATORY)

Hermes must be enabled for all production builds. Verify in `app.json`:

```json
{
    "expo": {
        "jsEngine": "hermes"
    }
}
```

### Bundle Size Monitoring

```typescript
// Lazy load heavy screens with React.lazy + Suspense equivalent
// Expo Router automatically code-splits by route, but within a screen:
import { lazy, Suspense } from 'react'

const HeavyChart = lazy(() => import('../components/HeavyChart'))

export function AnalyticsScreen() {
    return (
        <Suspense fallback={<LoadingSpinner />}>
            <HeavyChart />
        </Suspense>
    )
}
```

---

## Directory Structure

```text
/
  /app                        # Expo Router file-based routing
    _layout.tsx               # Root layout (fonts, providers, global error boundary)
    +not-found.tsx            # 404 screen
    /( auth)                  # Auth group (unauthenticated)
      _layout.tsx
      sign-in.tsx             # /sign-in
      sign-up.tsx             # /sign-up
    /(tabs)                   # Main app tab group
      _layout.tsx             # Tab bar configuration
      index.tsx               # / (Home)
      /users
        index.tsx             # /users
        [id].tsx              # /users/:id
        create.tsx            # /users/create
      /settings
        index.tsx             # /settings
  /components
    /ui                       # Primitive UI components
      Button.tsx
      Text.tsx
      Card.tsx
      InputField.tsx
    /features                 # Feature-specific components
      /users
        UserCard.tsx
        UserList.tsx
        UserFilters.tsx
      /orders
        OrderForm.tsx
  /hooks                      # Custom hooks
    useUsers.ts
    usePagination.ts
    useDebounce.ts
    useSheet.ts
  /stores                     # Zustand stores
    useAuthStore.ts
    useUIStore.ts
  /api                        # API layer (fetchers)
    /users
      index.ts                # getUsers, createUser, updateUser, deleteUser
    client.ts                 # Axios / fetch base client with auth interceptor
  /constants
    theme.ts                  # Design tokens (colors, spacing, typography)
    config.ts                 # App config (API URLs, feature flags)
  /types                      # TypeScript types
    user.ts
    api.ts
  /utils                      # Utility functions
    cn.ts                     # NativeWind class merge utility
    api-error.ts
    format.ts
  /assets
    /fonts                    # Font files loaded via expo-font
    /images                   # Static images
  /e2e                        # Detox E2E tests
    /tests
      users.test.ts
/app.json                     # Expo app configuration
/eas.json                     # EAS Build profiles
/tailwind.config.js           # NativeWind configuration
/tsconfig.json                # TypeScript configuration (strict mode)
```

---

## Forbidden Patterns

**The following patterns are never allowed. Agents MUST refuse to implement these:**

### TypeScript Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `any` type | Defeats TypeScript purpose | Use proper types, `unknown`, or generics |
| Type assertions without validation | Runtime crashes | Use type guards or Zod parsing |
| `// @ts-ignore` or `// @ts-expect-error` | Hides real errors | Fix the type issue properly |
| Non-strict mode | Allows unsafe code | Enable `"strict": true` in tsconfig |

### Accessibility Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `<TouchableOpacity>` without `accessibilityRole` | Not announced correctly by screen readers | Always set `accessibilityRole="button"` |
| Images without `accessibilityLabel` | Screen readers skip silently | Provide descriptive label on every image |
| Touch targets smaller than 44x44pt | Fails WCAG 2.5.5, hard to tap | Use `minWidth/minHeight` or `hitSlop` |
| Removing focus outline without alternative | Focus invisible on keyboard/TV | Provide custom focus styles |
| `accessible={false}` on interactive elements | Hides button from VoiceOver | Only use on purely decorative elements |

### State Management Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `useEffect` for data fetching with setState | Race conditions, no caching | Use TanStack Query `useQuery` |
| `AsyncStorage` for sensitive data | Unencrypted on disk | Use `expo-secure-store` |
| `AsyncStorage` for high-frequency reads | Slow, async, not suitable | Use MMKV for all key-value persistence |
| Prop drilling > 3 levels | Unmaintainable | Use Zustand store or React context |
| Storing server state in Zustand manually | Stale data, duplicates TanStack cache | Use TanStack Query for all server state |
| `setState` inside TanStack Query callbacks | Redundant state | Query cache IS the state |

### Performance Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `<Image>` from React Native for network images | No caching, no placeholder | Use `expo-image` |
| `ScrollView` for long lists (> 20 items) | Renders all items at once — OOM risk | Use `FlatList` or `FlashList` |
| Inline function props to memoized children | Breaks memoization every render | Use `useCallback` |
| Missing `keyExtractor` in FlatList | Keys fallback to index — breaks reorders | Always provide stable `keyExtractor` |
| `getItemLayout` omitted for fixed-height items | No scroll position estimation | Always provide for fixed-height lists |
| `useEffect` with heavy synchronous work | Blocks JS thread | Move to `useMemo` or background worker |

### Security Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `AsyncStorage` for tokens | Unencrypted, accessible to other apps | Use `expo-secure-store` (Keychain/Keystore) |
| Hardcoded API keys in source code | Exposed in bundle | Use `expo-constants` + EAS Secrets |
| `console.log` with sensitive data in production | Log leakage | Strip with Babel in production builds |
| Disabled SSL pinning | MitM attacks possible | Enable certificate pinning for sensitive APIs |
| Deep link without validation | Open redirect, data injection | Validate and whitelist deep link params |

### Font Anti-Patterns

| Pattern | Why Forbidden | Correct Alternative |
|---------|---------------|---------------------|
| `fontFamily: 'System'` | No brand identity | Use loaded custom fonts |
| `fontFamily: 'Inter'` | Web/AI aesthetic | Use Satoshi, Cabinet Grotesk |
| `fontFamily: 'Roboto'` | Android default, overused | Use General Sans, Clash Display |
| Inline font files not via expo-font | Not preloaded, causes FOUT | Always load via `useFonts` in root layout |
| Missing `allowFontScaling` | Breaks system accessibility text size | Set `allowFontScaling` + `maxFontSizeMultiplier` |

**If existing code uses FORBIDDEN patterns → Report as blocker, DO NOT extend.**

---

## Standards Compliance Categories

**When invoked from bee:dev-refactor, check all categories:**

| Category | Bee Standard | What to Verify |
|----------|--------------|----------------|
| **TypeScript** | Strict mode, no `any` | tsconfig.json, *.tsx files |
| **Accessibility** | WCAG 2.1 AA (mobile) | `accessibilityRole`, labels, touch targets |
| **State Management** | Zustand + TanStack Query | No `useEffect` for fetching, no `AsyncStorage` for state |
| **Forms** | React Hook Form + Zod | Controller usage, Zod resolvers |
| **Styling** | NativeWind + design tokens | No hardcoded hex values, no inline styles with raw numbers |
| **Fonts** | Distinctive fonts via expo-font | No System/Roboto/Inter, loaded in root layout |
| **Performance** | FlatList, memo, expo-image | No ScrollView for lists, no inline callbacks to memo children |
| **Security** | expo-secure-store, EAS Secrets | No AsyncStorage for tokens, no hardcoded keys |
| **Navigation** | Expo Router type-safe routes | No manual navigation strings, typed `href` params |
| **Build** | Hermes enabled, EAS Build | `jsEngine: hermes` in app.json, OTA update channel configured |

---

## Navigation Patterns

### Expo Router File-Based Navigation

```typescript
// Navigate programmatically — always use typed router
import { router } from 'expo-router'

// Push (adds to stack)
router.push('/users/123')

// Replace (no back)
router.replace('/(auth)/sign-in')

// Go back
router.back()

// Navigate with params
router.push({ pathname: '/users/[id]', params: { id: user.id } })
```

### Type-Safe Routes (MANDATORY)

Enable typed routes in `app.json` and use `href` generics:

```json
{
    "expo": {
        "experiments": {
            "typedRoutes": true
        }
    }
}
```

```typescript
// Typed Link component
import { Link } from 'expo-router'

<Link href="/users/123" asChild>
    <Pressable>
        <Text>View User</Text>
    </Pressable>
</Link>

// Typed router.push
router.push({
    pathname: '/users/[id]',
    params: { id: '123' },
})

// Read typed params in a screen
import { useLocalSearchParams } from 'expo-router'

export default function UserDetailScreen() {
    const { id } = useLocalSearchParams<{ id: string }>()
    const { data: user } = useUser(id)
    // ...
}
```

### Tab Navigation Layout

```typescript
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router'
import { HomeIcon, UsersIcon, SettingsIcon } from '@/components/icons'

export default function TabLayout() {
    return (
        <Tabs
            screenOptions={{
                tabBarActiveTintColor: colors.primary,
                headerShown: false,
            }}
        >
            <Tabs.Screen
                name="index"
                options={{
                    title: 'Home',
                    tabBarIcon: ({ color }) => <HomeIcon color={color} size={24} />,
                    tabBarAccessibilityLabel: 'Home tab',
                }}
            />
            <Tabs.Screen
                name="users"
                options={{
                    title: 'Users',
                    tabBarIcon: ({ color }) => <UsersIcon color={color} size={24} />,
                    tabBarAccessibilityLabel: 'Users tab',
                }}
            />
            <Tabs.Screen
                name="settings"
                options={{
                    title: 'Settings',
                    tabBarIcon: ({ color }) => <SettingsIcon color={color} size={24} />,
                    tabBarAccessibilityLabel: 'Settings tab',
                }}
            />
        </Tabs>
    )
}
```

### Deep Linking Configuration

```json
// app.json
{
    "expo": {
        "scheme": "myapp",
        "intentFilters": [
            {
                "action": "VIEW",
                "autoVerify": true,
                "data": [{ "scheme": "https", "host": "myapp.com" }],
                "category": ["BROWSABLE", "DEFAULT"]
            }
        ]
    }
}
```

```typescript
// Validate incoming deep link params
import { useLocalSearchParams } from 'expo-router'
import { z } from 'zod'

const inviteParamsSchema = z.object({
    token: z.string().min(1),
    email: z.string().email().optional(),
})

export default function InviteScreen() {
    const rawParams = useLocalSearchParams()

    const result = inviteParamsSchema.safeParse(rawParams)
    if (!result.success) {
        // Invalid deep link — redirect to home
        router.replace('/')
        return null
    }

    const { token, email } = result.data
    // Safe to use
}
```

---

## Native Module Integration

### Expo SDK Modules (Prefer over bare native)

Always prefer Expo SDK modules before writing custom native code:

```typescript
// Camera
import { CameraView, useCameraPermissions } from 'expo-camera'

// Location
import * as Location from 'expo-location'

// Notifications
import * as Notifications from 'expo-notifications'

// Secure storage
import * as SecureStore from 'expo-secure-store'

// File system
import * as FileSystem from 'expo-file-system'

// Haptics
import * as Haptics from 'expo-haptics'
```

### Permission Pattern (MANDATORY)

Always request permissions explicitly before accessing native APIs. Never call native APIs without confirmed permission.

```typescript
// hooks/useCameraPermission.ts
import { useCameraPermissions } from 'expo-camera'
import { Alert, Linking } from 'react-native'

export function useCameraWithPermission() {
    const [permission, requestPermission] = useCameraPermissions()

    const openSettings = () => Linking.openSettings()

    const requestWithFallback = async (): Promise<boolean> => {
        if (permission?.granted) return true

        if (permission?.canAskAgain === false) {
            Alert.alert(
                'Camera Permission Required',
                'Please enable camera access in Settings.',
                [
                    { text: 'Cancel', style: 'cancel' },
                    { text: 'Open Settings', onPress: openSettings },
                ]
            )
            return false
        }

        const result = await requestPermission()
        return result.granted
    }

    return {
        hasPermission: permission?.granted ?? false,
        requestWithFallback,
    }
}
```

### Custom Expo Modules (when SDK does not cover a need)

```typescript
// modules/my-native-module/index.ts
import { NativeModule, requireNativeModule } from 'expo-modules-core'

interface MyNativeModuleType extends NativeModule {
    doSomethingNative(value: string): Promise<string>
}

export default requireNativeModule<MyNativeModuleType>('MyNativeModule')
```

```typescript
// modules/my-native-module/src/MyNativeModule.types.ts
export type ChangeEventPayload = {
    value: string
}
```

---

## Platform-Specific Code

### File Extension Splitting (.ios.tsx / .android.tsx)

For significant behavioral differences, use platform-specific files:

```typescript
// components/DatePicker.ios.tsx
import DateTimePicker from '@react-native-community/datetimepicker'

export function DatePicker({ value, onChange }: DatePickerProps) {
    return (
        <DateTimePicker
            value={value}
            mode="date"
            display="inline"  // iOS calendar inline display
            onChange={(e, date) => date && onChange(date)}
        />
    )
}

// components/DatePicker.android.tsx
import DateTimePicker from '@react-native-community/datetimepicker'

export function DatePicker({ value, onChange }: DatePickerProps) {
    return (
        <DateTimePicker
            value={value}
            mode="date"
            display="default"  // Android spinner/calendar dialog
            onChange={(e, date) => date && onChange(date)}
        />
    )
}

// Import without extension — React Native resolves automatically
import { DatePicker } from '@/components/DatePicker'
```

### Platform.select for Inline Differences

```typescript
import { Platform, StyleSheet } from 'react-native'

// Behavioral differences
const ANIMATION_DURATION = Platform.select({
    ios: 300,
    android: 250,
    default: 300,
})

// Style differences
const styles = StyleSheet.create({
    header: {
        ...Platform.select({
            ios: {
                paddingTop: 0,        // SafeAreaView handles it on iOS
            },
            android: {
                paddingTop: StatusBar.currentHeight ?? 0,
            },
        }),
    },
})

// Component differences
const Separator = Platform.select({
    ios: () => <View className="h-px bg-gray-200" />,
    android: () => <View className="h-0.5 bg-gray-300" />,
    default: () => <View className="h-px bg-gray-200" />,
})!
```

### Safe Area Handling (MANDATORY)

```typescript
// Always use SafeAreaView or useSafeAreaInsets — never hardcode insets
import { SafeAreaView } from 'react-native-safe-area-context'
import { useSafeAreaInsets } from 'react-native-safe-area-context'

// Screen-level safe area
export function HomeScreen() {
    return (
        <SafeAreaView className="flex-1" edges={['top', 'bottom']}>
            {/* content */}
        </SafeAreaView>
    )
}

// Inset-aware custom bottom bar
export function BottomBar() {
    const insets = useSafeAreaInsets()

    return (
        <View style={{ paddingBottom: insets.bottom + 8 }}>
            {/* bar content */}
        </View>
    )
}
```

---

## Testing Standards

### React Native Testing Library (Unit & Component Tests)

```typescript
// components/features/users/__tests__/UserCard.test.tsx
import { render, screen, fireEvent } from '@testing-library/react-native'
import { UserCard } from '../UserCard'

const mockUser: User = {
    id: '1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: 'admin',
}

describe('UserCard', () => {
    it('renders user name and role', () => {
        render(<UserCard user={mockUser} onPress={jest.fn()} />)

        expect(screen.getByText('Jane Doe')).toBeTruthy()
        expect(screen.getByText('admin')).toBeTruthy()
    })

    it('calls onPress with user id when pressed', () => {
        const onPress = jest.fn()
        render(<UserCard user={mockUser} onPress={onPress} />)

        fireEvent.press(screen.getByRole('button'))

        expect(onPress).toHaveBeenCalledWith('1')
    })

    it('has accessible label', () => {
        render(<UserCard user={mockUser} onPress={jest.fn()} />)

        expect(screen.getByLabelText('Jane Doe, admin')).toBeTruthy()
    })
})
```

### Mocking TanStack Query in Tests

```typescript
// __tests__/setup/QueryWrapper.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

export function createQueryWrapper() {
    const queryClient = new QueryClient({
        defaultOptions: {
            queries: { retry: false, gcTime: 0 },
            mutations: { retry: false },
        },
    })

    return function Wrapper({ children }: { children: React.ReactNode }) {
        return (
            <QueryClientProvider client={queryClient}>
                {children}
            </QueryClientProvider>
        )
    }
}

// In tests
import { renderWithQuery } from '@/test-utils'

it('shows loading state', async () => {
    const wrapper = createQueryWrapper()
    render(<UserList />, { wrapper })
    expect(screen.getByTestId('loading-indicator')).toBeTruthy()
})
```

### MSW for API Mocking

```typescript
// __mocks__/handlers/users.ts
import { http, HttpResponse } from 'msw'
import { mockUsers } from '../fixtures/users'

export const usersHandlers = [
    http.get('/api/users', () => {
        return HttpResponse.json({ data: mockUsers, total: mockUsers.length })
    }),

    http.post('/api/users', async ({ request }) => {
        const body = await request.json()
        const newUser = { id: 'new-id', ...body }
        return HttpResponse.json(newUser, { status: 201 })
    }),

    http.delete('/api/users/:id', ({ params }) => {
        return HttpResponse.json({ id: params.id })
    }),
]
```

### Detox E2E Tests

```typescript
// e2e/tests/users.test.ts
describe('Users screen', () => {
    beforeAll(async () => {
        await device.launchApp({ newInstance: true })
    })

    beforeEach(async () => {
        await device.reloadReactNative()
    })

    it('should display user list', async () => {
        await element(by.id('tab-users')).tap()
        await expect(element(by.id('user-list'))).toBeVisible()
        await expect(element(by.text('Jane Doe'))).toBeVisible()
    })

    it('should navigate to user detail on tap', async () => {
        await element(by.id('tab-users')).tap()
        await element(by.text('Jane Doe')).tap()

        await expect(element(by.id('user-detail-screen'))).toBeVisible()
        await expect(element(by.text('jane@example.com'))).toBeVisible()
    })

    it('should create a new user', async () => {
        await element(by.id('tab-users')).tap()
        await element(by.id('create-user-button')).tap()

        await element(by.id('input-name')).typeText('John Smith')
        await element(by.id('input-email')).typeText('john@example.com')
        await element(by.id('submit-button')).tap()

        await expect(element(by.text('John Smith'))).toBeVisible()
    })
})
```

### Snapshot Testing (Selective Use)

```typescript
// ONLY snapshot stable, pure presentational components
// NEVER snapshot components with async data, icons, or Date.now()
it('renders button variants correctly', () => {
    const tree = render(<Button variant="primary">Submit</Button>).toJSON()
    expect(tree).toMatchSnapshot()
})
```

### Test Coverage Requirements

| Category | Minimum Coverage | Priority |
|----------|-----------------|----------|
| Custom hooks | 90% | High |
| Utility functions | 95% | High |
| Component rendering | 80% | Medium |
| Form validation logic | 95% | High |
| API layer (fetchers) | 85% | High |
| E2E (critical flows) | All happy paths | High |

---

## Security Standards

### Secure Storage (MANDATORY)

Tokens and sensitive credentials MUST be stored in the device Keychain (iOS) / Keystore (Android) via `expo-secure-store`. Never use AsyncStorage or MMKV for sensitive data.

```typescript
// utils/secure-storage.ts
import * as SecureStore from 'expo-secure-store'

const KEYS = {
    AUTH_TOKEN: 'auth_token',
    REFRESH_TOKEN: 'refresh_token',
} as const

export const secureStorage = {
    async setToken(token: string): Promise<void> {
        await SecureStore.setItemAsync(KEYS.AUTH_TOKEN, token, {
            requireAuthentication: false, // Set true for biometric-gated storage
            keychainAccessible: SecureStore.WHEN_UNLOCKED,
        })
    },

    async getToken(): Promise<string | null> {
        return SecureStore.getItemAsync(KEYS.AUTH_TOKEN)
    },

    async clearAll(): Promise<void> {
        await Promise.all([
            SecureStore.deleteItemAsync(KEYS.AUTH_TOKEN),
            SecureStore.deleteItemAsync(KEYS.REFRESH_TOKEN),
        ])
    },
}
```

### Environment Variables & Secrets

```typescript
// FORBIDDEN — Hardcoding secrets in source code
const API_KEY = 'sk-live-abc123'  // NEVER do this

// CORRECT — Use EAS Secrets + expo-constants
import Constants from 'expo-constants'

const apiKey = Constants.expoConfig?.extra?.apiKey as string
```

```json
// app.config.ts (dynamic config)
export default {
    expo: {
        extra: {
            apiKey: process.env.API_KEY,
            apiBaseUrl: process.env.API_BASE_URL,
        },
    },
}
```

```bash
# Set secrets via EAS CLI — never commit to .env files
eas secret:create --scope project --name API_KEY --value "sk-live-abc123"
```

### Certificate Pinning

For apps handling financial or medical data, enable certificate pinning:

```typescript
// api/client.ts — with certificate pinning via react-native-ssl-pinning
import { fetch } from 'react-native-ssl-pinning'

export async function secureFetch<T>(url: string, options: RequestInit): Promise<T> {
    const response = await fetch(url, {
        ...options,
        sslPinning: {
            certs: ['cert-sha256-hash'],  // SHA-256 of server certificate
        },
    })
    return response.json()
}
```

### Production Build Security

```typescript
// babel.config.js — strip console.log in production
module.exports = (api) => {
    api.cache(true)
    const isProduction = process.env.NODE_ENV === 'production'

    return {
        presets: ['babel-preset-expo'],
        plugins: [
            ...(isProduction ? [['transform-remove-console', { exclude: ['error', 'warn'] }]] : []),
        ],
    }
}
```

### Input Validation (MANDATORY)

All API responses MUST be validated with Zod before use:

```typescript
// api/users.ts
import { z } from 'zod'

const userSchema = z.object({
    id: z.string().uuid(),
    name: z.string().min(1).max(100),
    email: z.string().email(),
    role: z.enum(['admin', 'user', 'guest']),
    createdAt: z.string().datetime(),
})

const usersResponseSchema = z.object({
    data: z.array(userSchema),
    total: z.number().int().nonnegative(),
})

export async function getUsers(filters: UserFilters): Promise<UsersResponse> {
    const response = await apiClient.get('/users', { params: filters })
    // Validate API response shape — catches backend contract breaks early
    return usersResponseSchema.parse(response.data)
}
```

---

## Build & Deploy

### EAS Build Profiles (MANDATORY)

All builds MUST use EAS Build. Local `react-native run-ios` is only for development.

```json
// eas.json
{
    "cli": {
        "version": ">= 7.0.0"
    },
    "build": {
        "development": {
            "developmentClient": true,
            "distribution": "internal",
            "env": {
                "APP_ENV": "development",
                "API_BASE_URL": "https://api-dev.myapp.com"
            }
        },
        "preview": {
            "distribution": "internal",
            "ios": { "simulator": false },
            "env": {
                "APP_ENV": "preview",
                "API_BASE_URL": "https://api-staging.myapp.com"
            }
        },
        "production": {
            "autoIncrement": true,
            "env": {
                "APP_ENV": "production",
                "API_BASE_URL": "https://api.myapp.com"
            }
        }
    },
    "submit": {
        "production": {
            "ios": { "appleId": "$(APPLE_ID)", "ascAppId": "$(ASC_APP_ID)" },
            "android": { "serviceAccountKeyPath": "./google-service-account.json" }
        }
    }
}
```

### OTA Updates with expo-updates

```typescript
// hooks/useOTAUpdate.ts
import * as Updates from 'expo-updates'
import { useEffect } from 'react'
import { Alert } from 'react-native'

export function useOTAUpdate() {
    useEffect(() => {
        if (!Updates.isEmbeddedLaunch) return  // Skip in dev client

        async function checkForUpdate() {
            try {
                const update = await Updates.checkForUpdateAsync()

                if (update.isAvailable) {
                    await Updates.fetchUpdateAsync()

                    Alert.alert(
                        'Update Available',
                        'A new version has been downloaded. Restart to apply it.',
                        [
                            { text: 'Later' },
                            {
                                text: 'Restart',
                                onPress: () => Updates.reloadAsync(),
                            },
                        ]
                    )
                }
            } catch (error) {
                console.warn('OTA update check failed:', error)
            }
        }

        checkForUpdate()
    }, [])
}
```

```json
// app.json — OTA update channels
{
    "expo": {
        "updates": {
            "enabled": true,
            "checkAutomatically": "ON_LOAD",
            "fallbackToCacheTimeout": 5000,
            "channel": "production"
        }
    }
}
```

### Build Commands

```bash
# Development build (installs Expo Dev Client)
eas build --profile development --platform all

# Preview / QA build (internal distribution)
eas build --profile preview --platform all

# Production build (App Store / Play Store)
eas build --profile production --platform all

# Submit to stores
eas submit --profile production --platform ios
eas submit --profile production --platform android

# OTA update (no store review required for JS changes)
eas update --branch production --message "Fix login crash"
```

### App Store Submission Checklist

| Item | Requirement |
|------|-------------|
| Privacy manifest | `PrivacyInfo.xcprivacy` (iOS 17+, required) |
| App tracking transparency | Prompt before IDFA access |
| Required device permissions | All `NSXxx UsageDescription` strings in app.json |
| Minimum OS versions | iOS 16+, Android API 24+ (align with Expo SDK support) |
| Screenshots | Required sizes for all supported devices |
| App icons | 1024x1024 PNG, no alpha channel (iOS) |
| Android adaptive icon | 108x108 foreground + background layers |
| Version bump | `autoIncrement: true` in eas.json for production |

### Version Management

```json
// app.json — Version fields
{
    "expo": {
        "version": "1.2.0",       // Semantic version shown to users
        "ios": {
            "buildNumber": "42"    // Monotonically increasing int
        },
        "android": {
            "versionCode": 42      // Monotonically increasing int
        }
    }
}
```

---

## Checklist

Before submitting mobile code, verify:

- [ ] TypeScript strict mode (no `any`)
- [ ] All components have `accessibilityRole` where appropriate
- [ ] Touch targets are minimum 44x44pt
- [ ] Forms validated with Zod via React Hook Form `Controller`
- [ ] TanStack Query for all server state (no `useEffect` + `setState`)
- [ ] Zustand for client state (no prop drilling > 3 levels)
- [ ] No `AsyncStorage` — MMKV for persistence, `expo-secure-store` for secrets
- [ ] Lists > 20 items use `FlatList` (never `ScrollView`)
- [ ] `memo` + `useCallback` applied to list items and their callbacks
- [ ] `expo-image` used for all network images
- [ ] No generic fonts (System, Roboto, Inter)
- [ ] Fonts loaded via `useFonts` in root `_layout.tsx`
- [ ] Animations respect `useReduceMotion`
- [ ] `Platform.select` or `.ios.tsx`/`.android.tsx` for platform differences
- [ ] `SafeAreaView` / `useSafeAreaInsets` — no hardcoded insets
- [ ] Typed Expo Router `href` params (no plain string navigation)
- [ ] Deep link params validated with Zod before use
- [ ] Secrets stored in EAS Secrets (not in `.env` committed to repo)
- [ ] `console.log` stripped in production builds
- [ ] `jsEngine: hermes` confirmed in `app.json`
- [ ] No FORBIDDEN patterns present
