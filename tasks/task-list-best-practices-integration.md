# Task List: Best Practices Integration

**Source PRD:** `/tasks/prd-best-practices-integration.md`
**Created:** 2025-11-29
**Updated:** 2025-11-30 (Added nested skills architecture, flow documentation, skill-selector review)
**Total Tasks:** 46
**Estimated Phases:** 5

---

## Overview

This task list implements the research-driven best practices integration into jmw-superclaude, including the **nested skills directory structure** for organizing core and stack-specific skills.

### Task Status Legend
- `[ ]` Not started
- `[~]` In progress
- `[x]` Completed
- `[!]` Blocked

---

## Phase 0: Directory Restructuring (Priority: MUST - DO FIRST)

### Task 0.1: Create Nested Directory Structure
**FR Reference:** FR-8.1

**Changes Required:**
- [ ] Create `skills/core/` directory
- [ ] Create `skills/web-app-db/` directory
- [ ] Create `skills/python-backend/` directory
- [ ] Verify directory structure matches plan

**Acceptance Criteria:**
- [ ] All three directories exist
- [ ] No errors in creation

---

### Task 0.2: Move Existing Skills to core/
**FR Reference:** FR-8.1

**Changes Required:**
- [ ] Move `skills/sc-agent/` → `skills/core/sc-agent/`
- [ ] Move `skills/sc-quality/` → `skills/core/sc-quality/`
- [ ] Move `skills/confidence-check/` → `skills/core/confidence-check/`
- [ ] Move `skills/self-review/` → `skills/core/self-review/`
- [ ] Move `skills/deep-research/` → `skills/core/deep-research/`
- [ ] Move `skills/repo-index/` → `skills/core/repo-index/`
- [ ] Move `skills/index-repo/` → `skills/core/index-repo/`
- [ ] Move `skills/create-prd/` → `skills/core/create-prd/`
- [ ] Move `skills/generate-tasks/` → `skills/core/generate-tasks/`
- [ ] Move `skills/skill-selector/` → `skills/core/skill-selector/`
- [ ] Move `skills/session-summary/` → `skills/core/session-summary/`
- [ ] Move `skills/sc-executor/` → `skills/core/sc-executor/`
- [ ] Move `skills/sc-architecture/` → `skills/core/sc-architecture/`
- [ ] Move `skills/sc-security/` → `skills/core/sc-security/`
- [ ] Move `skills/sc-performance/` → `skills/core/sc-performance/`
- [ ] Move `skills/sc-workflows/` → `skills/core/sc-workflows/`

**Acceptance Criteria:**
- [ ] All 16 skills moved to core/
- [ ] Original directories removed
- [ ] Skills still accessible

---

### Task 0.3: Update marketplace.json with Explicit Paths
**File:** `.claude-plugin/marketplace.json`
**FR Reference:** FR-8.2

**Changes Required:**
- [ ] Update skills array with explicit paths
- [ ] Use format: `"./core/skill-name"`
- [ ] Include all core skills
- [ ] Prepare placeholder entries for stack-specific skills (commented)

**New Content:**
```json
{
  "skills": [
    "./core/sc-agent",
    "./core/sc-quality",
    "./core/confidence-check",
    "./core/self-review",
    "./core/deep-research",
    "./core/repo-index",
    "./core/index-repo",
    "./core/create-prd",
    "./core/generate-tasks",
    "./core/skill-selector",
    "./core/session-summary",
    "./core/sc-executor",
    "./core/sc-architecture",
    "./core/sc-security",
    "./core/sc-performance",
    "./core/sc-workflows",
    "./core/code-review"
  ]
}
```

**Acceptance Criteria:**
- [ ] All skills enumerated with correct paths
- [ ] JSON valid (no syntax errors)
- [ ] Skills still discoverable after update

---

### Task 0.4: Add stack: Field to All Core Skill Frontmatter
**FR Reference:** FR-8.3

**Changes Required:**
For each skill in `skills/core/*/SKILL.md`:
- [ ] sc-agent: Add `stack: all`
- [ ] sc-quality: Add `stack: all`
- [ ] confidence-check: Add `stack: all`
- [ ] self-review: Add `stack: all`
- [ ] deep-research: Add `stack: all`
- [ ] repo-index: Add `stack: all`
- [ ] index-repo: Add `stack: all`
- [ ] create-prd: Add `stack: all`
- [ ] generate-tasks: Add `stack: all`
- [ ] skill-selector: Add `stack: all`
- [ ] session-summary: Add `stack: all`
- [ ] sc-executor: Add `stack: all`
- [ ] sc-architecture: Add `stack: all`
- [ ] sc-security: Add `stack: all`
- [ ] sc-performance: Add `stack: all`
- [ ] sc-workflows: Add `stack: all`

