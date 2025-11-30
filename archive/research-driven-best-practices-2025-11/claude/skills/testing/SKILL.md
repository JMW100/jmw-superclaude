---
name: testing
description: "Test-Driven Development workflows with Jest, React Testing Library, Supertest, and Playwright. Covers TDD process, edge case patterns, property-based testing, and test organization. Use when writing tests, setting up test infrastructure, or following TDD workflow."
---

# Testing Skill

## When to Use
- Starting new feature development (TDD workflow)
- Writing unit tests for services/utilities
- Testing React components
- Testing API Route Handlers
- Writing E2E tests for user journeys
- Catching edge cases LLMs typically miss

## TDD Workflow with Claude

Follow this explicit process for robust code:

### Step 1: Define the Contract

```typescript
// contracts/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
```

### Step 2: Write Failing Tests First

**Prompt to Claude:**
> "Write tests for UserService.createUser that handles: success case, duplicate email, validation errors. We're doing TDD - don't create mock implementations yet."

```typescript
// features/users/service.test.ts
import { UserService } from './service';
import { resetDatabase, createTestUser } from '@/tests/helpers';

describe('UserService.createUser', () => {
  beforeEach(async () => {
    await resetDatabase();
  });

  it('creates a user with valid input', async () => {
    const input = { email: 'test@example.com', name: 'Test User' };
    
    const user = await UserService.createUser(input);
    
    expect(user).toMatchObject({
      email: 'test@example.com',
      name: 'Test User',
    });
    expect(user.id).toBeDefined();
    expect(user.createdAt).toBeDefined();
  });

  it('throws ConflictError for duplicate email', async () => {
    await createTestUser({ email: 'existing@example.com' });
    
    await expect(
      UserService.createUser({ 
        email: 'existing@example.com', 
        name: 'New User' 
      })
    ).rejects.toThrow('User with this email already exists');
  });

  // Edge cases LLMs often miss
  it('handles email with unusual but valid format', async () => {
    const input = { email: 'user+tag@sub.domain.com', name: 'Test' };
    const user = await UserService.createUser(input);
    expect(user.email).toBe('user+tag@sub.domain.com');
  });

  it('trims whitespace from name', async () => {
    const input = { email: 'test@example.com', name: '  Padded Name  ' };
    const user = await UserService.createUser(input);
    expect(user.name).toBe('Padded Name');
  });
});
```

### Step 3: Confirm Tests Fail

**Prompt to Claude:**
> "Run the tests and confirm they fail. Don't write implementation yet."

```bash
npm run test -- features/users/service.test.ts
```

### Step 4: Implement to Pass Tests

**Prompt to Claude:**
> "Write code to pass the tests. Don't modify the tests. Keep going until all tests pass."

### Step 5: Verify Implementation

**Prompt to Claude:**
> "Use a subagent to verify the implementation isn't overfitting to tests - check for edge cases we might have missed."

## Edge Cases LLMs Commonly Miss

ALWAYS include tests for these patterns:

### Boundary Values

```typescript
describe('boundary values', () => {
  // Empty inputs
  it('handles empty string', () => {
    expect(parseAmount('')).toBe(0);
  });
  
  it('handles empty array', () => {
    expect(calculateAverage([])).toBe(0);
  });
  
  // Numeric boundaries
  it('handles zero', () => {
    expect(divide(10, 0)).toThrow('Division by zero');
  });
  
  it('handles negative numbers', () => {
    expect(absoluteValue(-5)).toBe(5);
  });
  
  it('handles MAX_SAFE_INTEGER', () => {
    expect(increment(Number.MAX_SAFE_INTEGER)).toBe(Number.MAX_SAFE_INTEGER + 1);
  });
  
  // Off-by-one
  it('includes boundary in range', () => {
    expect(isInRange(10, 1, 10)).toBe(true); // Is 10 included?
  });
});
```

### Null/Undefined Handling

```typescript
describe('null/undefined handling', () => {
  it('handles null input', () => {
    expect(formatName(null)).toBe('');
  });
  
  it('handles undefined input', () => {
    expect(formatName(undefined)).toBe('');
  });
  
  it('handles object with missing properties', () => {
    const partial = { name: 'Test' }; // missing email
    expect(() => processUser(partial as User)).toThrow();
  });
});
```

