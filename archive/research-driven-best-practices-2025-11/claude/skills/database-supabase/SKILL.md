---
name: database-supabase
description: "Database development with Supabase, PostgreSQL migrations, Row Level Security policies, and type generation. Use when creating tables, writing migrations, setting up RLS, or working with the Supabase client."
---

# Database & Supabase Development Skill

## When to Use
- Creating or modifying database tables
- Writing SQL migrations
- Setting up Row Level Security (RLS) policies
- Generating TypeScript types from database schema
- Working with the Supabase client
- Designing database relationships

## Supabase Project Structure

```
supabase/
├── config.toml          # Supabase configuration
├── migrations/          # SQL migration files (timestamped)
│   ├── 20240101000000_create_users.sql
│   └── 20240102000000_add_posts.sql
├── seed.sql             # Seed data for development
└── functions/           # Edge Functions (if used)
```

## Migration Workflow

### 1. Create a new migration

```bash
npx supabase migration new create_users_table
```

This creates a timestamped file in `supabase/migrations/`.

### 2. Write the migration SQL

```sql
-- supabase/migrations/20240101000000_create_users.sql

-- Create the table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  stripe_customer_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Enable RLS (ALWAYS DO THIS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = id)
  WITH CHECK ((SELECT auth.uid()) = id);

-- Index for common queries
CREATE INDEX users_email_idx ON users (email);
CREATE INDEX users_stripe_customer_idx ON users (stripe_customer_id);
```

### 3. Apply locally and test

```bash
# Reset local database and apply all migrations
npx supabase db reset

# Or apply just new migrations
npx supabase db push
```

### 4. Generate TypeScript types

```bash
npx supabase gen types typescript --local > src/types/database.ts
```

### 5. Deploy to production

```bash
npx supabase db push --db-url $PRODUCTION_DB_URL
```

## Row Level Security (RLS) Patterns

**CRITICAL**: ALWAYS enable RLS on every table. Tables without RLS are accessible to anyone with the anon key.

### Basic Patterns

```sql
-- User owns the row
CREATE POLICY "Users can CRUD own data"
  ON posts FOR ALL
  TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

-- Read-only for all, write for owner
CREATE POLICY "Anyone can read"
  ON posts FOR SELECT
  TO authenticated, anon
  USING (published = true);

CREATE POLICY "Owner can modify"
  ON posts FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- Admin override
CREATE POLICY "Admins have full access"
  ON posts FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = (SELECT auth.uid()) 
      AND users.role = 'admin'
    )
  );
```

### Performance Tip

ALWAYS wrap `auth.uid()` in a subquery for better performance:

```sql
-- ✅ Good: Subquery (evaluated once per query)
USING ((SELECT auth.uid()) = user_id)

-- ❌ Bad: Direct call (may be evaluated per row)
USING (auth.uid() = user_id)
```

### Multi-tenant Pattern

```sql
-- Organizations table
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);

-- Organization membership
CREATE TABLE organization_members (
  organization_id UUID REFERENCES organizations(id),
  user_id UUID REFERENCES users(id),
  role TEXT NOT NULL DEFAULT 'member',
  PRIMARY KEY (organization_id, user_id)
);

-- Resources belong to organizations
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),
  name TEXT NOT NULL
);

-- RLS: Users can only see projects in their organizations
CREATE POLICY "Members can view org projects"
  ON projects FOR SELECT
  TO authenticated
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM organization_members 
      WHERE user_id = (SELECT auth.uid())
    )
  );
```

## Supabase Client Setup

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/types/database';

// Server-side client (for API routes, Server Components)
export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY! // Full access, server only!
);

// Client-side client (respects RLS)
export const createBrowserClient = () => 
  createClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
```

### Using Types from Generated Schema

```typescript
// The generated types give you full type safety
import type { Database } from '@/types/database';

type User = Database['public']['Tables']['users']['Row'];
type NewUser = Database['public']['Tables']['users']['Insert'];
type UpdateUser = Database['public']['Tables']['users']['Update'];

// Usage in queries
const { data, error } = await supabase
  .from('users')
  .select('*')
  .eq('id', userId)
  .single();

