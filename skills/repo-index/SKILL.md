# Repo-Index - Repository Briefing & Codebase Orientation

**Purpose:** Quick codebase orientation at session start to compress repository context for token-efficient work.

**When to invoke:** Use this skill at the beginning of a session or when the codebase has changed substantially to get oriented.

---

## What This Skill Does

Repo-Index provides a **compact briefing** of the repository structure, highlighting key areas, entry points, and recent changes. It determines whether PROJECT_INDEX.md needs regeneration (>7 days old).

**Key Value:** Enables quick orientation without reading entire codebase, saving thousands of tokens per session.

---

## When to Use

Use repo-index skill:
- **At session start** for quick codebase orientation
- **After significant changes** (major refactoring, new features)
- **When switching projects** to get oriented quickly
- **Before investigation** to understand code organization

**Do NOT use for:**
- Detailed file analysis (use Read/Grep instead)
- Generating full PROJECT_INDEX.md (use @index-repo instead)
- Searching for specific code (use Glob/Grep instead)

---

## Core Responsibilities

Repo-Index performs these duties:

### 1. Inspect Directory Structure

Identify key areas:
- **Code**: `src/`, `lib/`, main source directories
- **Tests**: `tests/`, `__tests__/`, `*.test.*` files
- **Documentation**: `docs/`, `*.md` files
- **Configuration**: `*.toml`, `*.yaml`, `*.json`, `.env.example`
- **Scripts**: `scripts/`, `bin/`, build scripts

### 2. Surface Recently Changed Files

Identify high-activity areas:
- Use `git log --stat --since="7 days ago"` or similar
- Highlight files with recent commits
- Note new files or significant changes

### 3. Check PROJECT_INDEX.md Freshness

**Trigger condition:**
- If `PROJECT_INDEX.md` is **>7 days old** → Recommend regeneration
- If `PROJECT_INDEX.md` is **missing** → Recommend creation
- If fresh (<7 days) → Confirm and skip regeneration

### 4. Highlight Entry Points & Service Boundaries

Identify:
- **Entry points**: `main.py`, `index.ts`, CLI entry files
- **Service boundaries**: API routes, module interfaces
- **Key documentation**: README, ARCHITECTURE, ADRs (Architecture Decision Records)

---

## Operating Procedure

### Step 1: Detect Index Freshness

Check if PROJECT_INDEX.md exists and when it was last modified:

```bash
# Check last modified time
stat -c '%y' PROJECT_INDEX.md 2>/dev/null || echo "Not found"

# Or use ls
ls -l PROJECT_INDEX.md
```

**Decision logic:**
- **<7 days old**: Index is fresh → Use it, skip regeneration
- **>7 days old**: Index is stale → Recommend regeneration
- **Missing**: No index → Recommend creation

### Step 2: Run Parallel Glob Searches

Execute **5 searches in parallel** for different file types:

```
Parallel glob searches:
1. Code files: src/**/*.{ts,py,js,tsx,jsx}
2. Documentation: docs/**/*.md, *.md
3. Configuration: *.toml, *.yaml, *.json, .env.example
4. Tests: tests/**/*.{py,ts,js}, **/*.test.*
5. Scripts: scripts/**/*,bin/**/*
```

**Important:** Execute in parallel (single message, multiple tool calls) for efficiency.

### Step 3: Summarize Results

Provide **compact brief** with key findings:

```markdown
📦 Repository Summary:
  - Code: {primary directories} ({file count})
  - Tests: {test directories} ({coverage info if available})
  - Docs: {documentation structure}
  - Config: {key configuration files}

🎯 Entry Points:
  - {main entry files}

🔄 Recent Changes (last 7 days):
  - {high-activity files or "None"}

📊 INDEX Status:
  - PROJECT_INDEX.md: {fresh/stale/missing}
  - {Recommendation if needed}
```

### Step 4: Trigger Index Regeneration (If Needed)

If PROJECT_INDEX.md is stale or missing:
```
🔄 Recommendation: Run @index-repo to regenerate PROJECT_INDEX.md
   Benefit: 94% token reduction (58K → 3K per session)
```

---

## Output Format

Provide briefing in this **compact, data-driven** format:

```markdown
## Repository Briefing

### 📦 Structure Summary

**Code:**
- `src/superclaude/` (42 files) - Main library
- `src/superclaude/pm_agent/` (5 files) - PM agent patterns
- `src/superclaude/execution/` (3 files) - Execution engines

**Tests:**
- `tests/pm_agent/` (15 files) - PM agent tests
- `tests/execution/` (8 files) - Execution tests
- pytest plugin integration tests

**Documentation:**
- `docs/developer-guide/` - Developer documentation
- `docs/user-guide/` - User documentation
- `README.md`, `CONTRIBUTING.md` - Project docs

**Configuration:**
- `pyproject.toml` - Python project config
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.env.example` - Environment template

### 🎯 Entry Points

- `src/superclaude/cli/main.py` - CLI entry point
- `src/superclaude/pytest_plugin.py` - Pytest plugin entry
- `scripts/install.sh` - Installation script

### 🔄 Recent Activity (last 7 days)

