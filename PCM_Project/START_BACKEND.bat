@echo off
title PCM Backend Server
cd /d "%~dp0\PCM_Backend"
set ASPNETCORE_ENVIRONMENT=Development
echo [*] Starting PCM Backend Server...
echo [*] Environment: %ASPNETCORE_ENVIRONMENT%
echo [*] Listening on: http://localhost:5001
echo [*] Press Ctrl+C to stop
dotnet run --no-build
pause
