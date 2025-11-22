# SC Executor - Multi-Task Project Executor

## When to Use This Skill

Use this skill when you have:
- A defined task list (from sc-workflows or manual planning)
- Multiple tasks that need systematic execution
- Want to execute all tasks until completion
- Need sc-agent to work on each task and report back

**Prerequisites:**
1. Product requirements defined
2. Architecture decided
3. Task list created (numbered list of tasks)

**This skill will:**
- Execute each task systematically using sc-agent
- Collect summaries from each task execution
- Track progress and validate completion
- Continue until all tasks are complete

---

## How It Works

**Pattern: Supervisor → Worker**
```
sc-executor (supervisor)
    ↓
    Delegates to sc-agent (worker) for Task 1
    ← Receives summary
    ↓
    Delegates to sc-agent (worker) for Task 2
    ← Receives summary
    ↓
    ... repeat until all tasks complete
```

---

## Usage

**Step 1: Define your tasks** (you do this manually):
```
1. Implement user database schema
2. Create authentication API with JWT
3. Add RBAC authorization
4. Build user CRUD endpoints
5. Write integration tests
6. Security audit and hardening
```

**Step 2: Invoke sc-executor:**
```
use sc-executor to implement these tasks:
1. Implement user database schema
2. Create authentication API with JWT
3. Add RBAC authorization
4. Build user CRUD endpoints
5. Write integration tests
6. Security audit and hardening
```

**Step 3: sc-executor executes systematically:**
- For each task, delegates to sc-agent
- sc-agent implements with TDD, returns summary
- sc-executor validates, marks complete, moves to next
- Continues until all tasks done

---

## Protocol

### Phase 1: Initialize (5%)

1. **Parse Task List**
   - Extract numbered tasks from user input
   - Validate task list is clear and actionable
   - Create TodoWrite list for tracking

2. **Confirm Scope**
   - Total tasks: X
   - Estimated time per task (if provided)
   - Ask user to confirm before starting

**Output:**
```
📋 Task Execution Plan
Tasks to execute: 6
1. Implement user database schema
2. Create authentication API with JWT
3. Add RBAC authorization
4. Build user CRUD endpoints
5. Write integration tests
6. Security audit and hardening

Ready to proceed? (yes/no)
```

---

### Phase 2: Execute Tasks (85%)

**For each task in the list:**

1. **Mark Task as In Progress**
   - Update TodoWrite: Task N → in_progress

2. **Delegate to sc-agent**
   - Invoke: "use sc-agent to implement [Task N]"
   - sc-agent executes full workflow:
     - Clarify scope
     - Run confidence-check (if needed)
     - Investigate
     - Implement with TDD
     - self-review validation
   - sc-agent returns summary (not full details)

3. **Validate Completion**
   - Did sc-agent complete the task?
   - Did tests pass?
   - Did self-review pass?
   - Any blockers or issues?

4. **Record Summary**
   - Task name
   - Status: ✅ Complete / ⚠️ Partial / ❌ Failed
   - Key outputs (files created, tests added)
   - Any issues or follow-ups

5. **Mark Complete**
   - Update TodoWrite: Task N → completed
   - Move to next task

**If Task Fails:**
- Stop execution
- Report issue to user
- Ask: Fix and retry? Skip and continue? Abort?

**Output per task:**
```
✅ Task 1 Complete: Implement user database schema
- Created: schema.sql, migration scripts
- Tests: 8 unit tests added (100% coverage)
- Review: Passed (no issues)
- Time: 15 minutes

Moving to Task 2...
```

---

### Phase 3: Final Summary (10%)

After all tasks complete:

1. **Aggregate Results**
   - Total tasks completed: X/Y
   - Total files created/modified
   - Total tests added
   - Total time elapsed

2. **Cross-Cutting Validation**
   - Run final integration test suite
   - Security check (if security tasks included)
   - Performance check (if applicable)

3. **Deployment Readiness**
   - All tasks complete? ✅
   - All tests passing? ✅
   - No critical issues? ✅
   - Ready for deployment? ✅

