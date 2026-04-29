# PEOPL Frontend - Environment Setup

This is a one-time setup guide for new machines. Once complete, you only need `npm run dev` to work on the project.

## Prerequisites

Ensure Git is installed (`git --version`). If not:
- **Mac:** `xcode-select --install`
- **Windows:** https://git-scm.com/download/win

Git is required before anything else.

## Agent-assisted setup (Claude Code)

**Always run the bootstrap script first.** The script is the authoritative definition of "setup" and is idempotent — safe to re-run if it stops partway. Only fall back to the manual checklist below if the script itself fails. You will need to guide the user through the process because the script will run in a different window you won't be able to see what's happening.

### Step 1: Run the bootstrap script

Detect the OS and run the appropriate script:

**Mac / Linux:**
```bash
bash .claude/skills/setup-dev/scripts/bootstrap-mac.sh
```

**Windows:**

Do **NOT** invoke the Windows bootstrap via `powershell.exe -File` from bash — this causes encoding errors. Use `Start-Process -Verb RunAs` instead:
```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PWD\.claude\skills\setup-dev\scripts\bootstrap-windows.ps1`""
```
The script will run in a new elevated window. Inform the user to approve the UAC prompt. The script writes all output to `.claude/skills/setup-dev/scripts/logs/bootstrap.log` — read that file to monitor progress and diagnose failures without asking the user to relay text.

On Windows, before running the script, scan for curly quotes or em-dashes that would break it:
```powershell
$p = '.claude\skills\setup-dev\scripts\bootstrap-windows.ps1'
(Get-Content $p -Raw) -replace '\u201C','"' -replace '\u201D','"' -replace '\u2018',"'" -replace '\u2019',"'" | Set-Content $p -Encoding UTF8
```

### Step 2: Prompt the user to fill in `.env.local`

The bootstrap opens `.env.local` automatically. Remind the user which values are required (see "After bootstrap" section below). Do not proceed to `npm run dev` until credentials are in place.

---

### Manual fallback checklist

Use this **only** if the bootstrap script fails. Verify each step — do not skip or assume.

**1. Check Git**

```bash
git --version
```
If missing, install it before continuing (see Prerequisites above).

**2. Check VS Code**

```bash
code --version 2>/dev/null || echo "not found"
```
If missing, install via winget:
```powershell
winget install --id Microsoft.VisualStudioCode -e --source winget --accept-package-agreements --accept-source-agreements
```

**3. Install VS Code extensions**

Always install these regardless of whether VS Code was already present:
```bash
code --install-extension anthropic.claude-code --force
code --install-extension dbaeumer.vscode-eslint --force
code --install-extension eamodio.gitlens --force
code --install-extension usernamehw.errorlens --force
code --install-extension aaron-bond.better-comments --force
code --install-extension ms-vscode.powershell --force
```
If `code` is not in PATH (common mid-session in bash after a fresh install), use the full path:
```bash
"$LOCALAPPDATA/Programs/Microsoft VS Code/bin/code" --install-extension anthropic.claude-code --force
# repeat for each extension
```

**4. Check nvm and Node 20**

Check whether nvm-windows is installed and Node 20 is available:
```powershell
# Check nvm
Test-Path "$env:LOCALAPPDATA\nvm\nvm.exe"  # or $env:APPDATA\nvm\nvm.exe

# Check Node 20
node --version  # should be v20.x.x
```
If nvm-windows is missing:
```powershell
winget install --id CoreyButler.NVMforWindows -e --source winget --accept-package-agreements --accept-source-agreements
```
If Node 20 is not active:
```powershell
nvm install 20
nvm use 20
```
Node 20 may be installed but not in the current bash PATH. Check known locations:
- `C:\Users\<user>\AppData\Local\nvm\v20.x.x\node.exe`
- nvm symlink typically at `C:\nvm4w\nodejs` or `C:\Program Files\nodejs`

Add the active Node to bash PATH before running npm commands:
```bash
export PATH="/c/nvm4w/nodejs:$PATH"   # adjust path to match your nvm symlink
node -v  # verify v20.x.x
```

**5. Install dependencies and run setup**

```bash
cd <repo-root>
npm run setup
```
This installs dependencies, creates `.env.local`, and runs typecheck. If `npm run setup` is not available, run manually:
```bash
npm ci
[ -f .env.local ] || cp .env.example .env.local && echo "Created .env.local"
npm run typecheck
```
All typecheck errors must be resolved before continuing.

**6. Open VS Code**

Open the project folder and `.env.local` side by side so the user can fill in credentials:
```bash
VSCODE="$LOCALAPPDATA/Programs/Microsoft VS Code/bin/code"
"$VSCODE" .
"$VSCODE" .env.local
```
If `code` is in PATH, use `code . && code .env.local` directly.

**7. Prompt the user to fill in `.env.local`**

Remind the user which values are required (see "After bootstrap" section below). Do not proceed to `npm run dev` until credentials are in place.

## Bootstrap

Run the bootstrap script for your OS from the repository root. The script is **idempotent** -- safe to re-run if it stops partway.

### Windows

The script self-elevates -- no need to open PowerShell as Administrator manually:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
.\.claude\skills\setup-dev\scripts\bootstrap-windows.ps1
```

The script will:
1. Install Git, VS Code, VS Code extensions, and GitHub CLI
2. Install nvm-windows and Node 20
3. Run `npm run setup` (installs dependencies, creates `.env.local`, runs typecheck)
4. Open VS Code with `.env.local` ready to fill in

### Mac / Linux

```bash
bash .claude/skills/setup-dev/scripts/bootstrap-mac.sh
```

## After bootstrap

1. Fill in the credentials in `.env.local` (opened automatically by the bootstrap):
   - `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`
   - `NEXTAUTH_SECRET` — generate with: `openssl rand -base64 32`
   - `PEOPL_AUNA_API_URL` / `PEOPL_AUNA_API_KEY`
   - `PEOPL_COMMUNITY_API_URL` / `PEOPL_COMMUNITY_API_KEY`
   - `PIPO_API_URL` / `PIPO_API_KEY`

2. Start the development server in a new terminal:
   ```bash
   # Mac/Linux
   nvm use
   npm run dev

   # Windows
   nvm use 20
   npm run dev
   ```

3. Open http://localhost:3000

## Verifying the environment

To check that all prerequisites are installed without running a full bootstrap:

```bash
bash .claude/skills/setup-dev/scripts/verify.sh
```

This checks Git, Node, nvm, VS Code extensions, `node_modules`, `.env.local`, and typecheck. No admin privileges required.
