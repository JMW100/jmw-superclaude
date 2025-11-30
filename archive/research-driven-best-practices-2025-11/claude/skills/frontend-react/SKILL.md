---
name: frontend-react
description: "Frontend development with React, Next.js App Router, TypeScript, and Tailwind CSS. Covers Atomic Design component patterns, Server vs Client Components, state management, and accessible UI. Use when building UI components, pages, or working with React hooks."
---

# Frontend React Development Skill

## When to Use
- Creating React components (atoms, molecules, organisms)
- Building Next.js pages and layouts
- Deciding between Server and Client Components
- Implementing state management
- Styling with Tailwind CSS
- Handling forms and user interactions

## Component Architecture: Atomic Design

Organize components by complexity level, not by feature:

```
src/components/
├── atoms/           # Single-purpose elements
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Label.tsx
│   └── Badge.tsx
├── molecules/       # Simple combinations of atoms
│   ├── FormField.tsx      # Label + Input + Error
│   ├── SearchBar.tsx      # Input + Button
│   └── NavLink.tsx        # Icon + Text link
├── organisms/       # Complex, self-contained sections
│   ├── Header.tsx         # Logo + Nav + UserMenu
│   ├── LoginForm.tsx      # Multiple FormFields + Button
│   └── DataTable.tsx      # Table with sorting, pagination
└── layouts/         # Page structure wrappers
    ├── MainLayout.tsx
    └── AuthLayout.tsx
```

### When to Use Each Level

**Atoms**: Single HTML element with styling and variants
- Button, Input, Label, Badge, Avatar, Spinner
- No business logic, highly reusable

**Molecules**: 2-3 atoms working together
- FormField (Label + Input + ErrorMessage)
- SearchBar (Input + Button)
- Card (Container + Title + Content)
- Still no business logic, just composition

**Organisms**: Self-contained, feature-complete sections
- Header, Footer, Sidebar
- LoginForm, CheckoutForm
- DataTable, CommentThread
- May have internal state and business logic

## Component Template

### Atom Example

```tsx
// components/atoms/Button.tsx
import { forwardRef, type ButtonHTMLAttributes } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-blue-600 text-white hover:bg-blue-700',
        secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
        ghost: 'hover:bg-gray-100',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4',
        lg: 'h-12 px-6 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, isLoading, children, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(buttonVariants({ variant, size }), className)}
        disabled={disabled || isLoading}
        {...props}
      >
        {isLoading ? (
          <span className="mr-2 h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
        ) : null}
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

### Molecule Example

```tsx
// components/molecules/FormField.tsx
import { forwardRef, type InputHTMLAttributes } from 'react';
import { Label } from '@/components/atoms/Label';
import { Input } from '@/components/atoms/Input';

interface FormFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  hint?: string;
}

export const FormField = forwardRef<HTMLInputElement, FormFieldProps>(
  ({ label, error, hint, id, className, ...props }, ref) => {
    const inputId = id ?? label.toLowerCase().replace(/\s+/g, '-');
    
    return (
      <div className={className}>
        <Label htmlFor={inputId}>{label}</Label>
        <Input
          ref={ref}
          id={inputId}
          aria-describedby={error ? `${inputId}-error` : hint ? `${inputId}-hint` : undefined}
          aria-invalid={!!error}
          {...props}
        />
        {hint && !error && (
          <p id={`${inputId}-hint`} className="mt-1 text-sm text-gray-500">
            {hint}
          </p>
        )}
        {error && (
          <p id={`${inputId}-error`} className="mt-1 text-sm text-red-600" role="alert">
            {error}
          </p>
        )}
      </div>
    );
  }
);

FormField.displayName = 'FormField';
```

### Organism Example

```tsx
// components/organisms/LoginForm.tsx
'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/atoms/Button';
import { FormField } from '@/components/molecules/FormField';

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

interface LoginFormProps {
  onSubmit: (data: LoginFormData) => Promise<void>;
}

export function LoginForm({ onSubmit }: LoginFormProps) {
  const [isLoading, setIsLoading] = useState(false);
  
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });
  
  const handleFormSubmit = async (data: LoginFormData) => {
    setIsLoading(true);
    try {
      await onSubmit(data);
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
      <FormField
        label="Email"
        type="email"
        error={errors.email?.message}
        {...register('email')}
      />
      <FormField
        label="Password"
        type="password"
        error={errors.password?.message}
        {...register('password')}
      />
      <Button type="submit" isLoading={isLoading} className="w-full">
        Sign In
      </Button>
    </form>
  );
}
```

## Server vs Client Components

### Server Components (Default)

Use for:
- Fetching data directly (no API route needed)
- Accessing backend resources
- Keeping sensitive logic server-side
- Static or rarely-changing content

```tsx
// app/posts/page.tsx (Server Component by default)
import { supabase } from '@/lib/supabase';
import { PostCard } from '@/components/organisms/PostCard';

