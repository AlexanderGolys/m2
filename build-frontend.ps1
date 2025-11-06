# Build frontend for production on Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Building Frontend for Production" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location frontend

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies first..." -ForegroundColor Yellow
    npm install
}

Write-Host "Building production bundle..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Build output is in: frontend/dist" -ForegroundColor White
    Write-Host ""
    Write-Host "To deploy to your server:" -ForegroundColor Cyan
    Write-Host "  1. Upload the 'dist' folder to your server" -ForegroundColor White
    Write-Host "  2. Or use SCP:" -ForegroundColor White
    Write-Host "     scp -r dist/* user@your-server:/var/www/html/m2/" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Build failed!" -ForegroundColor Red
}

Set-Location ..

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
