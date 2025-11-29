# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is **JMW SuperClaude** - a Claude Code plugin providing 15 specialized skills for confidence-driven development. The plugin extends Claude Code with systematic workflows for investigation, confidence checking, research, and validation.

## Repository Structure

```
.claude/
  settings.local.json # Hooks configuration (SessionEnd, etc.)
skills/               # 16 skills (plugin root location)
  [skill-name]/
    SKILL.md
.claude-plugin/
  marketplace.json    # Marketplace configuration
  plugin.json         # Plugin metadata
scripts/
  generate-summary.py # Session summary extraction script
  install-hooks.sh    # Hook installation script
hooks/
  hooks.json          # Optional ntfy.sh notification hooks (reference)
preferences/
  web-app-db.md       # Next.js + Supabase stack preferences
  python-backend.md   # FastAPI + SQLAlchemy preferences
```

## Key Concepts

### Skills Architecture

Skills are invoked with `use [skill-name]` and are loaded from `skills/[skill-name]/SKILL.md`. Each skill is a self-contained markdown file that provides instructions for specific workflows.

**15 Skills across 4 categories:**

1. **Core Skills (6)**: sc-agent, confidence-check, deep-research, self-review, repo-index, index-repo
2. **Domain Skills (6)**: sc-architecture, sc-security, sc-performance, sc-quality, sc-workflows, sc-executor
3. **Planning Skills (2)**: create-prd, generate-tasks (both use Opus 4)
4. **Helper Skills (1)**: skill-selector

### Technical Preferences System

The plugin includes opinionated technical preferences for common stacks:
- **preferences/web-app-db.md**: Next.js + Tailwind + Shadcn + Clerk + Stripe + Supabase + Drizzle
- **preferences/python-backend.md**: FastAPI + SQLAlchemy + Alembic + Pydantic + PostgreSQL + pytest

Skills like sc-agent, sc-architecture, and confidence-check automatically load relevant preferences based on project context.

### Hooks System

Optional notification hooks via ntfy.sh:
- `hooks/hooks.json` defines "Notification" and "Stop" hooks
- Uses `$NTFY_TOPIC` environment variable
- Sends push notifications when Claude Code needs attention or completes tasks

## Development Workflow

### No Build Process

This repository contains only markdown files and JSON configuration. There is no build, lint, or test process.

### Modifying Skills

To update a skill:
1. Edit the relevant `skills/[skill-name]/SKILL.md` file
2. The skill will be immediately available (no compilation needed)
3. Test the skill by using it: `use [skill-name]`

### Modifying Preferences

To update technical preferences:
1. Edit `preferences/web-app-db.md` or `preferences/python-backend.md`
2. Skills that reference these files will use the updated preferences
3. Keep preferences concise - focus on deviations from defaults, not general best practices

### Adding New Skills

1. Create directory: `skills/[skill-name]/`
2. Add `SKILL.md` with the skill instructions
3. Skills are auto-discovered from the directory structure

## Core Workflow Patterns

### sc-agent: 5-Step Task Protocol

The sc-agent skill coordinates complex multi-step tasks:

1. **Clarify scope** - Define success criteria and constraints
2. **Plan investigation** - Use parallel execution, delegate to specialized skills
3. **Iterate until confident** - Require ≥0.90 confidence before implementation
4. **Implementation wave** - TDD, complexity assessment, planning, loop detection
5. **Self-review** - Validate outcomes and identify follow-up

**Key Implementation Details:**
- **Complexity assessment**: Simple/Medium/Hard determines planning depth
- **TDD always**: Write failing tests first, then implement to pass
- **Loop detection**: Max 20 attempts, stop if stuck (same error 3x or no progress after 10 attempts)
- **Session summaries**: Automatic extraction from Claude Code logs at session end
- **Educational explanations**: Explain what/why/alternatives/takeaway throughout

### confidence-check: 5 Weighted Checks

Pre-implementation assessment prevents wrong-direction work:

| Check | Weight | What It Verifies |
|-------|--------|-----------------|
| No Duplicates | 25% | No similar functionality in codebase |
| Architecture Compliant | 25% | Uses existing tech stack and patterns |
| Official Docs Verified | 20% | Documentation reviewed |
| Working OSS Reference | 15% | OSS implementations found |
| Root Cause Identified | 15% | Problem source clearly identified |

**Decision Thresholds:**
- ≥0.90: Proceed with implementation
- 0.70-0.89: Ask questions, present alternatives
- <0.70: STOP - Investigate further

**ROI**: Spend 100-200 tokens to save 5,000-50,000 tokens on wrong-direction work.

### deep-research: Wave→Checkpoint→Wave

Parallel research execution for 3-5x speedup:
- **Wave 1**: Multiple parallel searches (Tavily, Context7, WebFetch, WebSearch)
- **Checkpoint**: Analyze results, verify sources, identify gaps
- **Wave 2**: Fill gaps, verify conflicts, find examples

### Session Summary Pattern

Session summaries are automatically generated at session end from Claude Code's native logs:
- Stored in `.context/session-YYYY-MM-DD-HHMM.md` (timestamped files)
- Symlinked via `.context/session-latest.md` for easy reference
- Format: Inverted pyramid (Current State → Decisions → Full Narrative)
- Collapsible sections for scan-to-detail reading
- CLAUDE.md references `.context/session-latest.md` for auto-loading
- Manual checkpoint: `use session-summary` skill
- Automatic generation: SessionEnd hook runs Python extraction script

## Plugin Development

For detailed plugin development guidance, see [docs/plugin-development.md](docs/plugin-development.md), which covers:
- Plugin file structure and location requirements
- SKILL.md YAML frontmatter format
- JSON schema requirements for plugin.json and marketplace.json
- Testing workflow for plugin changes
- Common mistakes and troubleshooting

## Important Conventions

### File Organization

- Skills go in `skills/[skill-name]/SKILL.md`
- Preferences go in `preferences/[stack-name].md`
- Plugin metadata in `.claude-plugin/`
- Hooks configuration in `.claude/settings.local.json`
- Scripts in `scripts/`

### Naming

- Skill directories: kebab-case (e.g., `confidence-check`, `sc-agent`)
- Skill files: Always `SKILL.md` (uppercase)
- Preference files: kebab-case with stack identifier

### Markdown Style

- Use `**bold**` for emphasis
- Use `✅ ❌ ⚠️` emojis sparingly for status indicators
- Use tables for structured data
- Use code blocks with language identifiers
- Keep sections scannable with clear headers

## Technical Stack Preferences

When working on projects using these stacks, skills automatically load relevant preferences:

### Web Apps (Next.js + Supabase)
See `preferences/web-app-db.md` for:
- Critical userId convention: `text("user_id")` not uuid
- ActionState return type pattern for server actions
- Naming: functionNameAction/functionNameStorage
- Import convention: Always `@/` never relative paths

### Python Backends (FastAPI + SQLAlchemy)
See `preferences/python-backend.md` for:
- Critical UUID convention for IDs
- Schema class pattern: Base/Create/Update/Response/InDB
- Async/await requirements for all database operations
- Response model always specified in endpoints

## Success Indicators

The plugin is working correctly when:
1. Skills follow documented protocols systematically
2. Confidence checks prevent premature implementation
3. Session summaries capture decision narratives in `.context/`
4. Skills delegate to each other appropriately
5. Token usage is optimized through repo-index and confidence-check
6. TDD is enforced (tests before implementation)
7. Loop detection prevents infinite attempts
8. Educational explanations provided throughout implementation
