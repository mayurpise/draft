#!/bin/bash

# Draft Plugin Installer for Claude Code

set -e

PLUGIN_DIR="$HOME/.claude/plugins/draft"
PLUGINS_FILE="$HOME/.claude/plugins/installed_plugins.json"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Installing Draft plugin for Claude Code..."

# Step 1: Clone or update plugin
if [ -d "$PLUGIN_DIR" ]; then
    echo "Updating existing installation..."
    cd "$PLUGIN_DIR" && git pull
else
    echo "Cloning plugin..."
    git clone https://github.com/mayurpise/draft.git "$PLUGIN_DIR"
fi

# Step 2: Register plugin in installed_plugins.json
echo "Registering plugin..."

if [ ! -f "$PLUGINS_FILE" ]; then
    # Create new file
    cat > "$PLUGINS_FILE" << EOF
{
  "version": 2,
  "plugins": {
    "draft@local": [
      {
        "scope": "user",
        "installPath": "$PLUGIN_DIR",
        "version": "1.0.0",
        "installedAt": "$(date -Iseconds)",
        "lastUpdated": "$(date -Iseconds)"
      }
    ]
  }
}
EOF
else
    # Check if draft@local already exists
    if grep -q '"draft@local"' "$PLUGINS_FILE"; then
        echo "Plugin already registered in installed_plugins.json"
    else
        # Add draft@local to existing plugins
        # Using a temp file for safe editing
        tmp_file=$(mktemp)
        # Insert before the last closing braces
        sed '$ d' "$PLUGINS_FILE" > "$tmp_file"  # Remove last line
        sed -i '$ d' "$tmp_file"  # Remove second to last line
        cat >> "$tmp_file" << EOF
    },
    "draft@local": [
      {
        "scope": "user",
        "installPath": "$PLUGIN_DIR",
        "version": "1.0.0",
        "installedAt": "$(date -Iseconds)",
        "lastUpdated": "$(date -Iseconds)"
      }
    ]
  }
}
EOF
        mv "$tmp_file" "$PLUGINS_FILE"
    fi
fi

# Step 3: Enable plugin in settings.json
echo "Enabling plugin..."

if [ ! -f "$SETTINGS_FILE" ]; then
    # Create new settings file
    cat > "$SETTINGS_FILE" << EOF
{
  "enabledPlugins": {
    "draft@local": true
  }
}
EOF
else
    # Check if draft@local already enabled
    if grep -q '"draft@local"' "$SETTINGS_FILE"; then
        echo "Plugin already enabled in settings.json"
    else
        # Add to enabledPlugins
        tmp_file=$(mktemp)
        if grep -q '"enabledPlugins"' "$SETTINGS_FILE"; then
            # Add to existing enabledPlugins
            sed 's/"enabledPlugins": {/"enabledPlugins": {\n    "draft@local": true,/' "$SETTINGS_FILE" > "$tmp_file"
            mv "$tmp_file" "$SETTINGS_FILE"
        else
            # Add enabledPlugins section
            sed 's/{/{  "enabledPlugins": { "draft@local": true },/' "$SETTINGS_FILE" > "$tmp_file"
            mv "$tmp_file" "$SETTINGS_FILE"
        fi
    fi
fi

echo ""
echo "Installation complete!"
echo ""
echo "Please restart Claude Code to load the plugin."
echo ""
echo "Verify with: /draft:status"
