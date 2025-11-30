# Product Requirements Document: Research-Driven Best Practices Integration

## Document Info
- **Version:** 1.0
- **Date:** 2025-11-29
- **Status:** Draft - Ready for Review
- **Author:** Generated via create-prd skill

---

## 1. Introduction/Overview

### 1.1 Problem Statement

Research-driven best practices for LLM-assisted development have identified key patterns that improve code quality, reduce rework, and prevent common errors. The jmw-superclaude plugin currently has gaps in:

1. **TDD Enforcement** - Tests are mentioned in sc-agent but not strictly enforced; no verification that tests fail before implementation
2. **Edge Case Testing** - Generic testing guidance exists in sc-quality but lacks a comprehensive checklist of edge case categories
3. **Read-Only Code Review** - No safe audit capability with tool restrictions to prevent accidental modifications during reviews
4. **CI/CD Patterns** - No guidance on pre-commit hooks, GitHub Actions, or quality gates
5. **Architecture Documentation** - No comprehensive human-readable overview of how the entire plugin system works

### 1.2 Feature Description

This initiative integrates research-driven best practices into jmw-superclaude through:

- **Stricter TDD Enforcement** in sc-agent with explicit "skip for trivial" escape hatch
- **Edge Case Reference Checklist** in sc-quality via preference-injected extensions
- **New code-review Skill** - Read-only skill with tool restrictions (allowed-tools: [Read, Grep, Glob])
- **CI/CD Preference Template** - Stack-agnostic guidance for quality gates and automation
- **Architecture Documentation** - docs/ARCHITECTURE.md explaining the entire system

### 1.3 Design Philosophy: Stack-Aware Skill Architecture

**Core Principle:** Skills are organized hierarchically by stack. Stack-specific workflows are separate skills, not injected content.

**Primary Mechanism: Nested Skill Directories**

Skills are organized into stack-based directories:
```
skills/
├── core/                    # Stack-agnostic skills (always available)
│   ├── sc-agent/
│   ├── sc-quality/
│   ├── confidence-check/
│   └── ...
├── web-app-db/              # Next.js + Supabase stack skills
│   ├── clerk-auth/
│   ├── stripe-payments/
│   ├── supabase-rls/
│   └── ...
└── python-backend/          # FastAPI + SQLAlchemy stack skills
    ├── fastapi-crud/
    ├── pytest-async/
    └── ...
```

