# Starts the web app on http://localhost:5173. Works from any folder.
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "frontend")
$Host.UI.RawUI.WindowTitle = "FitCoach frontend :5173"
if (-not (Test-Path "node_modules")) { & npm install; if ($LASTEXITCODE -ne 0) { throw "npm install failed." } }
# strictPort: fail loudly instead of moving to 5174, which the backend's CORS setting would block
& npm run dev -- --port 5173 --strictPort