- `src/superclaude/pm_agent/confidence.py` (modified 2 days ago)
- `tests/test_confidence.py` (modified 2 days ago)
- `docs/developer-guide/README.md` (modified 5 days ago)

### 📊 PROJECT_INDEX Status

- **Status:** ⚠️ Stale (last updated 12 days ago)
- **Recommendation:** Run `@index-repo` to regenerate
- **Benefit:** 94% token reduction (58K → 3K per session)

---

**Ready for task.** Repository briefing complete.
```

---

## Example: Fresh Index (No Regeneration)

```markdown
## Repository Briefing

### 📦 Structure Summary

**Code:** `src/auth/` (12 files), `src/api/` (8 files)
**Tests:** `tests/` (20 files), 85% coverage
**Docs:** `docs/` (comprehensive), `API.md` available
**Config:** Standard Node.js project (package.json, tsconfig.json)

### 🎯 Entry Points

- `src/index.ts` - API server entry
- `src/cli.ts` - CLI tool

### 🔄 Recent Activity

No significant changes in last 7 days

### 📊 PROJECT_INDEX Status

- **Status:** ✅ Fresh (updated 3 days ago)
- **Action:** None needed - using existing index

---

**Ready for task.** Using current PROJECT_INDEX.md for context.
```

---

## Integration with SC Agent & Index-Repo

**Workflow integration:**

```
Session start:
  ↓
@repo-index (this skill)
  ↓
Check PROJECT_INDEX.md freshness
  ↓
If stale/missing → @index-repo (generate new index)
If fresh → Use existing index
  ↓
@sc-agent (proceed with task)
```

**Relationship with @index-repo:**
- **repo-index** = Quick briefing (2-3 min, session start)
- **index-repo** = Full index generation (5-10 min, when needed)

**Decision flow:**
- repo-index **detects** when index is stale
- repo-index **recommends** running index-repo
- SC Agent or user **decides** whether to regenerate
- index-repo **creates** new PROJECT_INDEX.md

---

## 5 Parallel Glob Searches

**Execute these in parallel** (single message, 5 tool calls):

### 1. Code Files
```
Pattern: src/**/*.{ts,py,js,tsx,jsx}
Purpose: Find all source code files
Expected: Main library, modules, components
```

### 2. Documentation Files
```
Patterns:
  - docs/**/*.md
  - *.md (root level)
Purpose: Find all documentation
Expected: README, guides, ADRs, API docs
```

### 3. Configuration Files
```
Patterns:
  - *.toml
  - *.yaml, *.yml
  - *.json (package.json, tsconfig.json, etc.)
  - .env.example
Purpose: Find project configuration
Expected: Build configs, dependencies, settings
```

### 4. Test Files
```
Patterns:
  - tests/**/*.{py,ts,js}
  - **/*.test.*
  - **/*.spec.*
Purpose: Find all test files
Expected: Unit tests, integration tests
```

### 5. Script Files
```
Patterns:
  - scripts/**/*
  - bin/**/*
Purpose: Find automation and utility scripts
Expected: Build scripts, installers, helpers
```

---

## Success Criteria

You'll know Repo-Index is working when:
1. ✅ Briefing provided within 2-3 minutes
2. ✅ All 5 file categories identified
3. ✅ Entry points clearly listed
4. ✅ PROJECT_INDEX.md freshness checked
5. ✅ Recommendation made (regenerate or use existing)
6. ✅ Output is compact and scannable
7. ✅ Recent changes surfaced (if any)
8. ✅ Token-efficient (brief, not exhaustive)

---

## Token Efficiency

**Problem without repo-index:**
- Reading entire codebase: ~58,000 tokens
- Slow orientation, high token cost

**Solution with repo-index:**
- Quick briefing: ~500-1,000 tokens
- Points to PROJECT_INDEX.md: ~3,000 tokens (if fresh)
- **Total: ~4,000 tokens vs 58,000 tokens = 93% reduction**

**ROI:**
- Time: 2-3 minutes for orientation
- Tokens: Save 54,000 tokens per session
- Value: Immediate codebase understanding

---

## Common Patterns

**Pattern 1: New Session, Fresh Index**
```
User: "Start working on feature X"
repo-index: Quick briefing → INDEX fresh → Use existing
→ Ready to work (4K tokens used)
```

**Pattern 2: New Session, Stale Index**
```
User: "Start working on feature X"
repo-index: Quick briefing → INDEX 10 days old → Recommend regeneration
index-repo: Generate new PROJECT_INDEX.md
→ Ready to work (4K tokens used, index refreshed)
```

**Pattern 3: Major Refactoring Done**
```
Developer: Completed major refactoring
repo-index: Briefing → Many recent changes → INDEX now stale
→ Recommend regeneration to capture new structure
```

---

## Tips for Effective Use

1. **Always run at session start** for quick orientation
2. **Check git log** for recent changes (last 7 days)
3. **Trust the freshness check** - don't regenerate unnecessarily
4. **Keep briefing concise** - high-level only
5. **Highlight anomalies** - unusual structure, missing docs, etc.
6. **Defer to index-repo** for full indexing
7. **Update INDEX regularly** - weekly or after major changes

The repo-index exists to **provide instant orientation** without token waste. Keep it short, data-driven, and actionable.
