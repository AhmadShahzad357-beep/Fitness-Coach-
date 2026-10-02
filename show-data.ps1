# Shows what FitCoach saved in backend\fitcoach.db.
$venvPy = Join-Path $PSScriptRoot "backend\.venv\Scripts\python.exe"
if (-not (Test-Path $venvPy)) { throw "Run setup.ps1 first." }
& $venvPy (Join-Path $PSScriptRoot "backend\show_data.py")
