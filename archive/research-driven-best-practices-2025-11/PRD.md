# Product Requirements Document: Best Practices Integration

## Document Info
- **Version:** 1.0
- **Date:** 2025-11-29
- **Status:** Draft - Pending Review

---

## 1. Overview

### 1.1 Problem Statement
Research-driven best practices for LLM-assisted development have identified key patterns that improve code quality, reduce rework, and prevent common errors. jmw-superclaude currently lacks:

1. **Explicit TDD enforcement** - Tests mentioned but not required before implementation
2. **Comprehensive edge case testing** - Generic testing guidance without detailed patterns
3. **Read-only code review mode** - No safe audit capability with tool restrictions
4. **Contract-first development** - No systematic schema-before-implementation pattern

### 1.2 Objectives
1. Strengthen TDD as a core workflow pattern across skills
2. Add comprehensive edge case testing guidance
3. Introduce safe code review with tool restrictions
4. Provide templates for common patterns (ADRs, CI/CD)
5. Maintain stack-agnostic philosophy (no specific frameworks)

### 1.3 Success Criteria
- [ ] TDD is explicitly required in sc-agent implementation phase
- [ ] Edge case checklist available in testing guidance
- [ ] Code review skill prevents file modifications
- [ ] ADR and CI/CD templates available in docs/
- [ ] No stack-specific content added to core skills

---

## 2. Requirements

### 2.1 Skill Updates (MUST HAVE)

#### 2.1.1 Update sc-agent: TDD Enforcement
**Current:** TDD mentioned in Step 4.C but not enforced
**Required Changes:**

```markdown
#### C. Test-Driven Development (ALL tasks)
ALWAYS write tests first - this is NON-NEGOTIABLE:

1. **Create test file BEFORE implementation:**
   - Identify test file location
   - Write test cases for success path
   - Write test cases for edge cases
   - Run tests - MUST FAIL (proves tests are meaningful)
   - Log: "Tests written: X test cases, all failing as expected"

2. **Implement to pass tests:**
   - Write MINIMAL code to pass tests
   - Run tests after each change
   - Track: "Tests passing: X/Y"
   - NEVER modify tests to make them pass

3. **Verify TDD compliance:**
   - Git history shows tests committed before implementation
   - Or: Test file timestamps precede implementation
   - If TDD not followed: Flag as deviation

**TDD Checkpoints:**
- [ ] Test file exists
- [ ] Tests fail before implementation
- [ ] Tests pass after implementation
- [ ] No test modifications during implementation
```

**Acceptance Criteria:**
- sc-agent refuses to proceed with implementation before tests exist
- Progress tracking shows "Tests passing: X/Y" format
- Self-review asks "Was TDD followed?"

#### 2.1.2 Update sc-quality: Add Edge Case Reference
**Current:** Generic testing tasks without detailed patterns
**Required Changes:**

Add new section or subsection to sc-quality:

```markdown
### Edge Case Reference

Use this checklist when writing tests:

**Boundary Values:**
- Empty inputs: `""`, `[]`, `{}`
- Zero: `0`, `-0`
- Negative numbers
- MAX_SAFE_INTEGER, MIN_SAFE_INTEGER
- Off-by-one errors (< vs <=)

**Null/Undefined Handling:**
- null input
- undefined input
- Missing object properties
- Nested nulls (user?.profile?.email)

**Special Strings:**
- Unicode: `café`, `日本語`, emoji
- Very long (10K+ chars)
- Whitespace only: `"   "`
- SQL injection: `'; DROP TABLE users; --`
- XSS: `<script>alert('xss')</script>`
- Path traversal: `../../../etc/passwd`

**Async Edge Cases:**
- Timeout handling
- Concurrent requests (race conditions)
- Request cancellation
- Out-of-order responses
- Retry exhaustion

**Date/Time:**
- Timezone boundaries
- DST transitions
- Leap years (Feb 29)
- Invalid dates (Feb 30)
- Epoch (1970-01-01)
- Far future/past

**Currency/Numbers:**
- Zero amounts
- Negative amounts (refunds)
- Rounding: 10.005 → 10.01 or 10.00?
- Very large values
- Floating point precision
```

**Acceptance Criteria:**
- Edge case checklist available in sc-quality
- Organized by category for easy scanning
- Includes security-relevant edge cases

#### 2.1.3 Update self-review: Add TDD Verification
**Current:** Question 1 asks about test execution
**Required Changes:**

Add to Question 1 or as new Question:

```markdown
### Question 1b: TDD Compliance Verified?

