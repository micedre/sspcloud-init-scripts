#!/bin/bash

set +e
set -o pipefail

## Install Node/NPM

echo "Installing Node.js via n-install..."

curl -fsSL https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | bash -s -- -q 22

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

## Install Claude Code

curl -fsSL https://claude.ai/install.sh | bash

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

/home/onyxia/.local/bin/claude mcp add-json kubernetes '{"name":"kubernetes","command":"npx","args":["kubernetes-mcp-server@latest"]}'
echo "alias claudio='ANTHROPIC_BASE_URL=${OPENAI_BASE_URL} ANTHROPIC_AUTH_TOKEN=${OPENAI_API_KEY} claude --model ${OPENAI_DEFAULT_MODEL}'" >> ~/.bashrc

# git clone https://github.com/wshobson/agents.git "$HOME/.claude/agents"

### Install OpenCode
echo "Installing Opencode..."
curl -fsSL https://opencode.ai/install | bash

mkdir -p "$HOME/.config/opencode/"
cat > "$HOME/.config/opencode/opencode.json" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model":"llmlab/${OPENAI_DEFAULT_MODEL}",
  "provider": {
    "llmlab": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LLM Lab SSPCloud",
      "options": {
        "baseURL": "${OPENAI_BASE_URL}",
        "headers": {
          "Content-Type": "application/json"
        },
        "apiKey": "{env:OPENAI_API_KEY}"
      },
      "models": {
        "${OPENAI_DEFAULT_MODEL}": {
          "name": "${OPENAI_DEFAULT_MODEL}",
          "limit": {
            "context": 64536,
            "output": 64536
          }
        }
      }
    }
  }
}
EOF

## Install git-ai 

curl -sSL https://usegitai.com/install.sh | bash

## Install extensions
### Rest client

echo "Installing Extensions..."


code-server --install-extension humao.rest-client
code-server --install-extension fcrespo82.markdown-table-formatter
code-server --install-extension lucien-martijn.parquet-visualizer
code-server --install-extension astral-sh.ty
code-server --install-extension krish-r.vscode-toggle-terminal
code-server --install-extension the0807.uv-toolkit

publisher="ms-toolsai" extension_name="datawrangler" version="1.24.0"
echo https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${extension_name}/${version}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
wget -O /tmp/datawrangler.vsix https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${extension_name}/${version}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
code-server --install-extension /tmp/datawrangler.vsix

### Settings 

# Define the configuration directory for VS Code
VSCODE_CONFIG_DIR="$HOME/.local/share/code-server/User"

# Create the configuration directory if necessary
mkdir -p "$VSCODE_CONFIG_DIR"

# User settings file
SETTINGS_FILE="$VSCODE_CONFIG_DIR/settings.json"

cat > "$SETTINGS_FILE" << EOF
{
  "editor.formatOnSave": true,
  "editor.tabSize": 4,
  "editor.wordWrap": "on",
  "editor.fontSize": 14,
  "editor.minimap.enabled": false,
  "files.autoSave": "onFocusChange",
  "terminal.integrated.fontSize": 14,
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "notebook.output.textLineLimit": 100,
  "workbench.colorTheme": "Default Dark Modern",  # Set the theme
  "editor.rulers": [80, 100, 120],  # Add specific vertical rulers
  "files.trimTrailingWhitespace": true,  # Automatically trim trailing whitespace
  "files.insertFinalNewline": true,  # Ensure files end with a newline
  "workbench.settings.showAISearchToggle": false,
  "workbench.secondarySideBar.defaultVisibility": "hidden",
  "chat.disableAIFeatures": true,
  "security.workspace.trust.enabled": true
}
EOF

chown onyxia: "$SETTINGS_FILE"
