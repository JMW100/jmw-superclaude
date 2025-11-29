#!/usr/bin/env python3
"""
Generate Session Summary from Claude Code Session Logs

This script extracts and summarizes information from Claude Code's native session logs
and creates a human-readable markdown summary in the inverted pyramid format.

Usage:
    python scripts/generate-summary.py

The script will:
1. Find the current project directory
2. Locate the most recent session log in ~/.claude/projects/
3. Extract key information (decisions, actions, outcomes)
4. Generate a summary in .context/session-YYYY-MM-DD-HHMM.md
5. Update .context/session-latest.md symlink
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Optional

def get_project_directory() -> str:
    """Get current working directory as absolute path."""
    return os.getcwd()

def get_claude_project_name(project_dir: str) -> str:
    """
    Convert project directory to Claude Code project directory name.

    Example: /Users/jonathanwells/code/jmw-superclaude
          -> -Users-jonathanwells-code-jmw-superclaude
    """
    # Replace all / with -
    claude_name = project_dir.replace('/', '-')
    return claude_name

def find_latest_session_log(project_dir: str) -> Optional[Path]:
    """
    Find the most recent session log file for the current project.

    Returns:
        Path to session log file, or None if not found
    """
    claude_dir = Path.home() / '.claude' / 'projects'
    claude_project_name = get_claude_project_name(project_dir)
    project_log_dir = claude_dir / claude_project_name

    if not project_log_dir.exists():
        print(f"No Claude Code session directory found: {project_log_dir}", file=sys.stderr)
        return None

    # Find all .jsonl files
    session_files = list(project_log_dir.glob('*.jsonl'))

    if not session_files:
        print(f"No session logs found in: {project_log_dir}", file=sys.stderr)
        return None

    # Return most recently modified
    latest = max(session_files, key=lambda p: p.stat().st_mtime)
    return latest

def parse_session_log(log_file: Path) -> List[Dict[str, Any]]:
    """
    Parse JSONL session log file.

    Each line is a JSON object representing an event in the session.
    """
    events = []
    with open(log_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    events.append(json.loads(line))
                except json.JSONDecodeError as e:
                    print(f"Warning: Failed to parse line: {e}", file=sys.stderr)
                    continue
    return events

def extract_summary_data(events: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Extract key information from session events.

    Returns a dictionary with:
        - user_messages: List of user prompts
        - assistant_messages: List of assistant responses
        - tool_uses: List of tools used
        - errors: List of errors encountered
        - decisions: Extracted decisions and reasoning
    """
    data = {
        'user_messages': [],
        'assistant_messages': [],
        'tool_uses': [],
        'tool_results': [],
        'errors': []
    }

    for event in events:
        if not isinstance(event, dict):
            continue

        # Handle nested message format (actual Claude Code log structure)
        # Events have: {"message": {"role": "...", "content": [...]}, "type": "user"|"assistant", ...}
        msg = event.get('message', event)  # Fall back to event itself for flat format
        role = msg.get('role')
        content = msg.get('content', '')

        # User messages
        if role == 'user':
            if isinstance(content, str):
                data['user_messages'].append(content)
            elif isinstance(content, list):
                for item in content:
                    if isinstance(item, dict) and item.get('type') == 'text':
                        data['user_messages'].append(item.get('text', ''))
                    elif isinstance(item, str):
                        data['user_messages'].append(item)

        # Assistant messages
        elif role == 'assistant':
            if isinstance(content, str):
                data['assistant_messages'].append(content)
            elif isinstance(content, list):
                for item in content:
                    if isinstance(item, dict):
                        if item.get('type') == 'text':
                            data['assistant_messages'].append(item.get('text', ''))
                        elif item.get('type') == 'tool_use':
                            data['tool_uses'].append({
                                'name': item.get('name'),
                                'input': item.get('input')
                            })

        # Tool results (can be at event level)
        if event.get('type') == 'tool_result':
            result = {
                'tool_use_id': event.get('tool_use_id'),
                'content': event.get('content')
            }
            if event.get('is_error'):
                data['errors'].append(result)
            data['tool_results'].append(result)

    return data

def generate_current_state(data: Dict[str, Any]) -> str:
    """Generate the 'Current State' section."""
    # Extract last few assistant messages for context
    recent_work = data['assistant_messages'][-3:] if data['assistant_messages'] else []

    # Count tool uses
    tool_count = len(data['tool_uses'])
    error_count = len(data['errors'])

    state = f"""**State:** Session with {tool_count} actions taken"""
    if error_count > 0:
        state += f" | **Errors:** {error_count} encountered"
    else:
        state += " | **Errors:** None"

    state += f" | **Messages:** {len(data['user_messages'])} exchanges"

    return state

