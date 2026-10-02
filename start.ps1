# Opens the backend and the frontend in two windows, then the browser.
$ErrorActionPreference = "Stop"
$shell = (Get-Process -Id $PID).Path
foreach ($script in "run-backend.ps1", "run-frontend.ps1") {
    $path = Join-Path $PSScriptRoot $script
    Start-Process -FilePath $shell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$path`""
}
Write-Host "Waiting for the servers to start..."
Start-Sleep -Seconds 8
Start-Process "http://localhost:5173"
