# ADR-002: Use Next.js App Router with Server Components

## Status
Accepted

## Date
2024-01-15

## Context
We need a frontend framework that supports:
- Server-side rendering for SEO and performance
- Type-safe data fetching
- Easy deployment
- Good developer experience for a solo developer
- Integration with our Supabase backend

## Decision
Use Next.js 14 with the App Router, defaulting to Server Components.

Key patterns:
- **Server Components by default**: Fetch data directly, no API routes needed for reads
- **Client Components only when necessary**: useState, useEffect, event handlers, browser APIs
- **Streaming with Suspense**: Wrap async components for progressive loading
- **Server Actions for mutations**: Type-safe form handling without manual API routes

## Consequences

### Positive
- **Reduced client JavaScript**: Server Components don't ship JS to browser
- **Simplified data fetching**: Direct database access in components, no fetch waterfalls
- **Automatic caching**: Built-in request deduplication and caching
- **Vercel integration**: Zero-config deployment with preview environments
- **Type safety end-to-end**: TypeScript from database types to rendered components

### Negative
- **Mental model shift**: Must understand Server vs Client Component boundaries
- **Newer patterns**: Less community content compared to Pages Router
- **Debugging complexity**: Errors can occur on server or client, different stack traces
- **Hydration mismatches**: Must be careful about client-only code in shared components

### Neutral
- Learning curve for developers familiar with traditional React SPA patterns
- Some third-party libraries not yet compatible with Server Components

## Alternatives Considered

- **Next.js Pages Router**: More established, but Server Components are the future. Better to learn new patterns now.

- **Remix**: Excellent patterns, similar philosophy. Chose Next.js for larger ecosystem and Vercel deployment simplicity.

- **SvelteKit**: Great DX, smaller bundles. But smaller ecosystem and would need to learn new framework.

- **Create React App + Express**: Full control, but requires manual SSR setup, deployment configuration, and more infrastructure code.
