#!/usr/bin/env bash
set -euo pipefail

echo "=== PEOPL Frontend Setup ==="

# 1. Check Node version
REQUIRED_MAJOR=20
CURRENT_MAJOR=$(node -v 2>/dev/null | sed 's/v\([0-9]*\).*/\1/' || echo "0")
if [ "$CURRENT_MAJOR" -lt "$REQUIRED_MAJOR" ]; then
  echo "ERROR: Node >= $REQUIRED_MAJOR required (found: $(node -v 2>/dev/null || echo 'none'))"
  echo "Run: nvm install  (reads .nvmrc automatically)"
  exit 1
fi
echo "Node $(node -v) OK"

# 2. Create .env.local if it does not exist
if [ ! -f .env.local ]; then
  cp .env.example .env.local
  echo "Created .env.local from .env.example — fill in real values before running."
else
  echo ".env.local already exists, skipping."
fi

# 3. Install dependencies
echo "Installing dependencies..."
npm ci

# 4. Type check
echo "Running typecheck..."
npm run typecheck

echo ""
echo "Setup complete. Run 'npm run dev' to start."
