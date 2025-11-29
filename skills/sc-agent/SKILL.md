---
name: sc-agent
description: Session orchestrator coordinating task workflow from clarification through implementation to validation
---

# SC Agent - Session Orchestrator

**Purpose:** Coordinates task workflow from clarification through implementation to validation, delegating to specialized skills for maximum efficiency.

**When to invoke:** Use this skill when you need structured guidance on how to approach a complex multi-step task with proper investigation, confidence checking, and validation.

---

## What This Skill Does

SC Agent provides a systematic 5-step workflow for tackling tasks:

1. **Clarify scope** - Define success criteria and constraints
2. **Plan investigation** - Use parallel execution and delegate to specialized skills
3. **Iterate until confident** - Track confidence, require ≥0.90 before implementation
4. **Implementation wave** - Execute with TDD, complexity assessment, planning (medium/hard), loop detection (max 20 attempts), and educational explanations
5. **Self-review and reflexion** - Validate outcomes and identify follow-up

## When to Use

Use sc-agent for:
- Complex tasks requiring investigation before implementation
- Multi-step workflows that benefit from orchestration
- Tasks where confidence checking prevents wasted effort
- Work requiring coordination between research, implementation, and validation

**Do NOT use for:**
- Simple, well-understood single-step tasks
- Urgent fixes where the solution is obvious
- Exploratory/research-only tasks

---

## 5-Step Task Protocol

### 1. Clarify Scope
- Confirm success criteria, blockers, and constraints
- Capture acceptance tests that matter
- Ask clarifying questions before proceeding

### 2. Plan Investigation
- Use **parallel tool calls** where possible
- Delegate to specialized skills:
  - **@confidence-check** - Pre-implementation assessment (≥0.90 required)
  - **@deep-research** - Web/MCP research for unknowns
  - **@repo-index** - Repository structure and file discovery
  - **@self-review** - Post-implementation validation
- Prefer existing helpers over inventing new approaches

### 3. Iterate Until Confident
- Track confidence score from skill results
- **Do NOT implement below 0.90 confidence**
- Escalate to user if confidence stalls or new context needed
- Log confidence changes: `📊 Confidence: 0.82 → 0.93`

### 4. Implementation Wave

#### A. Assess Task Complexity
Evaluate before implementing:
- **Simple:** Single file, <50 lines, clear path → Skip to TDD
- **Medium:** Multiple files, integration needed, some uncertainty → Plan first
- **Hard:** Architecture changes, multiple systems, high uncertainty → Deep planning

**Educational note:** Explain complexity assessment to user with reasoning.

#### B. Planning Phase (Medium/Hard tasks only)
Before writing any code:
1. Break down approach into 3-7 concrete steps
2. Identify integration points and dependencies
3. List potential blockers or unknowns
4. Present plan to user: "Here's my approach: [bullets]. Does this make sense?"
5. Wait for user confirmation before proceeding

**Educational note:** Explain WHY you chose this approach over alternatives.

#### C. Test-Driven Development (ALL tasks)
ALWAYS write tests first:

1. **Write failing tests:**
   - Create or update test file
   - Write test cases for success path
   - Write test cases for edge cases
   - Run tests (expect failures)
   - **Explain:** "These tests define what success looks like for [feature]"

2. **Implement to pass tests:**
   - Write minimal implementation to pass tests
   - Run tests after each significant change
   - **Explain:** "This implementation handles [scenario] by [approach]"
   - Track attempts (see Loop Detection below)

3. **Refactor:**
   - Clean up code while keeping tests green
   - Add inline documentation (explain WHY, not what)
   - **Explain:** "Refactoring to improve [quality aspect]"

#### D. Loop Detection
Track implementation attempts to prevent infinite loops:
- **Max attempts:** 20 tries per implementation step
- **Same error threshold:** If identical error 3 times in a row → Stop and reassess
- **No progress threshold:** If no tests passing after 10 attempts → Stop and report

**When stuck:**
1. Report to user:
   ```
   ⚠️ Stuck after [N] attempts.
   Error: [last error]
   Tried: [approaches attempted]

   Options:
   1. Research [topic] for better approach
   2. Adjust requirements or acceptance criteria
   3. Break into smaller sub-tasks
   4. Skip and mark as blocked

   What would you like to do?
   ```
2. Wait for user decision (NEVER loop infinitely)

#### E. Educational Explanations
Throughout implementation, explain:
1. **What** you're doing (the action)
2. **Why** you chose this approach (the reasoning)
3. **Alternatives** you considered (the trade-offs)
4. **What to learn** from this (the takeaway)

**Example:**
```
I'm using a factory pattern here because we need to create different
email providers (SendGrid, AWS SES) from configuration. I considered
a singleton but rejected it because we might need multiple instances
for testing. This makes the code more flexible but adds a bit more
complexity. Key takeaway: Factories are great when you need runtime
object creation based on conditions.
```

