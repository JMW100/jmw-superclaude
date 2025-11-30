# Assessment: Research Best Practices vs jmw-superclaude

## Executive Summary

After deep analysis of the research-driven best practices and existing jmw-superclaude skills, this assessment identifies **high-value general patterns** to incorporate while evolving jmw-superclaude's architecture to support **both stack-agnostic core skills AND stack-specific skills**.

**Key Finding:** The research best practices are optimized for a specific stack (Next.js + Supabase + Vercel). Rather than excluding this stack-specific content, jmw-superclaude will adopt a **nested directory structure** that organizes skills by stack, with core generic skills separated from stack-specific skills.

**Architectural Decision:** Use nested skill directories (proven pattern from [anthropics/skills](https://github.com/anthropics/skills) repository) to organize skills by stack while keeping them in a single plugin.

---

## Category Analysis

### 1. What Should Be CHANGED (Existing Skills Need Updates)

#### 1.1 sc-agent: Strengthen TDD Enforcement
**Current State:** TDD is mentioned in Step 4 but not enforced systematically
**Research Gap:** Research shows TDD with explicit "write failing tests first, then implement" as a core pattern
**Recommendation:**
- Add explicit TDD phase with test-first requirement
- Add "tests must fail before implementation begins" gate
- Track test creation as separate task from implementation

#### 1.2 sc-quality: Add Edge Case Reference
**Current State:** Generic testing guidance without comprehensive edge case patterns
**Research Gap:** Research includes detailed edge-cases.md with boundary values, null handling, async patterns, security inputs
**Recommendation:**
- Add comprehensive edge case checklist to sc-quality
- Include property-based testing patterns (fast-check)
- Add domain-specific edge cases (dates, currency, strings, etc.)

#### 1.3 confidence-check: Contract-First is Stack-Specific (NO CHANGE)
**Current State:** 5 checks (duplicates, architecture, docs, OSS, root cause)
**Research Gap:** Research emphasizes contract-first development (define schemas before implementation)
**Decision:** Contracts-first does NOT belong in core skills.

**Rationale:**
- Contracts (Zod schemas, Pydantic models) apply to web-app-db and python-backend stacks
- Simpler stacks (multi-agent-orchestration) don't use contract-first patterns
- Adding to core skills would impose patterns that don't apply universally

**Recommendation:**
- Keep confidence-check's 5 checks unchanged
- Add contracts-first guidance to **stack preference Skill Extensions**:
  - `preferences/web-app-db.md` → "Define Zod schemas before API implementation"
  - `preferences/python-backend.md` → "Define Pydantic schemas before endpoint implementation"

#### 1.4 self-review: Strengthen Test Verification
**Current State:** Question 1 asks "Tests/Validation Executed?" but doesn't verify TDD was followed
**Research Gap:** Research emphasizes verifying tests existed BEFORE implementation
**Recommendation:**
- Add verification that tests were written first (TDD compliance)
- Ask "Were tests written before implementation?"

#### 1.5 skill-selector: Add Stack Awareness
**Current State:** Recommends skills based on task type only
**Research Gap:** No filtering based on active stack/preference
**Recommendation:**
- Detect active stack from loaded preference or project files
- Filter skill recommendations to show only relevant stack skills
- Group output by category (core vs stack-specific)

#### 1.6 sc-architecture: Add Flow Documentation
**Current State:** Focuses on system design, APIs, databases, infrastructure
**Gap:** No explicit step to document assumed user flows and data flows before implementation
**Why Add:** Making flow assumptions explicit gives user opportunity to review and correct before implementation begins - prevents wrong-direction work (same philosophy as confidence-check)
**Recommendation:**
- Add "Flow Documentation" section requiring explicit user/data flow documentation
- User Flow: Step-by-step user journey (e.g., "User clicks Subscribe → Stripe checkout → webhook confirms → premium content")
- Data Flow: How data moves through system (e.g., "Form → Server Action → Zod validate → Supabase insert → revalidate")
- Prompt user to review flows before proceeding
- Skip for pure infrastructure changes with no user-facing or data flow

---

### 2. What Should Be ADDED (New Skills/Content Needed)

#### 2.1 ARCHITECTURAL CHANGE: Nested Skill Directory Structure
**Research Evidence:** [anthropics/skills](https://github.com/anthropics/skills) repository uses nested structure with `document-skills/pdf/`, `document-skills/docx/`, etc.
**Why Add:** Enables stack-specific skills while maintaining organization
**Implementation:**
```
skills/
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
│   └── code-review/SKILL.md     # NEW
├── web-app-db/                  # Next.js + Supabase stack
│   ├── clerk-auth/SKILL.md      # NEW
│   ├── stripe-payments/SKILL.md # NEW
│   ├── supabase-rls/SKILL.md    # NEW
│   ├── nextjs-api/SKILL.md      # NEW
│   └── react-testing/SKILL.md   # NEW
└── python-backend/              # FastAPI + SQLAlchemy stack
    ├── fastapi-crud/SKILL.md    # NEW
    └── pytest-async/SKILL.md    # NEW
```

**Requires:** Explicit enumeration in marketplace.json:
```json
{
  "skills": [
    "./core/sc-agent",
    "./core/sc-quality",
    "./web-app-db/clerk-auth",
    "./web-app-db/stripe-payments",
    "./python-backend/fastapi-crud"
  ]
}
```

#### 2.2 NEW SKILL: code-review (Read-Only)
**Location:** `skills/core/code-review/SKILL.md`
**Research Pattern:** Skill with `allowed-tools: [Read, Grep, Glob]` for safe auditing
**Why Add:** Prevents accidental modifications during review, creates safe audit mode
**Content:**
- Structured review checklist (correctness, security, performance, conventions)
- Tool restrictions enforce read-only mode
- Security checklist specific to common vulnerabilities

#### 2.3 NEW STACK SKILLS: Web App (Next.js + Supabase)
**Location:** `skills/web-app-db/`

| Skill | Purpose | Key Content |
|-------|---------|-------------|
| clerk-auth | Clerk authentication patterns | Setup, middleware, testing mocks, session handling |
| stripe-payments | Stripe integration | Webhooks, checkout, subscriptions, testing |
| supabase-rls | Row Level Security | Policy patterns, testing RLS, migrations |
| nextjs-api | Next.js API patterns | Route Handlers, Server Actions, Zod validation |
| react-testing | React/Next.js testing | RTL, Server Components, mocking patterns |

#### 2.4 NEW STACK SKILLS: Python Backend
**Location:** `skills/python-backend/`

| Skill | Purpose | Key Content |
|-------|---------|-------------|
| fastapi-crud | FastAPI CRUD patterns | Endpoints, Pydantic schemas, dependency injection |
| pytest-async | Async pytest patterns | Fixtures, async tests, SQLAlchemy testing |

#### 2.5 Frontmatter Stack Field
**All skills** should include a `stack:` field in frontmatter:
```yaml
---
name: clerk-auth
description: Clerk authentication patterns for Next.js
stack: web-app-db
---
```

Core skills use `stack: all`:
```yaml
---
name: sc-agent
description: Task orchestration with confidence-driven development
stack: all
---
```

#### 2.6 NEW FEATURE: Commands for Common Workflows
**Research Pattern:** `/project:backend-feature` and `/project:frontend-feature` commands
**Why Add:** Provides explicit workflow entry points that chain skills together
**Proposed Commands:**
- `implement-feature` - chains confidence-check → sc-agent → self-review
- `review-code` - invokes read-only code-review skill
- `write-tests` - invokes sc-quality with edge case checklist

#### 2.7 NEW CONTENT: ADR Template
**Research Pattern:** Architecture Decision Records for documenting decisions
**Why Add:** Complements sc-architecture by providing decision documentation format
**Location:** `docs/templates/adr-template.md`

#### 2.8 NEW PREFERENCE FILE: CI/CD Guidance
**Research Pattern:** Comprehensive cicd-devops skill
**Why Add:** CI/CD is stack-agnostic enough to be generally useful
**Location:** `preferences/cicd-template.md`
**Content:**
- Pre-commit hooks setup (Husky/lint-staged pattern)
- GitHub Actions workflow templates
- Quality gates configuration
- Deployment workflow patterns

#### 2.9 NEW DOCUMENTATION: ARCHITECTURE.md
**Why Add:** Comprehensive human-readable overview of how the plugin works
**Location:** `docs/ARCHITECTURE.md`
**Content:**
- Nested directory structure explanation
- Skill discovery and loading
- Preference-injection pattern
- Stack-aware skill-selector
- Diagrams of skill relationships

#### 2.10 NEW FILE: _SKILL-INDEX.md
**Why Add:** Human-browsable index of all skills organized by stack
**Location:** `skills/_SKILL-INDEX.md`
**Content:**
- Core skills list with descriptions
- Web-app-db skills list
- Python-backend skills list
- Links to each skill

---

### 3. What Should REMAIN THE SAME (Already Excellent)

#### 3.1 confidence-check: Core Pattern
**Status:** ✅ Keep as-is
**Why:** The 5-check weighted scoring system is unique to jmw-superclaude and provides structured pre-implementation assessment. Research doesn't have an equivalent.

#### 3.2 sc-agent: 5-Step Protocol
**Status:** ✅ Keep core structure
**Why:** The Clarify → Plan → Iterate → Implement → Review workflow is comprehensive and well-designed. Only needs TDD strengthening within Step 4.

#### 3.3 deep-research: Wave→Checkpoint→Wave
**Status:** ✅ Keep as-is
**Why:** Unique parallel research pattern not present in research best practices. Provides significant speedup for research tasks.

#### 3.4 session-summary: Log Extraction
**Status:** ✅ Keep as-is
**Why:** Unique capability for maintaining session continuity. Research doesn't address this.

#### 3.5 repo-index / index-repo: Context Compression
**Status:** ✅ Keep as-is
**Why:** Token optimization through repository indexing is valuable and not covered in research.

#### 3.6 self-review: Evidence-Only Pattern
**Status:** ✅ Keep core pattern (enhance TDD verification)
**Why:** The 4-question evidence-based validation is rigorous and effective.

#### 3.7 create-prd / generate-tasks: Opus 4 Planning
**Status:** ✅ Keep as-is
**Why:** Specialized planning skills using higher-capability model not present in research.

#### 3.8 Domain Skills (sc-architecture, sc-security, sc-performance)
**Status:** ✅ Keep as-is (move to core/)
**Why:** Well-structured domain-specific guidance. These are stack-agnostic and belong in core.

#### 3.9 Preferences System Architecture
**Status:** ✅ Keep as-is
**Why:** The separation of stack preferences (web-app-db.md, python-backend.md) from core skills is correct. Preferences continue to provide conventions and skill extensions.

---

### 4. Architectural Decision: Nested Skills (REVISED)

#### Previous Position (SUPERSEDED)
The original assessment recommended NOT adding stack-specific skills, suggesting they belong in user-created preferences only.

#### New Position (ADOPTED)
**Stack-specific skills WILL be added to the plugin** using a nested directory structure, following the pattern established by [Anthropic's official skills repository](https://github.com/anthropics/skills).

**Evidence Supporting This Decision:**
1. `anthropics/skills` repo has `document-skills/pdf/SKILL.md`, `document-skills/docx/SKILL.md` - nested structure works
2. `marketplace.json` explicitly lists nested paths: `"./document-skills/pdf"`
3. Install command supports nested paths: `/plugin install document-skills@anthropic-agent-skills`
4. Claude Code discovers skills via explicit enumeration, not recursive search

**Benefits:**
- Visual organization by stack
- Single plugin with all skills
- Stack membership clear from folder location
- Frontmatter `stack:` field enables smart filtering
- skill-selector can filter by active stack

**Tradeoffs:**
- Must maintain marketplace.json with explicit paths
- Deeper nesting for skill paths
- Need to update existing documentation

---

## Integration Strategy

### Phase 0: Directory Restructuring (NEW - FIRST)
1. Create nested directory structure (core/, web-app-db/, python-backend/)
2. Move all existing skills to core/
3. Update marketplace.json with explicit paths
4. Add `stack: all` to all core skill frontmatter
5. Create _SKILL-INDEX.md for human browsing

### Phase 1: Core Skill Updates
1. Strengthen TDD enforcement in sc-agent
2. Add edge case checklist to sc-quality
3. Add TDD verification question to self-review
4. Enhance skill-selector with stack awareness

### Phase 2: New Core Skills
5. Create code-review skill with tool restrictions
6. Create CI/CD preference template
7. Create ADR template

### Phase 3: Stack-Specific Skills
8. Create web-app-db skills (clerk-auth, stripe-payments, supabase-rls, nextjs-api, react-testing)
9. Create python-backend skills (fastapi-crud, pytest-async)
10. Add skill extensions to preference files

### Phase 4: Documentation & Polish
11. Create docs/ARCHITECTURE.md
12. Update CLAUDE.md with new structure
13. Update docs/plugin-development.md with nested skills guidance
14. Testing and validation

---

## Key Decisions (UPDATED)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Nested skill directories?** | **YES** | Proven by anthropics/skills, enables stack organization |
| **Stack-specific skills in plugin?** | **YES** | User requirement, nested structure makes it clean |
| **Separate sc-tdd skill?** | No | TDD in sc-agent + testing in sc-quality |
| **6th confidence check?** | No | Contracts part of architecture check |
| **CI/CD as skill vs preference?** | Preference | Not a workflow, just reference patterns |
| **Hard TDD blocking?** | No | Escape hatch for trivial changes |

---

## Summary Metrics (UPDATED)

| Category | Count | Items |
|----------|-------|-------|
| **CHANGE** | 6 | sc-agent TDD, sc-quality edge cases, self-review TDD, skill-selector stack-awareness, sc-architecture flow docs, directory structure |
| **ADD (Core)** | 4 | code-review skill, CI/CD template, ADR template, ARCHITECTURE.md |
| **ADD (Stack)** | 7 | clerk-auth, stripe-payments, supabase-rls, nextjs-api, react-testing, fastapi-crud, pytest-async |
| **KEEP** | 9 | confidence-check core, sc-agent core, deep-research, session-summary, repo-index, self-review core, create-prd, generate-tasks, domain skills |
| **RESTRUCTURE** | 16 | All existing skills move to core/ directory |

**Total Impact:** Significant restructuring with nested directory organization, plus focused additions for testing, review, and stack-specific workflows.

---

## Appendix: Research Sources

- [anthropics/skills](https://github.com/anthropics/skills) - Official Anthropic skills repo with nested structure
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference) - Plugin documentation
- [Claude Code Skills](https://code.claude.com/docs/en/skills) - Skills documentation
- `research driven best practices/CLAUDE.md` - Stack-specific workflow patterns
- `research driven best practices/claude/skills/*.md` - Skill patterns from research
- `research driven best practices/docs/building-robust-systems-guide.md` - Best practices guide
