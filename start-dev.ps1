# Quick start script for local development on Windows
# IMPORTANT: Macaulay2 only runs on Linux!
# This script starts the frontend, which needs to connect to a backend on your Linux server

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Macaulay2 Web Interface - Frontend Dev" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  IMPORTANT:" -ForegroundColor Yellow
Write-Host "Macaulay2 only runs on Linux. This starts ONLY the frontend." -ForegroundColor White
Write-Host "The backend must be deployed to your Linux server first." -ForegroundColor White
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "frontend") -or -not (Test-Path "backend")) {
    Write-Host "❌ Error: Run this script from the project root directory" -ForegroundColor Red
    exit 1
}

# Check for .env.development
Write-Host "Checking frontend configuration..." -ForegroundColor Yellow
if (-not (Test-Path "frontend\.env.development")) {
    Write-Host ""
    Write-Host "⚠️  No .env.development file found!" -ForegroundColor Yellow
    Write-Host ""
    $createEnv = Read-Host "Do you want to create one now? (y/n)"
    
    if ($createEnv -eq "y" -or $createEnv -eq "Y") {
        $serverUrl = Read-Host "Enter your backend URL (e.g., https://yourdomain.com/api or http://localhost:8000 if using WSL)"
        
        Set-Content "frontend\.env.development" "VITE_API_URL=$serverUrl"
        Write-Host "✅ Created .env.development" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️  Frontend will use default: http://localhost:8000" -ForegroundColor Yellow
        Write-Host "   You can change this later in frontend/.env.development" -ForegroundColor Gray
    }
}

# Start Frontend
Write-Host ""
Write-Host "Starting frontend..." -ForegroundColor Yellow
Set-Location frontend

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing npm dependencies (first time only)..." -ForegroundColor Yellow
    npm install
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✅ Frontend Starting!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frontend will open at: http://localhost:5173" -ForegroundColor White
Write-Host ""
Write-Host "📝 NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Deploy backend to your Linux server:" -ForegroundColor White
Write-Host "   - See DEPLOYMENT.md for instructions" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Make sure frontend/.env.development points to your server" -ForegroundColor White
Write-Host ""
Write-Host "3. Start developing! Changes will hot-reload automatically" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the dev server" -ForegroundColor Gray
Write-Host ""

# Run dev server (blocking)
npm run dev

Set-Location ..