**Output:**
```
🎉 Project Execution Complete!

Summary:
========
✅ Tasks completed: 6/6 (100%)
✅ Files created: 15
✅ Tests added: 45 (coverage: 87%)
✅ Total time: 2.5 hours

Task Breakdown:
1. ✅ Implement user database schema - 15 min
2. ✅ Create authentication API with JWT - 30 min
3. ✅ Add RBAC authorization - 25 min
4. ✅ Build user CRUD endpoints - 35 min
5. ✅ Write integration tests - 40 min
6. ✅ Security audit and hardening - 35 min

Final Validation:
✅ All integration tests passing (45/45)
✅ Security audit: No critical issues
✅ Code coverage: 87%

🚀 Ready for deployment!

Next Steps:
- Review generated code
- Run manual testing if needed
- Deploy to staging environment
```

---

## Task Summary Format

**Each sc-agent execution returns a concise summary:**

```markdown
## Task: [Task Name]

**Status:** ✅ Complete / ⚠️ Partial / ❌ Failed

**What was implemented:**
- [Key implementation detail 1]
- [Key implementation detail 2]
- [Key implementation detail 3]

**Files created/modified:**
- path/to/file1.ts (created)
- path/to/file2.ts (modified)

**Tests added:**
- X unit tests
- Y integration tests
- Coverage: Z%

**Self-Review Result:**
✅ Tests passing
✅ Edge cases covered
✅ Requirements met
⚠️ Follow-up: [if any issues]

**Time:** [X minutes]
```

---

## Error Handling

### Task Fails Confidence Check (<0.70)

```
⚠️ Task 3 Failed: Confidence check below threshold

Confidence Score: 0.65
Issues:
- Missing dependency documentation
- Unclear integration points
- No OSS reference found

Options:
1. Research and retry (recommended)
2. Skip task and continue
3. Abort execution

Your choice?
```

### Task Implementation Fails

```
❌ Task 4 Failed: Implementation error

Error: Database migration failed
Details: Column 'user_id' already exists

Options:
1. Debug and retry
2. Skip and continue (mark as TODO)
3. Abort execution

Your choice?
```

### Task Review Fails

```
⚠️ Task 5 Partial: Self-review found issues

Issues:
- 2 tests failing
- Edge case not covered: empty input
- Security concern: no input validation

Options:
1. Fix issues and re-review
2. Accept partial and continue (create follow-up task)
3. Abort execution

Your choice?
```

---

## Advanced Features

### Parallel Execution (Optional)

If tasks are independent, execute in parallel:

```
use sc-executor to implement tasks in parallel:
Group 1 (parallel):
  1. Implement user schema
  2. Implement product schema
Group 2 (sequential - depends on Group 1):
  3. Create authentication API
  4. Create authorization middleware
```

**sc-executor will:**
- Execute Group 1 tasks concurrently (2 sc-agent instances)
- Wait for both to complete
- Execute Group 2 sequentially

### Checkpoint & Resume

If execution is interrupted:

```
💾 Checkpoint saved at Task 3/6

Resume with:
use sc-executor to resume from checkpoint
```

**sc-executor will:**
- Load saved state
- Skip completed tasks (1-2)
- Continue from Task 3

---

## Integration with Other Skills

**Before using sc-executor:**
1. `use sc-workflows to create implementation plan` → Get task list
2. `use sc-architecture to design system` → Validate architecture
3. `use confidence-check to assess overall project` → Ensure feasibility

**During sc-executor execution:**
- sc-executor delegates to `sc-agent` for each task
- sc-agent uses `confidence-check`, `self-review` as needed
- sc-agent may delegate to domain skills (`sc-security`, `sc-architecture`, etc.)

**After sc-executor completes:**
1. `use sc-security for final security audit` (if not in task list)
2. `use sc-performance for load testing` (if not in task list)
3. `use sc-quality for coverage analysis` (if not in task list)

---

## Example: Complete Workflow

**1. Planning (you do this manually):**
```
use sc-workflows to create implementation plan for user management system

# You get task list:
1. Database schema (users, roles, permissions)
2. Authentication API (JWT, login, logout)
3. Authorization middleware (RBAC)
4. User CRUD API (create, read, update, delete)
5. Integration tests
6. Security audit
```

**2. Execution (sc-executor automates):**
```
use sc-executor to implement these tasks:
1. Database schema (users, roles, permissions)
2. Authentication API (JWT, login, logout)
3. Authorization middleware (RBAC)
4. User CRUD API (create, read, update, delete)
5. Integration tests
6. Security audit
```