// data is typed as User | null
```

## Common Query Patterns

### Select with relations

```typescript
// Get posts with author info
const { data: posts } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    content,
    created_at,
    author:users(id, name, email)
  `)
  .order('created_at', { ascending: false });
```

### Upsert pattern

```typescript
// Insert or update based on constraint
const { data, error } = await supabase
  .from('user_settings')
  .upsert(
    { user_id: userId, theme: 'dark', notifications: true },
    { onConflict: 'user_id' }
  );
```

### Pagination

```typescript
const PAGE_SIZE = 20;

async function getPosts(page: number) {
  const from = page * PAGE_SIZE;
  const to = from + PAGE_SIZE - 1;
  
  const { data, count } = await supabase
    .from('posts')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);
  
  return {
    posts: data,
    totalPages: Math.ceil((count ?? 0) / PAGE_SIZE),
  };
}
```

### Realtime subscriptions

```typescript
// Subscribe to changes
const channel = supabase
  .channel('posts-changes')
  .on(
    'postgres_changes',
    { event: '*', schema: 'public', table: 'posts' },
    (payload) => {
      console.log('Change:', payload);
    }
  )
  .subscribe();

// Cleanup
channel.unsubscribe();
```

## Database Design Best Practices

### Use UUIDs for primary keys

```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
```

### Always include timestamps

```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

### Use enums for fixed values (via CHECK constraints)

```sql
-- For simple cases, use CHECK
status TEXT NOT NULL DEFAULT 'draft' 
  CHECK (status IN ('draft', 'published', 'archived'))

-- For complex cases, create a type
CREATE TYPE subscription_status AS ENUM ('active', 'canceled', 'past_due');
```

### Foreign key conventions

```sql
-- Always name constraints explicitly
user_id UUID NOT NULL 
  REFERENCES users(id) 
  ON DELETE CASCADE
  CONSTRAINT fk_posts_user
```

### Indexes for performance

```sql
-- Index foreign keys (not automatic in PostgreSQL)
CREATE INDEX posts_user_id_idx ON posts (user_id);

-- Index commonly filtered columns
CREATE INDEX posts_status_idx ON posts (status) WHERE status = 'published';

-- Composite index for multi-column queries
CREATE INDEX posts_user_status_idx ON posts (user_id, status);
```

## Testing Database Code

### Use a test database

```bash
# In .env.test
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_KEY=your-local-service-key
```

### Reset between tests

```typescript
// tests/helpers/db.ts
import { supabase } from '@/lib/supabase';

export async function resetDatabase() {
  // Truncate in correct order (respect foreign keys)
  await supabase.rpc('truncate_tables', {
    tables: ['posts', 'users']
  });
}

// Create a stored procedure for this
// supabase/migrations/99999_test_helpers.sql
CREATE OR REPLACE FUNCTION truncate_tables(tables TEXT[])
RETURNS void AS $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format('TRUNCATE TABLE %I CASCADE', t);
  END LOOP;
END;
$$ LANGUAGE plpgsql;
```

## CI/CD Integration

### GitHub Actions for migrations

```yaml
# .github/workflows/db-migrate.yml
name: Database Migrations
on:
  push:
    branches: [main]
    paths:
      - 'supabase/migrations/**'

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: supabase/setup-cli@v1
        with:
          version: latest
      
      - name: Push migrations
        run: supabase db push --db-url ${{ secrets.SUPABASE_DB_URL }}
      
      - name: Verify types are current
        run: |
          supabase gen types typescript --db-url ${{ secrets.SUPABASE_DB_URL }} > types.gen.ts
          if ! git diff --exit-code src/types/database.ts types.gen.ts; then
            echo "::error::Generated types are out of sync with migrations"
            exit 1
          fi
```

## Common Mistakes to Avoid

❌ **Don't** forget to enable RLS on new tables
✅ **Do** add `ALTER TABLE x ENABLE ROW LEVEL SECURITY` in every migration

❌ **Don't** use service role key on the client
✅ **Do** use anon key client-side, service key server-side only

❌ **Don't** write migrations that can't be reversed
✅ **Do** consider how you'd roll back each change

❌ **Don't** skip indexes on foreign keys
✅ **Do** create indexes for columns used in JOINs and WHERE clauses

❌ **Don't** store sensitive data without encryption
✅ **Do** use Supabase Vault for secrets, hash passwords with pgcrypto
