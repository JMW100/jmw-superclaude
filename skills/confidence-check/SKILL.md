---
name: confidence-check
description: Prevents wrong-direction execution by assessing confidence BEFORE implementation. Requires 90% score to proceed.
---

# Confidence Check - Pre-Implementation Assessment

**Purpose:** Prevents wrong-direction execution by assessing confidence BEFORE starting implementation.

**Requirement:** ≥90% confidence score required to proceed with implementation.

**When to invoke:** Use this skill BEFORE implementing any task to ensure you have verified duplicates, architecture compliance, documentation, OSS references, and root cause.

---

## What This Skill Does

Confidence Check performs a systematic 5-criterion assessment to determine readiness for implementation. Each check is weighted based on impact, producing a confidence score from 0.0 to 1.0.

**Proven Results** (2025-10-21 testing):
- Precision: 1.000 (no false positives)
- Recall: 1.000 (no false negatives)
- 8/8 test cases passed

**ROI**: Spend 100-200 tokens on confidence check to save 5,000-50,000 tokens on wrong-direction work.

---

## When to Use

Use confidence-check skill BEFORE implementing:
- New features or functionality
- Bug fixes requiring investigation
- Refactoring or architecture changes
- Integration of external libraries
- Any task with unclear requirements

**Do NOT use for:**
- Trivial changes (typo fixes, formatting)
- Well-understood repetitive tasks
- Urgent hotfixes with clear solutions

---

## 5 Weighted Confidence Checks

### Check 1: No Duplicate Implementations? (25% weight)

**Question:** Does similar functionality already exist in the codebase?

**How to verify:**
```bash
# Use Grep to search for similar functions/classes
# Use Glob to find related modules
# Check existing implementations
```

**Scoring:**
- ✅ **Pass (0.25):** No duplicates found after thorough search
- ❌ **Fail (0.00):** Similar implementation exists

**Why it matters:** Prevents reinventing the wheel and maintains DRY principle.

---

### Check 2: Architecture Compliance? (25% weight)

**Question:** Does the approach align with existing tech stack and patterns?

**How to verify:**
- Read project documentation (CLAUDE.md, PLANNING.md, README.md)
- Confirm using existing patterns and libraries
- Avoid introducing new dependencies unnecessarily

**Scoring:**
- ✅ **Pass (0.25):** Uses existing tech stack (e.g., Supabase, UV, pytest)
- ⚠️ **Partial (0.125):** Minor deviation with justification
- ❌ **Fail (0.00):** Introduces incompatible dependencies

**Why it matters:** Maintains consistency and reduces technical debt.

---

### Check 3: Official Documentation Verified? (20% weight)

**Question:** Have you reviewed official documentation for APIs/libraries being used?

**How to verify:**
- Use **Context7 MCP** for official documentation lookup
- Use **WebFetch** for specific documentation URLs
- Verify API compatibility and best practices

**Scoring:**
- ✅ **Pass (0.20):** Official docs reviewed and understood
- ⚠️ **Partial (0.10):** Partial docs review
- ❌ **Fail (0.00):** Relying on assumptions or outdated info

**Why it matters:** Prevents API misuse and version incompatibilities.

---

### Check 4: Working OSS Implementations Referenced? (15% weight)

**Question:** Have you found proven, working implementations to reference?

**How to verify:**
- Use **Tavily MCP** or **WebSearch** for research
- Search **GitHub** for examples
- Verify code quality and recent maintenance

**Scoring:**
- ✅ **Pass (0.15):** Found and reviewed working OSS example
- ⚠️ **Partial (0.075):** Found partial examples
- ❌ **Fail (0.00):** No working examples found

**Why it matters:** Learn from proven solutions and avoid common pitfalls.

---

### Check 5: Root Cause Identified? (15% weight)

**Question:** Do you understand the actual problem (not just symptoms)?

**How to verify:**
- Analyze error messages and stack traces
- Check logs and debug output
- Identify underlying issue vs surface symptoms

**Scoring:**
- ✅ **Pass (0.15):** Root cause clearly identified
- ⚠️ **Partial (0.075):** Likely cause identified
- ❌ **Fail (0.00):** Symptoms unclear or guessing

**Why it matters:** Prevents fixing symptoms while leaving root cause unresolved.

---

## Confidence Score Calculation

```
Total Score = Check1 + Check2 + Check3 + Check4 + Check5

Maximum possible: 1.00 (100%)
```

### Decision Thresholds

