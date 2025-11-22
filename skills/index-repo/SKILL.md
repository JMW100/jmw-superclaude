# Index-Repo - Generate PROJECT_INDEX.md for 94% Token Reduction

**Purpose:** Generate comprehensive PROJECT_INDEX.md to reduce per-session token usage from 58,000 to 3,000 tokens (94% reduction).

**When to invoke:** Use this skill on first task in a new codebase, when PROJECT_INDEX.md is >7 days old, or after significant codebase changes.

---

## What This Skill Does

Index-Repo creates a structured, human-readable index of the entire repository that compresses codebase context into a single document for massive token savings across all future sessions.

**ROI:** Spend 2,000 tokens once to save 55,000 tokens per session forever.

---

## Problem Statement

**Before indexing:**
- Need to read multiple files to understand codebase
- ~58,000 tokens per session for full context
- Slow orientation, expensive exploration

**After indexing:**
- Read single PROJECT_INDEX.md file
- ~3,000 tokens per session for full context
- **94% token reduction**
- Instant orientation

**Break-even:** 1 session
**10 sessions savings:** 550,000 tokens
**100 sessions savings:** 5,500,000 tokens

---

## When to Use

Use index-repo skill when:
- **First task in new codebase** - No index exists
- **Index is stale** - PROJECT_INDEX.md >7 days old
- **After major changes** - Significant refactoring, new features, restructuring
- **@repo-index recommends it** - Triggered by freshness check

**Do NOT use when:**
- Index is fresh (<7 days old) - Use existing index instead
- Trivial changes only - Index still accurate
- Emergency hotfix - Skip indexing, use existing context

---

## 4-Phase Index Creation Flow

### Phase 1: Analyze Repository Structure

Execute **5 parallel Glob searches** for comprehensive discovery:

#### 1. Code Structure
```
Patterns:
  src/**/*.{ts,py,js,tsx,jsx}
  lib/**/*.{ts,py,js}
  {project_name}/**/*.py

Purpose: Find all source code files
Extract: Entry points, modules, classes, functions
```

#### 2. Documentation
```
Patterns:
  docs/**/*.md
  *.md (root level)
  README*.md
  ARCHITECTURE.md, CONTRIBUTING.md, etc.

Purpose: Find all documentation files
Extract: Documentation structure, guides, references
```

#### 3. Configuration
```
Patterns:
  *.toml (pyproject.toml, etc.)
  *.yaml, *.yml (.github/, config/)
  *.json (package.json, tsconfig.json)
  .env.example

Exclude: package-lock.json, node_modules/

Purpose: Find project configuration
Extract: Build configs, dependencies, settings
```

#### 4. Tests
```
Patterns:
  tests/**/*.{py,ts,js}
  **/*.test.{ts,py,js}
  **/*.spec.{ts,py,js}
  __tests__/**/*

Purpose: Find all test files
Extract: Test coverage, test patterns
```

#### 5. Scripts & Tools
```
Patterns:
  scripts/**/*
  bin/**/*
  tools/**/*
  Makefile, *.sh

Purpose: Find automation and utility scripts
Extract: Build scripts, installers, helpers
```

**Critical:** Execute all 5 searches **in parallel** (single message, 5 tool calls) for efficiency.

---

### Phase 2: Extract Metadata

For each file category discovered, extract key information:

#### Entry Points
- **CLI entry**: `main.py`, `cli.py`, `index.ts`
- **API entry**: `app.py`, `server.ts`, `api/index.js`
- **Test entry**: `conftest.py`, `jest.config.js`
- **Build entry**: `setup.py`, `package.json`

#### Key Modules & Exports
- Module name and purpose
- Public API surface (exported functions/classes)
- Key dependencies between modules

#### API Surface
- Public functions and their signatures
- Exported classes and interfaces
- Configuration options

#### Dependencies
- External dependencies (from package.json, pyproject.toml, etc.)
- Internal module dependencies
- Version requirements

---

### Phase 3: Generate PROJECT_INDEX.md

Create structured index file with this format:

```markdown
# Project Index: {project_name}

**Generated:** {timestamp}
**Generator:** SuperClaude index-repo skill
**Purpose:** Compressed repository context for token-efficient sessions

---

## 📁 Project Structure

```
{project_name}/
├── src/                    # Source code
│   ├── cli/                # CLI entry points
│   ├── core/               # Core functionality
│   └── utils/              # Utility functions
├── tests/                  # Test suite
├── docs/                   # Documentation
├── scripts/                # Automation scripts
└── [config files]          # Configuration
```

---

## 🚀 Entry Points

### CLI Entry Point
- **Path:** `src/cli/main.py`
- **Purpose:** Command-line interface
- **Usage:** `python -m {project}.cli`

### API Entry Point
- **Path:** `src/api/server.ts`
- **Purpose:** REST API server
- **Usage:** `npm start`

### Test Entry Point
- **Path:** `tests/conftest.py`
- **Purpose:** Pytest configuration and fixtures
- **Usage:** `pytest tests/`

---

## 📦 Core Modules

### Module: {module_name}
- **Path:** `src/core/{module_name}.py`
- **Exports:** `{FunctionA}`, `{ClassB}`, `{ConstantC}`
- **Purpose:** {1-line description of module purpose}
- **Dependencies:** {other_module}, {external_lib}

### Module: {another_module}
- **Path:** `src/utils/{another_module}.ts`
- **Exports:** `{helperX}`, `{helperY}`
- **Purpose:** {1-line description}
- **Dependencies:** None

---

## 🔧 Configuration Files

- **pyproject.toml** - Python project configuration, dependencies
- **tsconfig.json** - TypeScript compiler configuration
- **package.json** - Node.js dependencies and scripts
- **.env.example** - Environment variable template
- **.pre-commit-config.yaml** - Pre-commit hooks configuration

---

## 📚 Documentation Structure

- **README.md** - Project overview and quick start
- **docs/user-guide/** - User documentation
- **docs/developer-guide/** - Developer documentation
- **docs/architecture/** - Architecture decision records (ADRs)
- **CONTRIBUTING.md** - Contribution guidelines
- **CHANGELOG.md** - Version history

---

## 🧪 Test Coverage

- **Unit tests:** {count} files in `tests/unit/`
- **Integration tests:** {count} files in `tests/integration/`
- **E2E tests:** {count} files in `tests/e2e/`
- **Coverage:** {percentage}% (run `pytest --cov` for details)
- **Test framework:** pytest / jest / {framework}

---

## 🔗 Key Dependencies

### Production Dependencies
- **{dependency_name}** ({version}) - {purpose/usage}
- **{another_dep}** ({version}) - {purpose}

### Development Dependencies
- **pytest** - Testing framework
- **black** - Code formatter
- **mypy** - Type checking

---

## 📝 Quick Start Guide

### Installation
```bash
# Clone repository
git clone {repo_url}

# Install dependencies
{install_command}

# Setup environment
cp .env.example .env
```

### Development
```bash
# Run tests
{test_command}

# Run locally
{run_command}

# Build
{build_command}
```

### Common Commands
- `{command}` - {description}
- `{command}` - {description}

---

## 🎯 Project Metadata

- **Language:** Python / TypeScript / {languages}
- **Framework:** {framework_name}
- **Build tool:** {build_tool}
- **Package manager:** pip / npm / {manager}
- **Version:** {version} (from VERSION or package.json)

---

## 📊 Repository Statistics

- **Total files:** {count}
- **Source files:** {count}
- **Test files:** {count}
- **Documentation files:** {count}
- **Last updated:** {date}

---

**Index generated by SuperClaude index-repo skill**
**Next update recommended:** {date + 7 days}
```

**Additionally create PROJECT_INDEX.json** (machine-readable format) with structured data.

---

### Phase 4: Validation

Quality checks before finalizing:

```markdown
Index Quality Checklist:
- [ ] All entry points identified and documented
- [ ] Core modules have descriptions
- [ ] Index file size < 5KB (for token efficiency)
- [ ] Human-readable and scannable format
- [ ] Dependencies listed with versions
- [ ] Quick start guide is actionable
- [ ] No sensitive information included
- [ ] Timestamp and next update date added
```

If any check fails, refine the index before saving.

---

## Output Format

When invoking this skill, generate two files:

### 1. PROJECT_INDEX.md
- **Size:** ~3KB (human-readable)
- **Format:** Markdown with structure above
- **Purpose:** Quick reference for developers and Claude

### 2. PROJECT_INDEX.json
- **Size:** ~10KB (machine-readable)
- **Format:** JSON with structured data
- **Purpose:** Programmatic access, tooling integration