**Format:**
```yaml
---
name: sc-agent
description: ...
stack: all
---
```

**Acceptance Criteria:**
- [ ] All 16 core skills have stack: all in frontmatter
- [ ] YAML frontmatter remains valid

---

### Task 0.5: Create _SKILL-INDEX.md
**File:** `skills/_SKILL-INDEX.md` (NEW)
**FR Reference:** FR-8.4

**Changes Required:**
- [ ] Create human-readable index file
- [ ] List all core skills with descriptions
- [ ] Add sections for web-app-db and python-backend (placeholders)
- [ ] Include relative links to each skill

**Template:**
```markdown
# Skill Index

## Core Skills (stack: all)
| Skill | Description |
|-------|-------------|
| [sc-agent](./core/sc-agent/SKILL.md) | Task orchestration with confidence-driven development |
| ... | ... |

## Web App Skills (stack: web-app-db)
*Coming soon*

## Python Backend Skills (stack: python-backend)
*Coming soon*
```

**Acceptance Criteria:**
- [ ] Index file created
- [ ] All core skills listed
- [ ] Links work correctly

---

### Task 0.6: Verify Plugin Still Works After Restructuring
**Type:** Validation

**Verification Steps:**
- [ ] Run `use skill-selector` - should work
- [ ] Run `use sc-agent` - should work
- [ ] Verify skills are discoverable in plugin list
- [ ] Check for any broken references

**Acceptance Criteria:**
- [ ] All existing functionality preserved
- [ ] No regressions from restructuring

---

## Phase 1: Core Skill Updates (Priority: MUST)

### Task 1.1: Update sc-agent with TDD Enforcement
**File:** `skills/core/sc-agent/SKILL.md`
**FR Reference:** FR-1.1, FR-1.2

**Changes Required:**
- [ ] Locate Step 4 (Implementation) section
- [ ] Replace/enhance TDD subsection with stricter enforcement
- [ ] Add "Tests MUST fail before implementation" requirement
- [ ] Add progress tracking format: "Tests passing: X/Y"
- [ ] Add TDD skip escape hatch for trivial changes
- [ ] Add trivial change classification list (typos, config, docs, imports)
- [ ] Add explicit logging requirement when skipping TDD