export default async function PostsPage() {
  // Direct database access - no fetch needed!
  const { data: posts } = await supabase
    .from('posts')
    .select('*, author:users(name)')
    .order('created_at', { ascending: false });
  
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {posts?.map((post) => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}
```

### Client Components ('use client')

Use for:
- useState, useEffect, useContext
- Event handlers (onClick, onChange)
- Browser APIs (localStorage, window)
- Interactive UI (forms, modals, tooltips)

```tsx
// components/organisms/SearchPosts.tsx
'use client';

import { useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { SearchBar } from '@/components/molecules/SearchBar';

export function SearchPosts() {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();
  const router = useRouter();
  
  const handleSearch = () => {
    startTransition(() => {
      router.push(`/posts?search=${encodeURIComponent(query)}`);
    });
  };
  
  return (
    <SearchBar
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      onSearch={handleSearch}
      isLoading={isPending}
      placeholder="Search posts..."
    />
  );
}
```

### Composition Pattern

Wrap Client Components in Server Components to minimize client JS:

```tsx
// app/posts/page.tsx (Server Component)
import { Suspense } from 'react';
import { PostsList } from './PostsList'; // Server Component
import { SearchPosts } from '@/components/organisms/SearchPosts'; // Client Component

export default function PostsPage() {
  return (
    <div>
      <SearchPosts /> {/* Interactive, client-side */}
      <Suspense fallback={<PostsSkeleton />}>
        <PostsList /> {/* Data fetching, server-side */}
      </Suspense>
    </div>
  );
}
```

## State Management

### Local State (useState)
For component-specific state that doesn't need to be shared.

### Form State (React Hook Form)
For complex forms with validation.

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const { register, handleSubmit, formState: { errors } } = useForm({
  resolver: zodResolver(schema),
  defaultValues: { name: '', email: '' },
});
```

### Server State (React Query / SWR)
For data that comes from the server and needs caching/revalidation.

```tsx
// Using SWR
import useSWR from 'swr';

function Profile({ userId }: { userId: string }) {
  const { data, error, isLoading } = useSWR(
    `/api/users/${userId}`,
    fetcher
  );
  
  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;
  return <ProfileCard user={data} />;
}
```

### Shared State (Zustand)
For state shared across multiple components.

```tsx
// stores/cart.ts
import { create } from 'zustand';

interface CartStore {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  clearCart: () => void;
}

export const useCartStore = create<CartStore>((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ 
    items: [...state.items, item] 
  })),
  removeItem: (id) => set((state) => ({ 
    items: state.items.filter(i => i.id !== id) 
  })),
  clearCart: () => set({ items: [] }),
}));

// Usage in component
function CartButton() {
  const itemCount = useCartStore((state) => state.items.length);
  return <Button>Cart ({itemCount})</Button>;
}
```

## Tailwind CSS Patterns

### Utility function for conditional classes

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage
<div className={cn(
  'base-classes',
  isActive && 'active-classes',
  variant === 'primary' && 'primary-classes'
)} />
```

### Responsive patterns

```tsx
// Mobile-first approach
<div className="
  grid 
  grid-cols-1       // Mobile: 1 column
  md:grid-cols-2    // Tablet: 2 columns
  lg:grid-cols-3    // Desktop: 3 columns
  gap-4
">
```

### Dark mode

```tsx
// Automatic based on system preference
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
```

## Accessibility Checklist

Every component should:
- [ ] Have proper `aria-*` attributes where needed
- [ ] Be keyboard navigable (focus states, tab order)
- [ ] Have sufficient color contrast
- [ ] Include screen reader text for icons/images
- [ ] Handle loading and error states

```tsx
// Good accessibility patterns
<button
  aria-label="Close dialog"
  aria-pressed={isOpen}
  onClick={onClose}
>
  <XIcon aria-hidden="true" />
</button>

<img src={avatar} alt={`${user.name}'s profile picture`} />

<div role="status" aria-live="polite">
  {isLoading ? 'Loading...' : null}
</div>
```

## Testing Components

See the `testing` skill for detailed patterns. Quick reference:

```tsx
// components/atoms/Button.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });
  
  it('calls onClick when clicked', async () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    
    await userEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('shows loading spinner when isLoading', () => {
    render(<Button isLoading>Submit</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

## Common Mistakes to Avoid

❌ **Don't** use `'use client'` at the top of every component
✅ **Do** default to Server Components, add `'use client'` only when needed

❌ **Don't** fetch data in Client Components when Server Components work
✅ **Do** fetch data in Server Components, pass to Client Components as props

❌ **Don't** put all state in a global store
✅ **Do** use the right tool: local state, form state, server state, or shared state

❌ **Don't** forget loading and error states
✅ **Do** handle all states: loading, error, empty, and success

❌ **Don't** ignore accessibility
✅ **Do** use semantic HTML, ARIA attributes, and test with keyboard navigation

❌ **Don't** inline all styles or use magic strings
✅ **Do** use cva for variants, cn for conditional classes
