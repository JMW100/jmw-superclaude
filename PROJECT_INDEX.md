# Project Index: jmw-superclaude

**Generated:** 2025-11-30
**Generator:** SuperClaude index-repo skill
**Purpose:** Compressed repository context for token-efficient sessions
**Next update recommended:** 2025-12-07

---

## Overview

**jmw-superclaude** is a Claude Code plugin providing 16 specialized skills for confidence-driven development. The plugin extends Claude Code with systematic workflows for investigation, confidence checking, research, and validation.

**Key Value:** Skills enforce best practices (TDD, confidence checks, evidence-based review) and prevent wasted tokens from wrong-direction work.

---

## Project Structure

```
jmw-superclaude/
├── skills/                    # 16 plugin skills (plugin root)
│   ├── [skill-name]/SKILL.md  # Each skill in its own directory
├── preferences/               # Stack-specific conventions (3 files)
├── docs/                      # Active documentation (3 files)
├── tasks/                     # PRDs and task lists (permanent home)
├── archive/                   # Superseded historical docs
├── scripts/                   # Utility scripts (3 files)
├── hooks/                     # Optional ntfy.sh notification hooks
├── .claude-plugin/            # Plugin metadata (plugin.json, marketplace.json)
├── .context/                  # Session summaries (auto-generated)
├── CLAUDE.md                  # Main plugin instructions
├── README.md                  # User-facing overview
└── INSTALL.md                 # Installation guide
```

---

## Entry Points

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main plugin instructions, mandatory skill protocol |
| `README.md` | User-facing overview and quick start |
| `INSTALL.md` | Installation guide (3 methods) |
| `.claude-plugin/plugin.json` | Plugin metadata for Claude Code |
| `.claude-plugin/marketplace.json` | Marketplace configuration |

---

## Skills (16 total)

### Core Skills (7)
| Skill | Purpose |
|-------|---------|
| `sc-agent` | 5-step task orchestration with confidence-driven development |
| `confidence-check` | Pre-implementation assessment (5 weighted checks, ≥0.90 to proceed) |
| `deep-research` | Parallel web search with Wave→Checkpoint→Wave pattern |
| `self-review` | Post-implementation validation (4-question evidence-based) |
| `repo-index` | Quick codebase orientation at session start |
| `index-repo` | Generate PROJECT_INDEX.md (94% token reduction) |
| `session-summary` | Extract session logs into markdown summaries |

### Domain Skills (6)
| Skill | Purpose |
|-------|---------|
| `sc-architecture` | System design, APIs, databases, infrastructure |
| `sc-security` | Security audits, auth, threat modeling |
| `sc-performance` | Profiling, query optimization, caching |
| `sc-quality` | Test strategy, unit/integration/e2e testing |
| `sc-workflows` | Troubleshooting, debugging, documentation |
| `sc-executor` | Multi-task project executor |

### Planning Skills (2)
| Skill | Purpose |
|-------|---------|
| `create-prd` | Generate comprehensive PRDs |
| `generate-tasks` | Break down features into actionable tasks |

### Helper Skills (1)
| Skill | Purpose |
|-------|---------|
| `skill-selector` | Recommend appropriate skill(s) for any task |

---

## Preferences (3)

Stack-specific conventions loaded by skills at runtime:

| File | Stack |
|------|-------|
| `preferences/web-app-db.md` | Next.js + Tailwind + Shadcn + Clerk + Stripe + Supabase + Drizzle |
| `preferences/python-backend.md` | FastAPI + SQLAlchemy + Alembic + Pydantic + PostgreSQL + pytest |
| `preferences/multi-agent-orchestration.md` | Multi-agent patterns |

---

## Documentation

### Active Docs (`docs/`)
| File | Purpose |
|------|---------|
| `plugin-development.md` | Plugin file structure, SKILL.md format, JSON schemas |
| `building-robust-systems-guide.md` | Best practices for LLM-assisted development |
| `git-private-repo-setup.md` | Quick reference for GitHub setup |

### Tasks (`tasks/`)
| File | Purpose |
|------|---------|
| `prd-best-practices-integration.md` | Living PRD for plugin enhancements (47 tasks) |
| `task-list-best-practices-integration.md` | Detailed task breakdown by phase |
| `claude-md-skill-protocol-update.md` | Proposed CLAUDE.md updates |

### Archive (`archive/`)
Superseded documentation preserved for historical context. See `archive/README.md`.

---

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/install.sh` | Comprehensive installation script |
| `scripts/install-hooks.sh` | Hook installation for ntfy.sh notifications |
| `scripts/generate-summary.py` | Session summary extraction from Claude Code logs |

---

## Configuration

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin metadata (name, version, description) |
| `.claude-plugin/marketplace.json` | Marketplace configuration |
| `.claude/settings.local.json` | Local hooks configuration |
| `hooks/hooks.json` | Optional ntfy.sh notification hooks |

---

## Key Workflows

### Mandatory Skill Protocol
```
For ANY non-trivial task:
1. use skill-selector → get recommendation
2. use [recommended-skill] → execute workflow
3. Only proceed manually if "no applicable skill"
```

### Confidence-Driven Development
```
confidence-check (≥0.90 required)
  ↓
sc-agent (5-step orchestration)
  ↓
self-review (evidence-based validation)
```

### Session Context
```
Session start → use repo-index (quick briefing)
  ↓
If INDEX stale → use index-repo (regenerate)
  ↓
Session end → session-summary (auto-generated)
```

---

## Pending Work

**Active PRD:** `tasks/prd-best-practices-integration.md`
- 47 tasks across 5 phases
- Phase 0: Directory restructuring (skills → core/, web-app-db/, python-backend/)
- Phases 1-5: Core updates, new skills, stack-specific skills, docs, validation

---

## Repository Statistics

| Metric | Count |
|--------|-------|
| Skills | 16 |
| Preferences | 3 |
| Active docs | 3 |
| Scripts | 3 |
| Pending tasks | 47 |
| Session files | 10 |

---

## Quick Reference

**Invoke a skill:** `use [skill-name]`
**Check skill options:** `use skill-selector`
**Orient on codebase:** `use repo-index`
**Generate index:** `use index-repo`

---

**Index generated by SuperClaude index-repo skill**