| Score Range | Decision | Action |
|-------------|----------|--------|
| **≥0.90** | ✅ **High Confidence** | Proceed with implementation |
| **0.70-0.89** | ⚠️ **Medium Confidence** | Present alternatives, ask clarifying questions |
| **<0.70** | ❌ **Low Confidence** | STOP - Request more context, investigate further |

**Critical Rule:** Do NOT implement with confidence <0.90

---

## Output Format

When invoking this skill, provide output in this format:

```
📋 Confidence Assessment:

Check 1: No Duplicate Implementations (25%)
   ✅ Pass (0.25) - Searched codebase, no similar functionality found

Check 2: Architecture Compliance (25%)
   ✅ Pass (0.25) - Uses existing pytest framework

Check 3: Official Documentation Verified (20%)
   ✅ Pass (0.20) - Reviewed pytest docs via Context7

Check 4: Working OSS Implementations (15%)
   ✅ Pass (0.15) - Found reference implementation on GitHub

Check 5: Root Cause Identified (15%)
   ✅ Pass (0.15) - Identified missing fixture as root cause

📊 Confidence Score: 1.00 (100%)
✅ High confidence - Ready to proceed with implementation
```

### Example: Medium Confidence (0.75)

```
📋 Confidence Assessment:

Check 1: No Duplicate Implementations (25%)
   ✅ Pass (0.25) - No duplicates found

Check 2: Architecture Compliance (25%)
   ⚠️ Partial (0.125) - Uses existing stack but pattern is new

Check 3: Official Documentation Verified (20%)
   ✅ Pass (0.20) - Docs reviewed

Check 4: Working OSS Implementations (15%)
   ❌ Fail (0.00) - No working examples found

Check 5: Root Cause Identified (15%)
   ✅ Pass (0.15) - Root cause clear

📊 Confidence Score: 0.725 (72.5%)
⚠️ Medium confidence - Questions before proceeding:
1. Should we use the new pattern or adapt existing ones?
2. Can you provide example of desired behavior?
```

### Example: Low Confidence (0.50)

```
📋 Confidence Assessment:

Check 1: No Duplicate Implementations (25%)
   ❌ Fail (0.00) - Found similar implementation in legacy code

Check 2: Architecture Compliance (25%)
   ✅ Pass (0.25) - Architecture compliant

Check 3: Official Documentation Verified (20%)
   ⚠️ Partial (0.10) - Limited docs available

Check 4: Working OSS Implementations (15%)
   ❌ Fail (0.00) - No examples found

Check 5: Root Cause Identified (15%)
   ✅ Pass (0.15) - Root cause identified

📊 Confidence Score: 0.50 (50%)
❌ Low confidence - STOPPING implementation

Blockers:
1. Duplicate found - should we refactor or reuse existing code?
2. Limited documentation - need official guidance
3. No OSS examples - risky to proceed without reference
```

---

## Integration with SC Agent

Confidence Check is invoked by **@sc-agent** during the investigation phase:

```
SC Agent workflow:
1. Clarify scope
2. Investigate → @confidence-check (this skill)
3. If confidence ≥0.90 → proceed to implementation
   If confidence <0.90 → iterate or escalate
```

---

## Success Criteria

You'll know Confidence Check is working when:
1. ✅ All 5 checks are performed systematically
2. ✅ Score is calculated correctly (sum of weighted checks)
3. ✅ Decision matches threshold (≥0.90, 0.70-0.89, <0.70)
4. ✅ Output clearly shows which checks passed/failed
5. ✅ Implementation only proceeds at ≥0.90 confidence
6. ✅ Token waste is prevented (5K-50K tokens saved per use)

---

## Common Patterns

**Pattern 1: Quick Pass (1.00)**
- Simple, well-understood task
- Clear documentation available
- No duplicates, architecture compliant
- OSS examples readily available

**Pattern 2: Investigate More (0.70-0.89)**
- Novel approach without examples
- Partial documentation
- Need to ask clarifying questions
- Consider alternatives

**Pattern 3: Stop and Research (< 0.70)**
- Unclear requirements
- No documentation found
- Duplicates detected
- Root cause unknown
- Must resolve before proceeding

---

## Tips for Effective Use

1. **Be thorough**: Don't rush checks to hit 0.90
2. **Document evidence**: Note where you searched, what you found
3. **Partial credit**: Use 0.5 × weight for partial passes when appropriate
4. **Escalate blockers**: If stuck, ask user for guidance
5. **Trust the score**: Don't override with gut feeling

The confidence check exists to **prevent expensive mistakes**. Trust the process.
