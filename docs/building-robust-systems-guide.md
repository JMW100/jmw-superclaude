# Building Robust Systems with Claude Code and LLM-Assisted Development

**Claude Code, Anthropic's CLI coding agent, fundamentally changes how solo developers can build production-quality software** by combining agentic AI capabilities with thoughtful architecture patterns, rigorous testing, and automated CI/CD. The key to success lies not just in using the tool, but in structuring your codebase, documentation, and workflows so LLMs can work effectively within bounded contexts. This guide synthesizes best practices across Claude Code configuration, LLM-friendly architecture, testing strategies, and the Next.js/Supabase/Vercel stack to help you ship reliable software faster.

## Claude Code Configuration and the CLAUDE.md System

The foundation of effective Claude Code usage is the **CLAUDE.md file**—a markdown document that serves as persistent memory across sessions. Claude loads these files hierarchically: global settings from `~/.claude/CLAUDE.md`, project-wide context from your repository root, and directory-specific instructions from subdirectories. The key insight is treating CLAUDE.md like a prompt to be refined iteratively—keeping it lean (every line consumes context window), specific ("use 2-space indentation" beats "format code properly"), and actionable.

### What Belongs in Root CLAUDE.md

A well-structured CLAUDE.md for production systems should include:

**Quick Commands**: Build, test, lint, and deploy commands that Claude can run without searching for documentation.

**Architecture Overview**: Brief description of tech stack and folder structure so Claude understands where things live.

**Workflow Process**: For non-trivial changes, define the steps Claude should follow. A proven pattern:

1. **Clarify**: Restate the task, ask clarifying questions if ambiguous
2. **Explore & Plan**: Inspect relevant files, propose a step-by-step plan
3. **Contract-First & TDD**: Define schemas first, write failing tests
4. **Implement**: Make small, focused changes
5. **Verify**: Run typecheck, lint, and tests
6. **Summarize**: Describe changes and tradeoffs

This workflow prevents Claude from making assumptions and diving straight into code that may miss requirements.

**Critical Rules**: Non-negotiable guardrails like "always run typecheck after changes," "never use `any` type," and "always enable RLS on Supabase tables."

**Code Style**: Conventions for imports, variable declarations, async patterns.

The `/init` command auto-generates a starting CLAUDE.md by analyzing your codebase—use it as a baseline, then refine based on actual friction points.

### Context Management

Context management becomes critical during longer sessions. Monitor the context meter and use `/compact` at natural breakpoints rather than waiting for auto-compaction at 95% capacity. Between distinct tasks, `/clear` resets context completely. For complex reasoning, use progressive thinking triggers: "think" allocates baseline thinking budget, "think hard" increases it, "think harder" goes further, and "ultrathink" maximizes reasoning depth for architecture decisions.

## The Skills System: Progressive Disclosure

Skills are folders containing instructions, scripts, and resources that Claude loads dynamically. The key design principle is **progressive disclosure**—showing just enough information to help Claude decide what to do next, then revealing more details as needed.

How it works:
1. **Metadata only (~100 tokens per skill)**: At startup, Claude sees skill names and descriptions
2. **Full instructions (<5k tokens)**: When a skill matches the task, Claude loads the SKILL.md body
3. **Reference files (as needed)**: Detailed documentation, scripts, and templates load only when required

This architecture means you can have many skills available without overwhelming Claude's context window.

### Skill Structure

Each skill requires a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: backend-api
description: "Backend API development with Next.js Route Handlers, Zod validation, 
error handling, and service layer patterns. Use when building API endpoints, 
server actions, or business logic services."
---

# Backend API Development Skill

## When to Use
- Creating or modifying API Route Handlers
- Implementing service layer business logic
- Integrating external APIs (Stripe, etc.)

