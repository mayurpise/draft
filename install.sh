#!/bin/bash

# Draft Plugin Installer for Claude Code

set -e

PLUGIN_DIR="$HOME/.claude/plugins/draft"

echo "================================================"
echo "       Draft Plugin Installer for Claude Code"
echo "================================================"
echo ""

# Step 1: Clone or update plugin
if [ -d "$PLUGIN_DIR" ]; then
    echo "Updating existing installation..."
    cd "$PLUGIN_DIR" && git pull
    echo ""
else
    echo "Cloning plugin..."
    mkdir -p "$HOME/.claude/plugins"
    git clone https://github.com/mayurpise/draft.git "$PLUGIN_DIR"
    echo ""
fi

echo "================================================"
echo "                Installation Complete!"
echo "================================================"
echo ""
echo "To use the Draft plugin, start Claude Code with:"
echo ""
echo "    claude --plugin-dir ~/.claude/plugins/draft"
echo ""
echo "For convenience, add this alias to your ~/.bashrc or ~/.zshrc:"
echo ""
echo "    alias claude-draft='claude --plugin-dir ~/.claude/plugins/draft'"
echo ""
echo "------------------------------------------------"
echo "Available commands:"
echo "    /draft            - Show overview"
echo "    /draft:init       - Initialize project"
echo "    /draft:new-track  - Create a new feature track"
echo "    /draft:implement  - Execute tasks from plan"
echo "    /draft:status     - Show progress"
echo "    /draft:revert     - Git-aware rollback"
echo "================================================"
echo ""
