# Self-Review - Post-Implementation Validation

**Purpose:** Evidence-based post-implementation validation to confirm production readiness and capture lessons learned.

**When to invoke:** Use this skill IMMEDIATELY after completing implementation to verify tests pass, requirements met, edge cases considered, and follow-up actions identified.

---

## What This Skill Does

Self-Review performs systematic validation after implementation using **evidence-only** (no speculation). It ensures nothing is declared "complete" without proof of success.

**Key Principle:** Focus on **evidence, not storytelling**. Show command outputs, test results, and concrete artifacts.

---

## When to Use

Use self-review skill AFTER:
- Completing any implementation (features, bug fixes, refactoring)
- Making changes that could affect system behavior
- Writing new code that needs validation
- Finishing a task assigned by @sc-agent

**Do NOT use for:**
- Planning or pre-implementation (use @confidence-check instead)
- Research tasks with no implementation
- Trivial changes (typo fixes, comments)

---

## 4 Mandatory Questions

Self-Review MUST answer these 4 questions with evidence:

### Question 1: Tests/Validation Executed?

**Required:** Include exact command + outcome

**Evidence to provide:**
- Exact command run (e.g., `uv run pytest -m unit`)
- Exit code (0 = pass, non-zero = fail)
- Key output showing pass/fail
- Number of tests run and passed

**Example:**
```
✅ Tests Executed:
Command: uv run pytest tests/test_auth.py -v
Result: 15 tests passed, 0 failed
Exit code: 0

Output snippet:
  test_login_success PASSED
  test_logout PASSED
  test_invalid_credentials PASSED
```

**If no tests:** Explain why and what manual validation was done.

---

### Question 2: Edge Cases Covered?

**Required:** List anything intentionally left out or not tested

**What to identify:**
- Boundary conditions (empty inputs, max values, etc.)
- Error conditions (network failures, timeouts, etc.)
- Concurrent access scenarios
- Unusual but valid inputs
- Performance under load

**Format:**
```
✅ Edge Cases Covered:
- Empty input validation
- SQL injection prevention
- Rate limiting behavior

⚠️ Edge Cases NOT Covered (intentional):
- Concurrency behavior (requires load testing setup)
- Network partition scenarios (out of scope)
- Legacy data migration (separate ticket)
```

**Be honest:** It's better to document what's NOT covered than to claim false coverage.

---

### Question 3: Requirements Matched?

**Required:** Tie back to acceptance criteria

**How to validate:**
- List original requirements or user story
- Check each requirement against implementation
- Note any deviations with justification
- Confirm success criteria met

**Format:**
```
✅ Requirements Matched:

Original acceptance criteria:
1. Users can log in with email/password ✅
2. Session expires after 24 hours ✅
3. Failed logins are rate-limited ✅

Deviations:
- None

All acceptance criteria met.
```

**If requirements unclear:** Note ambiguity and assumptions made.

---

### Question 4: Follow-up or Rollback Steps Needed?

**Required:** Identify next actions or contingency plans

**Follow-up types:**
- **Technical debt:** Things to improve later
- **Documentation:** README updates, API docs
- **Monitoring:** Metrics to add, alerts to configure
- **Future enhancements:** Ideas discovered during implementation
- **Rollback plan:** How to revert if issues found in production

**Format:**
```
📓 Follow-up Actions:
- Add load tests for concurrent login scenarios (next sprint)
- Update API documentation with new endpoints (this week)
- Configure CloudWatch alerts for failed login rate (ops team)

🔄 Rollback Plan:
- Revert commit abc123 if login failures spike
- Feature flag 'new_auth' can disable new flow
- Database migration is reversible (down.sql provided)
```

---

## Evidence-Based Validation Requirements

**Critical Rule:** NO SPECULATION

✅ **Evidence-based (Good):**
```
✅ Tests: Ran `pytest tests/` - 24 passed, 0 failed
✅ Performance: Response time <100ms (measured with curl)
✅ Memory: No leaks detected (ran valgrind, clean output)
```

❌ **Speculation (Bad):**
```
❌ "Tests should pass" (didn't actually run them)
❌ "Performance seems fine" (no measurement)
❌ "Probably no memory leaks" (didn't check)
```

**Show, don't tell:**
- Include command outputs (truncated if long)
- Paste test results
- Show file changes (git diff summary)
- Provide measurements (time, memory, etc.)

---

## Output Format

When invoking this skill, provide output in this **checklist-style** format:

```markdown
## Self-Review Report

### 1. Tests/Validation Executed

✅ Command: {exact command}
✅ Result: {pass/fail with counts}
✅ Evidence: {key output snippet}

### 2. Edge Cases

✅ Covered:
- {edge case 1}
- {edge case 2}

⚠️ NOT Covered (intentional):
- {gap 1} - {reason}
- {gap 2} - {reason}

### 3. Requirements Matched

✅ Original criteria:
1. {requirement} ✅
2. {requirement} ✅

Deviations: {none or explain}

### 4. Follow-up/Rollback

📓 Follow-up:
- {action item 1}
- {action item 2}

🔄 Rollback plan:
- {how to revert}

---

## Residual Risks

⚠️ {risk 1} - Mitigation: {how to address}
⚠️ {risk 2} - Mitigation: {how to address}

## Lessons Learned

📝 {pattern or learning to remember}
```

