#!/bin/bash
#
# JMW SuperClaude - Hook Installation Script
#
# This script installs the SessionEnd hook for automatic session summaries.
# Run this from your project directory after installing the plugin.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JMW100/jmw-superclaude/main/scripts/install-hooks.sh | bash
#
#   Or if you have the repo cloned:
#   bash /path/to/jmw-superclaude/scripts/install-hooks.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "  JMW SuperClaude - Hook Installation"
echo "=========================================="
echo ""

# Check if we're in a directory with .claude
if [ ! -d ".claude" ]; then
    echo -e "${YELLOW}Creating .claude directory...${NC}"
    mkdir -p .claude
fi

# Define the settings file
SETTINGS_FILE=".claude/settings.local.json"

# Check if settings file exists
if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}Found existing $SETTINGS_FILE${NC}"

    # Check if hooks already configured
    if grep -q '"SessionEnd"' "$SETTINGS_FILE" 2>/dev/null; then
        echo -e "${GREEN}SessionEnd hook already configured. Skipping.${NC}"
        exit 0
    fi

    # Backup existing file
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
    echo -e "${YELLOW}Backed up to ${SETTINGS_FILE}.backup${NC}"

    # Try to merge hooks into existing file using Python
    if command -v python3 &> /dev/null; then
        python3 << 'PYTHON_SCRIPT'
import json
import sys

settings_file = ".claude/settings.local.json"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except:
    settings = {}

# Add hooks section
if 'hooks' not in settings:
    settings['hooks'] = {}

settings['hooks']['SessionEnd'] = [
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

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("Hooks merged successfully")
PYTHON_SCRIPT
    else
        echo -e "${RED}Python3 not found. Please manually add hooks to $SETTINGS_FILE${NC}"
        echo ""
        echo "Add this to your settings file:"
        echo '  "hooks": {'
        echo '    "SessionEnd": [{'
        echo '      "matcher": "",'
        echo '      "hooks": [{"type": "command", "command": "python3 scripts/generate-summary.py"}]'
        echo '    }]'
        echo '  }'
        exit 1
    fi
else
    # Create new settings file
    echo -e "${YELLOW}Creating $SETTINGS_FILE...${NC}"
    cat > "$SETTINGS_FILE" << 'EOF'
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
EOF
fi

# Create .context directory for session summaries
if [ ! -d ".context" ]; then
    echo -e "${YELLOW}Creating .context directory for session summaries...${NC}"
    mkdir -p .context
fi

# Copy the generate-summary.py script if not present
if [ ! -f "scripts/generate-summary.py" ]; then
    echo -e "${YELLOW}Note: scripts/generate-summary.py not found.${NC}"
    echo "The plugin should provide this file. If you installed via the plugin system,"
    echo "it should be available. Otherwise, copy it from the jmw-superclaude repo."
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  Installation Complete!"
echo "==========================================${NC}"
echo ""
echo "What was configured:"
echo "  - SessionEnd hook for automatic session summaries"
echo "  - .context/ directory for storing summaries"
echo ""
echo "When you end a Claude Code session, it will automatically:"
echo "  1. Run scripts/generate-summary.py"
echo "  2. Create .context/session-YYYY-MM-DD-HHMM.md"
echo "  3. Update .context/session-latest.md symlink"
echo ""
echo "To enable session context loading, add this to your CLAUDE.md:"
echo ""
echo '  ## Session Context'
echo '  Before starting work, read `.context/session-latest.md` for recent context.'
echo ""
