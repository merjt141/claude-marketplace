#!/usr/bin/env bash
set -euo pipefail

echo "=== PEOPL Frontend — Bootstrap Mac ==="

# --------------------------------------------
# 1. Xcode Command Line Tools (includes git)
# --------------------------------------------
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  echo "Accept the dialog that appears, wait for it to finish, then re-run this script."
  xcode-select --install
  exit 0
fi
echo "Xcode CLI Tools: OK"

# --------------------------------------------
# 2. Homebrew
# --------------------------------------------
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add brew to PATH (required on Apple Silicon during the same session)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
echo "Homebrew $(brew --version | head -1): OK"

# --------------------------------------------
# 3. VS Code
# --------------------------------------------
if ! command -v code &>/dev/null; then
  echo "Installing VS Code..."
  brew install --cask visual-studio-code
fi

# Fallback: if 'code' still not in PATH, try resolving from the app bundle
if ! command -v code &>/dev/null; then
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [ -f "$CODE_BIN" ]; then
    echo "code not in PATH yet — using full path fallback"
    alias code="$CODE_BIN"
    export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
  else
    echo "WARNING: VS Code installed but 'code' command not found. Open VS Code manually and run 'Shell Command: Install code command in PATH' from the command palette."
  fi
fi
echo "VS Code: OK"

# Install extensions
echo "Installing VS Code extensions..."
code --install-extension anthropic.claude-code --force
code --install-extension dbaeumer.vscode-eslint --force
code --install-extension eamodio.gitlens --force
code --install-extension usernamehw.errorlens --force
code --install-extension aaron-bond.better-comments --force
code --install-extension timonwong.shellcheck --force

# --------------------------------------------
# 4. GitHub CLI
# --------------------------------------------
if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  brew install gh
fi
echo "GitHub CLI $(gh --version | head -1 | sed 's/gh version //'): OK"

# --------------------------------------------
# 5. nvm + Node 20
# --------------------------------------------
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
echo "nvm $(nvm --version): OK"

# Check if Node 20 is already installed and active
NODE_OK=false
if command -v node &>/dev/null; then
  NODE_VER=$(node -v 2>/dev/null || echo "")
  if [[ "$NODE_VER" == v20.* ]]; then
    NODE_OK=true
  fi
fi

if [ "$NODE_OK" = false ]; then
  echo "Installing Node 20..."
  nvm install 20
fi
nvm use 20
echo "Node $(node -v): OK"

# --------------------------------------------
# 6. Project setup
# --------------------------------------------
echo ""
echo "Setting up project..."
bash "$(dirname "$0")/setup.sh"

# --------------------------------------------
# 7. Reminder: fill in .env.local
# --------------------------------------------
echo ""
echo "============================================"
echo " ACTION REQUIRED: complete .env.local       "
echo "============================================"
echo "Open .env.local and fill in:"
echo "  GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET"
echo "  NEXTAUTH_SECRET  (generate: openssl rand -base64 32)"
echo "  PEOPL_AUNA_API_URL / PEOPL_AUNA_API_KEY"
echo "  PEOPL_COMMUNITY_API_URL / PEOPL_COMMUNITY_API_KEY"
echo "  PIPO_API_URL / PIPO_API_KEY"
echo ""
echo "Bootstrap complete. After filling .env.local, run: npm run dev"
