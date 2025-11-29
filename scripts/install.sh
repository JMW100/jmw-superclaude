#!/bin/bash
#
# JMW SuperClaude - Complete Installation Script
#
# This script completes SuperClaude setup after plugin installation:
# - Installs SessionEnd hook for automatic session summaries
# - Copies required scripts to your project
# - Copies preferences for customization
# - Creates necessary directories
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JMW100/jmw-superclaude/main/scripts/install.sh | bash
#
# Options:
#   --minimal     Skip preferences (only hooks + scripts)
#   --with-docs   Also copy docs/ for local reference
#   --help        Show this help message
#

set -e

# Configuration
GITHUB_RAW="https://raw.githubusercontent.com/JMW100/jmw-superclaude/main"
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/jmw-superclaude-marketplace"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
MINIMAL=false
WITH_DOCS=false

# Track what was installed
INSTALLED_ITEMS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --minimal)
            MINIMAL=true
            shift
            ;;
        --with-docs)
            WITH_DOCS=true
            shift
            ;;
        --help)
            echo "JMW SuperClaude - Complete Installation Script"
            echo ""
            echo "Usage: curl -fsSL .../install.sh | bash [-s -- OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --minimal     Skip preferences (only hooks + scripts)"
            echo "  --with-docs   Also copy docs/ for local reference"
            echo "  --help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  curl -fsSL .../install.sh | bash"
            echo "  curl -fsSL .../install.sh | bash -s -- --minimal"
            echo "  curl -fsSL .../install.sh | bash -s -- --with-docs"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo ""
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  JMW SuperClaude - Complete Installation${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Helper function: copy file from plugin or download from GitHub
copy_file() {
    local src_path=$1
    local dest_path=$2
    local dest_dir=$(dirname "$dest_path")

    # Create destination directory if needed
    mkdir -p "$dest_dir"

    # Check if file exists at plugin location
    if [ -f "$PLUGIN_DIR/$src_path" ]; then
        cp "$PLUGIN_DIR/$src_path" "$dest_path"
        echo -e "${GREEN}  ✓ Copied from plugin: $dest_path${NC}"
        return 0
    fi

    # Fall back to GitHub download
    if command -v curl &> /dev/null; then
        if curl -fsSL "$GITHUB_RAW/$src_path" -o "$dest_path" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Downloaded: $dest_path${NC}"
            return 0
        fi
    fi

    echo -e "${RED}  ✗ Failed to copy: $src_path${NC}"
    return 1
}

# Helper function: copy directory from plugin or download files from GitHub
copy_dir() {
    local src_dir=$1
    local dest_dir=$2
    local files=("${@:3}")

    mkdir -p "$dest_dir"

    for file in "${files[@]}"; do
        copy_file "$src_dir/$file" "$dest_dir/$file"
    done
}

# ============================================
# 1. Create .claude directory
# ============================================
if [ ! -d ".claude" ]; then
    echo -e "${YELLOW}Creating .claude directory...${NC}"
    mkdir -p .claude
fi

# ============================================
# 2. Install SessionEnd hook
# ============================================
echo -e "${YELLOW}Installing SessionEnd hook...${NC}"

SETTINGS_FILE=".claude/settings.local.json"

if [ -f "$SETTINGS_FILE" ]; then
    # Check if hooks already configured
    if grep -q '"SessionEnd"' "$SETTINGS_FILE" 2>/dev/null; then
        echo -e "${GREEN}  ✓ SessionEnd hook already configured${NC}"
    else
        # Backup existing file
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
        echo -e "${YELLOW}  Backed up to ${SETTINGS_FILE}.backup${NC}"

        # Merge hooks using Python
        if command -v python3 &> /dev/null; then
            python3 << 'PYTHON_SCRIPT'
import json

settings_file = ".claude/settings.local.json"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except:
    settings = {}

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
PYTHON_SCRIPT
            echo -e "${GREEN}  ✓ SessionEnd hook merged into settings${NC}"
        else
            echo -e "${RED}  ✗ Python3 required for merging. Please add hook manually.${NC}"
        fi
    fi
else
    # Create new settings file
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
    echo -e "${GREEN}  ✓ Created $SETTINGS_FILE with SessionEnd hook${NC}"
fi
INSTALLED_ITEMS+=("SessionEnd hook")

# ============================================
# 3. Create .context directory
# ============================================
if [ ! -d ".context" ]; then
    echo -e "${YELLOW}Creating .context directory for session summaries...${NC}"
    mkdir -p .context
    echo -e "${GREEN}  ✓ Created .context/${NC}"
fi
INSTALLED_ITEMS+=(".context/ directory")

# ============================================
# 4. Copy scripts
# ============================================
echo -e "${YELLOW}Installing scripts...${NC}"
mkdir -p scripts

if copy_file "scripts/generate-summary.py" "scripts/generate-summary.py"; then
    chmod +x scripts/generate-summary.py
    INSTALLED_ITEMS+=("scripts/generate-summary.py")
fi

# ============================================
# 5. Copy preferences (unless --minimal)
# ============================================
if [ "$MINIMAL" = false ]; then
    echo -e "${YELLOW}Installing preferences...${NC}"
    mkdir -p preferences

    PREF_FILES=("web-app-db.md" "python-backend.md" "multi-agent-orchestration.md")
    for pref in "${PREF_FILES[@]}"; do
        if copy_file "preferences/$pref" "preferences/$pref"; then
            INSTALLED_ITEMS+=("preferences/$pref")
        fi
    done
else
    echo -e "${YELLOW}Skipping preferences (--minimal flag)${NC}"
fi

# ============================================
# 6. Copy docs (if --with-docs)
# ============================================
if [ "$WITH_DOCS" = true ]; then
    echo -e "${YELLOW}Installing docs...${NC}"
    mkdir -p docs

    if copy_file "docs/plugin-development.md" "docs/plugin-development.md"; then
        INSTALLED_ITEMS+=("docs/plugin-development.md")
    fi
fi

# ============================================
# Summary
# ============================================
echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "What was installed:"
for item in "${INSTALLED_ITEMS[@]}"; do
    echo -e "  ${GREEN}✓${NC} $item"
done

echo ""
echo -e "${BLUE}Session summaries will be automatically generated when you end a Claude Code session.${NC}"
echo ""

# ============================================
# Suggest CLAUDE.md snippet
# ============================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Recommended: Add this to your CLAUDE.md:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "## Session Context"
echo ""
echo "Before starting work, read \`.context/session-latest.md\` for recent context."
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}You're all set! Try: use skill-selector${NC}"
echo ""