**Acceptance Criteria:**
- [ ] TDD section clearly states tests must be written first
- [ ] Tests must fail initially (proves they're meaningful)
- [ ] Skip escape hatch documented with explicit criteria
- [ ] Progress format documented

**Estimated Tokens Added:** +200-300

---

### Task 1.2: Add Edge Case Reference to sc-quality
**File:** `skills/core/sc-quality/SKILL.md`
**FR Reference:** FR-2.1

**Changes Required:**
- [ ] Add new section "### Edge Case Reference Checklist"
- [ ] Add Boundary Values category (empty, zero, negative, max, off-by-one)
- [ ] Add Null/Undefined category (null, undefined, missing props, nested nulls)
- [ ] Add Special Strings category (unicode, long, whitespace, SQL injection, XSS, path traversal)
- [ ] Add Async Edge Cases category (timeout, concurrent, cancellation, out-of-order, retry)
- [ ] Add Date/Time category (timezone, DST, leap year, invalid, epoch, far future/past)
- [ ] Add Currency/Numbers category (zero, negative, rounding, large, float precision)
- [ ] Add note about stack-specific patterns via preference extensions

**Acceptance Criteria:**
- [ ] All 6 categories present with specific examples
- [ ] Security-relevant edge cases included (SQL injection, XSS, path traversal)
- [ ] Organized for easy scanning
- [ ] Reference to preference extensions for stack-specific patterns

**Estimated Tokens Added:** +400-500

---

### Task 1.3: Add TDD Verification to self-review
**File:** `skills/core/self-review/SKILL.md`
**FR Reference:** FR-6.1

**Changes Required:**
- [ ] Add "Question 1b: TDD Compliance Verified?" after Question 1
- [ ] Add verification checklist (test file first, initial failure, no test mods)
- [ ] Add output format for TDD compliance reporting
- [ ] Add "TDD Skipped" format for trivial changes
- [ ] Add deviation handling (flag, document impact, recommend retroactive tests)
- [ ] Add git history verification suggestion

**Acceptance Criteria:**
- [ ] TDD compliance is explicitly checked
- [ ] Both "TDD followed" and "TDD skipped" formats provided
- [ ] Deviation handling documented
- [ ] Git history mentioned as verification method

**Estimated Tokens Added:** +100-150

---

### Task 1.4: Enhance skill-selector with Stack Awareness
**File:** `skills/core/skill-selector/SKILL.md`
**FR Reference:** FR-11.1, FR-11.2, FR-11.3

**Changes Required:**
- [ ] Add "## Stack-Aware Filtering" section
- [ ] Add stack detection logic (preference file, project files, user specification)
- [ ] Add filtering rules (show core + active stack, hide other stacks)
- [ ] Update output format to group by Core vs Stack-specific
- [ ] Add stack detection examples
- [ ] Update skill reference table with stack column

**Acceptance Criteria:**
- [ ] Stack detection documented
- [ ] Filtering rules clear
- [ ] Output format shows grouping
- [ ] Examples included

**Estimated Tokens Added:** +300-400

---

### Task 1.5: Add Flow Documentation to sc-architecture
**File:** `skills/core/sc-architecture/SKILL.md`
**FR Reference:** FR-12.1, FR-12.2, FR-12.3, FR-12.4

**Changes Required:**
- [ ] Add "## Flow Documentation" section
- [ ] Add User Flow documentation requirement (step-by-step user journey)
- [ ] Add Data Flow documentation requirement (how data moves through system)
- [ ] Add arrow notation format: "Step 1 → Step 2 → Step 3"
- [ ] Add user review gate: "⚠️ Please review these assumed flows before I proceed"
- [ ] Add skip criteria (pure infrastructure, no user-facing/data flow)
- [ ] Add examples for both user flow and data flow

**Output Format:**
```markdown
## Assumed Flows

### User Flow
1. [Step] → 2. [Step] → 3. [Step]

### Data Flow
[Source] → [Transform] → [Destination]

⚠️ Please review these assumed flows before I proceed with implementation.
```

**Acceptance Criteria:**
- [ ] Flow Documentation section present
- [ ] User Flow format documented with example
- [ ] Data Flow format documented with example
- [ ] User review gate included
- [ ] Skip criteria documented

**Estimated Tokens Added:** +200-300

---

### Task 1.6: Review and Simplify skill-selector
**File:** `skills/core/skill-selector/SKILL.md`
**FR Reference:** Critical path component (CLAUDE.md mandates use)

**Rationale:**
CLAUDE.md now requires using skill-selector first for all non-trivial tasks. As a critical path component, it must be:
- Simple enough to be reliable
- Clear enough to select the right skill
- Organized for quick decision-making

**Review Areas:**
- [ ] Assess current complexity (~487 lines) - is it too long?
- [ ] Evaluate decision tree clarity - does it lead to correct selections?
- [ ] Review FAQ section - is it still accurate after architecture changes?
- [ ] Check skill descriptions - do they reflect nested structure?
- [ ] Evaluate organization - phases vs task types vs scenarios
- [ ] Consider simplification opportunities

**Potential Changes:**
- [ ] Remove redundant sections
- [ ] Simplify decision tree
- [ ] Update skill descriptions for nested architecture
- [ ] Consolidate overlapping guidance
- [ ] Add stack-specific skill recommendations (after Task 1.4)

**Acceptance Criteria:**
- [ ] Complexity assessed and documented
- [ ] Clear recommendation on simplification (or rationale for keeping as-is)
- [ ] All skill descriptions accurate for new architecture
- [ ] Decision paths tested for common scenarios

**Note:** This task should be done AFTER Task 1.4 (stack awareness) since they're related.

---

## Phase 2: New Core Skills & Templates (Priority: MUST/SHOULD)

### Task 2.1: Create code-review Skill
**File:** `skills/core/code-review/SKILL.md` (NEW)
**FR Reference:** FR-3.1, FR-3.2, FR-3.3

**Changes Required:**
- [ ] Create directory `skills/core/code-review/`
- [ ] Create SKILL.md with YAML frontmatter
- [ ] Add `allowed-tools: [Read, Grep, Glob]` in frontmatter
- [ ] Add `stack: all` in frontmatter
- [ ] Add "When to Use / When NOT to Use" section
- [ ] Add "Review Process" sections (Scope, Correctness, Security, Performance, Conventions)
- [ ] Add Security Checklist (OWASP top 10 relevant items)
- [ ] Add Output Format (Strengths, Issues by Priority, Suggested Tests, Refactor Suggestions)
- [ ] Add explicit "DO NOT MODIFY FILES" reminders (at least 3 places)
- [ ] Add severity levels (Critical, High, Medium, Low)

**Acceptance Criteria:**
- [ ] Frontmatter includes allowed-tools restriction and stack: all
- [ ] All review sections present
- [ ] Security checklist comprehensive
- [ ] Output format clearly structured
- [ ] Multiple "DO NOT MODIFY" reminders present

**Estimated Tokens Added:** +1500-2000

---

### Task 2.2: Create CI/CD Preference Template
**File:** `preferences/cicd-template.md` (NEW)
**FR Reference:** FR-4.1, FR-4.2

**Changes Required:**
- [ ] Create new file `preferences/cicd-template.md`
- [ ] Add Pre-commit Hooks Pattern section (Husky, lint-staged)
- [ ] Add GitHub Actions Workflow Template section
- [ ] Add Quality Gates Configuration section (blocking vs non-blocking)
- [ ] Add Environment Variables Management section
- [ ] Add Database Migration Workflow section (optional)
- [ ] Keep all content stack-agnostic (patterns, not specific implementations)

**Acceptance Criteria:**
- [ ] All 4 required sections present
- [ ] Content is stack-agnostic
- [ ] Examples are adaptable to different stacks
- [ ] Quality gates concept clearly explained

**Estimated Tokens Added:** +500-700

---

### Task 2.3: Update sc-workflows to Reference code-review
**File:** `skills/core/sc-workflows/SKILL.md`
**FR Reference:** FR-3.4

**Changes Required:**
- [ ] Locate Task 8: Review & Validation Workflow
- [ ] Add reference to @code-review skill for dedicated read-only reviews
- [ ] Explain when to use code-review vs sc-workflows review task
- [ ] Add to Integration Examples section

**Acceptance Criteria:**
- [ ] code-review skill referenced in Task 8
- [ ] Clear guidance on when to use which skill
- [ ] Integration example added

**Estimated Tokens Added:** +50-100

---

### Task 2.4: Create ADR Template
**File:** `docs/templates/adr-template.md` (NEW)
**FR Reference:** From original PRD

**Changes Required:**
- [ ] Create directory `docs/templates/`
- [ ] Create adr-template.md
- [ ] Add Status section (Proposed/Accepted/Deprecated/Superseded)
- [ ] Add Date section
- [ ] Add Context section
- [ ] Add Decision section
- [ ] Add Consequences section (Positive, Negative, Neutral)
- [ ] Add Alternatives Considered section

**Acceptance Criteria:**
- [ ] Template is complete and usable
- [ ] All standard ADR sections present
- [ ] Format is copy-paste ready

**Estimated Tokens Added:** +200-300

---

### Task 2.5: Update marketplace.json with code-review
**File:** `.claude-plugin/marketplace.json`

**Changes Required:**
- [ ] Add `"./core/code-review"` to skills array

**Acceptance Criteria:**
- [ ] code-review skill listed
- [ ] JSON valid

---

## Phase 3: Stack-Specific Skills (Priority: MUST/SHOULD)

### Task 3.1: Create clerk-auth Skill
**File:** `skills/web-app-db/clerk-auth/SKILL.md` (NEW)
**FR Reference:** FR-9.1

**Changes Required:**
- [ ] Create directory `skills/web-app-db/clerk-auth/`
- [ ] Create SKILL.md with frontmatter (stack: web-app-db)
- [ ] Add Clerk setup and configuration patterns
- [ ] Add middleware patterns for route protection
- [ ] Add session handling in Server Components
- [ ] Add testing with @clerk/testing mocks
- [ ] Add user metadata and organization patterns

**Acceptance Criteria:**
- [ ] Frontmatter has stack: web-app-db
- [ ] All required patterns documented
- [ ] Testing guidance included

**Estimated Tokens Added:** +1000-1500

---

### Task 3.2: Create stripe-payments Skill
**File:** `skills/web-app-db/stripe-payments/SKILL.md` (NEW)
**FR Reference:** FR-9.2

**Changes Required:**
- [ ] Create directory `skills/web-app-db/stripe-payments/`
- [ ] Create SKILL.md with frontmatter (stack: web-app-db)
- [ ] Add Stripe checkout integration patterns
- [ ] Add webhook handling and signature verification
- [ ] Add subscription management patterns
- [ ] Add testing with stripe-mock
- [ ] Add customer portal integration

**Acceptance Criteria:**
- [ ] Frontmatter has stack: web-app-db
- [ ] Webhook security emphasized
- [ ] Testing guidance included

**Estimated Tokens Added:** +1000-1500

---

### Task 3.3: Create supabase-rls Skill
**File:** `skills/web-app-db/supabase-rls/SKILL.md` (NEW)
**FR Reference:** FR-9.3

**Changes Required:**
- [ ] Create directory `skills/web-app-db/supabase-rls/`
- [ ] Create SKILL.md with frontmatter (stack: web-app-db)
- [ ] Add Row Level Security policy patterns
- [ ] Add multi-tenant RLS policies
- [ ] Add testing RLS policies
- [ ] Add migration workflow for policies
- [ ] Add common RLS mistakes to avoid

**Acceptance Criteria:**
- [ ] Frontmatter has stack: web-app-db
- [ ] Policy patterns comprehensive
- [ ] Testing guidance included
- [ ] Common mistakes documented

**Estimated Tokens Added:** +1000-1500

---

### Task 3.4: Create nextjs-api Skill
**File:** `skills/web-app-db/nextjs-api/SKILL.md` (NEW)
**FR Reference:** FR-9.4

**Changes Required:**
- [ ] Create directory `skills/web-app-db/nextjs-api/`
- [ ] Create SKILL.md with frontmatter (stack: web-app-db)
- [ ] Add Route Handler patterns (GET, POST, PUT, DELETE)
- [ ] Add Server Action patterns with ActionState<T>
- [ ] Add Zod validation integration
- [ ] Add error handling patterns
- [ ] Add response formatting

**Acceptance Criteria:**
- [ ] Frontmatter has stack: web-app-db
- [ ] Both Route Handlers and Server Actions covered
- [ ] Zod integration documented

**Estimated Tokens Added:** +800-1200

---

### Task 3.5: Create react-testing Skill
**File:** `skills/web-app-db/react-testing/SKILL.md` (NEW)
**FR Reference:** FR-9.5

**Changes Required:**
- [ ] Create directory `skills/web-app-db/react-testing/`
- [ ] Create SKILL.md with frontmatter (stack: web-app-db)
- [ ] Add React Testing Library patterns
- [ ] Add Server Component testing strategies
- [ ] Add Client Component testing with mocks
- [ ] Add integration testing with MSW
- [ ] Add Playwright E2E patterns for Next.js

**Acceptance Criteria:**
- [ ] Frontmatter has stack: web-app-db
- [ ] RTL patterns comprehensive
- [ ] Server/Client Component distinction clear

**Estimated Tokens Added:** +800-1200

---

### Task 3.6: Create fastapi-crud Skill
**File:** `skills/python-backend/fastapi-crud/SKILL.md` (NEW)
**FR Reference:** FR-10.1

**Changes Required:**
- [ ] Create directory `skills/python-backend/fastapi-crud/`
- [ ] Create SKILL.md with frontmatter (stack: python-backend)
- [ ] Add CRUD endpoint patterns
- [ ] Add Pydantic schema patterns (Base/Create/Update/Response/InDB)
- [ ] Add dependency injection patterns
- [ ] Add error handling with HTTPException
- [ ] Add response model patterns

**Acceptance Criteria:**
- [ ] Frontmatter has stack: python-backend
- [ ] Pydantic patterns match python-backend.md conventions
- [ ] All CRUD operations covered

**Estimated Tokens Added:** +800-1200

---

### Task 3.7: Create pytest-async Skill
**File:** `skills/python-backend/pytest-async/SKILL.md` (NEW)
**FR Reference:** FR-10.2

**Changes Required:**
- [ ] Create directory `skills/python-backend/pytest-async/`
- [ ] Create SKILL.md with frontmatter (stack: python-backend)
- [ ] Add async test patterns with pytest-asyncio
- [ ] Add SQLAlchemy async session fixtures
- [ ] Add FastAPI TestClient usage
- [ ] Add database rollback patterns for tests
- [ ] Add mocking external services

**Acceptance Criteria:**
- [ ] Frontmatter has stack: python-backend
- [ ] Async patterns comprehensive
- [ ] Fixtures well documented

**Estimated Tokens Added:** +600-900

---

### Task 3.8: Update marketplace.json with Stack-Specific Skills
**File:** `.claude-plugin/marketplace.json`

**Changes Required:**
- [ ] Add all web-app-db skills:
  - `"./web-app-db/clerk-auth"`
  - `"./web-app-db/stripe-payments"`
  - `"./web-app-db/supabase-rls"`
  - `"./web-app-db/nextjs-api"`
  - `"./web-app-db/react-testing"`
- [ ] Add all python-backend skills:
  - `"./python-backend/fastapi-crud"`
  - `"./python-backend/pytest-async"`

**Acceptance Criteria:**
- [ ] All 7 stack-specific skills listed
- [ ] Paths correct
- [ ] JSON valid

---

### Task 3.9: Update _SKILL-INDEX.md with Stack Skills
**File:** `skills/_SKILL-INDEX.md`

**Changes Required:**
- [ ] Add web-app-db skills section with descriptions
- [ ] Add python-backend skills section with descriptions
- [ ] Add links to each new skill

**Acceptance Criteria:**
- [ ] All stack skills listed
- [ ] Descriptions accurate
- [ ] Links work

---

## Phase 4: Preference Extensions & Documentation (Priority: SHOULD)

### Task 4.1: Add Skill Extensions to web-app-db.md
**File:** `preferences/web-app-db.md`
**FR Reference:** FR-7.2, FR-2.2

**Changes Required:**
- [ ] Add `## Skill Extensions` section at end of file
- [ ] Add `### sc-agent Extensions` with Next.js TDD patterns
- [ ] Add `### sc-agent Extensions` with **contracts-first: "Define Zod schemas in /contracts before API implementation"**
- [ ] Add `### sc-quality Extensions` with React/Next.js testing patterns
- [ ] Add `### confidence-check Extensions` with stack-specific checks
- [ ] Include React Testing Library guidance
- [ ] Include Server Component testing guidance
- [ ] Include Server Action testing guidance (ActionState<T>)
- [ ] Include Clerk auth mocking guidance
- [ ] Include Supabase testing guidance

**Acceptance Criteria:**
- [ ] Skill Extensions section present
- [ ] At least 3 skill extension subsections
- [ ] **Contracts-first (Zod) guidance included in sc-agent extensions**
- [ ] React/Next.js specific testing patterns included
- [ ] Supabase specific patterns included

**Estimated Tokens Added:** +300-400

---

### Task 4.2: Add Skill Extensions to python-backend.md
**File:** `preferences/python-backend.md`
**FR Reference:** FR-7.2

**Changes Required:**
- [ ] Add `## Skill Extensions` section at end of file
- [ ] Add `### sc-agent Extensions` with Python TDD patterns
- [ ] Add `### sc-agent Extensions` with **contracts-first: "Define Pydantic schemas (Base/Create/Update/Response/InDB) before endpoint implementation"**
- [ ] Add `### sc-quality Extensions` with pytest patterns
- [ ] Add `### confidence-check Extensions` with stack-specific checks
- [ ] Include pytest fixture patterns
- [ ] Include async test patterns
- [ ] Include SQLAlchemy test patterns
- [ ] Include FastAPI test client patterns

**Acceptance Criteria:**
- [ ] Skill Extensions section present
- [ ] At least 3 skill extension subsections
- [ ] **Contracts-first (Pydantic) guidance included in sc-agent extensions**
- [ ] pytest specific patterns included
- [ ] FastAPI/SQLAlchemy patterns included

**Estimated Tokens Added:** +300-400

---

### Task 4.3: Create docs/ARCHITECTURE.md
**File:** `docs/ARCHITECTURE.md` (NEW)
**FR Reference:** FR-5.1, FR-5.2, FR-5.3

**Changes Required:**
- [ ] Create comprehensive architecture document
- [ ] Add System Overview section (what jmw-superclaude is)
- [ ] Add Design Philosophy section (stack-agnostic core + stack-specific)
- [ ] Add **Nested Directory Structure** section (explain core/, web-app-db/, python-backend/)
- [ ] Add Component Architecture section (skills, preferences, hooks, scripts)
- [ ] Add Skill System section (discovery via marketplace.json, loading, invocation)
- [ ] Add Preference-Injection Pattern section (detailed explanation)
- [ ] Add Stack-Aware skill-selector section
- [ ] Add Skill Relationships Diagram (ASCII or Mermaid)
- [ ] Add Session Lifecycle section
- [ ] Add Hooks System section
- [ ] Add Token Optimization section (repo-index, confidence-check)
- [ ] Add Extension Points section (adding skills, preferences, new stacks)

**Acceptance Criteria:**
- [ ] All sections present
- [ ] Nested directory structure fully explained
- [ ] At least 2 diagrams included
- [ ] Readable by humans (not AI-focused like CLAUDE.md)

**Estimated Tokens Added:** +1500-2000

---

### Task 4.4: Update CLAUDE.md
**File:** `CLAUDE.md`
**FR Reference:** From PRD Section 7.1

**Changes Required:**
- [ ] Update Repository Structure to show nested skills (core/, web-app-db/, python-backend/)
- [ ] Add code-review to Skills Architecture list
- [ ] Update skill count (16 core + 7 stack = 23 total)
- [ ] Update skill categories to reflect nested structure
- [ ] Add reference to docs/ARCHITECTURE.md for detailed system overview
- [ ] Add note about stack-aware skill-selector
- [ ] Add Skill Usage Protocol section (use skill-selector first) - already added
- [ ] Add cicd-template.md to preferences list
- [ ] Update Success Indicators to mention nested structure

**Acceptance Criteria:**
- [ ] Directory structure accurate
- [ ] Skill counts accurate
- [ ] ARCHITECTURE.md referenced
- [ ] Stack awareness mentioned

**Estimated Tokens Added:** +200-300

---

### Task 4.5: Update docs/plugin-development.md
**File:** `docs/plugin-development.md`
**FR Reference:** From original PRD

**Changes Required:**
- [ ] Add section on **nested skills directory structure**
- [ ] Explain marketplace.json explicit enumeration requirement
- [ ] Add section on allowed-tools restriction pattern
- [ ] Add section on frontmatter stack: field
- [ ] Add section on creating stack-specific skills
- [ ] Add reference to ADR template for architecture decisions
- [ ] Add example of skill extensions in preferences
- [ ] Document preference-injection pattern for plugin developers
- [ ] Add guidance on adding new stacks

**Acceptance Criteria:**
- [ ] Nested skills fully documented
- [ ] marketplace.json format documented
- [ ] allowed-tools documented with example
- [ ] Stack-specific skill creation guided
- [ ] ADR template referenced
- [ ] Preference-injection explained

**Estimated Tokens Added:** +400-600

---

## Phase 5: Testing, Validation & Polish (Priority: SHOULD)

### Task 5.1: Test Nested Skills Discovery
**Type:** Validation (no file changes)

**Verification Steps:**
- [ ] Run `/plugin list` or equivalent to see installed skills
- [ ] Verify all core skills appear
- [ ] Verify stack-specific skills appear
- [ ] Test `use clerk-auth` works
- [ ] Test `use fastapi-crud` works
- [ ] Verify skills are invokable by name (not full path)

**Acceptance Criteria:**
- [ ] All 23+ skills discoverable
- [ ] Invocation works by name
- [ ] No errors from nested structure

---

### Task 5.2: Test code-review Skill Tool Restrictions
**Type:** Validation (no file changes)

**Verification Steps:**
- [ ] Invoke `use code-review` skill
- [ ] Attempt to use Edit tool (should be blocked)
- [ ] Attempt to use Write tool (should be blocked)
- [ ] Verify Read, Grep, Glob work correctly
- [ ] Document any bypass scenarios

**Acceptance Criteria:**
- [ ] Tool restrictions enforced
- [ ] No bypass possible
- [ ] Documented verification results

---

### Task 5.3: Test skill-selector Stack Filtering
**Type:** Validation (no file changes)

**Verification Steps:**
- [ ] Load web-app-db.md preference
- [ ] Invoke skill-selector
- [ ] Verify web-app-db skills appear
- [ ] Verify python-backend skills are hidden
- [ ] Test with no preference loaded (core skills only)
- [ ] Test explicit stack specification

**Acceptance Criteria:**
- [ ] Stack filtering works correctly
- [ ] Core skills always shown
- [ ] Non-active stack skills hidden

---

### Task 5.4: Test Preference Extensions Loading
**Type:** Validation (no file changes)

**Verification Steps:**
- [ ] Load web-app-db.md preference
- [ ] Invoke sc-quality and verify extensions appear
- [ ] Load python-backend.md preference
- [ ] Invoke sc-quality and verify different extensions appear
- [ ] Test with no preference loaded (generic patterns only)

**Acceptance Criteria:**
- [ ] Extensions load correctly per preference
- [ ] Generic patterns work without preference
- [ ] No conflicts between preferences

---

### Task 5.5: Test TDD Enforcement in sc-agent
**Type:** Validation (no file changes)

**Verification Steps:**
- [ ] Start implementation task with sc-agent
- [ ] Verify test creation is prompted first
- [ ] Verify tests must fail before implementation proceeds
- [ ] Test TDD skip with trivial change
- [ ] Verify skip is logged correctly

**Acceptance Criteria:**
- [ ] TDD flow enforced
- [ ] Skip works for trivial changes
- [ ] Logging correct

---

### Task 5.6: Validate Token Estimates
**Type:** Validation (no file changes)

**Verification Steps:**
- [ ] Count tokens in each updated skill
- [ ] Verify no skill exceeds 5K tokens
- [ ] Calculate total token impact
- [ ] Compare to estimates in PRD

**Acceptance Criteria:**
- [ ] All skills under 5K tokens
- [ ] Total impact within estimate range (~12000-17000)

---

### Task 5.7: Review Documentation Accuracy
**Type:** Validation (no file changes)

**Verification Steps:**
- [ ] Verify all internal links work (especially with new paths)
- [ ] Verify skill names match actual files
- [ ] Verify preference file references accurate
- [ ] Check for outdated information
- [ ] Verify _SKILL-INDEX.md is complete

**Acceptance Criteria:**
- [ ] All links valid
- [ ] All references accurate
- [ ] Index complete

---

## Summary

### By Priority

| Priority | Tasks | Status |
|----------|-------|--------|
| MUST (Phase 0) | 6 | Pending |
| MUST (Phase 1) | 6 | Pending |
| MUST (Phase 2) | 5 | Pending |
| MUST/SHOULD (Phase 3) | 9 | Pending |
| SHOULD (Phase 4) | 5 | Pending |
| Validation (Phase 5) | 7 | Pending |
| **Total** | **46** | **Pending** |

### By Phase

| Phase | Tasks | Focus |
|-------|-------|-------|
| Phase 0 | 6 | Directory restructuring (DO FIRST) |
| Phase 1 | 6 | Core skill updates (TDD, edge cases, skill-selector, flow docs, skill-selector review) |
| Phase 2 | 5 | New core skills & templates (code-review, CI/CD, ADR) |
| Phase 3 | 9 | Stack-specific skills (7 new skills + marketplace + index) |
| Phase 4 | 5 | Preference extensions & documentation |
| Phase 5 | 7 | Testing & validation |

### File Changes Summary

| Action | Count | Description |
|--------|-------|-------------|
| CREATE DIR | 3 | core/, web-app-db/, python-backend/ |
| MOVE | 16 | Existing skills → core/ |
| CREATE (Core) | 2 | code-review, _SKILL-INDEX.md |
| CREATE (Stack) | 7 | clerk-auth, stripe-payments, supabase-rls, nextjs-api, react-testing, fastapi-crud, pytest-async |
| CREATE (Docs) | 3 | ARCHITECTURE.md, adr-template.md, cicd-template.md |
| UPDATE | 11 | marketplace.json, CLAUDE.md, plugin-development.md, skill-selector, sc-agent, sc-quality, self-review, sc-workflows, sc-architecture, web-app-db.md, python-backend.md |
| VALIDATE | 8 | Testing tasks (no file changes) |

### Estimated Total Token Impact
- **Core skill updates:** ~1200-1650 tokens (includes sc-architecture flow docs)
- **New core skills:** ~1700-2300 tokens
- **Stack-specific skills:** ~6000-8500 tokens
- **Preferences updates:** ~1100-1500 tokens
- **Documentation:** ~2100-2900 tokens
- **Total:** ~12100-16850 tokens (7 new skills significantly increase total)

---

## Execution Order (Recommended)

```
PHASE 0 (Do First - Restructuring)
0.1 → 0.2 → 0.3 → 0.4 → 0.5 → 0.6 (sequential - depends on each other)

PHASE 1 (Core Updates)
1.1, 1.2, 1.3, 1.5 (parallel - different files)
    ↓
1.4 (skill-selector stack awareness)
    ↓
1.6 (skill-selector review - after 1.4)

PHASE 2 (New Core Content)
2.1 → 2.5 (code-review then marketplace)
2.2, 2.4 (parallel - independent)
2.3 (after code-review exists)

PHASE 3 (Stack Skills)
3.1, 3.2, 3.3, 3.4, 3.5 (parallel - web-app-db skills)
3.6, 3.7 (parallel - python-backend skills)
    ↓
3.8 → 3.9 (marketplace then index - after skills exist)

PHASE 4 (Docs & Extensions)
4.1, 4.2 (parallel - preference extensions)
4.3 (ARCHITECTURE.md - can start early)
4.4, 4.5 (after structure finalized)

PHASE 5 (Validation)
5.1 → 5.2 → 5.3 → 5.4 → 5.5 (test each feature)
5.6 → 5.7 (final validation)
5.8 (PRD update - anytime)
```

---

## Notes

- **Phase 0 is BLOCKING** - must complete before other phases
- Stack-specific skills can be developed in parallel within a stack
- Consider using `use sc-executor` to run multiple tasks systematically
- Validation tasks should happen after all file changes in a phase
- marketplace.json must be valid JSON at all times (use JSON linter)
