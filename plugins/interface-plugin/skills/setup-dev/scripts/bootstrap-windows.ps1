# PEOPL Frontend - Bootstrap Windows
# -------------------------------------------------------
# Run from the repository root:
#   Set-ExecutionPolicy Bypass -Scope Process
#   .\scripts\bootstrap-windows.ps1
#
# The script will self-elevate to Administrator if needed.
# It is idempotent -- safe to re-run if it stops partway.
# -------------------------------------------------------

$ErrorActionPreference = "Stop"

# --------------------------------------------
# 0. Self-elevate to Administrator if needed
# --------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host "Administrator privileges required -- approve the UAC prompt to continue." -ForegroundColor Yellow
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$scriptPath`""
    exit 0
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $repoRoot

$logDir = Join-Path $repoRoot "scripts\logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "bootstrap.log"
Start-Transcript -Path $logFile -Append | Out-Null

Write-Host "=== PEOPL Frontend - Bootstrap Windows ===" -ForegroundColor Cyan

# --------------------------------------------
# 1. Check winget
# --------------------------------------------
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error @"
winget not found.
Install 'App Installer' from the Microsoft Store:
  https://apps.microsoft.com/detail/9NBLGGH4NNS1
Then re-run this script.
"@
    exit 1
}
Write-Host "winget: OK" -ForegroundColor Green

# --------------------------------------------
# 2. Git for Windows (includes Git Bash)
# --------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git for Windows..."
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
} else {
    Write-Host "Git $(git --version): OK" -ForegroundColor Green
}

# --------------------------------------------
# 3. VS Code
# --------------------------------------------
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "Installing VS Code..."
    winget install --id Microsoft.VisualStudioCode -e --source winget --accept-package-agreements --accept-source-agreements
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
} else {
    Write-Host "VS Code: OK" -ForegroundColor Green
}

# Resolve code.cmd via known path if still not in PATH after install
$codeBin = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
if (-not (Get-Command code -ErrorAction SilentlyContinue) -and (Test-Path $codeBin)) {
    Write-Host "code not in PATH yet -- using full path fallback" -ForegroundColor DarkGray
    function global:code { & $codeBin @args }
}

Write-Host "Installing VS Code extensions..."
code --install-extension anthropic.claude-code --force
code --install-extension dbaeumer.vscode-eslint --force
code --install-extension eamodio.gitlens --force
code --install-extension usernamehw.errorlens --force
code --install-extension aaron-bond.better-comments --force
code --install-extension ms-vscode.powershell --force

# --------------------------------------------
# 4. GitHub CLI
# --------------------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing GitHub CLI..."
    winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
} else {
    Write-Host "GitHub CLI: OK" -ForegroundColor Green
}

# --------------------------------------------
# 5. nvm-windows
# --------------------------------------------
function Get-NvmDir {
    if (Test-Path "$env:LOCALAPPDATA\nvm\nvm.exe") { return "$env:LOCALAPPDATA\nvm" }
    if (Test-Path "$env:APPDATA\nvm\nvm.exe")      { return "$env:APPDATA\nvm" }
    return $null
}

$nvmDir = Get-NvmDir
$nvmExe = if ($nvmDir) { "$nvmDir\nvm.exe" } else { $null }

if (-not $nvmExe) {
    Write-Host "Installing nvm-windows..."
    winget install --id CoreyButler.NVMforWindows -e --source winget --accept-package-agreements --accept-source-agreements

    # Refresh PATH and NVM env vars after winget finishes
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $env:NVM_HOME = [System.Environment]::GetEnvironmentVariable("NVM_HOME", "Machine")
    if (-not $env:NVM_HOME) { $env:NVM_HOME = [System.Environment]::GetEnvironmentVariable("NVM_HOME", "User") }
    $env:NVM_SYMLINK = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "Machine")
    if (-not $env:NVM_SYMLINK) { $env:NVM_SYMLINK = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "User") }

    # Wait for nvm.exe to appear in either known location
    $retries = 0
    while (-not (Get-NvmDir) -and $retries -lt 30) {
        Start-Sleep -Seconds 1
        $retries++
    }

    $nvmDir = Get-NvmDir
    if (-not $nvmDir) {
        Write-Error "nvm.exe not found after installation. Close this terminal, open a new Administrator PowerShell, and re-run this script."
        exit 1
    }
    $nvmExe = "$nvmDir\nvm.exe"

    if ($env:PATH -notlike "*$nvmDir*") {
        $env:PATH = "$nvmDir;$env:PATH"
    }
}
Write-Host "nvm-windows: OK" -ForegroundColor Green

# --------------------------------------------
# 6. Node 20 via nvm
# --------------------------------------------
$nodeOk = $false
try {
    $nodeVer = & node --version 2>$null
    if ($nodeVer -match "^v20\.") { $nodeOk = $true }
} catch {}

if (-not $nodeOk) {
    Write-Host "Installing Node 20 via nvm..."
    & $nvmExe install 20
    & $nvmExe use 20
} else {
    Write-Host "Node ${nodeVer}: OK" -ForegroundColor Green
}

# Refresh PATH so node/npm are available
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")
$env:NVM_HOME = [System.Environment]::GetEnvironmentVariable("NVM_HOME", "Machine")
if (-not $env:NVM_HOME) { $env:NVM_HOME = [System.Environment]::GetEnvironmentVariable("NVM_HOME", "User") }
$env:NVM_SYMLINK = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "Machine")
if (-not $env:NVM_SYMLINK) { $env:NVM_SYMLINK = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "User") }

if ($env:NVM_SYMLINK -and (Test-Path $env:NVM_SYMLINK) -and ($env:PATH -notlike "*$env:NVM_SYMLINK*")) {
    $env:PATH = "$env:NVM_SYMLINK;$env:PATH"
} elseif ((Test-Path "$env:ProgramFiles\nodejs") -and ($env:PATH -notlike "*nodejs*")) {
    $env:PATH = "$env:ProgramFiles\nodejs;$env:PATH"
}

Write-Host "Node $(node --version): OK" -ForegroundColor Green

# --------------------------------------------
# 7. Project setup
# --------------------------------------------
Write-Host ""
Write-Host "Setting up project..." -ForegroundColor Cyan

$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBash) {
    & $gitBash -c "bash scripts/setup.sh"
} else {
    Write-Host "Git Bash not found -- running setup directly in PowerShell..." -ForegroundColor DarkGray

    Write-Host "Installing dependencies..."
    Write-Host "(EPERM warnings about node_modules cleanup are expected on OneDrive and do not affect the install)" -ForegroundColor DarkGray
    npm ci

    if (-not (Test-Path ".env.local")) {
        Copy-Item ".env.example" ".env.local"
        Write-Host "Created .env.local from .env.example" -ForegroundColor Yellow
    } else {
        Write-Host ".env.local already exists -- skipping."
    }

    Write-Host "Running typecheck..."
    npm run typecheck
}

# --------------------------------------------
# 8. Open project in VS Code
# --------------------------------------------
Write-Host ""
Write-Host "Opening project in VS Code..." -ForegroundColor Cyan
code $repoRoot
code "$repoRoot\.env.local"

# --------------------------------------------
# 9. Reminder: fill in .env.local
# --------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host " ACTION REQUIRED: complete .env.local       " -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "Fill in the values now open in VS Code:" -ForegroundColor Yellow
Write-Host "  GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET" -ForegroundColor Yellow
Write-Host "  NEXTAUTH_SECRET  (generate: openssl rand -base64 32)" -ForegroundColor Yellow
Write-Host "  PEOPL_AUNA_API_URL / PEOPL_AUNA_API_KEY" -ForegroundColor Yellow
Write-Host "  PEOPL_COMMUNITY_API_URL / PEOPL_COMMUNITY_API_KEY" -ForegroundColor Yellow
Write-Host "  PIPO_API_URL / PIPO_API_KEY" -ForegroundColor Yellow
Write-Host ""
Write-Host "Bootstrap complete. After filling .env.local, open a new terminal and run:" -ForegroundColor Green
Write-Host "  nvm use 20" -ForegroundColor Green
Write-Host "  npm run dev" -ForegroundColor Green

Stop-Transcript | Out-Null