def generate_decisions_section(data: Dict[str, Any]) -> str:
    """Generate the 'Key Decisions' collapsible section."""
    decisions = []

    # Extract decisions from conversation
    # Look for patterns like "I chose X because Y" or "decided to use X"
    for msg in data['assistant_messages']:
        if any(keyword in msg.lower() for keyword in ['chose', 'decided', 'selected', 'using', 'rejected']):
            # Truncate long messages
            snippet = msg[:200] + '...' if len(msg) > 200 else msg
            decisions.append(f"- {snippet}")

    if not decisions:
        decisions.append("- No explicit decisions recorded in this session")

    return '\n'.join(decisions)

def generate_narrative_section(data: Dict[str, Any]) -> str:
    """Generate the 'Full Narrative' collapsible section."""
    narrative = []

    # Interleave user and assistant messages chronologically
    user_idx = 0
    assistant_idx = 0

    while user_idx < len(data['user_messages']) or assistant_idx < len(data['assistant_messages']):
        if user_idx < len(data['user_messages']):
            narrative.append(f"**User:** {data['user_messages'][user_idx]}")
            user_idx += 1

        if assistant_idx < len(data['assistant_messages']):
            msg = data['assistant_messages'][assistant_idx]
            # Truncate very long messages
            if len(msg) > 500:
                msg = msg[:500] + "..."
            narrative.append(f"**Assistant:** {msg}")
            assistant_idx += 1

        narrative.append("")  # Empty line between exchanges

    return '\n'.join(narrative)

def generate_markdown_summary(data: Dict[str, Any], timestamp: str) -> str:
    """Generate the complete markdown summary in inverted pyramid format."""

    current_state = generate_current_state(data)
    decisions = generate_decisions_section(data)
    narrative = generate_narrative_section(data)

    markdown = f"""# Session Summary: {timestamp}

<!-- Quick scan -->
{current_state}

<details>
<summary>📋 Key Decisions (click to expand)</summary>

{decisions}

</details>

<details>
<summary>📖 Full Narrative (click for details)</summary>

{narrative}

</details>

---

*Generated automatically by session-summary from Claude Code session logs*
"""

    return markdown

def save_summary(project_dir: str, markdown: str, timestamp: str) -> Path:
    """
    Save summary to .context/ directory and update symlink.

    Returns:
        Path to the saved summary file
    """
    context_dir = Path(project_dir) / '.context'
    context_dir.mkdir(exist_ok=True)

    # Create timestamped filename
    summary_file = context_dir / f"session-{timestamp}.md"

    # Write summary
    with open(summary_file, 'w') as f:
        f.write(markdown)

    print(f"✅ Summary saved: {summary_file}")

    # Update symlink
    symlink_path = context_dir / 'session-latest.md'

    # Remove existing symlink if it exists
    if symlink_path.exists() or symlink_path.is_symlink():
        symlink_path.unlink()

    # Create new symlink (relative to context_dir)
    symlink_path.symlink_to(summary_file.name)
    print(f"✅ Symlink updated: session-latest.md -> {summary_file.name}")

    return summary_file

def main():
    """Main entry point."""
    print("🔍 Generating session summary...")

    # Get project directory
    project_dir = get_project_directory()
    print(f"📂 Project: {project_dir}")

    # Find latest session log
    log_file = find_latest_session_log(project_dir)
    if not log_file:
        print("❌ No session log found. Exiting.")
        sys.exit(1)

    print(f"📄 Session log: {log_file}")

    # Parse session log
    events = parse_session_log(log_file)
    print(f"📊 Parsed {len(events)} events")

    # Extract summary data
    data = extract_summary_data(events)
    print(f"💬 Found {len(data['user_messages'])} user messages, {len(data['assistant_messages'])} assistant messages")
    print(f"🔧 Found {len(data['tool_uses'])} tool uses")

    # Generate timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d-%H%M")

    # Generate markdown
    markdown = generate_markdown_summary(data, timestamp)

    # Save summary
    summary_file = save_summary(project_dir, markdown, timestamp)

    print(f"\n✅ Session summary generated successfully!")
    print(f"📝 Read: .context/session-latest.md")

if __name__ == '__main__':
    main()
