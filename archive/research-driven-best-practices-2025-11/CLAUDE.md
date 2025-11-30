# Project: SaaS Application

## Quick Commands
```bash
npm run dev          # Development server (Next.js)
npm run build        # Production build
npm run typecheck    # TypeScript validation (RUN AFTER CODE CHANGES)
npm run lint         # ESLint
npm run test         # Jest unit tests
npm run test:e2e     # Playwright E2E tests
npx supabase db push # Deploy database migrations
```

## Tech Stack
- **Frontend**: Next.js 14 (App Router), React, TypeScript, Tailwind CSS
- **Backend**: Next.js API Routes + Server Actions
- **Database**: Supabase (PostgreSQL + Row Level Security)
- **Payments**: Stripe
- **Deployment**: Vercel
- **Testing**: Jest, React Testing Library, Playwright

## Architecture Overview
```
src/
├── app/              # Next.js App Router (routes + API)
├── components/       # React components (atoms → molecules → organisms)
├── features/         # Feature modules (co-located logic)
├── lib/              # Shared utilities, clients (supabase.ts, stripe.ts)
├── types/            # Global TypeScript interfaces
└── contracts/        # Zod schemas for API validation
docs/
└── decisions/        # Architecture Decision Records (ADRs)
```

## Workflow (For Non-Trivial Changes)

1. **Clarify**: Restate the task. Ask clarifying questions if requirements are ambiguous.

2. **Explore & Plan**: Inspect relevant files. Propose a step-by-step plan (files to touch, tests to add). For complex changes, wait for confirmation before coding.

3. **Contract-First & TDD**: Define/update Zod schemas in `contracts/` first. Write failing tests. Use the `testing` skill for edge cases.

4. **Implement**: Make small, focused changes. Keep modules single-responsibility.

5. **Verify**: Run `npm run typecheck`, `npm run lint`, and relevant tests. Fix all failures.

6. **Summarize**: Describe changes, tests added, and any tradeoffs. Use conventional commit format.

For trivial changes (typos, simple additions), skip to implement and verify.

## CRITICAL Rules (Always Follow)

### Contract-First Development
- ALWAYS define or update Zod schemas and TypeScript types in `/contracts` BEFORE implementing backend APIs or services
- Types flow from schemas: `type X = z.infer<typeof XSchema>`

### Code Quality
- YOU MUST run `npm run typecheck` after making code changes
- ALWAYS validate API inputs with Zod schemas before processing
- NEVER use `any` type - use `unknown` and narrow with type guards
- Use absolute imports from `@/` (e.g., `@/lib/supabase`)

### Testing
- Write tests BEFORE implementation (TDD)
- Include edge cases: empty arrays, null, undefined, boundary values
- Test file naming: `*.test.ts` or `*.test.tsx` alongside source

### Security
- NEVER commit secrets or API keys
- ALWAYS use environment variables for sensitive config
- Supabase: ALWAYS enable RLS on tables, write policies first
- Stripe: ALWAYS verify webhook signatures

### Git Workflow
- Commit messages: `type(scope): description` (e.g., `feat(auth): add OAuth flow`)
- One logical change per commit
- Run typecheck and tests before committing

## Code Style
- ES modules (`import`/`export`), not CommonJS (`require`)
- Destructure imports: `import { useState } from 'react'`
- Prefer `const` over `let`, never `var`
- Use async/await, not raw Promises with `.then()`
- Server Components by default, `'use client'` only when needed

## Available Skills
Claude has specialized skills that activate automatically based on context:

- **backend-api**: Zod validation, Route Handlers, service layer, Stripe webhooks
- **database-supabase**: Migrations, RLS policies, type generation, queries
- **frontend-react**: Atomic Design, Server/Client Components, state management
- **testing**: TDD workflow, edge cases, property-based testing, test patterns
- **cicd-devops**: GitHub Actions, Vercel, pre-commit hooks
- **code-review**: Security, correctness, performance audits (read-only)

## Custom Commands
- `/project:frontend-feature <description>` - Guided frontend feature development
- `/project:backend-feature <description>` - Guided backend feature development

## Response Style
- Explain the "why" behind decisions (I'm learning)
- Show one complete example before variations
- Flag potential gotchas or common mistakes
- Keep explanations focused on the current task
