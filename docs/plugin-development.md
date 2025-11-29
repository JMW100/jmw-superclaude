# Plugin Development Guide

Comprehensive guide for developing and maintaining the JMW SuperClaude plugin for Claude Code.

---

## Plugin File Structure

Claude Code plugins have specific structure requirements. Files must be in exact locations for discovery.

```
jmw-superclaude/
├── .claude-plugin/
│   ├── plugin.json           # Plugin metadata (required)
│   └── marketplace.json      # Marketplace configuration (required for marketplace)
├── skills/                   # Skills directory (at plugin root, NOT .claude/skills/)
│   └── [skill-name]/
│       └── SKILL.md          # Skill file with YAML frontmatter
├── preferences/              # Optional technical preferences
│   └── [stack-name].md
├── scripts/                  # Optional utility scripts
│   └── *.py, *.sh
└── hooks/                    # Optional hook configuration reference
    └── hooks.json
```

**Critical:** Skills must be in `skills/` at the plugin root, not `.claude/skills/`. The `.claude/` directory is for project-level configuration, not plugin content.

---

## SKILL.md Requirements

Every skill file **must** have YAML frontmatter for Claude Code to discover it.

### Required Frontmatter Format

```yaml
---
name: skill-name
description: What this skill does and when to use it
---

# Skill Title

Rest of skill content...
```

### Field Constraints

| Field | Requirements |
|-------|-------------|
| `name` | Lowercase letters, numbers, hyphens only. Max 64 characters. Must match directory name. |
| `description` | What the skill does. Max 1024 characters. Shown in skill listings. |

### Example

```yaml
---
name: confidence-check
description: Prevents wrong-direction execution by assessing confidence BEFORE implementation. Requires 90% score to proceed.
---

# Confidence Check - Pre-Implementation Assessment

**Purpose:** Prevents wrong-direction execution...
```

**Without this frontmatter, skills will not be discovered via the plugin system.**

---

## Plugin JSON Schema

### plugin.json

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "What this plugin provides",
  "author": {
    "name": "Author Name",
    "url": "https://github.com/username"
  },
  "repository": "https://github.com/username/repo",
  "homepage": "https://github.com/username/repo",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

**Critical constraints:**
- `name`: kebab-case, no spaces (e.g., `jmw-superclaude` not `JMW SuperClaude`)
- `author`: Must be an object with `name` and `url` properties, not a string

### marketplace.json