---

## Example: Full Self-Review

**Task:** Implement user authentication with JWT

```markdown
## Self-Review Report

### 1. Tests/Validation Executed

✅ Command: `uv run pytest tests/test_auth.py -v`
✅ Result: 18 tests passed, 0 failed, Exit code 0
✅ Evidence:
```
test_register_new_user PASSED
test_login_valid_credentials PASSED
test_login_invalid_password FAILED → FIXED → PASSED
test_token_expiration PASSED
test_refresh_token PASSED
```

### 2. Edge Cases

✅ Covered:
- Empty username/password validation
- SQL injection prevention (parameterized queries)
- Token expiration and refresh
- Invalid token handling
- Password hashing with bcrypt

⚠️ NOT Covered (intentional):
- Concurrent login attempts - Reason: Requires load testing infrastructure (follow-up)
- OAuth provider failures - Reason: Out of scope for MVP
- Legacy password migration - Reason: Separate migration ticket (#234)

### 3. Requirements Matched

✅ Original acceptance criteria:
1. Users can register with email/password ✅
2. Passwords hashed securely (bcrypt) ✅
3. JWT tokens expire after 24 hours ✅
4. Refresh tokens work for 7 days ✅
5. Rate limiting on login attempts ✅

Deviations: None - all criteria met

### 4. Follow-up/Rollback

📓 Follow-up:
- Add load tests for concurrent logins (next sprint)
- Configure alerting for failed login rate >5% (ops team, this week)
- Document JWT secret rotation procedure (security review)

🔄 Rollback plan:
- Revert commits e4f2a1b..7c3d9e8 if auth failures spike
- Feature flag 'jwt_auth' can disable new system
- Database has migration rollback: `alembic downgrade -1`

---

## Residual Risks

⚠️ JWT secret rotation not automated - Mitigation: Manual rotation procedure documented, automation planned for Q2
⚠️ Rate limiting per IP only (not per user) - Mitigation: Acceptable for MVP, per-user limiting in backlog

## Lessons Learned

📝 Remember to test token expiration edge cases (caught one bug in testing)
📝 Bcrypt rounds should be configurable via env var (learned from security review)
```

---

## Integration with SC Agent

Self-Review is invoked by **@sc-agent** during final validation phase:

```
SC Agent workflow:
1. Clarify scope
2. Investigate (@confidence-check, @deep-research)
3. Implement (make changes)
4. Validate → @self-review (this skill)
5. Report to user with self-review results
```

**If issues found:** Recommend targeted fixes rather than reopening entire task.

---

## Reflexion Pattern Recording

When defects or issues are found during self-review, record them for future learning:

**What to record:**
- Error signature (what went wrong)
- Root cause (why it happened)
- Solution (how it was fixed)
- Prevention (how to avoid next time)

**Format:**
```json
{
  "error": "Tests passed but feature didn't work in production",
  "cause": "Test used mock data that didn't match production schema",
  "fix": "Updated tests to use production-like test fixtures",
  "prevention": "Always validate test data against production schema"
}
```

This creates a knowledge base to avoid repeating mistakes.

---

## Success Criteria

You'll know Self-Review is working when:
1. ✅ All 4 mandatory questions answered with evidence
2. ✅ No speculation - only concrete proof provided
3. ✅ Test commands and outputs shown
4. ✅ Edge cases honestly assessed (covered AND not covered)
5. ✅ Requirements explicitly tied to implementation
6. ✅ Follow-up actions clearly identified
7. ✅ Rollback plan documented
8. ✅ Residual risks noted with mitigation
9. ✅ Output is concise and checklist-style

---

## Common Anti-Patterns

❌ **Anti-pattern 1: Claiming success without evidence**
```
"Tests passed" (but didn't show command or output)
```

❌ **Anti-pattern 2: Hiding edge cases not covered**
```
Only lists what was tested, ignores gaps
```

❌ **Anti-pattern 3: Vague follow-up**
```
"Might need to add more tests later"
```

❌ **Anti-pattern 4: No rollback plan**
```
Assumes everything will work in production
```

❌ **Anti-pattern 5: Storytelling instead of checklists**
```
Long narrative about implementation journey
```

---

## Tips for Effective Self-Review

1. **Run tests immediately** before self-review (evidence must be fresh)
2. **Be brutally honest** about edge cases not covered
3. **Tie back to requirements** explicitly - don't assume coverage
4. **Plan for rollback** even if you're confident
5. **Keep it concise** - checklist format, not essays
6. **Document unknowns** - better than pretending to know
7. **Propose fixes, not reopening** - targeted actions only

The self-review exists to **catch issues before production**, not to make implementation look perfect. Honesty over optimism.
