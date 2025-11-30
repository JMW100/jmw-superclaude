# Proposed CLAUDE.md Update: Mandatory Skill Protocol

**Purpose:** Ensure skills are used instead of manual work
**Approach:** Option 3 - skill-selector as mandatory gate

---

## Addition to CLAUDE.md

Add this section after "## Key Concepts" and before "### Skills Architecture":

```markdown
### Skill Usage Protocol (MANDATORY)

**CRITICAL:** Before performing any non-trivial task manually, you MUST use skills.

**Protocol:**
1. For ANY non-trivial request, FIRST invoke `use skill-selector`
2. skill-selector will recommend the appropriate skill(s)
3. Use the recommended skill(s) - do NOT perform the task manually
4. Only proceed manually if skill-selector explicitly says "no applicable skill"

**Why This Matters:**
- Skills use optimized workflows (e.g., create-prd and generate-tasks use Opus 4)
- Skills enforce best practices (TDD, confidence checks, evidence-based review)
- Skills prevent wasted tokens from wrong-direction work
- Manual work bypasses these safeguards

**Examples of "Non-Trivial" Tasks:**
- Creating PRDs, requirements, or specifications
- Breaking down features into tasks
- Implementing new features
- Reviewing code
- Researching topics
- Debugging or troubleshooting
- Performance optimization
- Security assessments

**Trivial Tasks (OK to skip skill-selector):**
- Answering a quick question
- Making a single small edit
- Running a command the user specified
- Reading a file the user asked about

**Anti-Pattern to Avoid:**
```
❌ User: "Create a PRD for user authentication"
   Claude: *writes PRD manually*

✅ User: "Create a PRD for user authentication"
   Claude: "use skill-selector" → recommends create-prd → "use create-prd"
```

**Remember:** If you find yourself about to write a PRD, task list, research summary, implementation plan, or review - STOP and use skill-selector first.
```

---

## Where to Insert

**Current CLAUDE.md structure:**
```
# CLAUDE.md
## Repository Overview
## Repository Structure
## Key Concepts          ← INSERT NEW SECTION HERE
### Skills Architecture
### Technical Preferences System
### Hooks System
...
```

**New structure:**
```
# CLAUDE.md
## Repository Overview
## Repository Structure
## Key Concepts
### Skill Usage Protocol (MANDATORY)  ← NEW
### Skills Architecture
### Technical Preferences System
### Hooks System
...
```

---

## Rationale

1. **Single Rule:** "Use skill-selector first" - one instruction to remember
2. **Self-Maintaining:** skill-selector knows about all skills; no routing table to update
3. **Handles Ambiguity:** skill-selector reasons about edge cases
4. **Forces the Pause:** Cannot shortcut with "I know this one"
5. **Early in Document:** Placed in Key Concepts so it's read early in context

---

## Implementation

To apply this update, edit CLAUDE.md and add the section above after the "## Key Concepts" header and before "### Skills Architecture".

**Estimated Token Impact:** +200-250 tokens to CLAUDE.md