```json
{
  "name": "marketplace-name",
  "description": "Marketplace description",
  "owner": {
    "name": "Owner Name",
    "url": "https://github.com/username"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./",
      "description": "Plugin description",
      "version": "1.0.0",
      "author": {
        "name": "Author Name",
        "url": "https://github.com/username"
      },
      "license": "MIT",
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

**Critical constraints:**
- `name`: kebab-case, no spaces
- `owner`: Must be an object with `name` and `url` properties, not a string
- `plugins[].author`: Must be an object, not a string

---

## Installation Paths

When users install the plugin via `/plugin install`, files are copied to:

```
~/.claude/plugins/marketplaces/[marketplace-name]/
```

This is a **user-level** installation that applies to all projects for that user.

**Important:** Changes to the source repository require users to run:
```
/plugin marketplace update [marketplace-name]
```

---

## Testing Workflow

### Setup Test Environment

1. Create a separate test directory (not the plugin source):
   ```bash
   mkdir ~/code/test-plugin-install
   cd ~/code/test-plugin-install
   git init
   ```

2. Start Claude Code in the test directory

### Install and Test

1. Add the marketplace:
   ```
   /plugin marketplace add https://github.com/JMW100/jmw-superclaude
   ```

2. Install the plugin:
   ```
   /plugin install jmw-superclaude@jmw-superclaude
   ```

3. Verify installation:
   ```
   /plugin
   ```
   Should show plugin as "Installed"

4. Test skill discovery:
   ```
   use skill-selector
   ```

### After Making Changes

1. Commit and push changes to the source repository
2. In test directory, update the marketplace:
   ```
   /plugin marketplace update jmw-superclaude-marketplace
   ```
3. Re-test skill discovery

### Verify Frontmatter

Check that skills have correct frontmatter:
```bash
head -5 ~/.claude/plugins/marketplaces/jmw-superclaude-marketplace/skills/skill-selector/SKILL.md
```

Should show:
```yaml
---
name: skill-selector
description: ...
---
```

---

## Common Mistakes

### Skills Not Discovered

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Skill not found" | Skills in `.claude/skills/` | Move to `skills/` at plugin root |
| "Skill not found" | Missing YAML frontmatter | Add `---` block with `name` and `description` |
| "Skill not found" | Frontmatter `name` doesn't match directory | Ensure `name: skill-name` matches `skills/skill-name/` |

### Plugin Schema Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "name cannot contain spaces" | Name has spaces | Use kebab-case: `my-plugin` not `My Plugin` |
| "author: Expected object, received string" | `"author": "Name"` | Use object: `"author": {"name": "...", "url": "..."}` |
| "owner: Expected object, received string" | `"owner": "Name"` | Use object: `"owner": {"name": "...", "url": "..."}` |

### Marketplace Not Updating

| Symptom | Cause | Fix |
|---------|-------|-----|
| Old skill content after push | Marketplace cache | Run `/plugin marketplace update [name]` |
| Changes not reflected | Forgot to push | `git push` then update marketplace |

---

## Plugin Development Principles

### What the Plugin Does

1. **Prevents wrong-direction execution** - confidence-check requires ≥0.90 before implementation
2. **Systematizes workflows** - sc-agent provides 5-step protocol
3. **Enables parallel research** - deep-research coordinates multiple sources
4. **Documents decisions** - session summaries capture problem-solving journey
5. **Validates outcomes** - self-review provides evidence-based validation
6. **Optimizes tokens** - repo-index reduces 58K tokens to 3K (94% reduction)

### What to Avoid

When modifying this plugin:

❌ Don't add build/test/lint processes (it's just markdown and JSON)
❌ Don't make skills overly verbose (skills are loaded into context)
❌ Don't duplicate general best practices (assume modern LLM baseline)
❌ Don't hardcode stack choices (use preferences/ files for opinions)
❌ Don't create circular skill dependencies
❌ Don't add files that won't be read by skills or plugin system

### Skill Design Principles

1. **Clear purpose statement** - First line states what the skill does
2. **When to invoke** - Explicit guidance on when to use/not use
3. **Weighted scoring** - confidence-check uses explicit weights for objectivity
4. **Output format examples** - Show concrete examples of good output
5. **Integration points** - Document how skills work together
6. **Token discipline** - Keep communication concise, avoid redundancy
7. **Delegation over reinvention** - Skills should delegate to other skills when appropriate

---

## Adding New Skills

1. Create directory:
   ```bash
   mkdir skills/my-new-skill
   ```

2. Create `SKILL.md` with frontmatter:
   ```yaml
   ---
   name: my-new-skill
   description: Brief description of what this skill does
   ---

   # My New Skill - Title

   **Purpose:** What this skill does.

   **When to invoke:** When to use this skill.

   ---

   ## What This Skill Does

   ...
   ```

3. Test locally (skills in source repo work directly)

4. Commit, push, and update marketplace for plugin users

---

## Modifying Existing Skills

1. Edit the skill file directly: `skills/[skill-name]/SKILL.md`
2. Test the skill: `use [skill-name]`
3. Commit and push changes
4. Users update via: `/plugin marketplace update jmw-superclaude-marketplace`

**Note:** No build process required. Changes are immediate for local development.

---

## Hook Installation

Hooks cannot be auto-installed by plugins for security reasons. Users must manually install hooks.

### SessionEnd Hook (for session summaries)

Users run the installation script:
```bash
curl -fsSL https://raw.githubusercontent.com/JMW100/jmw-superclaude/main/scripts/install.sh | bash
```

Or if they have the repo cloned:
```bash
bash scripts/install.sh
```

Or manually add to `.claude/settings.local.json`:
```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python3 scripts/generate-summary.py"
          }
        ]
      }
    ]
  }
}
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024 | Initial release with 16 skills |
| 1.0.1 | 2024 | Added YAML frontmatter for plugin discovery |
| 1.0.2 | 2024 | Comprehensive install.sh replacing install-hooks.sh |
