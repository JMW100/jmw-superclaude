---
name: cicd-devops
description: "CI/CD pipeline setup with GitHub Actions, Vercel deployment, pre-commit hooks, and automated testing. Use when setting up continuous integration, deployment pipelines, git hooks, or automating quality checks."
---

# CI/CD & DevOps Skill

## When to Use
- Setting up GitHub Actions workflows
- Configuring Vercel deployment
- Installing pre-commit hooks (Husky)
- Automating test runs and linting
- Managing environment variables
- Database migration automation

## Complete CI/CD Setup Guide

### Step 1: Pre-commit Hooks with Husky

Catch issues before they enter the repository.

```bash
# Install dependencies
npm install -D husky lint-staged

# Initialize Husky
npx husky init
```

Create the pre-commit hook:

```bash
# .husky/pre-commit
npm run lint-staged
```

Configure lint-staged:

```json
// package.json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "prettier --write",
      "eslint --fix"
    ],
    "*.{json,md,css}": [
      "prettier --write"
    ]
  }
}
```

Add pre-push hook for tests:

```bash
# .husky/pre-push
npm run typecheck
npm run test -- --passWithNoTests
```

### Step 2: GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  # Job 1: Linting and Type Checking
  quality:
    name: Code Quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint
      
      - name: Run TypeScript check
        run: npm run typecheck
      
      - name: Check Prettier formatting
        run: npx prettier --check .

  # Job 2: Unit Tests
  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    needs: quality
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests with coverage
        run: npm run test -- --coverage --ci
      
      - name: Upload coverage report
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          fail_ci_if_error: false

  # Job 3: Build Check
  build:
    name: Build
    runs-on: ubuntu-latest
    needs: quality
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build application
        run: npm run build
        env:
          # Add build-time env vars here
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}

  # Job 4: E2E Tests (runs on PRs to main only)
  e2e:
    name: E2E Tests
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium
      
      - name: Run E2E tests
        run: npm run test:e2e
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
      
      - name: Upload Playwright report
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

### Step 3: Database Migration Workflow

Create `.github/workflows/db-migrate.yml`:

```yaml
name: Database Migrations

on:
  push:
    branches: [main]
    paths:
      - 'supabase/migrations/**'

jobs:
  migrate:
    name: Apply Migrations
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
        with:
          version: latest
      
      - name: Apply migrations to staging
        if: github.ref == 'refs/heads/develop'
        run: supabase db push --db-url "${{ secrets.STAGING_DATABASE_URL }}"
      
      - name: Apply migrations to production
        if: github.ref == 'refs/heads/main'
        run: supabase db push --db-url "${{ secrets.PRODUCTION_DATABASE_URL }}"
      
      - name: Verify generated types match
        run: |
          supabase gen types typescript --db-url "${{ secrets.PRODUCTION_DATABASE_URL }}" > types.gen.ts
          if ! diff -q types.gen.ts src/types/database.ts > /dev/null 2>&1; then
            echo "::warning::Generated types differ from committed types"
            echo "Run 'supabase gen types typescript --local > src/types/database.ts' and commit"
          fi
```

### Step 4: Vercel Configuration

Create `vercel.json`:

```json
{
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm ci",
  "framework": "nextjs",
  "git": {
    "deploymentEnabled": {
      "main": true,
      "develop": true
    }
  },
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL": "@supabase_url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase_anon_key"
  }
}
```

**Vercel Environment Variables Setup:**

1. Go to Vercel Dashboard → Project → Settings → Environment Variables
2. Add variables for each environment (Production, Preview, Development):
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY` (server-side only, not NEXT_PUBLIC_)
   - `STRIPE_SECRET_KEY`
   - `STRIPE_WEBHOOK_SECRET`

### Step 5: Package.json Scripts

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix",
    "typecheck": "tsc --noEmit",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "db:migrate": "supabase db push",
    "db:reset": "supabase db reset",
    "db:types": "supabase gen types typescript --local > src/types/database.ts",
    "prepare": "husky"
  }
}
```

## Environment Variables Management

### Local Development

Create `.env.local` (never commit this):

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-local-service-key
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

Create `.env.example` (commit this as documentation):

```bash
# .env.example
# Copy this to .env.local and fill in values

# Supabase (required)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Stripe (required for payments)
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
```

### Type-safe Environment Variables

```typescript
// lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
  // Public (accessible in browser)
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
  
  // Server-only
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  STRIPE_WEBHOOK_SECRET: z.string().startsWith('whsec_'),
});

// Validate at build time / server startup
export const env = envSchema.parse({
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
  STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
  STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET,
});
```

## GitHub Repository Settings

### Branch Protection Rules

For `main` branch:
- ✅ Require pull request before merging
- ✅ Require status checks to pass (quality, test, build)
- ✅ Require branches to be up to date
- ✅ Require conversation resolution before merging

### Secrets Configuration

Go to Settings → Secrets and variables → Actions:

```
NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY
PRODUCTION_DATABASE_URL
STAGING_DATABASE_URL
STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET
CODECOV_TOKEN (optional, for coverage reports)
```

## Deployment Workflow

### Standard Flow

```
feature branch → PR → CI checks → merge to main → Vercel auto-deploy
```

### Database Changes Flow

```
1. Create migration: npx supabase migration new feature_name
2. Write SQL
3. Test locally: npx supabase db reset
4. Generate types: npm run db:types
5. Commit migration + types
6. PR → merge → GitHub Action applies migration
```

## Monitoring and Alerts

### Vercel Analytics

Enable in Vercel Dashboard → Project → Analytics

### Error Monitoring (Optional - Sentry)

```bash
npm install @sentry/nextjs
npx @sentry/wizard@latest -i nextjs
```

### Health Check Endpoint

```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET() {
  try {
    // Check database connection
    const { error } = await supabase.from('users').select('count').limit(1);
    
    if (error) {
      return NextResponse.json(
        { status: 'unhealthy', database: 'disconnected' },
        { status: 503 }
      );
    }
    
    return NextResponse.json({
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString(),
    });
  } catch {
    return NextResponse.json(
      { status: 'unhealthy' },
      { status: 503 }
    );
  }
}
```

## Quick Setup Checklist

### Initial Setup
- [ ] Initialize git repository
- [ ] Run `npm install -D husky lint-staged`
- [ ] Run `npx husky init`
- [ ] Create `.husky/pre-commit` and `.husky/pre-push`
- [ ] Add lint-staged config to package.json
- [ ] Create `.env.example`
- [ ] Add `.env.local` to `.gitignore`

### GitHub Setup
- [ ] Create repository
- [ ] Add secrets (Supabase, Stripe, etc.)
- [ ] Create `.github/workflows/ci.yml`
- [ ] Create `.github/workflows/db-migrate.yml`
- [ ] Configure branch protection rules

### Vercel Setup
- [ ] Connect GitHub repository
- [ ] Add environment variables
- [ ] Configure production domain
- [ ] Enable preview deployments

## Common CI/CD Mistakes to Avoid

❌ **Don't** commit secrets or .env files
✅ **Do** use GitHub Secrets and Vercel Environment Variables

❌ **Don't** skip CI checks by force-pushing
✅ **Do** fix failing checks before merging

❌ **Don't** deploy migrations without testing locally
✅ **Do** run `supabase db reset` locally before committing migrations

❌ **Don't** deploy on Fridays (or late at night)
✅ **Do** deploy early in the week when you can monitor

❌ **Don't** have different configs between local and CI
✅ **Do** ensure CI mirrors local development as closely as possible