### Special String Inputs

```typescript
describe('special string inputs', () => {
  it('handles Unicode characters', () => {
    expect(slugify('Café München')).toBe('cafe-munchen');
  });
  
  it('handles emoji', () => {
    expect(stripEmoji('Hello 👋 World')).toBe('Hello  World');
  });
  
  it('handles very long strings', () => {
    const longString = 'a'.repeat(10000);
    expect(truncate(longString, 100)).toHaveLength(100);
  });
  
  it('handles strings with only whitespace', () => {
    expect(isEmpty('   \t\n  ')).toBe(true);
  });
  
  it('handles SQL injection attempts', () => {
    const malicious = "'; DROP TABLE users; --";
    expect(sanitize(malicious)).not.toContain('DROP');
  });
});
```

### Async Edge Cases

```typescript
describe('async edge cases', () => {
  it('handles timeout', async () => {
    jest.useFakeTimers();
    
    const promise = fetchWithTimeout(url, 5000);
    jest.advanceTimersByTime(5001);
    
    await expect(promise).rejects.toThrow('Timeout');
  });
  
  it('handles concurrent requests correctly', async () => {
    const results = await Promise.all([
      incrementCounter(),
      incrementCounter(),
      incrementCounter(),
    ]);
    
    expect(await getCounter()).toBe(3); // Not 1!
  });
  
  it('handles request cancellation', async () => {
    const controller = new AbortController();
    const promise = fetchData({ signal: controller.signal });
    
    controller.abort();
    
    await expect(promise).rejects.toThrow('aborted');
  });
});
```

## Property-Based Testing with fast-check

Complements example-based tests by generating thousands of random inputs:

```typescript
import fc from 'fast-check';

describe('property-based tests', () => {
  // Idempotency: applying twice equals applying once
  it('sort is idempotent', () => {
    fc.assert(
      fc.property(fc.array(fc.integer()), (arr) => {
        const sorted = [...arr].sort((a, b) => a - b);
        const sortedTwice = [...sorted].sort((a, b) => a - b);
        return JSON.stringify(sorted) === JSON.stringify(sortedTwice);
      })
    );
  });
  
  // Reversibility: operation can be undone
  it('encode/decode are inverse operations', () => {
    fc.assert(
      fc.property(fc.string(), (str) => {
        return decode(encode(str)) === str;
      })
    );
  });
  
  // Invariant: property that always holds
  it('array length unchanged by map', () => {
    fc.assert(
      fc.property(
        fc.array(fc.integer()),
        fc.func(fc.integer()),
        (arr, fn) => arr.map(fn).length === arr.length
      )
    );
  });
  
  // Model-based: compare against simple reference
  it('optimized sort matches simple sort', () => {
    fc.assert(
      fc.property(fc.array(fc.integer()), (arr) => {
        const optimized = quickSort([...arr]);
        const reference = [...arr].sort((a, b) => a - b);
        return JSON.stringify(optimized) === JSON.stringify(reference);
      })
    );
  });
});
```

## Testing React Components

### Unit Testing Components

```typescript
// components/atoms/Button.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });
  
  it('applies variant classes', () => {
    render(<Button variant="destructive">Delete</Button>);
    expect(screen.getByRole('button')).toHaveClass('bg-red-600');
  });
  
  it('calls onClick handler', async () => {
    const user = userEvent.setup();
    const handleClick = jest.fn();
    
    render(<Button onClick={handleClick}>Click</Button>);
    await user.click(screen.getByRole('button'));
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('is disabled when isLoading', () => {
    render(<Button isLoading>Submit</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
  
  it('shows loading spinner when isLoading', () => {
    render(<Button isLoading>Submit</Button>);
    expect(screen.getByRole('button').querySelector('.animate-spin')).toBeInTheDocument();
  });
});
```

### Testing Forms