**Both files saved to repository root.**

---

## Token Efficiency & ROI

### Cost Analysis

**One-time cost:**
- Index creation: ~2,000 tokens
- Validation: ~500 tokens
- **Total:** ~2,500 tokens

**Per-session savings:**
- Without index: ~58,000 tokens (full codebase scan)
- With index: ~3,000 tokens (read PROJECT_INDEX.md)
- **Savings:** ~55,000 tokens per session

### ROI Timeline

| Sessions | Tokens Used (no index) | Tokens Used (with index) | Savings |
|----------|------------------------|--------------------------|---------|
| 1 | 58,000 | 5,500 | 52,500 (break-even) |
| 10 | 580,000 | 32,500 | 547,500 |
| 50 | 2,900,000 | 152,500 | 2,747,500 |
| 100 | 5,800,000 | 302,500 | 5,497,500 |

**Break-even point:** 1 session
**Value:** Exponential savings over project lifetime

---

## Integration with Repo-Index

**Workflow:**

```
Session start
  ↓
@repo-index (quick briefing)
  ↓
Check PROJECT_INDEX.md age
  ↓
If >7 days old or missing:
  → @index-repo (this skill)
  → Generate new index
  ↓
If <7 days old:
  → Use existing index
  ↓
Continue with task (3K tokens vs 58K)
```

**Relationship:**
- **@repo-index** = Detector (checks freshness, provides quick brief)
- **@index-repo** = Generator (creates/updates full index)

---

## Example: Generated Index

See the template in Phase 3 above for complete example structure.

**Key characteristics of good index:**
- ✅ Under 5KB size
- ✅ All entry points documented
- ✅ Module purposes clear
- ✅ Quick start actionable
- ✅ Dependencies with versions
- ✅ Human-scannable structure

---

## Success Criteria

You'll know Index-Repo is working when:
1. ✅ PROJECT_INDEX.md created and < 5KB
2. ✅ PROJECT_INDEX.json created with structured data
3. ✅ All 5 file categories discovered (code, docs, config, tests, scripts)
4. ✅ Entry points clearly identified
5. ✅ Core modules documented with exports
6. ✅ Dependencies listed with versions
7. ✅ Quick start guide included
8. ✅ Validation checklist passes
9. ✅ Timestamp and next update date added
10. ✅ Future sessions use 3K tokens instead of 58K

---

## Common Patterns

**Pattern 1: First Time Setup**
```
New repository → No index exists
→ Run @index-repo
→ Generate PROJECT_INDEX.md (2K tokens)
→ Future sessions use index (3K tokens vs 58K)
→ Massive savings forever
```

**Pattern 2: Stale Index Update**
```
Existing index 14 days old
→ @repo-index detects staleness
→ Recommend @index-repo
→ Regenerate index (2K tokens)
→ Updated index captures new structure
```

**Pattern 3: After Major Refactoring**
```
Completed big refactor
→ Old index outdated
→ Run @index-repo
→ New index reflects current structure
→ Team benefits from updated reference
```

---

## Tips for Effective Indexing

1. **Run on first session** in any new codebase
2. **Update weekly** or after major changes
3. **Validate index size** - keep under 5KB for token efficiency
4. **Make it human-readable** - developers will reference it too
5. **Include all entry points** - critical for orientation
6. **Document module purposes** - one-liners are enough
7. **List dependencies with versions** - helps with compatibility
8. **Add quick start** - enables immediate productivity
9. **Commit to git** - share benefits with whole team
10. **Update after milestones** - releases, major features, refactors

---

## Maintenance Schedule

**Recommended update frequency:**
- **Weekly:** Active development projects
- **Bi-weekly:** Moderate activity projects
- **Monthly:** Stable/maintenance projects
- **After major changes:** Always regenerate

**Auto-trigger:** When @repo-index detects >7 days age

---

## Advanced: Partial Updates

For very large codebases, you can regenerate sections:

**Quick mode** (skip test discovery):
- Faster generation (~1K tokens)
- Good for urgent context needs
- Update tests section later

**Update mode** (preserve existing, add new):
- Incremental updates
- Faster than full regeneration
- Good for daily changes

**Full mode** (default):
- Complete regeneration
- Most accurate
- Recommended for weekly updates

---

The index-repo skill exists to **eliminate token waste** across all future sessions. The one-time investment pays dividends forever.
