# ADR-001: Use Supabase (PostgreSQL) with Row Level Security

## Status
Accepted

## Date
2024-01-15

## Context
We need a database solution for our SaaS application that supports:
- Complex relational queries
- Real-time subscriptions for live updates
- Built-in authentication
- Fine-grained access control
- Minimal operational overhead for a solo developer

## Decision
Use Supabase as our primary database, which provides:
- Managed PostgreSQL with automatic backups
- Row Level Security (RLS) for access control at the database level
- Built-in Auth with multiple providers
- Real-time subscriptions via WebSockets
- Auto-generated TypeScript types from schema
- Local development environment via CLI

## Consequences

### Positive
- **Security by default**: RLS policies enforce access control regardless of application bugs
- **Type safety**: Generated types ensure frontend/backend stay in sync with schema
- **Real-time built-in**: No need to build separate WebSocket infrastructure
- **Generous free tier**: Sufficient for MVP and early customers
- **Local dev parity**: `supabase start` runs identical stack locally

### Negative
- **Vendor lock-in**: RLS policies and Auth are Supabase-specific patterns
- **Learning curve**: RLS policy syntax requires understanding PostgreSQL
- **Cold starts**: Paused projects on free tier have startup delay
- **Limited regions**: Fewer deployment regions than major cloud providers

### Neutral
- Need to manage migrations carefully (can't easily undo destructive changes)
- Must regenerate types after schema changes

## Alternatives Considered

- **PlanetScale (MySQL)**: Excellent scaling, but no row-level security built-in. Would need application-level access control.

- **Firebase/Firestore**: Great real-time, but NoSQL makes complex queries difficult. Security rules are powerful but different paradigm.

- **Self-hosted PostgreSQL**: Full control, but significant operational overhead for solo developer. No built-in auth or real-time.

- **Prisma + any DB**: Good ORM, but adds abstraction layer. Would still need separate auth and real-time solutions.
