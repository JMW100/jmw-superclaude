---
name: code-review
description: "Reviews code for correctness, security, performance, and project conventions. Use when asked to review, audit, or check code quality. Read-only - does not modify files."
allowed-tools: [Read, Grep, Glob]
---

# Code Review Skill

## When to Activate
- When asked to "review", "audit", or "check" code
- Before merging significant changes or refactors
- After implementing security-sensitive features (auth, payments, RLS)

## When NOT to Use
- Trivial changes (typos, formatting)
- Code that was just reviewed
- When the user wants immediate implementation, not review

## Review Process

### 1. Scope & Context
- Use Glob to locate relevant files (tests, implementations, contracts)
- Read related Zod schemas in `contracts/`, services, and existing tests
- Understand what the code is supposed to do before judging it

### 2. Correctness
- Does behavior match contracts and tests?
- Are edge cases handled? Check for:
  - Null/undefined inputs
  - Empty arrays/strings
  - Boundary values (0, -1, MAX_INT)
  - Async race conditions
- Are error states handled gracefully?

### 3. Security
- **Input validation**: Are all inputs validated with Zod before use?
- **Secrets**: No hardcoded keys, tokens, or passwords?
- **Supabase RLS**: 
  - Is RLS enabled on the table?
  - Do policies match intended access patterns?
  - Is `auth.uid()` wrapped in a subquery for performance?
- **Stripe webhooks**:
  - Is signature verified with `constructEvent()`?
  - Are only expected event types handled?
- **SQL injection**: Using parameterized queries, not string concatenation?

### 4. Performance
- N+1 queries: Are there loops that make database calls?
- Missing indexes: Are filtered/joined columns indexed?
- Unnecessary fetches: Is data fetched that isn't used?
- Client bundle: Are large dependencies imported in Client Components?

### 5. Conventions & Architecture
- **Types**: No `any`, proper null handling, strict TypeScript?
- **Layered architecture**: Business logic in services, not Route Handlers?
- **Atomic Design**: Components at appropriate level (atom/molecule/organism)?
- **Single responsibility**: Each function/component doing one thing?
- **Naming**: Clear, intention-revealing names?

## Output Format

Provide a structured review:

```
## Review: [File/Feature Name]

### ✅ Strengths
- [What's done well]

### ⚠️ Issues (by priority)

**High:**
- [Security or correctness issues]

**Medium:**
- [Performance or maintainability issues]

**Low:**
- [Style or minor improvements]

### 🧪 Suggested Tests
- [Specific test cases to add]

### 🛠 Refactor Suggestions
- [Concrete code improvements with examples]
```

## Security Checklist Quick Reference

```
□ All API inputs validated with Zod
□ No secrets in code (use env vars)
□ RLS enabled on all Supabase tables
□ RLS policies use (SELECT auth.uid()) pattern
□ Stripe webhooks verify signatures
□ No raw SQL string concatenation
□ Sensitive data not logged
□ Auth checks before data access
```

## Common Issues to Flag

### Backend
- Business logic in Route Handlers (should be in services)
- Missing error handling (bare try/catch with no useful response)
- Returning raw database errors to clients
- Not validating request body before use

### Frontend
- `'use client'` on components that don't need it
- Fetching data in Client Components when Server Components work
- Missing loading/error states
- Accessibility issues (no labels, missing ARIA)

### Database
- Tables without RLS enabled
- Missing indexes on foreign keys
- Overly permissive RLS policies
- Not using transactions for multi-step operations

### Testing
- Tests that test implementation, not behavior
- Missing edge case coverage
- Mocking too much (testing mocks, not code)
- No tests for error paths
