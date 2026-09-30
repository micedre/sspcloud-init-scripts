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

cfg="${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json"
mkdir -p "$(dirname "$cfg")"

if [ ! -s "$cfg" ]; then
  echo '{"hasCompletedOnboarding": true}' > "$cfg"
elif command -v jq >/dev/null 2>&1; then
  tmp=$(mktemp)
  jq '.hasCompletedOnboarding = true' "$cfg" > "$tmp"
  cat "$tmp" > "$cfg"   # keep the original file's permissions
  rm -f "$tmp"
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$cfg" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
data["hasCompletedOnboarding"] = True
with open(path, "w") as f:
    json.dump(data, f, indent=2)
EOF
else
  echo "Error: jq or python3 is needed to update the existing $cfg" >&2
  exit 1
fi

echo "hasCompletedOnboarding=true set in $cfg"


#/home/onyxia/.local/bin/claude mcp add-json kubernetes '{"name":"kubernetes","command":"npx","args":["kubernetes-mcp-server@latest"]}'
echo "alias claudio='ANTHROPIC_BASE_URL=${OPENAI_BASE_URL} ANTHROPIC_AUTH_TOKEN=${OPENAI_API_KEY} claude --model ${OPENAI_DEFAULT_MODEL}'" >> ~/.bashrc

# git clone https://github.com/wshobson/agents.git "$HOME/.claude/agents"

### Configure OpenCode

git clone https://github.com/micedre/opencode-onyxia "$HOME/opencode-onyxia"
bash "$HOME/opencode-onyxia/install.sh"


## Install extensions
### Rest client

echo "Installing Extensions..."


code-server --install-extension humao.rest-client
code-server --install-extension fcrespo82.markdown-table-formatter
code-server --install-extension lucien-martijn.parquet-visualizer
code-server --install-extension astral-sh.ty
code-server --install-extension krish-r.vscode-toggle-terminal
code-server --install-extension christofkaufmann.dataframe-viewer

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
  "python.terminal.activateEnvironment": false,
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "notebook.output.textLineLimit": 100,
  "workbench.colorTheme": "Default Dark Modern",  
  "editor.rulers": [80, 100, 120], 
  "files.trimTrailingWhitespace": true,  
  "files.insertFinalNewline": true,  
  "workbench.settings.showAISearchToggle": false,
  "workbench.secondarySideBar.defaultVisibility": "hidden",
  "chat.disableAIFeatures": true,
  "security.workspace.trust.enabled": false
}
EOF

chown onyxia: "$SETTINGS_FILE"
