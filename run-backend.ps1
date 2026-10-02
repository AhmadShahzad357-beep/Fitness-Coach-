# Starts the API on http://localhost:8000 (API docs: http://localhost:8000/docs). Works from any folder.
$ErrorActionPreference = "Stop"
$backend = Join-Path $PSScriptRoot "backend"
$venvPy = Join-Path $backend ".venv\Scripts\python.exe"
if (-not (Test-Path $venvPy)) { throw "Run setup.ps1 first." }
if (-not (Test-Path (Join-Path $backend ".env"))) { throw "backend\.env is missing. Run setup.ps1 first." }
Set-Location $backend
$Host.UI.RawUI.WindowTitle = "FitCoach backend :8000"
& $venvPy -m alembic upgrade head
if ($LASTEXITCODE -ne 0) { throw "Database migration failed." }
& $venvPy -m uvicorn app.main:app --reload --reload-dir app --port 8000
