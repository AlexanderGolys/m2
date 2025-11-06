# Install frontend dependencies on Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Installing Frontend Dependencies" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location frontend

if (Test-Path "node_modules") {
    Write-Host "⚠️  node_modules folder exists. Cleaning up..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force node_modules
    if (Test-Path "package-lock.json") {
        Remove-Item package-lock.json
    }
}

Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Frontend dependencies installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run the frontend with:" -ForegroundColor White
    Write-Host "  cd frontend" -ForegroundColor Cyan
    Write-Host "  npm run dev" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Installation failed!" -ForegroundColor Red
}

Set-Location ..

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
