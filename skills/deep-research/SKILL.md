---
name: deep-research
description: Parallel web search and evidence synthesis using Wave-Checkpoint-Wave pattern for 3-5x speed improvement
---

# Deep Research - Parallel Web Search & Evidence Synthesis

**Purpose:** Adaptive research specialist for external knowledge gathering with parallel execution and evidence-based synthesis.

**When to invoke:** Use this skill when you need authoritative information from outside the repository - official documentation, OSS examples, best practices, or technical specifications.

---

## What This Skill Does

Deep Research executes systematic web research using a **Wave→Checkpoint→Wave** pattern with parallel searches for 3-5x speed improvement over sequential searching.

**Key Features:**
- 4 depth levels (quick to exhaustive)
- Parallel execution with multiple MCP servers
- Evidence-based synthesis with source credibility tracking
- Structured output with citations and confidence scores

---

## When to Use

Use deep-research skill for:
- Finding official documentation for APIs/libraries
- Discovering OSS implementations and best practices
- Resolving technical unknowns before implementation
- Gathering evidence for architectural decisions
- Verifying external claims or specifications

**Do NOT use for:**
- Information already in the codebase (use Grep/Glob instead)
- Well-known facts requiring no verification
- Questions the user can answer directly

---

## 4 Depth Levels

Choose depth based on complexity and time available:

| Level | Searches | Time | Use When |
|-------|----------|------|----------|
| **quick** | 1-2 searches | 2-3 min | Simple lookup, confirming known info |
| **standard** | 3-5 searches | 5-7 min | **Default** - most common tasks |
| **deep** | 5-10 searches | 10-15 min | Complex topics, multiple aspects |
| **exhaustive** | 10+ searches | 20+ min | Critical decisions, comprehensive analysis |

**Default to standard** unless user specifies otherwise or task clearly requires different depth.

---

## 6-Phase Research Workflow

### Phase 1: Understand (5-10% effort)

**Goal:** Parse user query and establish scope

**Actions:**
- Restate the research question
- Extract primary topic
- Identify required detail level
- Note time constraints
- List success criteria
- Identify blocking assumptions or unknowns

**Output:**
```
🎯 Research Question: [restated clearly]
📋 Unknowns: [list key gaps]
⏱️ Depth: [quick/standard/deep/exhaustive]
```

---

### Phase 2: Plan (10-15% effort)

**Goal:** Create search strategy with parallel execution plan

**Actions:**
1. Identify key concepts and search terms
2. Plan parallel search queries
3. Select sources (official docs, GitHub, technical blogs)
4. Estimate depth level
5. Divide work into concurrent "hops"

**Output:**
```
🔍 Search Strategy:
Wave 1 (parallel):
  - Tavily: [search query 1]
  - Context7: [official docs lookup]
  - WebFetch: [specific URL if known]

Wave 2 (fill gaps):
  - [follow-up searches based on Wave 1 results]
```

---

### Phase 3: TodoWrite (5% effort)

**Goal:** Track research progress

Create task list:
```markdown
- [ ] Understanding phase complete
- [ ] Search queries planned
- [ ] Wave 1 parallel searches executed
- [ ] Checkpoint analysis done
- [ ] Wave 2 follow-up searches executed
- [ ] Results synthesized
- [ ] Validation complete
```

---

### Phase 4: Execute (50-60% effort)

**Goal:** Run searches using Wave→Checkpoint→Wave pattern

#### Wave 1: Parallel Searches

Execute **multiple searches simultaneously** (3-5x faster than sequential):

**Available Tools:**
- **Tavily MCP** - Primary web search with extraction
- **Context7 MCP** - Official documentation lookup
- **WebFetch** - Fetch specific known URLs
- **WebSearch** - Fallback if MCPs unavailable
- **Sequential MCP** - Reasoning and synthesis (optional)
- **Playwright MCP** - JavaScript-heavy content (rare)

**Critical Rule:** ALWAYS execute searches in parallel (multiple tool calls in one message)

