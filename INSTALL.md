# JMW SuperClaude - Installation Guide

## Quick Install

### Option 1: Install from GitHub (Recommended when published)

```bash
# Add the marketplace
/plugin marketplace add https://github.com/JMW100/jmw-superclaude

# Install the plugin
/plugin install jmw-superclaude@jmw-superclaude

# Verify skills are available
/help
```

### Option 2: Install Locally (For Development/Testing)

```bash
# Navigate to the directory where you cloned jmw-superclaude
cd /path/to/jmw-superclaude

# Add local marketplace (use absolute path)
/plugin marketplace add /absolute/path/to/jmw-superclaude

# Install the plugin
/plugin install jmw-superclaude@jmw-superclaude

# Verify installation
/help
```

## Verify Installation

After installation, check that the skills are available:

```bash
/help
```

You should see all 15 SuperClaude skills listed:
- confidence-check
- create-prd
- deep-research
- generate-tasks
- index-repo
- repo-index
- sc-agent
- sc-architecture
- sc-executor
- sc-performance
- sc-quality
- sc-security
- sc-workflows
- self-review
- skill-selector

## Test the Plugin

Try invoking a skill:

```bash
use skill-selector
```

Or:

```bash
use confidence-check
```

## Team Setup

To automatically install the plugin for your team, add to `.claude/settings.json` in your project repository:

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

When team members trust the repository, they'll automatically get the plugin.

## Optional: Setup Notifications

To enable push notifications for task completion:

1. **Install ntfy app** on your phone (iOS/Android)
2. **Subscribe to a topic** (e.g., `my-claude-work-xyz123`)
3. **Add hook configuration** to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -d \"Claude Code needs your attention\" ntfy.sh/YOUR_TOPIC"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -d \"Claude Code task complete!\" -H \"Title: Claude Code\" -H \"Tags: white_check_mark\" ntfy.sh/YOUR_TOPIC"
          }
        ]
      }
    ]
  }
}
```

Replace `YOUR_TOPIC` with your ntfy topic name.

## Updating the Plugin

When updates are available:

```bash
# Uninstall current version
/plugin uninstall jmw-superclaude@jmw-superclaude

# Reinstall to get latest version
/plugin install jmw-superclaude@jmw-superclaude
```

## Troubleshooting

### Skills Not Showing Up

1. Verify plugin is installed:
   ```bash
   /plugin
   ```

2. Check that plugin is enabled:
   ```bash
   /plugin enable jmw-superclaude@jmw-superclaude
   ```

3. Restart Claude Code (if using CLI)

### Local Development: Reinstalling After Changes

When testing local changes to the plugin:

```bash
# Uninstall
/plugin uninstall jmw-superclaude@jmw-superclaude

# Reinstall
/plugin install jmw-superclaude@jmw-superclaude

# Claude Code will restart to activate changes
```

## Next Steps

Once installed, see:
- **README.md** - Full feature list and usage examples
- **Recommended workflow** - Start with `use confidence-check`
- **Planning workflow** - `create-prd` → `generate-tasks` → `sc-architecture` → `sc-agent` → `self-review`

## Support

- **Issues**: https://github.com/JMW100/jmw-superclaude/issues
- **Source**: https://github.com/JMW100/jmw-superclaude
