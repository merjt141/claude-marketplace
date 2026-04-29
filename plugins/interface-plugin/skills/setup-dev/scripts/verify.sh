#!/usr/bin/env bash
# ----------------------------------------------------------
# PEOPL Frontend - Environment Verification
# ----------------------------------------------------------
# Checks that all prerequisites are installed and configured.
# No admin privileges required. Safe to re-run at any time.
#
# Usage:  bash scripts/verify.sh
# ----------------------------------------------------------

PASS=0
WARN=0
FAIL=0

pass() { echo "  [OK]   $1"; ((PASS++)); }
warn() { echo "  [WARN] $1"; ((WARN++)); }
fail() { echo "  [FAIL] $1"; ((FAIL++)); }

echo "=== PEOPL Frontend - Environment Verification ==="
echo ""

# --------------------------------------------
# 1. Git
# --------------------------------------------
if command -v git &>/dev/null; then
  pass "Git $(git --version | sed 's/git version //')"
else
  fail "Git not installed"
fi

# --------------------------------------------
# 2. GitHub CLI
# --------------------------------------------
if command -v gh &>/dev/null; then
  pass "GitHub CLI $(gh --version 2>/dev/null | head -1 | sed 's/gh version //' | sed 's/ (.*//')"
else
  fail "GitHub CLI not installed (required for PRs)"
fi

# --------------------------------------------
# 3. Node.js (v20.x required)
# --------------------------------------------
if command -v node &>/dev/null; then
  NODE_VER=$(node -v)
  if [[ "$NODE_VER" == v20.* ]]; then
    pass "Node $NODE_VER"
  else
    fail "Node $NODE_VER (v20.x required)"
  fi
else
  fail "Node not installed"
fi

# --------------------------------------------
# 4. npm
# --------------------------------------------
if command -v npm &>/dev/null; then
  pass "npm $(npm -v)"
else
  fail "npm not installed"
fi

# --------------------------------------------
# 5. nvm
# --------------------------------------------
NVM_FOUND=false
if command -v nvm &>/dev/null; then
  NVM_FOUND=true
elif [ -s "$HOME/.nvm/nvm.sh" ]; then
  NVM_FOUND=true
elif [ -s "$NVM_DIR/nvm.sh" ] 2>/dev/null; then
  NVM_FOUND=true
fi

if [ "$NVM_FOUND" = true ]; then
  pass "nvm found"
else
  warn "nvm not detected (optional but recommended)"
fi

# --------------------------------------------
# 6. VS Code
# --------------------------------------------
if command -v code &>/dev/null; then
  pass "VS Code $(code --version 2>/dev/null | head -1)"

  # Check extensions
  EXTENSIONS=$(code --list-extensions 2>/dev/null || echo "")
  REQUIRED_EXTENSIONS=(
    "anthropic.claude-code"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
    "usernamehw.errorlens"
    "aaron-bond.better-comments"
  )
  for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if echo "$EXTENSIONS" | grep -qi "^${ext}$"; then
      pass "Extension: $ext"
    else
      warn "Extension missing: $ext"
    fi
  done
else
  warn "VS Code not in PATH (optional for CLI-only workflow)"
fi

# --------------------------------------------
# 7. node_modules
# --------------------------------------------
if [ -d "node_modules" ]; then
  pass "node_modules present"
else
  fail "node_modules missing (run: npm ci)"
fi

# --------------------------------------------
# 8. .env.local
# --------------------------------------------
if [ -f ".env.local" ]; then
  pass ".env.local exists"

  # Check for placeholder values
  EMPTY_VARS=0
  while IFS='=' read -r key value; do
    # Skip comments and blank lines
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
    # Trim whitespace
    value=$(echo "$value" | xargs 2>/dev/null || echo "")
    if [ -z "$value" ]; then
      ((EMPTY_VARS++))
    fi
  done < .env.local

  if [ "$EMPTY_VARS" -gt 0 ]; then
    warn ".env.local has $EMPTY_VARS empty variable(s)"
  else
    pass ".env.local has no empty variables"
  fi
else
  fail ".env.local missing (run: npm run setup)"
fi

# --------------------------------------------
# 9. TypeScript check
# --------------------------------------------
if [ -d "node_modules" ] && command -v npm &>/dev/null; then
  echo ""
  echo "Running typecheck..."
  if npm run typecheck --silent 2>/dev/null; then
    pass "typecheck passes"
  else
    fail "typecheck has errors (run: npm run typecheck)"
  fi
else
  warn "Skipping typecheck (node_modules or npm missing)"
fi

# --------------------------------------------
# Summary
# --------------------------------------------
echo ""
echo "=== Results: $PASS passed, $WARN warnings, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  echo "Run the bootstrap script to fix failures: bash scripts/bootstrap-mac.sh"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "Environment is usable but has warnings."
  exit 0
else
  echo "Environment is ready."
  exit 0
fi