**3. sc-executor orchestrates:**
```
📋 Initializing execution for 6 tasks...
✅ TodoWrite list created

🔨 Task 1/6: Database schema
   Delegating to sc-agent...
   [sc-agent executes: confidence-check → implement → self-review]
   ✅ Complete (15 min)
   Summary: Created users, roles, permissions tables with migrations

🔨 Task 2/6: Authentication API
   Delegating to sc-agent...
   [sc-agent executes with TDD]
   ✅ Complete (30 min)
   Summary: JWT auth, login, logout endpoints with tests

🔨 Task 3/6: Authorization middleware
   Delegating to sc-agent...
   [sc-agent executes]
   ✅ Complete (25 min)
   Summary: RBAC middleware with role checking

🔨 Task 4/6: User CRUD API
   Delegating to sc-agent...
   [sc-agent executes]
   ✅ Complete (35 min)
   Summary: Create/read/update/delete endpoints with validation

🔨 Task 5/6: Integration tests
   Delegating to sc-agent...
   [sc-agent executes]
   ✅ Complete (40 min)
   Summary: 45 integration tests, 87% coverage

🔨 Task 6/6: Security audit
   Delegating to sc-security via sc-agent...
   [sc-agent → sc-security OWASP audit]
   ✅ Complete (35 min)
   Summary: No critical issues, 2 medium issues fixed

🎉 All tasks complete! (2h 40min total)
```

---

## Quality Checks

**Before starting execution:**
- [ ] Task list is clear and numbered
- [ ] Tasks are independent or dependencies noted
- [ ] User confirmed scope

**During execution (per task):**
- [ ] sc-agent completed task successfully
- [ ] Tests passing
- [ ] Self-review passed
- [ ] Summary recorded

**After all tasks:**
- [ ] All todos marked complete
- [ ] Integration tests passing
- [ ] No critical issues
- [ ] Deployment checklist reviewed

---

## Stopping Conditions

**Success:**
✅ All tasks completed successfully
✅ All tests passing
✅ No critical issues

**Stop and ask user:**
⚠️ Task failed confidence check (<0.70)
⚠️ Task implementation failed
⚠️ Task review found critical issues
⚠️ User requested stop

**Abort:**
❌ Max retries exceeded (3 per task)
❌ Critical security issue found
❌ User requested abort

---

## Tips for Effective Use

1. **Keep tasks focused**
   - Each task should be 15-45 minutes of work
   - Break large tasks into smaller ones
   - One clear deliverable per task

2. **Order tasks by dependency**
   - Database schema before API
   - API before tests
   - Tests before deployment

3. **Include validation tasks**
   - Security audit
   - Performance testing
   - Integration testing

4. **Use clear task names**
   - Good: "Implement JWT authentication with refresh tokens"
   - Bad: "Do auth stuff"

5. **Let sc-agent handle details**
   - Don't micro-specify in task list
   - sc-agent will ask for clarification if needed
   - Trust TDD workflow

---

## Differences from sc-agent

| Feature | sc-agent | sc-executor |
|---------|----------|-------------|
| **Scope** | Single task/feature | Multiple tasks (project) |
| **Pattern** | Worker (does the work) | Supervisor (delegates) |
| **Invocation** | One task at a time | List of tasks |
| **Output** | Full implementation details | Summary per task |
| **Duration** | 15-60 minutes | Hours to days |
| **Use case** | Implement one feature | Execute entire project plan |

---

## Example Task Lists

### Small Project (2-3 hours)
```
1. Add email verification to signup
2. Create password reset flow
3. Add rate limiting to auth endpoints
4. Write security tests
```

### Medium Project (1-2 days)
```
1. Database schema for orders
2. Shopping cart API (add/remove/update)
3. Checkout process (address, payment)
4. Order confirmation emails
5. Order history API
6. Integration tests
7. Load testing
8. Security audit
```

### Large Project (1 week)
```
1. Multi-tenant database schema
2. Tenant provisioning API
3. Tenant isolation middleware
4. Admin panel for tenant management
5. Billing integration (Stripe)
6. Usage tracking and analytics
7. Email notifications
8. Unit tests (80% coverage)
9. Integration tests
10. E2E tests for critical flows
11. Security audit
12. Performance testing and optimization
```

---

## References

- **sc-agent**: Single-task implementation (called by sc-executor)
- **sc-workflows**: Task planning (creates task list for sc-executor)
- **confidence-check**: Feasibility assessment (used by sc-agent)
- **self-review**: Validation (used by sc-agent)