✅ **Good:**
```
[Tavily search 1] + [Context7 lookup] + [WebFetch URL] (parallel in same message)
```

❌ **Bad:**
```
Execute search 1 → Wait for result → Execute search 2 → Wait (sequential)
```

#### Checkpoint: Analyze Results

Between waves, assess what you learned:
- **Verify source credibility** (official docs > GitHub > blogs)
- **Extract key information** with citations
- **Identify information gaps** that need filling
- **Note contradictions** that need resolution
- **Track confidence level** based on source quality

#### Wave 2: Follow-up Searches

Based on checkpoint analysis:
- Fill identified gaps
- Verify conflicting information
- Find code examples if needed
- Cross-check critical claims

**May require Wave 3+** for deep/exhaustive research.

---

### Phase 5: Validate (10-15% effort)

**Goal:** Quality check before reporting

**Validation Checklist:**
- ✅ Official documentation cited?
- ✅ Multiple sources confirm findings?
- ✅ Code examples verified (if applicable)?
- ✅ Contradictions resolved or noted?
- ✅ Confidence score ≥0.85?
- ✅ All sources include credibility notes?

If validation fails, return to Execute phase for additional searches.

---

### Phase 6: Synthesize (10-15% effort)

**Goal:** Deliver concise, actionable report

Combine findings into structured output (see Output Format below).

---

## MCP Server Integration

**Primary MCP Servers:**
- **Tavily** - Web search with automatic extraction and summarization
- **Context7** - Official documentation for popular frameworks/libraries
- **WebFetch** - Direct URL fetching for known resources
- **Sequential** - Multi-step reasoning and synthesis

**Fallback:**
- **WebSearch** - Built-in web search when MCPs unavailable

**Execution Strategy:**
1. Use **Tavily + Context7** in parallel for initial wave
2. Use **WebFetch** for specific URLs discovered in Wave 1
3. Use **Sequential** for complex synthesis if needed
4. Fall back to **WebSearch** if MCP servers unavailable

**If MCP unavailable:** Note the failure, use WebSearch fallback, flag gap for follow-up.

---

## Parallel Execution Pattern

**Performance Gain:** 3-5x faster than sequential execution

**How to Execute in Parallel:**

Single message with multiple tool calls:
```
Message 1:
  Tool call 1: Tavily search for "X best practices"
  Tool call 2: Context7 lookup for "X official docs"
  Tool call 3: WebFetch https://example.com/x-guide

(All execute concurrently, results arrive together)
```

**Do NOT:**
```
Message 1: Tavily search
Wait for response...
Message 2: Context7 lookup
Wait for response...
Message 3: WebFetch
```

This is 3x slower and wastes time.

---

## Output Format

Provide research results in this structured format:

```markdown
## Research Summary

{2-3 sentence overview of findings}

## Key Findings

1. {Finding with evidence}
   - Source: [Title](URL)
   - Credibility: {Official/High/Medium}

2. {Finding with evidence}
   - Source: [Title](URL)
   - Credibility: {Official/High/Medium}

3. {Finding with evidence}
   - Source: [Title](URL)
   - Credibility: {Official/High/Medium}

## Sources

| Type | Title | URL | Credibility | Notes |
|------|-------|-----|-------------|-------|
| 📚 Official | {Doc title} | {URL} | Official | {Why relevant} |
| 💻 GitHub | {Repo name} | {URL} | High | {Why relevant} |
| 📝 Blog | {Post title} | {URL} | Medium | {Why relevant} |

## Open Questions

- {Unresolved question or gap}
- {Suggested follow-up research}

## Confidence: {0.XX}/1.0

{Brief confidence justification}
```

---

## Example: Standard Depth Research

**Query:** "How to implement OAuth 2.0 with Supabase?"

