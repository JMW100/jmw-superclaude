---
name: session-summary
description: Extracts and compresses Claude Code session logs into human-readable markdown summaries
---

# Session Summary - Extract & Compress Session Logs

**Purpose:** Generates a comprehensive session summary from Claude Code's native session logs, creating a human-readable markdown file for future reference and context loading.

**When to invoke:**
- Manually at session checkpoints: `use session-summary`
- Automatically via SessionEnd hook (no invocation needed)

---

## What This Skill Does

Extracts information from Claude Code's session logs (stored in `~/.claude/projects/`) and creates a structured summary in `.context/session-[timestamp].md` with three sections:

1. **Current State** (quick scan) - Session status, actions taken, errors encountered
2. **Key Decisions** (collapsible) - Decisions made, reasoning, alternatives considered
3. **Full Narrative** (collapsible) - Complete chronological conversation

The summary uses the inverted pyramid format: scan-to-detail reading pattern.

---

## How It Works

This skill executes `scripts/generate-summary.py` which:

1. **Finds session log**: Locates most recent `.jsonl` file in `~/.claude/projects/[project-name]/`
2. **Parses events**: Extracts user messages, assistant messages, tool uses, and errors
3. **Generates summary**: Creates markdown with Current State, Decisions, and Narrative
4. **Saves to .context/**: Writes to `.context/session-YYYY-MM-DD-HHMM.md`
5. **Updates symlink**: Sets `.context/session-latest.md` → latest session file

---

## Output

After running, you'll have:

```
.context/
├── session-latest.md              # Symlink → most recent session
├── session-2025-11-28-1430.md     # Timestamped sessions
├── session-2025-11-28-1015.md
└── session-2025-11-27-0900.md
```

**CLAUDE.md reference:**
```markdown
Before starting work, read `.context/session-latest.md` for recent context.
```

This ensures every new Claude Code instance automatically loads your session summary.

---

## Manual Invocation

Use this skill when you want to:
- **Checkpoint progress mid-session** before switching tasks
- **Ensure summary is generated** before stopping work
- **Test the summary system** without waiting for session end

Simply invoke:
```
use session-summary
```

---

## Automatic Generation

The SessionEnd hook automatically runs this skill when you:
- End session with `/stop`
- Close terminal/Claude Code
- Session completes naturally

No manual invocation needed for normal workflow.

---

## Error Handling

The script gracefully handles:
- **No session directory**: Exits if `~/.claude/projects/[project]/` doesn't exist
- **No session files**: Exits if no `.jsonl` logs found
- **Parse errors**: Skips malformed JSON lines, continues processing

If generation fails, check:
1. Session log exists: `ls ~/.claude/projects/-Users-[your-path]/`
2. Python is available: `python3 --version`
3. Script is executable: `chmod +x scripts/generate-summary.py`

---

## Integration with CLAUDE.md

Add this to your project's `CLAUDE.md`:

```markdown
## Session Context

Before starting work, read `.context/session-latest.md` for recent decisions and current state.

This file is automatically updated at session end with:
- Current project state
- Key decisions made
- Full session narrative

Scroll down in the file for more detail if needed.
```

This ensures session summaries are automatically loaded in every new session.

---

## Success Criteria

You'll know it's working when:
1. ✅ `.context/` directory created in project root
2. ✅ Timestamped session files appear after each session
3. ✅ `session-latest.md` symlink points to most recent
4. ✅ Summary includes Current State, Decisions, and Narrative
5. ✅ New Claude Code sessions reference session summaries automatically
6. ✅ You can review decisions made weeks ago by reading `.context/` files
