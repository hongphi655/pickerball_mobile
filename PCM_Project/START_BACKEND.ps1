#!/usr/bin/env pwsh
# PCM Backend Startup Script for PowerShell

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     PCM Backend Server - Starting...      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $scriptDir "PCM_Backend"

Write-Host "Location: $backendDir" -ForegroundColor Cyan
Write-Host "Environment: Development" -ForegroundColor Cyan
Write-Host "Port: 5001" -ForegroundColor Cyan
Write-Host ""

# Stop any existing dotnet processes
Write-Host "Checking for existing processes..." -ForegroundColor Yellow
$existing = Get-Process dotnet -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "  Stopping existing dotnet process..." -ForegroundColor Yellow
    $existing | Stop-Process -Force
    Start-Sleep -Seconds 1
}

# Set environment
$env:ASPNETCORE_ENVIRONMENT = "Development"

# Start backend in separate process to avoid PowerShell race condition
Write-Host "Starting backend server..." -ForegroundColor Green
Start-Process pwsh -ArgumentList "-Command", "
    Set-Location '$backendDir'
    `$env:ASPNETCORE_ENVIRONMENT = 'Development'
    Write-Host '✅ Backend server starting...' -ForegroundColor Green
    Write-Host ''
    dotnet run --no-build
" -NoNewWindow

Start-Sleep -Seconds 5

# Test if server is running
Write-Host ""
Write-Host "Testing server connection..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:5001/health" -TimeoutSec 2
    Write-Host "✅ Server is running!" -ForegroundColor Green
    Write-Host "   Health check: $($health.status)" -ForegroundColor Green
    Write-Host "   Timestamp: $($health.timestamp)" -ForegroundColor Green
}
catch {
    Write-Host "❌ Server failed to start" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         ✅ Backend Server Ready!          ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "API Endpoints:" -ForegroundColor Cyan
Write-Host "  • Health:   http://localhost:5001/health" -ForegroundColor White
Write-Host "  • Login:    http://localhost:5001/api/auth/login" -ForegroundColor White
Write-Host "  • Swagger:  http://localhost:5001/swagger" -ForegroundColor White
Write-Host ""
Write-Host "Test Credentials:" -ForegroundColor Cyan
Write-Host "  • Username: admin" -ForegroundColor White
Write-Host "  • Password: Test123!" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the backend" -ForegroundColor Yellow

# Keep the terminal open
Read-Host "Press Enter to exit"
