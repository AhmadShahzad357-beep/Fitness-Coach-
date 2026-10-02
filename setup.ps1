# One-time setup: Python venv + packages, backend .env, database tables, frontend packages.
# Usage (from any folder):  powershell -ExecutionPolicy Bypass -File <repo>\setup.ps1
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$backend = Join-Path $root "backend"
$frontend = Join-Path $root "frontend"
$venvPy = Join-Path $backend ".venv\Scripts\python.exe"

function Step($text) { Write-Host "`n== $text" -ForegroundColor Cyan }
function Check($what) { if ($LASTEXITCODE -ne 0) { throw "$what failed (exit code $LASTEXITCODE). Read the error above." } }

Step "Checking Python and Node"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw "Python not found. Install Python 3.12 from python.org and tick 'Add python.exe to PATH'." }
$ok = & python -c "import sys; print(int(sys.version_info >= (3, 11)))"
if ($ok -ne "1") { throw "Python 3.11 or newer is needed (3.12 recommended)." }
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw "Node.js not found. Install the LTS version from nodejs.org." }
& python --version
& node --version

Step "Backend: virtual environment and packages"
if (-not (Test-Path $venvPy)) { & python -m venv (Join-Path $backend ".venv"); Check "Creating the virtual environment" }
& $venvPy -m pip install --upgrade pip --quiet; Check "pip upgrade"
& $venvPy -m pip install -r (Join-Path $backend "requirements.txt"); Check "Installing backend packages"

Step "Backend: .env file"
$envFile = Join-Path $backend ".env"
$text = ""
if (Test-Path $envFile) { $text = Get-Content $envFile -Raw; if ($null -eq $text) { $text = "" } }
$lines = @($text -split "\r?\n" | Where-Object { $_.Trim() -ne "" })
if (-not ($lines -match '^GROQ_API_KEY=\S+')) {
    $key = (Read-Host "Paste your Groq API key (https://console.groq.com/keys)").Trim()
    if (-not $key) { throw "A Groq API key is required." }
    $lines = @($lines | Where-Object { $_ -notmatch '^GROQ_API_KEY=' }) + "GROQ_API_KEY=$key"
}
if (-not ($lines -match '^JWT_SECRET=\S{32,}')) {
    $secret = & $venvPy -c "import secrets; print(secrets.token_urlsafe(48))"
    $lines = @($lines | Where-Object { $_ -notmatch '^JWT_SECRET=' }) + "JWT_SECRET=$secret"
}
if (-not ($lines -match '^RUN_REMINDER_WORKER_IN_API=')) { $lines += "RUN_REMINDER_WORKER_IN_API=true" }
# UTF-8 without BOM. PowerShell's ">" writes UTF-16, which the backend cannot read.
[System.IO.File]::WriteAllLines($envFile, [string[]]$lines, (New-Object System.Text.UTF8Encoding $false))
Write-Host "backend\.env is ready"

Step "Backend: database tables"
Push-Location $backend
try { & $venvPy -m alembic upgrade head; Check "Database migration" } finally { Pop-Location }

Step "Frontend: packages"
Push-Location $frontend
try { & npm install; Check "npm install" } finally { Pop-Location }

Write-Host "`nSetup done. Start the app with:" -ForegroundColor Green
Write-Host "  powershell -ExecutionPolicy Bypass -File `"$root\start.ps1`"" -ForegroundColor Green
