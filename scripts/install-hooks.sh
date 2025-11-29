#!/bin/bash
#
# JMW SuperClaude - Hook Installation Script (DEPRECATED)
#
# This script has been replaced by install.sh which does everything:
# - Installs hooks
# - Copies scripts
# - Copies preferences
#
# This file remains for backwards compatibility and redirects to install.sh
#

echo "Note: install-hooks.sh is deprecated. Redirecting to install.sh..."
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the new install script
if [ -f "$SCRIPT_DIR/install.sh" ]; then
    bash "$SCRIPT_DIR/install.sh" "$@"
else
    # If running via curl, download and run install.sh
    curl -fsSL https://raw.githubusercontent.com/JMW100/jmw-superclaude/main/scripts/install.sh | bash -s -- "$@"
fi
