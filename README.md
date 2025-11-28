# JMW SuperClaude

**JMW's customized version of SuperClaude** - A comprehensive Claude Code plugin providing 15 specialized skills for confidence-driven development.

## 🎉 Features

**16 SuperClaude Skills** across 4 categories:
- **7 Core Skills**: Session orchestration, confidence checks, research, review, repository indexing, and session summaries
- **6 Domain Skills**: Architecture, security, performance, quality, workflows, and execution
- **2 Planning Skills**: PRD generation and task breakdown (powered by Opus 4)
- **1 Helper Skill**: Skill selector to guide you to the right tool

**Total: 48+ specialized tasks** available through simple skill invocations.

## Installation

### Quick Start

```bash
# Add the SuperClaude marketplace
/plugin marketplace add https://github.com/JMW100/jmw-superclaude

# Install the plugin
/plugin install jmw-superclaude@jmw-superclaude

# Verify installation
/help
```

### Team Setup

Add to your repository's `.claude/settings.json`:

```json
{
  "plugins": {
    "marketplaces": [
      {
        "name": "jmw-superclaude",
        "source": "https://github.com/JMW100/jmw-superclaude"
      }
    ],
    "enabled": [
      "jmw-superclaude@jmw-superclaude"
    ]
  }
}
```

Team members will automatically get the plugin when they trust the repository.

## Skills Overview

### Core SuperClaude Skills (7)

| Skill | Description | Usage |
|-------|-------------|-------|
| **sc-agent** | Session orchestrator and task workflow coordinator | `use sc-agent for [task]` |
| **confidence-check** | Pre-implementation assessment (prevents 5K-50K wasted tokens) | `use confidence-check` |
| **deep-research** | Parallel web search (3-5x faster research) | `use deep-research on [topic]` |
| **self-review** | Post-implementation validation (evidence-based) | `use self-review` |
| **repo-index** | Quick repository briefing | `use repo-index` |
| **index-repo** | Generate PROJECT_INDEX.md (94% token reduction) | `use index-repo` |
| **session-summary** | Extract session summaries from Claude Code logs (automatic via SessionEnd hook) | `use session-summary` |

### Domain Task Skills (6)

| Skill | Tasks | Usage |
|-------|-------|-------|
| **sc-architecture** | 12 tasks: microservices, API design, tech stack, databases, infrastructure | `use sc-architecture` |
| **sc-security** | 10 tasks: authentication, authorization, OWASP audits, encryption, GDPR | `use sc-security` |
| **sc-workflows** | 8 tasks: troubleshooting, root cause analysis, documentation, planning | `use sc-workflows` |
| **sc-performance** | 8 tasks: profiling, database optimization, caching, load testing | `use sc-performance` |
| **sc-quality** | 10 tasks: test strategy, unit/integration/E2E testing, code review | `use sc-quality` |
| **sc-executor** | Multi-task project executor (supervisor-worker pattern) | `use sc-executor for [project]` |

### Planning & Documentation Skills (2)

| Skill | Description | Usage |
|-------|-------------|-------|
| **create-prd** | Product Requirements Document generator (Opus 4) | `use create-prd for [feature]` |
| **generate-tasks** | Task list generator from PRDs (Opus 4) | `use generate-tasks from prd-*.md` |

### Helper Skills (1)

| Skill | Description | Usage |
|-------|-------------|-------|
| **skill-selector** | Helps choose the right skill for your task | `use skill-selector` |

## Usage Examples

### Planning Workflow (Recommended)

```bash
# 1. Assess feasibility
use confidence-check

# 2. Create requirements document
use create-prd for user authentication

# 3. Break down into tasks
use generate-tasks from prd-user-authentication.md

# 4. Design system architecture
use sc-architecture

# 5. Implement with orchestration
use sc-agent for implement authentication

# 6. Validate implementation
use self-review
```

### Quick Development Tasks

```bash
# Research a technology
use deep-research on Redis caching strategies

# Review security
use sc-security for OWASP audit

# Optimize performance
use sc-performance for database queries

# Add comprehensive tests
use sc-quality for unit testing
```

## Core Development Patterns

### 1. Confidence-First Development

BEFORE implementing any feature, assess confidence using 5 checks:

| Check | Weight | Description |
|-------|--------|-------------|
| 1. No Duplicates | 25% | Search codebase for existing functionality |
| 2. Architecture Compliant | 25% | Uses existing tech stack and patterns |
| 3. Official Docs Verified | 20% | Documentation reviewed |
| 4. Working OSS Reference | 15% | OSS implementations found |
| 5. Root Cause Identified | 15% | Problem source clearly identified |