This pattern is proven by the [anthropics/skills](https://github.com/anthropics/skills) repository which uses nested directories (`document-skills/pdf/`, `document-skills/docx/`).

**Selection Mechanism: skill-selector Filtering**

The `skill-selector` skill filters recommendations based on active stack:
- Detects stack from loaded preference file or project structure
- Always shows core skills (stack: all)
- Shows stack-specific skills matching the active stack
- Hides skills from other stacks

**Secondary Mechanism: Preference Extensions**

For lightweight conventions that don't warrant a full skill, preference files may include `## Skill Extensions` sections:
- Contracts-first guidance (Zod schemas, Pydantic models)
- Stack-specific testing patterns
- Conventions that augment core skills

| Mechanism | Purpose | Example |
|-----------|---------|---------|
| **Nested directories** | Stack-specific workflows | `clerk-auth`, `stripe-payments` |
| **skill-selector** | Filter relevant skills | Hide python skills when web-app-db active |
| **Preference extensions** | Lightweight conventions | Contracts-first, testing patterns |

---

## 2. Goals

### 2.1 Primary Goal
**Improve code quality through stricter TDD enforcement** - Ensure tests are written before implementation, verified to fail first, and tracked throughout the development process.

### 2.2 Secondary Goals
1. **Comprehensive Testing** - Provide structured edge case checklists that developers can reference
2. **Token Savings** - Reduce wasted tokens from wrong-direction implementation by catching issues earlier
3. **Safe Code Review** - Enable read-only code audits without risk of accidental modification
4. **CI/CD Guidance** - Help developers set up quality gates and automation
5. **Documentation** - Provide clear architecture documentation for plugin maintainers and users

### 2.3 Success Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| TDD compliance tracking | 80%+ of implementations | Self-review reports include TDD verification |
| Edge case reference usage | Referenced in testing tasks | Grep for edge case patterns in session logs |
| code-review skill invocations | 20%+ of review requests | Skill usage tracking |
| Token savings on wrong-direction work | 30% reduction | Compare before/after on similar tasks |
| Architecture doc completeness | 100% of system documented | Manual review |

---

## 3. User Stories

### 3.1 As a developer implementing a new feature...
**I want** sc-agent to enforce that I write failing tests before implementation
**So that** I don't waste tokens implementing the wrong solution and have confidence my tests are meaningful

**Acceptance Criteria:**
- sc-agent explicitly prompts for test creation before implementation code
- Tests are verified to fail before proceeding
- Progress shows "Tests passing: X/Y" format
- TDD can be skipped with explicit acknowledgment for trivial changes

### 3.2 As a developer writing tests...
**I want** a comprehensive edge case checklist in sc-quality
**So that** I don't forget common edge cases like null handling, boundary values, or security inputs

**Acceptance Criteria:**
- Edge case checklist organized by category (boundary, null, strings, async, dates, currency)
- Checklist includes security-relevant edge cases (SQL injection, XSS, path traversal)
- Stack-specific testing patterns appear when preferences are loaded

### 3.3 As a developer reviewing code...
**I want** a read-only code review skill that cannot modify files
**So that** I can safely audit code without risk of accidental changes

**Acceptance Criteria:**
- code-review skill uses allowed-tools restriction [Read, Grep, Glob]
- Skill provides structured review output with severity levels
- Skill includes security checklist (OWASP top 10)
- Skill explicitly reminds "DO NOT MODIFY FILES"

### 3.4 As a developer setting up CI/CD...
**I want** a preference template with CI/CD patterns
**So that** I can quickly set up quality gates, pre-commit hooks, and GitHub Actions

**Acceptance Criteria:**
- Template is stack-agnostic (patterns, not specific implementations)
- Includes pre-commit hooks pattern
- Includes GitHub Actions workflow template
- Includes quality gates configuration

### 3.5 As a plugin maintainer or new user...
**I want** comprehensive architecture documentation
**So that** I understand how all the pieces of jmw-superclaude fit together

**Acceptance Criteria:**
- docs/ARCHITECTURE.md explains skill system, preferences, hooks
- Includes visual diagram of skill relationships
- Explains preference-injection pattern
- Covers session lifecycle and delegation patterns

---

## 4. Functional Requirements

### 4.1 TDD Enforcement in sc-agent (FR-1)

**FR-1.1: Test-First Verification**
The sc-agent skill MUST prompt for test creation before implementation code is written. The skill MUST verify tests fail before proceeding to implementation.

**Implementation Detail:**
```markdown
#### C. Test-Driven Development (ALL tasks)
ALWAYS write tests first - this is the default workflow:

1. **Create test file BEFORE implementation:**
   - Identify test file location
   - Write test cases for success path
   - Write test cases for edge cases (reference sc-quality edge case checklist)
   - Run tests - MUST FAIL (proves tests are meaningful)
   - Log: "Tests written: X test cases, all failing as expected"

2. **Implement to pass tests:**
   - Write MINIMAL code to pass tests
   - Run tests after each change
   - Track: "Tests passing: X/Y"
   - NEVER modify tests to make them pass (except fixing bugs in tests)

3. **Skip TDD escape hatch (trivial changes only):**
   If the change is trivial (typo fix, comment update, config change), you may skip TDD:
   - Log: "Skipping TDD: [reason] - trivial change"
   - Proceed directly to implementation
   - Still run existing tests after change
```

**FR-1.2: TDD Progress Tracking**
The sc-agent MUST display TDD progress in the format "Tests passing: X/Y" during implementation.

**FR-1.3: TDD Verification in Self-Review**
The self-review skill MUST include a TDD compliance question that verifies:
- Tests were created before implementation
- Tests failed initially (proving they're meaningful)
- No test modifications were made to pass tests

### 4.2 Edge Case Reference in sc-quality (FR-2)

**FR-2.1: Edge Case Checklist**
The sc-quality skill MUST include a comprehensive edge case reference checklist organized by category.

**Required Categories:**
1. **Boundary Values** - Empty inputs, zero, negative numbers, max values, off-by-one
2. **Null/Undefined Handling** - null, undefined, missing properties, nested nulls
3. **Special Strings** - Unicode, very long strings, whitespace only, SQL injection, XSS, path traversal
4. **Async Edge Cases** - Timeout, concurrent requests, cancellation, out-of-order responses, retry exhaustion
5. **Date/Time** - Timezone, DST, leap years, invalid dates, epoch, far future/past
6. **Currency/Numbers** - Zero amounts, negative amounts, rounding, large values, floating point precision

**FR-2.2: Stack-Specific Testing via Preference Extensions**
Testing patterns MUST be extendable through preference files. When a preference file is loaded, its `## Skill Extensions > ### sc-quality Extensions` section provides stack-specific testing guidance.

**Example for web-app-db.md:**
```markdown
## Skill Extensions

### sc-quality Extensions
**React/Next.js Testing Patterns:**
- Use React Testing Library (not Enzyme)
- Test user behavior, not implementation details
- Server Components: Test via integration tests, not unit tests
- Server Actions: Mock database client, test return types match ActionState<T>
- Mock Clerk auth with @clerk/testing package
- Mock Stripe with stripe-mock or manual mocks

**Supabase Testing:**
- Use test database with RLS disabled for unit tests
- Test RLS policies separately with policy-specific tests
- Mock Supabase client for component tests
```

### 4.3 New code-review Skill (FR-3)

**FR-3.1: Tool Restrictions**
The code-review skill MUST use allowed-tools restriction in its frontmatter:
```yaml
---
name: code-review
description: Reviews code for correctness, security, performance, and conventions. Read-only - does not modify files.
allowed-tools: [Read, Grep, Glob]
---
```

**FR-3.2: Review Structure**
The code-review skill MUST provide:
1. When to Use / When NOT to Use guidance
2. Review process sections: Scope, Correctness, Security, Performance, Conventions
3. Security checklist (OWASP top 10 relevant items)
4. Output format with: Strengths, Issues by Priority (Critical/High/Medium/Low), Suggested Tests, Refactor Suggestions

**FR-3.3: No Modification Reminders**
The skill MUST include explicit "DO NOT MODIFY FILES" reminders at multiple points in the skill definition.

**FR-3.4: Integration with sc-workflows**
The sc-workflows skill (Task 8: Review & Validation Workflow) MUST reference the code-review skill:
```markdown
**For dedicated code review:** Use the **@code-review** skill for read-only review with tool restrictions.
```

### 4.4 CI/CD Preference Template (FR-4)

**FR-4.1: Template Location**
Create `preferences/cicd-template.md` containing stack-agnostic CI/CD patterns.

**FR-4.2: Required Content**
The template MUST include:

1. **Pre-commit Hooks Pattern**
```markdown
## Pre-commit Hooks

**Pattern:** Run linting and formatting before commits

**Tools:**
- Husky (git hooks)
- lint-staged (run linters on staged files only)

**Configuration Example:**
```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
```

2. **GitHub Actions Workflow Template**
```markdown
## GitHub Actions

**Pattern:** Run quality checks on every PR

```yaml
name: Quality Gates
on: [pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup (Node/Python/etc)
      - name: Install dependencies
      - name: Type check
      - name: Lint
      - name: Test with coverage
      - name: Coverage threshold check
      - name: Security audit
```

3. **Quality Gates Configuration**
```markdown
## Quality Gates

**Required checks before merge:**
- [ ] All tests pass
- [ ] Coverage >= 80%
- [ ] No high/critical security vulnerabilities
- [ ] Linter passes (no errors)
- [ ] Type check passes

**Blocking vs Non-Blocking:**
- BLOCKING: Tests, security vulnerabilities
- NON-BLOCKING: Coverage warnings, lint warnings
```

4. **Environment Variables Management**
```markdown
## Environment Variables

**Patterns:**
- Use `.env.example` with placeholder values (committed)
- Use `.env.local` for actual values (gitignored)
- CI/CD: Store secrets in GitHub Secrets / Vercel Environment Variables
- Never commit actual secrets
```

### 4.5 Architecture Documentation (FR-5)

**FR-5.1: Create docs/ARCHITECTURE.md**
Create comprehensive architecture documentation that explains how the entire jmw-superclaude system works.

**FR-5.2: Required Sections**

1. **System Overview** - What jmw-superclaude is and its purpose
2. **Component Architecture** - Skills, preferences, hooks, scripts
3. **Skill System** - How skills are discovered, loaded, and invoked
4. **Preference-Injection Pattern** - How preferences extend skills with stack-specific content
5. **Skill Relationships Diagram** - Visual showing which skills delegate to which
6. **Session Lifecycle** - How a typical session flows through skills
7. **Hooks System** - SessionEnd hooks, notifications
8. **Token Optimization** - How repo-index and confidence-check save tokens
9. **Extension Points** - How users can add custom preferences or skills

**FR-5.3: Diagram Requirements**
Include ASCII or Mermaid diagrams showing:
- Skill delegation flow (sc-agent -> confidence-check -> deep-research -> self-review)
- Preference loading mechanism
- Session lifecycle

### 4.6 Self-Review TDD Verification (FR-6)

**FR-6.1: New TDD Compliance Question**
Add to self-review skill after Question 1 (Tests/Validation Executed):

```markdown
### Question 1b: TDD Compliance Verified?

**Required:** Confirm tests were written BEFORE implementation

**Verification Checklist:**
- [ ] Test file created before implementation code
- [ ] Tests failed on first run (proves they're meaningful)
- [ ] No test modifications made to force passing
- [ ] Or: TDD skipped (trivial change) - reason documented

**Format:**
```
TDD Compliance:
- Tests created: [before/after implementation]
- Initial failure confirmed: [Yes/No/Skipped]
- Test modifications during implementation: [None/Describe]

If TDD Skipped:
- Reason: [why skipped]
- Classification: [trivial change type]
```

**If TDD was NOT followed (and not trivial):**
- Flag as deviation
- Document impact on confidence
- Recommend adding tests retroactively
```

### 4.7 Preference File Extensions Structure (FR-7)

**FR-7.1: Standard Extension Format**
Preference files MAY include a `## Skill Extensions` section with subsections for each skill they extend:

```markdown
## Skill Extensions

### sc-agent Extensions
[Stack-specific guidance for sc-agent]

### sc-quality Extensions
[Stack-specific testing patterns]

### confidence-check Extensions
[Stack-specific checks to include]
```

**FR-7.2: Update Existing Preferences**
Update web-app-db.md and python-backend.md to include `## Skill Extensions` sections with stack-specific content.

### 4.8 Nested Skills Directory Structure (FR-8)

**FR-8.1: Create Nested Directory Structure**
Reorganize the skills/ directory into a nested structure:

```
skills/
├── _SKILL-INDEX.md              # Human-readable index
├── core/                        # Stack-agnostic skills
│   ├── sc-agent/SKILL.md
│   ├── sc-quality/SKILL.md
│   ├── confidence-check/SKILL.md
│   ├── self-review/SKILL.md
│   ├── deep-research/SKILL.md
│   ├── repo-index/SKILL.md
│   ├── index-repo/SKILL.md
│   ├── create-prd/SKILL.md
│   ├── generate-tasks/SKILL.md
│   ├── skill-selector/SKILL.md
│   ├── session-summary/SKILL.md
│   ├── sc-executor/SKILL.md
│   ├── sc-architecture/SKILL.md
│   ├── sc-security/SKILL.md
│   ├── sc-performance/SKILL.md
│   ├── sc-workflows/SKILL.md
│   └── code-review/SKILL.md
├── web-app-db/                  # Next.js + Supabase stack
│   ├── clerk-auth/SKILL.md
│   ├── stripe-payments/SKILL.md
│   ├── supabase-rls/SKILL.md
│   ├── nextjs-api/SKILL.md
│   └── react-testing/SKILL.md
└── python-backend/              # FastAPI + SQLAlchemy stack
    ├── fastapi-crud/SKILL.md
    └── pytest-async/SKILL.md
```

**FR-8.2: Update marketplace.json**
Explicitly enumerate all skill paths in marketplace.json:

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
    "./core/code-review",
    "./web-app-db/clerk-auth",
    "./web-app-db/stripe-payments",
    "./web-app-db/supabase-rls",
    "./web-app-db/nextjs-api",
    "./web-app-db/react-testing",
    "./python-backend/fastapi-crud",
    "./python-backend/pytest-async"
  ]
}
```

**FR-8.3: Add Stack Field to All Frontmatter**
All skills MUST include a `stack:` field in their YAML frontmatter:

Core skills:
```yaml
---
name: sc-agent
description: Task orchestration with confidence-driven development
stack: all
---
```

Stack-specific skills:
```yaml
---
name: clerk-auth
description: Clerk authentication patterns for Next.js
stack: web-app-db
---
```

**FR-8.4: Create _SKILL-INDEX.md**
Create a human-readable index file at `skills/_SKILL-INDEX.md` listing all skills by stack for easy browsing.

### 4.9 Stack-Specific Skills: Web App (FR-9)

**FR-9.1: clerk-auth Skill**
**Location:** `skills/web-app-db/clerk-auth/SKILL.md`
**Content:**
- Clerk setup and configuration
- Middleware patterns for route protection
- Session handling in Server Components
- Testing with @clerk/testing mocks
- User metadata and organization patterns

**FR-9.2: stripe-payments Skill**
**Location:** `skills/web-app-db/stripe-payments/SKILL.md`
**Content:**
- Stripe checkout integration
- Webhook handling and signature verification
- Subscription management patterns
- Testing with stripe-mock
- Customer portal integration

**FR-9.3: supabase-rls Skill**
**Location:** `skills/web-app-db/supabase-rls/SKILL.md`
**Content:**
- Row Level Security policy patterns
- Multi-tenant RLS policies
- Testing RLS policies
- Migration workflow for policies
- Common RLS mistakes to avoid

**FR-9.4: nextjs-api Skill**
**Location:** `skills/web-app-db/nextjs-api/SKILL.md`
**Content:**
- Route Handler patterns (GET, POST, PUT, DELETE)
- Server Action patterns with ActionState<T>
- Zod validation integration
- Error handling patterns
- Response formatting

**FR-9.5: react-testing Skill**
**Location:** `skills/web-app-db/react-testing/SKILL.md`
**Content:**
- React Testing Library patterns
- Server Component testing strategies
- Client Component testing with mocks
- Integration testing with MSW
- Playwright E2E patterns for Next.js

### 4.10 Stack-Specific Skills: Python Backend (FR-10)

**FR-10.1: fastapi-crud Skill**
**Location:** `skills/python-backend/fastapi-crud/SKILL.md`
**Content:**
- CRUD endpoint patterns
- Pydantic schema patterns (Base/Create/Update/Response/InDB)
- Dependency injection patterns
- Error handling with HTTPException
- Response model patterns

**FR-10.2: pytest-async Skill**
**Location:** `skills/python-backend/pytest-async/SKILL.md`
**Content:**
- Async test patterns with pytest-asyncio
- SQLAlchemy async session fixtures
- FastAPI TestClient usage
- Database rollback patterns for tests
- Mocking external services

### 4.11 Enhanced skill-selector with Stack Awareness (FR-11)

**FR-11.1: Stack Detection**
The skill-selector MUST detect the active stack from:
1. Loaded preference file (if web-app-db.md → stack is web-app-db)
2. Project files (package.json → web, pyproject.toml → python)
3. User explicit specification

**FR-11.2: Stack-Aware Filtering**
When recommending skills, skill-selector MUST:
1. Always show core skills (stack: all)
2. Show stack-specific skills matching the active stack
3. Hide skills from other stacks
4. Group output by category (Core vs Stack-specific)

**FR-11.3: Output Format**
```markdown
## Recommended Skills