```markdown
## Research Summary

Supabase provides built-in OAuth 2.0 support through Auth Helpers with providers like Google, GitHub, and custom OIDC. Implementation requires configuring providers in Supabase dashboard and using signInWithOAuth() client method.

## Key Findings

1. Supabase supports OAuth 2.0 natively through Auth Helpers library
   - Source: [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
   - Credibility: Official

2. Configuration requires two steps: dashboard setup + client code
   - Source: [OAuth Setup Guide](https://supabase.com/docs/guides/auth/social-login)
   - Credibility: Official

3. Working implementation available in community examples
   - Source: [supabase-community/auth-helpers](https://github.com/supabase-community/auth-helpers)
   - Credibility: High (official community repo)

## Sources

| Type | Title | URL | Credibility | Notes |
|------|-------|-----|-------------|-------|
| 📚 Official | Supabase Auth Docs | https://supabase.com/docs/guides/auth | Official | Primary reference |
| 📚 Official | OAuth Setup Guide | https://supabase.com/docs/guides/auth/social-login | Official | Step-by-step guide |
| 💻 GitHub | Auth Helpers | https://github.com/supabase-community/auth-helpers | High | Working examples |
| 📝 Blog | OAuth Best Practices | https://example.com/oauth-best-practices | Medium | Security recommendations |

## Open Questions

- None - implementation path is clear

## Confidence: 0.95/1.0

High confidence due to multiple official sources with working code examples.
```

---

## Integration with SC Agent

Deep Research is invoked by **@sc-agent** during investigation phase:

```
SC Agent workflow:
1. Clarify scope
2. Investigate
   → @confidence-check (Check 3: Official docs verified?)
   → If docs needed: @deep-research (this skill)
3. Use research findings to increase confidence
4. Proceed to implementation
```

**Escalation:** If authoritative sources are unavailable or clarification needed, escalate back to SC Agent who will consult user.

---

## Success Criteria

You'll know Deep Research is working when:
1. ✅ Searches execute in parallel (3-5x faster)
2. ✅ Multiple sources cited with credibility notes
3. ✅ Official documentation prioritized
4. ✅ Confidence score calculated based on source quality
5. ✅ Output follows structured format
6. ✅ Gaps and follow-up questions clearly identified
7. ✅ Wave→Checkpoint→Wave pattern visible in execution

---

## Common Patterns

**Pattern 1: Quick Verification (quick depth)**
- User asks: "Does library X support feature Y?"
- Wave 1: Context7 for official docs
- Result: Yes/No with official citation
- Time: 2-3 minutes

**Pattern 2: Best Practices (standard depth)**
- User asks: "Best way to implement X?"
- Wave 1: Tavily + Context7 (parallel)
- Checkpoint: Found official docs + 2 blog posts
- Wave 2: WebFetch for specific examples
- Result: Recommended approach with sources
- Time: 5-7 minutes

**Pattern 3: Architecture Decision (deep depth)**
- User asks: "Should we use library A or B?"
- Wave 1: Tavily for comparisons + Context7 for both docs (parallel)
- Checkpoint: Found official docs, need performance data
- Wave 2: GitHub for benchmarks + Stack Overflow discussions
- Wave 3: Technical blogs for real-world experience
- Result: Comparison matrix with tradeoffs
- Time: 10-15 minutes

**Pattern 4: Comprehensive Analysis (exhaustive depth)**
- User asks: "Complete overview of X ecosystem"
- Multiple waves of parallel searches
- 10+ sources across official docs, GitHub, blogs, papers
- Cross-verification of all claims
- Detailed synthesis with confidence tracking
- Time: 20+ minutes

---

## Tips for Effective Research

1. **Default to standard depth** unless clearly specified
2. **Always execute searches in parallel** for 3-5x speedup
3. **Prioritize official docs** (Context7 first, then Tavily)
4. **Track source credibility** (Official > High > Medium > Low)
5. **Use checkpoint analysis** to identify gaps before Wave 2
6. **Calculate confidence** based on source quality and agreement
7. **Note contradictions** - don't hide conflicting information
8. **Escalate to user** when authoritative sources are missing

The research process exists to **prevent implementation on false assumptions**. Take the time to find authoritative sources.
