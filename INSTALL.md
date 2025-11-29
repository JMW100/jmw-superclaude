# JMW SuperClaude - Installation Guide

Complete step-by-step instructions for installing JMW SuperClaude in a new project.

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- Python 3.x (for session summary generation)
- Git (for cloning/installation)

---

## Installation Methods

Choose **one** of the following methods:

| Method | Best For | Complexity |
|--------|----------|------------|
| [Method 1: Plugin System](#method-1-plugin-system-recommended) | Most users, easy updates | Simple |
| [Method 2: Git Clone](#method-2-git-clone) | Contributors, customization | Medium |
| [Method 3: Manual Copy](#method-3-manual-copy) | Selective installation | Advanced |

---

## Method 1: Plugin System (Recommended)

### Step 1: Add the Marketplace

Open Claude Code in your project directory and run:

```
/plugin marketplace add https://github.com/JMW100/jmw-superclaude
```

### Step 2: Install the Plugin

```
/plugin install jmw-superclaude@jmw-superclaude
```

### Step 3: Verify Installation

```
/help
```

You should see the SuperClaude skills listed (16 skills total).

### Step 4: Install Hooks (Required for Session Summaries)

The plugin system cannot auto-install hooks for security reasons. Run this manually:

**Option A: One-liner (curl)**
```bash
curl -fsSL https://raw.githubusercontent.com/JMW100/jmw-superclaude/main/scripts/install-hooks.sh | bash
```

**Option B: Download and run**
```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/JMW100/jmw-superclaude/main/scripts/install-hooks.sh -o install-hooks.sh

# Review it (always good practice)
cat install-hooks.sh

# Run it
bash install-hooks.sh
rm install-hooks.sh
```

### Step 5: Copy Required Scripts

The session summary feature needs the Python script in your project:

```bash
# Create scripts directory
mkdir -p scripts

# Download the script
curl -fsSL https://raw.githubusercontent.com/JMW100/jmw-superclaude/main/scripts/generate-summary.py -o scripts/generate-summary.py
chmod +x scripts/generate-summary.py
```

### Step 6: Enable Session Context Loading (Optional but Recommended)

Add this to your project's `CLAUDE.md` (create if it doesn't exist):

```markdown
## Session Context

Before starting work, read `.context/session-latest.md` for recent context.
```

### Done!

You're now ready to use JMW SuperClaude. Try:

```
use skill-selector
```

---

## Method 2: Git Clone

Best for contributors or those who want to customize the skills.

### Step 1: Clone the Repository

```bash
# Clone to a location outside your project
git clone https://github.com/JMW100/jmw-superclaude.git ~/jmw-superclaude
```

### Step 2: Symlink Skills into Your Project

```bash
# Navigate to your project
cd /path/to/your/project

# Create .claude directory if needed
mkdir -p .claude

# Symlink the skills
ln -s ~/jmw-superclaude/skills .claude/skills
```

### Step 3: Copy Scripts

```bash
# Create scripts directory
mkdir -p scripts

# Copy the session summary script
cp ~/jmw-superclaude/scripts/generate-summary.py scripts/
```

### Step 4: Install Hooks

```bash
bash ~/jmw-superclaude/scripts/install-hooks.sh
```

### Step 5: Enable Session Context Loading

Add to your `CLAUDE.md`:

```markdown
## Session Context

Before starting work, read `.context/session-latest.md` for recent context.
```

### Updating

To get the latest version:

```bash
cd ~/jmw-superclaude
git pull
```

Your symlinked skills will automatically update.

---

## Method 3: Manual Copy

For selective installation of specific skills only.

### Step 1: Download What You Need

Visit https://github.com/JMW100/jmw-superclaude and download:

- `skills/` - All skills (at plugin root) (or just the ones you want)
- `scripts/generate-summary.py` - Session summary script
- `scripts/install-hooks.sh` - Hook installation script
- `preferences/` - Technical preferences (optional)

### Step 2: Copy to Your Project

```bash
# Create directories
mkdir -p .claude/skills
mkdir -p scripts

# Copy skills to YOUR project's .claude/skills/ (example: just sc-agent and confidence-check)
cp -r /path/to/downloaded/skills/sc-agent .claude/skills/
cp -r /path/to/downloaded/skills/confidence-check .claude/skills/

# Copy scripts
cp /path/to/downloaded/scripts/generate-summary.py scripts/
```

### Step 3: Install Hooks

```bash
bash /path/to/downloaded/scripts/install-hooks.sh
```

---

## Team Setup

To share SuperClaude with your entire team, add this to your repository's `.claude/settings.json`:

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

**Note:** Each team member must still run the hook installation script individually (Step 4 of Method 1).

---

## What Gets Installed

| Component | Location | Purpose |
|-----------|----------|---------|
| Skills (16) | `skills/` | Core functionality |
| Session Summary Script | `scripts/generate-summary.py` | Extracts session summaries |
| SessionEnd Hook | `.claude/settings.local.json` | Auto-triggers summaries |
| Session Summaries | `.context/session-*.md` | Stored summaries |
| Preferences | `preferences/` | Tech stack conventions |

---

## Optional: Notification Hooks

To enable push notifications for task completion via [ntfy.sh](https://ntfy.sh):

1. **Install ntfy app** on your phone (iOS/Android)
2. **Subscribe to a topic** (e.g., `my-claude-alerts-xyz123`)
3. **Add to your `.claude/settings.local.json`** (merge with existing hooks):

```json
{
  "hooks": {
    "SessionEnd": [...],
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

---

## Post-Installation Verification

### Test 1: Skills Available

```
use skill-selector
```

Should display skill selection interface.

### Test 2: Session Summary Works

```bash
python3 scripts/generate-summary.py
```

Should create `.context/session-*.md` file.

### Test 3: List Installed Skills

Check that skills are discoverable:

```bash
ls -la skills/
```

Should show all 16 skill directories:
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
- session-summary
- skill-selector

---

## Troubleshooting

### "Skill not found" error

**Cause:** Skills not in correct location.

**Fix:** Ensure skills are in `skills/[skill-name]/SKILL.md`

### Session summaries not generating

**Cause 1:** Hook not installed.
```bash
cat .claude/settings.local.json | grep SessionEnd
```

**Cause 2:** Script not found.
```bash
ls -la scripts/generate-summary.py
```

**Fix:** Re-run the hook installation script.

### "Permission denied" on scripts

**Fix:**
```bash
chmod +x scripts/generate-summary.py
chmod +x scripts/install-hooks.sh
```

### Plugin not showing in `/plugin`

**Cause:** Marketplace not added.

**Fix:**
```
/plugin marketplace add https://github.com/JMW100/jmw-superclaude
/plugin marketplace update jmw-superclaude
```

---

## Updating the Plugin

### Via Plugin System

```
/plugin uninstall jmw-superclaude@jmw-superclaude
/plugin install jmw-superclaude@jmw-superclaude
```

### Via Git Clone

```bash
cd ~/jmw-superclaude
git pull
```

---

## Uninstallation

### Remove Plugin

```
/plugin uninstall jmw-superclaude@jmw-superclaude
/plugin marketplace remove jmw-superclaude
```

### Remove Local Files

```bash
rm -rf skills/
rm -f scripts/generate-summary.py
rm -rf .context/
```

### Remove Hooks

Edit `.claude/settings.local.json` and remove the `"hooks"` section.

---

## Next Steps

Once installed, see:
- **README.md** - Full feature list and usage examples
- **Recommended workflow** - Start with `use confidence-check`
- **Planning workflow** - `create-prd` → `generate-tasks` → `sc-architecture` → `sc-agent` → `self-review`

---

## Support

- **Issues:** https://github.com/JMW100/jmw-superclaude/issues
- **Source:** https://github.com/JMW100/jmw-superclaude
