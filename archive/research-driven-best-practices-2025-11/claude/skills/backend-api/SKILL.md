---
name: backend-api
description: "Backend API development with Next.js Route Handlers, Zod validation, error handling, and service layer patterns. Use when building API endpoints, server actions, business logic services, or working with external APIs like Stripe."
---

# Backend API Development Skill

## When to Use
- Creating or modifying API Route Handlers (`app/api/*/route.ts`)
- Building Server Actions
- Implementing service layer business logic
- Integrating external APIs (Stripe, etc.)
- Handling authentication/authorization logic

## Architecture Pattern

```
API Route Handler → Validation (Zod) → Service → Repository → Database
```

Each layer has a single responsibility:
- **Route Handler**: HTTP concerns only (parse request, call service, format response)
- **Service**: Business logic, orchestration, domain rules
- **Repository**: Data access, CRUD operations

## API Route Handler Pattern

ALWAYS follow this structure for Route Handlers:

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { UserService } from '@/features/users/service';

// 1. Define schema FIRST (contract-first development)
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
});

// 2. Type derived from schema (single source of truth)
type CreateUserInput = z.infer<typeof CreateUserSchema>;

export async function POST(request: NextRequest) {
  try {
    // 3. Parse and validate input
    const body = await request.json();
    const result = CreateUserSchema.safeParse(body);
    
    if (!result.success) {
      return NextResponse.json(
        { error: 'Validation failed', details: result.error.flatten() },
        { status: 400 }
      );
    }
    
    // 4. Call service (business logic lives there, not here)
    const user = await UserService.createUser(result.data);
    
    // 5. Return response
    return NextResponse.json(user, { status: 201 });
    
  } catch (error) {
    // 6. Centralized error handling
    return handleApiError(error);
  }
}
```

## Zod Schema Best Practices

### Define schemas in `/contracts` for shared types:

```typescript
// contracts/user.ts
import { z } from 'zod';

export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['user', 'admin']),
  createdAt: z.string().datetime(),
});

export const CreateUserSchema = UserSchema.omit({ 
  id: true, 
  createdAt: true 
});

export const UpdateUserSchema = CreateUserSchema.partial();

// Derive types from schemas
export type User = z.infer<typeof UserSchema>;
export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type UpdateUserInput = z.infer<typeof UpdateUserSchema>;
```

### Common Zod patterns:

```typescript
// Coerce string to number (for query params)
const pageSchema = z.coerce.number().int().positive().default(1);

// Transform and validate
const slugSchema = z.string().transform(s => s.toLowerCase().replace(/\s+/g, '-'));

// Discriminated unions for polymorphic data
const EventSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('click'), x: z.number(), y: z.number() }),
  z.object({ type: z.literal('scroll'), position: z.number() }),
]);

// Refine for custom validation
const PasswordSchema = z.string()
  .min(8)
  .refine(p => /[A-Z]/.test(p), 'Must contain uppercase')
  .refine(p => /[0-9]/.test(p), 'Must contain number');
```

## Service Layer Pattern

Services contain business logic and are framework-agnostic:

```typescript
// features/users/service.ts
import { db } from '@/lib/supabase';
import type { CreateUserInput, User } from '@/contracts/user';

export class UserService {
  static async createUser(input: CreateUserInput): Promise<User> {
    // Business rule: check for existing user
    const existing = await db.from('users')
      .select('id')
      .eq('email', input.email)
      .single();
    
    if (existing.data) {
      throw new ConflictError('User with this email already exists');
    }
    
    // Create user
    const { data, error } = await db.from('users')
      .insert(input)
      .select()
      .single();
    
    if (error) throw new DatabaseError(error.message);
    
    return data;
  }
  
  static async getUserById(id: string): Promise<User | null> {
    const { data, error } = await db.from('users')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error?.code === 'PGRST116') return null; // Not found
    if (error) throw new DatabaseError(error.message);
    
    return data;
  }
}
```

## Error Handling

### Define custom error classes:

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR'
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 409, 'CONFLICT');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED');
  }
}
```

### Centralized error handler:

```typescript
// lib/api-utils.ts
import { NextResponse } from 'next/server';
import { AppError } from './errors';

export function handleApiError(error: unknown) {
  console.error('API Error:', error);
  
  if (error instanceof AppError) {
    return NextResponse.json(
      { error: error.message, code: error.code },
      { status: error.statusCode }
    );
  }
  
  // Don't leak internal errors to client
  return NextResponse.json(
    { error: 'Internal server error', code: 'INTERNAL_ERROR' },
    { status: 500 }
  );
}
```

## Stripe Integration Pattern

### Webhook handler:

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from 'next/headers';
import { NextResponse } from 'next/server';
import Stripe from 'stripe';
import { stripe } from '@/lib/stripe';

export async function POST(request: Request) {
  const body = await request.text();
  const signature = (await headers()).get('stripe-signature')!;
  
  let event: Stripe.Event;
  
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    console.error('Webhook signature verification failed');
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }
  
  // Handle events
  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object as Stripe.Checkout.Session;
      await handleCheckoutComplete(session);
      break;
    }
    case 'customer.subscription.updated': {
      const subscription = event.data.object as Stripe.Subscription;
      await handleSubscriptionUpdate(subscription);
      break;
    }
    // Add more event handlers
  }
  
  return NextResponse.json({ received: true });
}

async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId;
  if (!userId) {
    console.error('No userId in checkout metadata');
    return;
  }
  
  await UserService.updateSubscription(userId, {
    stripeCustomerId: session.customer as string,
    subscriptionId: session.subscription as string,
    status: 'active',
  });
}
```

## Server Actions Pattern

Use for mutations that need client-side optimistic updates:

```typescript
// features/posts/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import { PostService } from './service';

const CreatePostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1),
});

export async function createPost(formData: FormData) {
  const result = CreatePostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
  });
  
  if (!result.success) {
    return { error: result.error.flatten() };
  }
  
  try {
    const post = await PostService.create(result.data);
    revalidatePath('/posts');
    return { data: post };
  } catch (error) {
    return { error: 'Failed to create post' };
  }
}
```

## TDD Workflow for Backend

1. **Define the contract first** (Zod schema + types)
2. **Write failing tests** for the service method
3. **Implement the service** to pass tests
4. **Write Route Handler tests** (integration)
5. **Implement the Route Handler**

See the `testing` skill for detailed test patterns.

## Common Mistakes to Avoid

❌ **Don't** put business logic in Route Handlers
✅ **Do** keep Route Handlers thin, delegate to services

❌ **Don't** use `any` for request bodies
✅ **Do** validate everything with Zod

❌ **Don't** return raw database errors to clients
✅ **Do** use custom error classes and sanitize responses

❌ **Don't** hardcode IDs or secrets
✅ **Do** use environment variables and pass IDs through metadata

❌ **Don't** skip error handling "for now"
✅ **Do** handle errors from the start with proper status codes
