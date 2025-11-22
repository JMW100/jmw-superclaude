# Web App + Database Technical Preferences

**Stack:** Next.js + Tailwind + Shadcn + Clerk + Stripe + Supabase + Drizzle

---

## Project Structure

```
actions/
  db/              # Database actions
  *-actions.ts     # Other actions
app/
  api/             # API routes
  route/
    _components/   # Route-specific components
    page.tsx
components/
  ui/              # Shadcn components
  utilities/       # Utility components
db/
  schema/          # All schemas here
types/             # All type definitions
```

---

## Critical Conventions

### Imports
- Always use `@/` for imports (never relative paths)

### Naming
- **Actions**: `functionNameAction()` - always end with "Action"
- **Storage**: `functionNameStorage()` - always end with "Storage"
- **Files**: kebab-case for all files/folders
- **Components**: kebab-case (e.g., `user-profile.tsx`)

### Database Schemas

**User ID Convention (CRITICAL):**
```ts
userId: text("user_id").notNull()  // Always text, never uuid
```

**Required Fields:**
```ts
createdAt: timestamp("created_at").defaultNow().notNull(),
updatedAt: timestamp("updated_at")
  .defaultNow()
  .notNull()
  .$onUpdate(() => new Date())
```

**Relationships:**
```ts
parentId: uuid("parent_id")
  .references(() => parentsTable.id, { onDelete: "cascade" })
  .notNull()
```

**Export Types:**
```ts
export type InsertEntity = typeof entityTable.$inferInsert
export type SelectEntity = typeof entityTable.$inferSelect
```

**Register in db.ts:**
```ts
// db/db.ts
const schema = {
  entities: entityTable,
  // ... other tables
}
```

### Server Actions

**Return Type (REQUIRED):**
```ts
// types/actions-types.ts
export type ActionState<T> =
  | { isSuccess: true; message: string; data: T }
  | { isSuccess: false; message: string; data?: never }
```

**Pattern:**
```ts
export async function createEntityAction(
  data: InsertEntity
): Promise<ActionState<SelectEntity>> {
  try {
    const [result] = await db.insert(table).values(data).returning()
    return { isSuccess: true, message: "Success", data: result }
  } catch (error) {
    console.error("Error:", error)
    return { isSuccess: false, message: "Failed" }
  }
}
```

**Date Handling:**
- Convert Date objects to ISO strings: `date.toISOString()`

### Environment Variables

- Frontend vars: `NEXT_PUBLIC_` prefix
- Always update `.env.example` when adding new vars
- Never expose server vars to frontend

### Storage (Supabase)

**Path Pattern:**
```
{bucket}/{userId}/{purpose}/{filename}
```

**Example:**
```
profile-images/user123/avatar/2024-02-13-photo.jpg
```

**Upload:**
```ts
await supabase.storage
  .from(bucket)
  .upload(path, file, {
    upsert: false,  // Use upsert for replace
    contentType: file.type
  })
```

**Security:**
- Implement RLS policies for user-specific access
- Use signed URLs for private files

---

## What to AVOID

❌ Hardcoding bucket names (use env vars)
❌ Manual migrations (always use `npm run db:generate`)
❌ Modifying Shadcn components
❌ Using server actions directly in client components
❌ Importing server components into client components

---

## Notes

- This file contains ONLY your specific preferences/opinions
- General best practices are assumed (modern LLM baseline knowledge)
- Focus: deviations from defaults, not explanations of basics
