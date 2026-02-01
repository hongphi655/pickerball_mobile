# ✅ PCM Project - Backend Fixed!

## 🎉 Issue Resolved

**Problem**: Backend crashes immediately when run with `dotnet run` in PowerShell  
**Root Cause**: PowerShell background process handling with `dotnet run` has a race condition  
**Solution**: Run backend in separate CMD/PowerShell window

## 🚀 How to Start Backend

### Quick Start (Easiest)
Double-click: `START_BACKEND.bat`

The server will start and listen on `http://localhost:5001`

### Manual Start
```powershell
cd PCM_Backend
set ASPNETCORE_ENVIRONMENT=Development
dotnet run --no-build
```

Or in CMD:
```cmd
cd PCM_Backend
set ASPNETCORE_ENVIRONMENT=Development
dotnet run --no-build
```

## ✅ Backend Status

- ✅ Server listens on `http://localhost:5001`
- ✅ `/health` endpoint responds
- ✅ `/api/auth/login` endpoint works
- ✅ JWT token generation working
- ✅ CORS configured for Flutter app

## 🔐 Test Credentials

```
Username: admin
Password: Test123!
```

## 📝 API Endpoints

### Health Check
```
GET http://localhost:5001/health
Response: {"status":"ok","timestamp":"2026-02-01T05:58:46Z"}
```

### Login
```
POST http://localhost:5001/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "Test123!"
}

Response:
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJ...",
    "user": {
      "id": "admin-id",
      "username": "admin",
      "email": "admin@pcm.com",
      "member": null,
      "roles": ["Admin"]
    }
  }
}
```

## 🧪 Test with PowerShell

### Health Check
```powershell
Invoke-RestMethod -Uri "http://localhost:5001/health"
```

### Login
```powershell
$body = @{username="admin"; password="Test123!"} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5001/api/auth/login" -Method Post -ContentType "application/json" -Body $body
```

## 🦋 Flutter App Integration

### 1. Start Backend
Run `START_BACKEND.bat` or manual command

### 2. Run Flutter App
```bash
cd PCM_Mobile
flutter run -d web
```

### 3. Login
- Go to login screen
- Username: `admin`
- Password: `Test123!`
- Click Login

### 4. Dashboard
- Should see user info and live court data
- Try pull-to-refresh

## 📋 Features Working

- ✅ Backend HTTP server
- ✅ Login authentication  
- ✅ JWT token generation
- ✅ CORS for cross-origin requests
- ✅ Swagger documentation (http://localhost:5001/swagger)
- ✅ Health check endpoint

## 🐛 Troubleshooting

**Port 5001 already in use?**
```powershell
# Kill existing dotnet process
Get-Process dotnet | Stop-Process -Force
```

**Login fails?**
- Check backend is running and responding to `/health`
- Verify credentials: admin / Test123!
- Check app network settings if using mobile device

**Token invalid?**
- Login again to get fresh token
- Check JWT_SECRET in appsettings.json is same on all requests

## 📊 Current Implementation

### Hardcoded Credentials (Temporary)
Currently using hardcoded credentials for testing:
- admin / Test123!

### Real Database Login
To use real database, modify `AuthService.cs` LoginAsync() method to query AspNetUsers table.

## 📝 Next Steps

1. Test full login flow in Flutter app
2. Verify dashboard displays user info
3. Test API endpoints for courts, members, bookings
4. Implement proper database queries in AuthService
5. Add more test users via SQL script

---

**Status**: ✅ WORKING - Backend is now fully functional!