**Decision Logic:**
- **≥90%**: ✅ High confidence - Proceed
- **70-89%**: ⚠️ Medium confidence - Ask questions
- **<70%**: ❌ Low confidence - Investigate more

**ROI**: Spend 100-200 tokens on confidence check to save 5,000-50,000 tokens on wrong-direction work.

### 2. Research Protocol (Wave→Checkpoint→Wave)

Parallel execution for 3-5x speedup:
- **Wave 1**: Multiple parallel searches (Tavily, Context7, WebFetch, WebSearch)
- **Checkpoint**: Analyze results, verify sources, identify gaps
- **Wave 2**: Fill gaps, verify conflicts, find examples

### 3. Token Optimization via Repository Indexing

- **Problem**: Reading all files → ~58,000 tokens
- **Solution**: Generate PROJECT_INDEX.md → ~3,000 tokens (94% reduction)
- **ROI**: 550,000 tokens saved over 10 sessions

### 4. Automatic Session Summaries

**NEW:** Session summaries replace manual engineering logs with automatic extraction from Claude Code's native logs.

**How it works:**
- **Automatic**: SessionEnd hook runs `generate-summary.py` when session ends
- **Manual**: `use session-summary` for mid-session checkpoints
- **Storage**: `.context/session-YYYY-MM-DD-HHMM.md` (timestamped files)
- **Access**: `.context/session-latest.md` symlink (auto-loaded via CLAUDE.md)

**Format** (Inverted Pyramid - scan to detail):
1. **Current State** (always visible) - Quick status, actions, errors
2. **Key Decisions** (collapsible) - What was chosen and why
3. **Full Narrative** (collapsible) - Complete chronological conversation

**Benefits:**
- ✅ **Memory aid**: Return to parked projects and remember your thinking
- ✅ **Context for future Claude instances**: Auto-loaded via CLAUDE.md reference
- ✅ **No logging burden**: Extracted from existing session logs, no active maintenance
- ✅ **Simple architecture**: Single source of truth (Claude Code's logs)

**Setup in your projects:**
Add to `.claude/CLAUDE.md`:
```markdown
## Session Context

Before starting work, read `.context/session-latest.md` for recent context.
```

## Technical Preferences

The plugin includes technical preferences for common tech stacks:

### Web App Development (Next.js + Supabase)
- File: `preferences/web-app-db.md`
- Auto-loaded by sc-agent, sc-architecture, confidence-check

**Key conventions:**
- `userId: text("user_id")` (always text, never uuid)
- ActionState return type for server actions
- Function names end with "Action" or "Storage"
- `@/` imports (never relative paths)
- kebab-case for all files/folders

### Python Backend Development
- File: `preferences/python-backend.md`
- Applies to: FastAPI, SQLAlchemy, async Python

Skills automatically detect and apply relevant preferences based on project context.

## Notification Hooks (Optional)

The plugin includes notification hooks for task completion alerts via [ntfy.sh](https://ntfy.sh).

**Setup:**
1. Install ntfy app on your phone
2. Subscribe to a unique topic (e.g., `my-claude-alerts-xyz`)
3. Configure in your `.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "curl -s -d 'Claude Code needs attention' ntfy.sh/YOUR_TOPIC"
      }]
    }],
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "curl -s -d 'Task complete!' -H 'Title: Claude Code' -H 'Tags: white_check_mark' ntfy.sh/YOUR_TOPIC"
      }]
    }]
  }
}
```

Replace `YOUR_TOPIC` with your ntfy topic name.

## Planning Skills with Opus 4

The `create-prd` and `generate-tasks` skills use **Claude Opus 4** for superior reasoning:

### create-prd
1. Asks 3-5 clarifying questions with multiple-choice options
2. Generates comprehensive PRD with 9 sections
3. Saves to `/tasks/prd-[feature-name].md`

### generate-tasks
1. Analyzes requirements (Phase 1: Parent tasks)
2. Waits for "Go" confirmation
3. Generates detailed sub-tasks (Phase 2)
4. Identifies relevant files and test requirements
5. Saves to `/tasks/tasks-[feature-name].md`

**Why Opus 4?**
- Superior reasoning for requirements analysis
- Comprehensive thinking catches edge cases
- Quality output suitable for stakeholders and developers

## License

MIT

## Support

- **Issues**: https://github.com/JMW100/jmw-superclaude/issues
- **Source**: https://github.com/JMW100/jmw-superclaude
- **Original Framework**: Based on [SuperClaude Framework](https://github.com/cyanheads/claude-code-super-prompts)

## Contributing

Contributions welcome! Please open an issue or PR on GitHub.