## Patterns and Examples
[Detailed instructions follow...]
```

The **name** and **description** are critical—they determine when Claude activates the skill. Write descriptions from Claude's perspective, focusing on triggers and capabilities.

### Essential Skills for SaaS Development

A robust setup includes skills for each development phase:

| Skill | Purpose | Key Contents |
|-------|---------|--------------|
| **backend-api** | API routes, services, Stripe | Zod validation, error handling, webhook patterns |
| **database-supabase** | Migrations, RLS, queries | Migration workflow, RLS patterns, type generation |
| **frontend-react** | Components, state, styling | Atomic Design, Server/Client Components, accessibility |
| **testing** | TDD workflow, edge cases | Test patterns per layer, property-based testing |
| **cicd-devops** | Pipelines, deployment | GitHub Actions, Vercel, pre-commit hooks |
| **code-review** | Quality audits | Security checklist, performance review, conventions |

### The Code-Review Skill: A Special Case

The code-review skill deserves special attention because it uses **tool restrictions** to prevent accidental modifications:

```yaml
---
name: code-review
description: "Reviews code for correctness, security, performance, and project 
conventions. Use when asked to review, audit, or check code quality."
allowed-tools: [Read, Grep, Glob]
---
```

By limiting Claude to read-only tools, you get a safe reviewer that can audit code without risk of unintended changes. This is particularly valuable for:
- Security-sensitive features (auth, payments, RLS policies)
- Pre-merge reviews of significant changes
- Auditing code you didn't write yourself

The skill should include structured output format (strengths, issues by priority, suggested tests, refactor suggestions) and security checklists specific to your stack.

## Commands: Macro Buttons for Common Workflows

While skills are **model-invoked** (Claude decides when to use them), commands are **user-invoked** (you explicitly type `/project:command-name`). Commands give you explicit control over which workflow to trigger.

Create commands by adding markdown files to `.claude/commands/`:

```markdown
# .claude/commands/frontend-feature.md

Use the **frontend-react** and **testing** skills for this task.

## Task
Implement a frontend feature: **$ARGUMENTS**

## Process
1. Understand & Plan - Restate feature, identify components, list tests
2. Contract & Types - Define props, decide state management approach
3. TDD - Write React Testing Library tests first, confirm they fail
4. Implement - Build bottom-up (atoms → molecules → organisms → pages)
5. Verify & Summarize - Run tests, summarize changes
```

This becomes available as `/project:frontend-feature <description>`.

**Why commands matter**: They codify your team's (or your own) best practices into repeatable workflows. Instead of remembering to "use the testing skill and follow TDD," you invoke a command that ensures the right process every time.

Recommended commands for SaaS development:
- `/project:frontend-feature` - Chains frontend-react + testing skills
- `/project:backend-feature` - Chains backend-api + database-supabase + testing skills

Keep commands concise—they should reference skills rather than duplicate their content.

## Architecture Patterns That Minimize LLM Context Requirements

**The core principle is small, focused files with clear boundaries.** Keep files under 200-300 lines, enforce single responsibility per module, and structure directories to reflect domain aggregates rather than technical layers. Good modularization limits the number of places where changes occur, reducing the context LLMs need during modifications.

### Recommended Project Structure

```
src/
├── app/                    # App Router (routing only)
│   ├── (routes)/          # Route groups
│   └── api/               # API Route Handlers
├── components/
│   ├── atoms/             # Button, Input, Label
│   ├── molecules/         # FormField, SearchBar
│   └── organisms/         # LoginForm, Header
├── features/
│   └── [feature]/
│       ├── api.ts         # Feature API calls
│       ├── types.ts       # Feature types
│       └── hooks.ts       # Feature hooks
├── lib/                   # Shared utilities
├── types/                 # Global type definitions
└── contracts/             # Zod schemas, API interfaces
docs/
└── decisions/             # Architecture Decision Records
```

### Contract-First Development

Define TypeScript interfaces and Zod schemas **before writing implementation code**. This contract-first approach provides LLMs with explicit specifications that reduce assumption-making.

```typescript
// contracts/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['user', 'admin']).default('user'),
});