### Core Skills
- sc-agent → for implementation orchestration
- confidence-check → for pre-implementation assessment

### Web App Skills (web-app-db)
- clerk-auth → for authentication setup
- stripe-payments → for payment integration
- supabase-rls → for database security

(Python skills hidden - not active stack)
```

### 4.12 Flow Documentation in sc-architecture (FR-12)

**FR-12.1: User Flow Documentation**
The sc-architecture skill MUST document assumed user flows before implementation (where applicable):
- Step-by-step user journey through the feature
- Arrow notation: "Step 1 → Step 2 → Step 3"
- Example: "User clicks 'Subscribe' → Stripe checkout → webhook confirms → user sees premium content"

**FR-12.2: Data Flow Documentation**
The sc-architecture skill MUST document assumed data flows before implementation (where applicable):
- How data moves through the system
- Include transforms and validations
- Example: "Form submit → Server Action → validate with Zod → Supabase insert → revalidate path → return ActionState"

**FR-12.3: User Review Gate**
After documenting flows, the skill MUST prompt the user to review before proceeding:
```markdown
## Assumed Flows

### User Flow
1. [Step] → 2. [Step] → 3. [Step]

### Data Flow
[Source] → [Transform] → [Destination]

⚠️ Please review these assumed flows before I proceed with implementation.
```

**FR-12.4: Skip Criteria**
Flow documentation MAY be skipped for:
- Pure infrastructure changes (CI/CD config, environment setup)
- Changes with no user-facing or data flow implications

**Rationale:** Making flow assumptions explicit gives users the opportunity to review and correct misunderstandings before implementation begins - prevents wrong-direction work (same philosophy as confidence-check).

---

## 5. Non-Goals (Out of Scope)

### 5.1 Stack-Specific Skills - REVISED
~~The following will NOT be created as separate skills~~ **SUPERSEDED**

**NEW DECISION:** Stack-specific skills WILL be added using a nested directory structure. See FR-8 and FR-9 for details.

**Evidence:** The [anthropics/skills](https://github.com/anthropics/skills) repository uses nested structure (`document-skills/pdf/`, `document-skills/docx/`) proving this pattern is supported.

### 5.2 Contract-First as Core Skill Content
Contract-first development will NOT be added to any core skill (confidence-check, sc-agent, etc.).

**Rationale:**
- Contracts (Zod schemas, Pydantic models) are stack-specific patterns
- web-app-db and python-backend stacks use contracts; simpler stacks (multi-agent-orchestration) do not
- Adding to core skills would impose patterns that don't apply universally

**Instead:** Add contracts-first guidance to stack preference Skill Extensions (FR-7.2):
- `preferences/web-app-db.md` → "Define Zod schemas before API implementation"
- `preferences/python-backend.md` → "Define Pydantic schemas before endpoint implementation"

### 5.3 Separate sc-tdd Skill
A dedicated TDD skill will NOT be created.

**Rationale:** TDD enforcement belongs in sc-agent (orchestrator) and testing guidance in sc-quality. Creating a separate skill would fragment the workflow.

### 5.4 Hard TDD Blocking
TDD will NOT hard-block implementation for trivial changes.

**Rationale:** User requirement specifies "strong recommendation with explicit skip escape hatch" to avoid friction on truly trivial changes.

### 5.5 Command Files in Plugin
Custom command files (`.claude/commands/*.md`) will NOT be added to the plugin.

**Rationale:** Commands are user-specific workflow shortcuts. Users can create their own as needed.

---

## 6. Design Considerations

### 6.1 Preference-Injection Architecture

**Pattern Overview:**
```
┌─────────────────────────────────────────────────────────────┐
│                    jmw-superclaude Plugin                    │
├─────────────────────────────────────────────────────────────┤
│  skills/                                                     │
│  ├── sc-agent/SKILL.md      (stack-agnostic orchestrator)   │
│  ├── sc-quality/SKILL.md    (stack-agnostic testing)        │
│  ├── code-review/SKILL.md   (stack-agnostic review)         │
│  └── ...                                                     │
├─────────────────────────────────────────────────────────────┤
│  preferences/                                                │
│  ├── web-app-db.md          (Next.js + Supabase specifics)  │
│  │   └── ## Skill Extensions                                │
│  │       ├── ### sc-agent Extensions                        │
│  │       ├── ### sc-quality Extensions                      │
│  │       └── ### confidence-check Extensions                │
│  ├── python-backend.md      (FastAPI + SQLAlchemy specifics)│
│  │   └── ## Skill Extensions                                │
│  └── cicd-template.md       (CI/CD patterns - stack-agnostic)│
└─────────────────────────────────────────────────────────────┘
```

**How It Works at Runtime:**
1. User starts session in a project
2. Claude detects project type (Next.js, Python, etc.) or user specifies preference
3. Relevant preference file is loaded
4. When skills are invoked, they have access to preference content
5. Skills reference their extensions from the loaded preference

### 6.2 Tool Restriction Implementation

**For code-review skill:**
```yaml
---
name: code-review
allowed-tools: [Read, Grep, Glob]
---
```

The `allowed-tools` frontmatter restricts which tools the skill can use. This is enforced by Claude Code's skill system.

**Restricted Tools (for code-review):**
- Edit (file modification)
- Write (file creation)
- Bash (command execution that could modify files)
- NotebookEdit (notebook modification)

### 6.3 TDD Skip Escape Hatch Design

**Decision:** Strong recommendation with explicit skip acknowledgment

**Implementation:**
```markdown
**TDD Skip Criteria (trivial changes only):**
- Typo fixes in comments or strings
- Configuration value changes
- README/documentation updates
- Import organization/formatting

**When skipping TDD:**
1. Explicitly state: "Skipping TDD: [reason]"
2. Classify change as one of the above types
3. Still run existing tests after change
4. Log in output: "TDD skipped (trivial): [classification]"
```

This provides flexibility without undermining TDD as the default.

---

## 7. Technical Considerations

### 7.1 File Changes Summary

#### Phase 0: Directory Restructuring

| File | Action | Priority | Notes |
|------|--------|----------|-------|
| `skills/core/` | CREATE DIR | MUST | New directory for core skills |
| `skills/web-app-db/` | CREATE DIR | MUST | New directory for web stack skills |
| `skills/python-backend/` | CREATE DIR | MUST | New directory for python stack skills |
| `skills/*/SKILL.md` (16 files) | MOVE | MUST | Move existing skills to core/ |
| `.claude-plugin/marketplace.json` | UPDATE | MUST | Add explicit skill paths |
| `skills/_SKILL-INDEX.md` | CREATE | SHOULD | Human-readable skill index |

#### Core Skill Updates

| File | Action | Priority | Estimated Tokens |
|------|--------|----------|------------------|
| `skills/core/sc-agent/SKILL.md` | UPDATE | MUST | +200-300 |
| `skills/core/sc-quality/SKILL.md` | UPDATE | MUST | +400-500 |
| `skills/core/self-review/SKILL.md` | UPDATE | MUST | +100-150 |
| `skills/core/sc-workflows/SKILL.md` | UPDATE | SHOULD | +50-100 |
| `skills/core/skill-selector/SKILL.md` | UPDATE | MUST | +300-400 |
| `skills/core/sc-architecture/SKILL.md` | UPDATE | MUST | +200-300 |
| `skills/core/code-review/SKILL.md` | CREATE | MUST | +1500-2000 |

#### Stack-Specific Skills (NEW)

| File | Action | Priority | Estimated Tokens |
|------|--------|----------|------------------|
| `skills/web-app-db/clerk-auth/SKILL.md` | CREATE | MUST | +1000-1500 |
| `skills/web-app-db/stripe-payments/SKILL.md` | CREATE | MUST | +1000-1500 |
| `skills/web-app-db/supabase-rls/SKILL.md` | CREATE | MUST | +1000-1500 |
| `skills/web-app-db/nextjs-api/SKILL.md` | CREATE | SHOULD | +800-1200 |
| `skills/web-app-db/react-testing/SKILL.md` | CREATE | SHOULD | +800-1200 |
| `skills/python-backend/fastapi-crud/SKILL.md` | CREATE | SHOULD | +800-1200 |
| `skills/python-backend/pytest-async/SKILL.md` | CREATE | SHOULD | +600-900 |

#### Preferences & Documentation

| File | Action | Priority | Estimated Tokens |
|------|--------|----------|------------------|
| `preferences/web-app-db.md` | UPDATE | SHOULD | +300-400 |
| `preferences/python-backend.md` | UPDATE | SHOULD | +300-400 |
| `preferences/cicd-template.md` | CREATE | SHOULD | +500-700 |
| `docs/ARCHITECTURE.md` | CREATE | MUST | +1500-2000 |
| `docs/plugin-development.md` | UPDATE | MUST | +400-600 |
| `docs/templates/adr-template.md` | CREATE | SHOULD | +200-300 |
| `CLAUDE.md` | UPDATE | MUST | +200-300 |

**Total Estimated Token Impact:** ~12000-17000 additional tokens across all files (including 7 new stack-specific skills)

### 7.2 Token Impact Analysis

**Per-Session Impact:**
- If all updated skills are loaded: +700-950 tokens
- If code-review skill loaded: +1500-2000 tokens
- If CI/CD preference loaded: +500-700 tokens

**ROI Justification:**
- confidence-check saves 5,000-50,000 tokens per wrong-direction catch
- TDD enforcement catches errors earlier, saving rework tokens
- Edge case checklist reduces missed bugs (costly to fix later)

### 7.3 Dependencies

**No External Dependencies Added**
- All changes are markdown content
- No new tools or integrations required
- Uses existing Claude Code skill system features (allowed-tools)

**Internal Dependencies:**
- code-review skill depends on allowed-tools frontmatter feature
- Preference extensions depend on skill loading mechanism
- Self-review TDD check depends on sc-agent TDD enforcement

### 7.4 Backward Compatibility

**Fully Backward Compatible:**
- Existing skills continue to work unchanged
- New features are additive
- Preference extensions are optional
- TDD skip escape hatch ensures no workflow blocking

---

## 8. Success Metrics

### 8.1 Adoption Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| TDD compliance in implementations | 80%+ | Self-review reports with TDD verification |
| code-review skill usage | 20%+ of review requests | Skill invocation tracking |
| Edge case checklist reference | Used in testing tasks | Pattern matching in outputs |
| CI/CD template usage | Downloaded/copied by users | Manual feedback |

### 8.2 Quality Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Reduced rework from missed edge cases | 25% fewer | Compare before/after on similar tasks |
| Earlier defect detection | Defects caught in testing vs production | User feedback |
| Clear audit trail in reviews | 100% structured output | code-review skill validation |
| Token savings | 30% on investigation phase | Compare before/after |

### 8.3 Validation Criteria

| Criteria | Validation Method |
|----------|-------------------|
| All skills remain under 5K tokens | Token count per skill file |
| No circular dependencies | Skill reference analysis |
| Documentation references accurate | Manual link checking |
| allowed-tools restriction works | Test code-review skill |
| Preference extensions load correctly | Test with sample preferences |

---

## 9. Open Questions

### 9.1 Technical Questions

1. **allowed-tools Enforcement:** How strictly does Claude Code enforce the allowed-tools restriction? Can it be bypassed? Need to test thoroughly.

2. **Preference Auto-Detection:** Should skills automatically detect and load relevant preferences based on project structure, or require explicit user specification?

3. **Extension Merging:** If multiple preferences are loaded, how should conflicting skill extensions be handled? (First wins? Merge? Error?)

### 9.2 Content Questions

4. **Edge Case Completeness:** Is the proposed edge case checklist comprehensive enough, or are there important categories missing?

5. **Security Checklist Scope:** Should the code-review security checklist include all OWASP Top 10, or focus on the most relevant items for code review?

6. **CI/CD Template Depth:** How much detail should the CI/CD template provide? High-level patterns only, or include copy-paste ready configurations?

### 9.3 Process Questions

7. **TDD Skip Criteria:** Are the proposed "trivial change" categories too narrow or too broad? Should users be able to define their own criteria?

8. **Architecture Doc Maintenance:** Who will maintain docs/ARCHITECTURE.md as the plugin evolves? Should it auto-generate from skill files?

### 9.4 Future Enhancements (Out of Current Scope)

9. **Skill-Aware Task Generation:** Enhance generate-tasks to recommend which skill should be used for each generated task. Currently, generate-tasks outputs tasks like "Implement login endpoint" without specifying the skill. A skill-aware version would output "Implement login endpoint → use sc-agent (with TDD)". This would make task lists more actionable and ensure skills are used consistently.

   **Example Enhancement:**
   ```
   Current:
   1. Design auth database schema
   2. Implement login endpoint
   3. Security review

   Skill-Aware:
   1. Design auth database schema → use sc-architecture
   2. Implement login endpoint → use sc-agent
   3. Security review → use sc-security
   4. Validate implementation → use self-review
   ```

   **Note:** Not needed for the current PRD (editing markdown files), but valuable for general feature development workflows.

---

## 10. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **TDD slows simple changes** | Medium | Low | Escape hatch for trivial changes documented in sc-agent |
| **allowed-tools not enforced** | Low | High | Thorough testing of code-review skill before release |
| **Edge case checklist too long** | Medium | Medium | Organize by category, allow filtering |
| **Stack-specific content creep** | Medium | Medium | Review PRs for scope creep, keep skills focused |
| **Nested directory structure complexity** | Low | Medium | Clear documentation in ARCHITECTURE.md |
| **marketplace.json maintenance burden** | Medium | Low | Document update process, consider automation |
| **skill-selector as critical path** | High | High | Task 1.6 reviews and simplifies; must be reliable |
| **Format mismatch with sc-executor** | Low | Medium | Test with Phase 0 first before full execution |

**Key Risk:** skill-selector is now mandatory (per CLAUDE.md). If it fails to recommend the right skill, the entire workflow breaks. Task 1.6 addresses this by reviewing and simplifying skill-selector.

---

## 11. Implementation Phases

### Phase 1: Core Skill Updates
- [ ] Update sc-agent with TDD enforcement (FR-1)
- [ ] Add edge case checklist to sc-quality (FR-2.1)
- [ ] Add TDD verification to self-review (FR-6)
- [ ] Add flow documentation to sc-architecture (FR-12)

### Phase 2: New Skill & Templates (Week 2)
- [ ] Create code-review skill (FR-3)
- [ ] Create CI/CD preference template (FR-4)
- [ ] Update sc-workflows to reference code-review (FR-3.4)

### Phase 3: Preference Extensions & Documentation (Week 3)
- [ ] Add skill extensions to web-app-db.md (FR-7.2)
- [ ] Add skill extensions to python-backend.md (FR-7.2)
- [ ] Create docs/ARCHITECTURE.md (FR-5)
- [ ] Update CLAUDE.md with new references

### Phase 4: Testing & Polish (Week 4)
- [ ] Test all updated skills
- [ ] Validate allowed-tools restriction works
- [ ] Review and refine documentation
- [ ] Gather user feedback

---

## 12. Appendices

### Appendix A: Research Sources

- `archive/research-driven-best-practices-2025-11/CLAUDE.md` - Stack-specific workflow patterns
- `archive/research-driven-best-practices-2025-11/claude/skills/*.md` - Skill patterns from research
- `docs/building-robust-systems-guide.md` - Best practices guide (moved to active docs)

### Appendix B: Related Documents

- `CLAUDE.md` - Main plugin documentation
- `docs/plugin-development.md` - Plugin development guide
- Existing preference files in `preferences/`

### Appendix C: Decision Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Separate code-review skill? | Yes | Read-only tool restriction requires dedicated skill |
| Separate sc-tdd skill? | No | TDD is orchestration (sc-agent) + testing (sc-quality) |
| Contract-first in core skills? | No | Stack-specific pattern; belongs in preference Skill Extensions |
| **Stack-specific skills?** | **YES (REVISED)** | **Nested directory structure proven by anthropics/skills repo** |
| **Nested skill directories?** | **YES** | **Evidence: anthropics/skills uses document-skills/pdf/ pattern** |
| Hard TDD block? | No | User requested escape hatch for trivial changes |
| Commands in plugin? | No | User-specific workflow, not plugin content |
| CI/CD as skill vs preference? | Preference template | Not a workflow, just reference patterns |
| Skill organization method? | Nested directories | Visual org + frontmatter stack: field + smart skill-selector |
| marketplace.json maintenance? | Explicit enumeration | Required for nested skills, acceptable tradeoff |

### Appendix D: Glossary

| Term | Definition |
|------|------------|
| Preference-Injection | Pattern where preferences extend core skills with stack-specific content |
| TDD | Test-Driven Development - write tests before implementation |
| Skill Extensions | Sections in preference files that add content to core skills |
| allowed-tools | YAML frontmatter restricting which tools a skill can use |
| Edge Case | Input or scenario at the boundary of expected behavior |
| Quality Gate | Automated check that must pass before code can be merged |