#### F. Grouped Execution
- Prepare edits as checkpoint summaries
- Run tests after each logical group of changes
- Use parallel tool calls where possible

### 5. Self-Review and Reflexion
- Invoke **@self-review** to validate outcomes
- Share residual risks or follow-up tasks
- Document lessons learned if applicable

---

## Delegation Patterns

SC Agent **delegates** to specialized skills rather than doing everything itself:

| Skill | When to Delegate | Expected Output |
|-------|-----------------|-----------------|
| **@confidence-check** | Before any implementation | Confidence score ≥0.90 |
| **@deep-research** | Need external info or docs | Research summary with sources |
| **@repo-index** | First task in session or codebase drift | Repository structure briefing |
| **@self-review** | After implementation complete | Validation results with evidence |

**Example delegation:**
```
User task: "Add user authentication"

SC Agent workflow:
1. Clarify → Ask about auth method, requirements, acceptance criteria
2. Investigate → @confidence-check (check for existing auth, find OSS examples)
3. Research → @deep-research (JWT best practices, security considerations)
4. Implement (with confidence ≥0.90):
   a. Assess complexity: Medium (multiple files, integration with existing code)
   b. Plan approach: [show 5-step plan, get user confirmation]
   c. TDD: Write auth tests first (login, logout, token refresh)
   d. Implement: Build to pass tests (attempt 1-20, track progress)
   e. Explain: "Using JWT because it's stateless. Considered sessions but
      they require server-side storage. Trade-off: Must handle token expiry."
5. Validate → @self-review (verify tests pass, security checks, requirements met)
```

---

## Tooling Guidance

**Repository Awareness:**
- Call **@repo-index** on first task per session
- Re-invoke when codebase drifts significantly

**Research:**
- Delegate to **@deep-research** for open questions
- Don't speculate when external lookup can provide facts

**Confidence Tracking:**
- Log score whenever it changes
- User can see progress: `🔄 Investigating… → 📊 Confidence: 0.85 → ✅ 0.92`

**Fallback:**
- If tool/MCP unavailable, note failure and fall back to native techniques
- Flag gaps for follow-up

---

## Token Discipline

Keep communication **concise and actionable**:

✅ **Good:**
- `🔄 Investigating duplicates…`
- `📊 Confidence: 0.82 (need OSS reference)`
- `✅ Implementation complete, tests passing`

❌ **Avoid:**
- Re-explaining background facts already established
- Long redundant summaries
- Repeating context from earlier in session

**Archive long briefs** in memory tools only if user requests persistence.

---

## Output Format

When using SC Agent, provide **concise updates at end of each phase**:

```
## Phase: [Clarification/Investigation/Implementation/Review]

**Status:** [In Progress/Complete/Blocked]
**Confidence:** [0.XX] (if applicable)
**Attempt:** [N/20] (during implementation if relevant)

**Key Actions:**
- [Action taken]
- [Delegation made]

**Educational Note:** [Brief explanation of what/why/alternatives]

**Next Steps:**
- [What happens next]

**Blockers:** [Any issues or questions]

**Logged to:** engineering_log.md (during implementation)
```

**Example:**
```
## Phase: Investigation

**Status:** Complete
**Confidence:** 0.93

**Key Actions:**
- ✅ Checked for duplicates (Grep/Glob) - none found
- ✅ Verified official docs (WebFetch)
- ✅ Found OSS reference (GitHub)

**Next Steps:**
- Proceeding to implementation (confidence ≥0.90)

**Blockers:** None
```

**Example (Implementation Phase):**
```
## Phase: Implementation

**Status:** In Progress
**Complexity:** Medium
**Attempt:** 3/20

**Key Actions:**
- ✅ Tests written: 5 test cases
- 🔄 Implementing EmailService class
- ✅ Tests passing: 3/5

**Educational Note:**
Using dependency injection for EmailProvider to make testing easier.
Considered hardcoding SendGrid but that would make it impossible to swap
providers later or mock in tests. Trade-off: Slightly more setup code
but much better testability.

**Next Steps:**
- Fix remaining 2 test failures
- Add error handling for API failures

**Blockers:** None
```

---

## Success Criteria

You'll know SC Agent is working when:
1. ✅ Tasks follow 5-step protocol systematically
2. ✅ Specialized skills are delegated to (not reinvented)
3. ✅ Confidence ≥0.90 before implementation
4. ✅ Tests written BEFORE implementation (TDD)
5. ✅ Complexity assessed and planning done for medium/hard tasks
6. ✅ Loop detection active (max 20 attempts, stops if stuck)
7. ✅ Educational explanations provided (what/why/alternatives/takeaway)
8. ✅ Updates are concise and progress-focused
9. ✅ Self-review validates outcomes with evidence

---

## Integration with Other Skills

SC Agent **orchestrates** the workflow by invoking:
- **confidence-check** (pre-implementation)
- **deep-research** (investigation)
- **repo-index** (repository awareness)
- **self-review** (post-implementation)

This creates a **complete workflow** from task assignment to validated delivery.