// Derive types from schemas (single source of truth)
export type CreateUserInput = z.infer<typeof CreateUserSchema>;
```

When asking Claude to implement a function, providing the schema definition alongside test expectations produces dramatically better results than vague requirements.

**Make contract-first a critical rule**: Add "ALWAYS define or update Zod schemas in `/contracts` BEFORE implementing backend APIs or services" to your CLAUDE.md.

### Task Decomposition

Break features into LLM-manageable chunks. Instead of "build a user dashboard," decompose into:
1. "Define the UserStats schema in contracts/"
2. "Write a service method to aggregate user statistics"
3. "Create the StatsCard atom component"
4. "Build the UserDashboard organism using StatsCard"

Each prompt has clear inputs, outputs, and scope.

## Testing Strategies That Catch Bugs LLMs Typically Miss

**Test-Driven Development and LLMs are highly complementary**—research shows that providing tests leads to higher success rates in code generation. Tests act as guardrails, giving the model concrete specifications to implement against.

### The TDD Workflow with Claude

1. **Define the contract first** (Zod schema + types)
2. **Write failing tests** for the service method
3. **Implement to pass tests** (don't modify tests)
4. **Verify with subagent** - "Use a subagent to verify the implementation isn't overfitting to tests"

### Edge Cases LLMs Commonly Miss

Research identifies consistent gaps in LLM-generated code that require explicit testing:

| Category | Test Cases |
|----------|------------|
| **Boundary values** | Empty string `""`, zero `0`, negative zero `-0`, MAX_SAFE_INTEGER, off-by-one |
| **Null/undefined** | null input, undefined input, missing object properties |
| **Special strings** | Unicode, emoji, very long (10k+ chars), whitespace only, SQL injection attempts |
| **Async issues** | Timeout handling, concurrent requests, request cancellation, out-of-order responses |

### Property-Based Testing

Combine example-based testing with property-based testing using fast-check—this combination achieves significantly higher bug detection than either approach alone:

```typescript
import fc from 'fast-check';

it('sort is idempotent', () => {
  fc.assert(
    fc.property(fc.array(fc.integer()), (arr) => {
      const sorted = [...arr].sort((a, b) => a - b);
      const sortedTwice = [...sorted].sort((a, b) => a - b);
      return JSON.stringify(sorted) === JSON.stringify(sortedTwice);
    })
  );
});
```

Property-based testing generates thousands of random inputs to find edge cases humans (and LLMs) miss.

### Testing Pyramid

- **Unit tests (Jest + React Testing Library)**: Test component behavior, not implementation. Mock at boundaries only.
- **API tests (Supertest)**: Validate endpoint contracts, authentication flows, error responses.
- **Contract validation (Zod)**: Validate response schemas at runtime and in tests.
- **E2E tests (Playwright)**: Test critical user journeys only (they're expensive).

Target 80%+ unit test coverage, integration tests for key flows, E2E for critical paths.

## Documentation That Helps LLMs Understand Your Codebase

**Document intent, not mechanics**—LLMs can read code but need context about why decisions were made.

### JSDoc with Examples

JSDoc with `@example` blocks is crucial because LLMs learn patterns from concrete examples:

```typescript
/**
 * Calculates total price with tax
 * @param price - Base price in cents
 * @param taxRate - Tax rate as decimal (0.08 for 8%)
 * @returns Total price including tax
 * @example
 * const total = calculateTotal(1000, 0.08); // Returns 1080
 * @throws {Error} If price is negative
 */
function calculateTotal(price: number, taxRate: number): number {
  if (price < 0) throw new Error('Price cannot be negative');
  return Math.round(price * (1 + taxRate));
}
```

### Architecture Decision Records (ADRs)

ADRs document the "why" behind architectural choices, providing context LLMs need to make consistent decisions:

```markdown
# ADR-001: Use Supabase (PostgreSQL) with Row Level Security

## Status
Accepted

## Context
We need a database supporting complex queries, real-time subscriptions, 
and fine-grained access control with minimal operational overhead.

## Decision
Use Supabase with RLS policies for access control at the database level.