**Required:** Confirm tests were written BEFORE implementation

**How to verify:**
- Check git history: tests committed before implementation
- Review timestamps: test files created first
- Confirm tests failed initially (proves they're meaningful)

**Format:**
TDD Followed:
- Tests created: [timestamp or commit]
- Implementation: [timestamp or commit]
- Initial test failure confirmed: Yes/No

TDD Not Followed (explain deviation):
- Reason: [why TDD was skipped]
- Risk: [impact of skipping TDD]
- Mitigation: [how to address]
```

**Acceptance Criteria:**
- Self-review explicitly checks TDD compliance
- Deviations from TDD are flagged and explained
- Output format includes TDD verification

---

### 2.2 New Skills (MUST HAVE)

#### 2.2.1 New Skill: code-review (Read-Only)
**Purpose:** Safe code review with no modification capability

**Location:** `skills/code-review/SKILL.md`

**Key Features:**
```yaml
---
name: code-review
description: "Reviews code for correctness, security, performance, and conventions. Read-only - does not modify files."
allowed-tools: [Read, Grep, Glob]
---
```

**Content Requirements:**
- Tool restrictions in frontmatter (allowed-tools)
- Structured review checklist
- Security checklist (OWASP top 10)
- Output format with severity levels
- Explicit "DO NOT MODIFY" reminders

**Sections:**
1. When to Use / When NOT to Use
2. Review Process (Scope, Correctness, Security, Performance, Conventions)
3. Security Checklist
4. Output Format (Strengths, Issues by Priority, Suggested Tests, Refactor Suggestions)

**Acceptance Criteria:**
- Skill uses allowed-tools restriction
- Cannot modify files when invoked
- Provides structured review output
- Includes security-specific checklist

---

### 2.3 New Content (SHOULD HAVE)

#### 2.3.1 ADR Template
**Location:** `docs/templates/adr-template.md`

**Content:**
```markdown
# ADR-XXX: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Date
YYYY-MM-DD

## Context
What is the issue we're seeing that motivates this decision?

## Decision
What is the change that we're proposing and/or doing?

## Consequences

### Positive
- [Benefit 1]
- [Benefit 2]

### Negative
- [Tradeoff 1]
- [Tradeoff 2]

### Neutral
- [Side effect that's neither good nor bad]

## Alternatives Considered
- **[Alternative 1]**: Why rejected
- **[Alternative 2]**: Why rejected
```

**Acceptance Criteria:**
- Template is complete and usable
- Located in docs/templates/
- Referenced from sc-architecture skill

#### 2.3.2 CI/CD Preference Template
**Location:** `preferences/cicd-template.md`

**Content Requirements:**
- Pre-commit hooks pattern (Husky + lint-staged)
- GitHub Actions workflow template
- Quality gates configuration
- Environment variables management
- Database migration workflow

**Note:** This should be a template/pattern, not a specific stack implementation.

**Acceptance Criteria:**
- Template is stack-agnostic
- Provides patterns users can adapt
- Includes quality gates concept

---

### 2.4 Documentation Updates (SHOULD HAVE)

#### 2.4.1 Update CLAUDE.md
**Required Changes:**
- Reference new code-review skill
- Document TDD requirement
- Add ADR template location

#### 2.4.2 Update docs/plugin-development.md
**Required Changes:**
- Document allowed-tools restriction pattern
- Show how to create stack-specific skills
- Reference ADR template for architecture decisions

---

### 2.5 Optional Enhancements (NICE TO HAVE)

#### 2.5.1 Commands for Common Workflows
**Purpose:** Explicit workflow entry points

**Proposed Commands:**
- `.claude/commands/implement-feature.md` - chains confidence-check → sc-agent → self-review
- `.claude/commands/review-code.md` - invokes code-review skill

**Note:** Depends on whether commands should be in the plugin or user-created.

#### 2.5.2 sc-tdd Dedicated Skill
**Alternative to:** Enhancing sc-quality
**Purpose:** Focused TDD skill separate from quality

**Decision Required:** Should testing have its own skill or enhance sc-quality?

---

## 3. Non-Requirements (Explicitly Out of Scope)

### 3.1 Stack-Specific Skills
The following will NOT be added to jmw-superclaude:
- backend-api (Next.js specific)
- frontend-react (React specific)
- database-supabase (Supabase specific)

**Rationale:** jmw-superclaude is stack-agnostic. Stack-specific content belongs in user-created preferences.

### 3.2 Project-Specific CLAUDE.md Content
- Quick commands section
- Project architecture overview
- Environment-specific configuration

**Rationale:** This is per-project configuration, not plugin content.

### 3.3 Contract-First as Separate Check
Contract-first development pattern will NOT be added as a 6th confidence check.

**Rationale:** Can be incorporated into Architecture Compliance check. Keeping 5 checks maintains simplicity.

---

## 4. Technical Specifications

### 4.1 File Changes Summary

| File | Action | Priority |
|------|--------|----------|
| `skills/sc-agent/SKILL.md` | UPDATE | MUST |
| `skills/sc-quality/SKILL.md` | UPDATE | MUST |
| `skills/self-review/SKILL.md` | UPDATE | MUST |
| `skills/code-review/SKILL.md` | CREATE | MUST |
| `docs/templates/adr-template.md` | CREATE | SHOULD |
| `preferences/cicd-template.md` | CREATE | SHOULD |
| `CLAUDE.md` | UPDATE | SHOULD |
| `docs/plugin-development.md` | UPDATE | SHOULD |

### 4.2 Skill Frontmatter Schema
For code-review skill, use this frontmatter:

```yaml
---
name: code-review
description: "Reviews code for correctness, security, performance, and conventions. Read-only - does not modify files."
allowed-tools: [Read, Grep, Glob]
---
```

### 4.3 Token Impact Assessment
- sc-agent update: +200-300 tokens
- sc-quality edge cases: +400-500 tokens
- self-review TDD check: +100-150 tokens
- code-review skill: +1500-2000 tokens (new skill)
- ADR template: +300 tokens (reference only)
- CI/CD template: +500 tokens (reference only)

**Total Estimated Impact:** ~3000-4000 additional tokens when skills loaded

---

## 5. Success Metrics

### 5.1 Adoption Metrics
- code-review skill invoked in 20%+ of review requests
- TDD compliance tracked in 80%+ of implementations
- Edge case checklist referenced in testing tasks

### 5.2 Quality Metrics
- Reduced rework from missed edge cases
- Earlier defect detection through TDD
- Clear audit trail in code reviews

### 5.3 Validation
- All skills remain under 5K tokens when loaded
- No circular dependencies between skills
- Documentation references are accurate

---

## 6. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| TDD requirement slows simple tasks | Medium | Medium | Add "skip for trivial changes" guidance |
| allowed-tools restriction not enforced | Low | High | Test skill thoroughly before release |
| Edge case checklist too long | Low | Low | Organize by category, make scannable |
| Stack-specific content creeps in | Medium | Medium | Review PRs for stack assumptions |

---

## 7. Timeline

### Phase 1: Core Skill Updates (Week 1)
- [ ] Update sc-agent with TDD enforcement
- [ ] Add edge case checklist to sc-quality
- [ ] Add TDD verification to self-review

### Phase 2: New Skill & Templates (Week 2)
- [ ] Create code-review skill
- [ ] Create ADR template
- [ ] Create CI/CD preference template

### Phase 3: Documentation & Polish (Week 3)
- [ ] Update CLAUDE.md
- [ ] Update plugin-development.md
- [ ] Final review and testing

---

## 8. Appendices

### Appendix A: Research Sources
- `research driven best practices/CLAUDE.md`
- `research driven best practices/claude/skills/*.md`
- `research driven best practices/docs/building-robust-systems-guide.md`

### Appendix B: Related Documents
- `research driven best practices/ASSESSMENT.md`
- `docs/plugin-development.md`

### Appendix C: Decision Log
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Separate sc-tdd skill? | No - enhance sc-quality | Less skill proliferation |
| 6th confidence check? | No - keep 5 | Contracts part of architecture |
| Stack-specific skills? | No | Preserve stack-agnostic design |
| Commands in plugin? | TBD | User preference |
