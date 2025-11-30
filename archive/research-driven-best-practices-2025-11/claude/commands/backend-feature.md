Use the **backend-api**, **database-supabase**, and **testing** skills for this task.

## Task
Implement a backend feature: **$ARGUMENTS**

## Process

### 1. Understand & Plan
- Restate the feature and acceptance criteria
- Identify what's needed:
  - Zod schemas in `/contracts` to define or update
  - Services and repositories to touch
  - Database migrations or RLS policies
  - API Route Handlers
- Present plan and wait for confirmation if complex

### 2. Contract-First
- Define/update Zod schemas in `/contracts`
- Derive TypeScript types from schemas
- Define input validation, output shapes, and error cases

### 3. Database (if needed)
- Create migration: `npx supabase migration new <name>`
- Write SQL with RLS policies (always enable RLS)
- Test locally: `npx supabase db reset`
- Generate types: `npm run db:types`

### 4. TDD
- Write Jest tests for service methods first
- Write Supertest tests for API routes
- Consider fast-check property tests for core logic
- Run tests, confirm they fail

### 5. Implement
- Repository layer: data access only (using `database-supabase` patterns)
- Service layer: business logic
- Route Handler: HTTP concerns only, delegates to service
- Follow error handling patterns from `backend-api` skill

### 6. Verify & Summarize
- Run `npm run test`, `npm run typecheck`, `npm run lint`
- Summarize: endpoints created, tests added, migrations, RLS policies