```typescript
// components/organisms/LoginForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  const mockSubmit = jest.fn();
  
  beforeEach(() => {
    mockSubmit.mockClear();
  });
  
  it('submits with valid data', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    await waitFor(() => {
      expect(mockSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
  
  it('shows validation errors for invalid email', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'invalid-email');
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    expect(await screen.findByText(/valid email/i)).toBeInTheDocument();
    expect(mockSubmit).not.toHaveBeenCalled();
  });
  
  it('shows validation error for short password', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'short');
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    expect(await screen.findByText(/at least 8 characters/i)).toBeInTheDocument();
  });
  
  it('disables submit while loading', async () => {
    const user = userEvent.setup();
    mockSubmit.mockImplementation(() => new Promise(() => {})); // Never resolves
    
    render(<LoginForm onSubmit={mockSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    
    await waitFor(() => {
      expect(screen.getByRole('button', { name: /sign in/i })).toBeDisabled();
    });
  });
});
```

## Testing API Routes

```typescript
// app/api/users/route.test.ts
import { POST, GET } from './route';
import { NextRequest } from 'next/server';
import { resetDatabase, createTestUser } from '@/tests/helpers';

describe('POST /api/users', () => {
  beforeEach(async () => {
    await resetDatabase();
  });
  
  it('creates user with valid input', async () => {
    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ email: 'new@example.com', name: 'New User' }),
    });
    
    const response = await POST(request);
    const data = await response.json();
    
    expect(response.status).toBe(201);
    expect(data).toMatchObject({
      email: 'new@example.com',
      name: 'New User',
    });
  });
  
  it('returns 400 for invalid email', async () => {
    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ email: 'invalid', name: 'Test' }),
    });
    
    const response = await POST(request);
    const data = await response.json();
    
    expect(response.status).toBe(400);
    expect(data.error).toBe('Validation failed');
  });
  
  it('returns 409 for duplicate email', async () => {
    await createTestUser({ email: 'existing@example.com' });
    
    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ email: 'existing@example.com', name: 'Test' }),
    });
    
    const response = await POST(request);
    
    expect(response.status).toBe(409);
  });
});
```

## E2E Testing with Playwright

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('user can sign up and sign in', async ({ page }) => {
    // Sign up
    await page.goto('/signup');
    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'securePassword123');
    await page.fill('[name="name"]', 'New User');
    await page.click('button[type="submit"]');
    
    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('text=Welcome, New User')).toBeVisible();
    
    // Sign out
    await page.click('button:has-text("Sign Out")');
    await expect(page).toHaveURL('/');
    
    // Sign in
    await page.goto('/login');
    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'securePassword123');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL('/dashboard');
  });
  
  test('shows error for invalid credentials', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[name="email"]', 'wrong@example.com');
    await page.fill('[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');
    
    await expect(page.locator('text=Invalid email or password')).toBeVisible();
    await expect(page).toHaveURL('/login');
  });
});
```

## Test Helpers Setup

```typescript
// tests/helpers/index.ts
import { supabase } from '@/lib/supabase';

export async function resetDatabase() {
  // Truncate in dependency order
  await supabase.from('posts').delete().neq('id', '');
  await supabase.from('users').delete().neq('id', '');
}

export async function createTestUser(overrides: Partial<User> = {}) {
  const defaults = {
    email: `test-${Date.now()}@example.com`,
    name: 'Test User',
    role: 'user',
  };
  
  const { data, error } = await supabase
    .from('users')
    .insert({ ...defaults, ...overrides })
    .select()
    .single();
  
  if (error) throw error;
  return data;
}

export async function createTestPost(userId: string, overrides: Partial<Post> = {}) {
  const defaults = {
    title: 'Test Post',
    content: 'Test content',
    user_id: userId,
    published: false,
  };
  
  const { data, error } = await supabase
    .from('posts')
    .insert({ ...defaults, ...overrides })
    .select()
    .single();
  
  if (error) throw error;
  return data;
}
```

## Jest Configuration

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

```typescript
// tests/setup.ts
import '@testing-library/jest-dom';

// Mock next/navigation
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
  useSearchParams: () => new URLSearchParams(),
  usePathname: () => '/',
}));
```

## Common Testing Mistakes to Avoid

❌ **Don't** test implementation details
✅ **Do** test behavior from user's perspective

❌ **Don't** forget to test error states
✅ **Do** test loading, error, empty, and success states

❌ **Don't** write tests after implementation
✅ **Do** write tests first (TDD), then implement

❌ **Don't** rely only on example-based tests
✅ **Do** combine with property-based testing for edge cases

❌ **Don't** mock everything
✅ **Do** use real implementations where practical, mock at boundaries