## Consequences
**Positive**: Security by default, type safety, real-time built-in
**Negative**: Vendor lock-in, RLS learning curve
```

Store ADRs in `/docs/decisions/` with consistent naming like `adr-001-database-choice.md`. Keep them immutable—add new ADRs to supersede old ones rather than editing history.

ADRs are valuable because:
- They capture context that would otherwise be lost
- Claude can read them to understand constraints and tradeoffs
- They prevent re-litigating decisions that were already made thoughtfully

## CI/CD Pipeline for Solo Developers

### Pre-commit Hooks

Catch issues before they enter the repository using Husky and lint-staged:

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["prettier --write", "eslint --fix"],
    "*.{json,md,css}": ["prettier --write"]
  }
}
```

Add a pre-push hook for tests to prevent broken code from reaching the repository.

### GitHub Actions Workflow

A minimal effective setup for Next.js/Supabase/Vercel:

1. **Quality job**: ESLint, TypeScript check, Prettier
2. **Test job**: Jest with coverage
3. **Build job**: Production build verification
4. **E2E job** (PRs only): Playwright tests

### Database Migration Workflow

1. Create migration: `npx supabase migration new feature_name`
2. Write SQL with RLS policies (always enable RLS)
3. Test locally: `npx supabase db reset`
4. Generate types: `npm run db:types`
5. Commit migration + types
6. GitHub Action applies migration on merge

## Stack-Specific Patterns

### Next.js App Router

- **Server Components by default**: Fetch data directly, no API routes needed for reads
- **Client Components only for interactivity**: useState, useEffect, event handlers
- **Wrap async components in Suspense**: Enable streaming

Common mistake: Calling Route Handlers from Server Components creates unnecessary network hops.

### Supabase Row Level Security

**Non-negotiable**: Enable RLS on every table. Tables without RLS are accessible to anyone with the anon key.

```sql
-- Always wrap auth.uid() in subquery for performance
CREATE POLICY "Users can view own data"
  ON posts FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);
```

### Stripe Webhooks

Always verify signatures and handle only expected events:

```typescript
const event = stripe.webhooks.constructEvent(
  body,
  signature,
  process.env.STRIPE_WEBHOOK_SECRET!
);
```

## What Not to Include (and Why)

Effective configuration requires knowing what to leave out:

**Skip llms.txt**: While it's an emerging standard for LLM-friendly documentation, Claude Code already knows where your skills and CLAUDE.md files are. Adding llms.txt creates maintenance overhead without clear benefit for Claude Code specifically.

**Keep commands concise**: Commands should reference skills, not duplicate them. A 25-line command that says "use the backend-api and testing skills" is better than a 60-line command that copies content from those skills.

**Don't over-document in CLAUDE.md**: If you find yourself adding pages of instructions to CLAUDE.md, it probably belongs in a skill that loads on-demand.

**Avoid prescriptive workflows for trivial changes**: The 6-step workflow (Clarify → Plan → TDD → Implement → Verify → Summarize) is for non-trivial changes. For typo fixes or simple additions, Claude should just do the work.

## Putting It All Together

The practices outlined here—lean CLAUDE.md files, contract-first development, comprehensive testing with edge case coverage, automated CI/CD, structured documentation with ADRs, and phase-specific skills with commands—create a foundation where LLM-assisted development amplifies your capabilities rather than introducing chaos.

### Quick Start Checklist

1. **Initialize Claude Code**: Run `/init` to generate baseline CLAUDE.md
2. **Add workflow section**: Define your process for non-trivial changes
3. **Install skills**: Copy skills to `.claude/skills/` in your project
4. **Add commands**: Create `.claude/commands/` for common workflows
5. **Set up CI/CD**: GitHub Actions + Husky pre-commit hooks
6. **Create first ADRs**: Document your database and frontend architecture choices
7. **Iterate**: Refine based on friction points

### The Mental Model

Think of this setup as creating a **well-documented workspace for a brilliant but context-limited collaborator**. Claude can do amazing work, but it needs:
- Clear boundaries (skills, architecture)
- Explicit processes (workflow, TDD)
- Safety nets (tests, type checking, code review)
- Context about decisions (ADRs, contracts)

Start with the basics, iterate based on friction points, and let the tooling evolve alongside your project. The investment in structure pays dividends as your codebase grows.
