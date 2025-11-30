Use the **frontend-react** and **testing** skills for this task.

## Task
Implement a frontend feature: **$ARGUMENTS**

## Process

### 1. Understand & Plan
- Restate the feature in your own words
- Identify Atomic Design levels involved (atoms → molecules → organisms → pages)
- List components to create or modify
- Identify tests to add (React Testing Library, possibly Playwright for E2E)
- Present plan and wait for confirmation if complex

### 2. Contract & Types
- Define TypeScript interfaces for component props
- Decide state management approach:
  - `useState` for component-local UI state
  - React Query/SWR for server data
  - Zustand only if truly shared across distant components
- For forms: use React Hook Form + Zod validation

### 3. TDD
- Write React Testing Library tests first
- Include edge cases from the `testing` skill (empty states, loading, errors)
- Run tests, confirm they fail

### 4. Implement
- Build bottom-up: atoms → molecules → organisms → pages
- Follow patterns from `frontend-react` skill
- Keep components small and composable
- Use Tailwind, ensure accessibility

### 5. Verify & Summarize
- Run `npm run test` and `npm run typecheck`
- Summarize: components created, tests added, usage examples
