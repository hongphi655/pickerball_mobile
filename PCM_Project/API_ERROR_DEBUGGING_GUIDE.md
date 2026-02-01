# API Error Debugging Guide

## Summary of Issues Fixed

### 1. Enhanced Error Handling in API Service
**File**: `PCM_Mobile/lib/services/api_service.dart`

#### Fixed Methods:
- `getMembers()` - Added comprehensive error handling for 401, 500, and timeout errors
- `getCourts()` - Added comprehensive error handling for 401, 500, and timeout errors

#### Improvements:
- ✅ Properly catches `DioError` exceptions with specific error types
- ✅ Distinguishes between authentication errors (401) and server errors (500)
- ✅ Handles network timeout errors with user-friendly messages
- ✅ Returns clean error messages in Vietnamese for user display
- ✅ Automatically clears auth token on 401 responses

### 2. Enhanced Backend Error Logging
**File**: `PCM_Backend/Controllers/AdminMembersController.cs`

#### Changes:
- ✅ Added try-catch wrapper to `GetMembers()` endpoint
- ✅ Logs detailed error information including exception type, message, and stack trace
- ✅ Returns proper HTTP 500 response with error details
- ✅ Fixed response type to use `ApiResponse<List<MemberDto>>` instead of string

### 3. Improved UI Error Display
**File**: `PCM_Mobile/lib/screens/home/admin_dashboard.dart`

#### Enhancements:
- ✅ Added `_ErrorStatCard` widget to display errors in the dashboard
- ✅ Shows error messages alongside loading states
- ✅ Both CourtProvider and MemberProvider errors are displayed
- ✅ Added error handling in `_initializeData()` with dialog display
- ✅ Clean error message formatting (removes "Exception:" prefix, etc.)

## Common Error Scenarios & Solutions

### Error 1: "Token invalidated - clearing storage" (401 Unauthorized)

**Symptoms:**
- User is redirected to login screen unexpectedly
- API calls return 401 Unauthorized
- auth_token is cleared from secure storage

**Root Causes:**
1. JWT token has expired
2. Token was invalidated on server
3. Token signature doesn't match server's signing key
4. User's role changed and is no longer authorized

**Solutions:**
1. **Check Token Expiration:**
   - Tokens are configured for 1440 minutes (24 hours) in `appsettings.json`
   - If testing with old tokens, they may be expired

2. **Verify JWT Configuration:**
   - Check `appsettings.json` JWT secret matches across backend and frontend
   - Ensure token was generated with correct signing key

3. **Check User Roles:**
   - Verify user has "Admin" role in AspNetRoles table
   - Run: `SELECT u.Id, u.UserName, r.Name FROM AspNetUsers u LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id WHERE u.UserName = 'admin';`

4. **Regenerate Token:**
   - Log out and log in again to get a fresh token
   - Fresh tokens bypass expiration issues

### Error 2: "API Error: 500 - Server Error" on /api/admin/members

**Symptoms:**
- Getting 500 Server Error from `/api/admin/members` endpoint
- Error occurs even with valid JWT token
- Admin dashboard member count shows error

**Root Causes:**
1. Database query failed (Members table missing data, null reference exception)
2. Include() operation failed due to missing User navigation property
3. Mapping Members to MemberDto failed (null values in required fields)
4. DbContext lifetime issue (Transient instead of Scoped)

**Debugging Steps:**

1. **Check Backend Console Logs:**
   - Backend logs detailed errors from the try-catch block
   - Look for pattern: `[GetMembers] ERROR: {ExceptionType}: {Message}`
   - Example: `[GetMembers] ERROR: NullReferenceException: Object reference not set to an instance of an object.`

2. **Verify Database Tables Exist:**
   ```sql
   -- Check if Members table exists
   SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Members';
   
   -- Check if data exists
   SELECT COUNT(*) as MemberCount FROM Members;
   
   -- Check for NULL values in required fields
   SELECT Id, FullName, UserId FROM Members WHERE FullName IS NULL OR UserId IS NULL;
   ```

3. **Verify User Foreign Key:**
   ```sql
   -- Check if User references are valid
   SELECT m.Id, m.FullName, m.UserId, u.Id as UserExists
   FROM Members m
   LEFT JOIN AspNetUsers u ON m.UserId = u.Id
   WHERE u.Id IS NULL;
   ```

4. **Test Endpoint Directly:**
   ```bash
   # Using PowerShell
   $headers = @{
       "Authorization" = "Bearer YOUR_JWT_TOKEN_HERE"
       "Content-Type" = "application/json"
   }
   Invoke-WebRequest -Uri "http://localhost:5001/api/admin/members" -Headers $headers
   ```

### Error 3: "Kết nối bị gián đoạn" (Connection Timeout)

**Symptoms:**
- "Kết nối bị gián đoạn - kiểm tra kết nối mạng" message appears
- Network appears to be working
- Other endpoints may work fine

**Root Causes:**
1. Backend server not running
2. Backend listening on wrong port
3. Firewall blocking connection
4. Network unreachable

**Solutions:**
1. **Verify Backend is Running:**
   ```bash
   cd PCM_Backend
   dotnet run  # Should show "Now listening on: http://localhost:5001"
   ```

2. **Check Port Configuration:**
   - Default port: 5001
   - Verify in `Program.cs`: `app.Urls.Add("http://localhost:5001");`

3. **Verify Network Connectivity:**
   ```bash
   Test-NetConnection -ComputerName localhost -Port 5001
   curl http://localhost:5001/health  # If health endpoint exists
   ```

## Testing Checklist

### Quick Test Steps:

1. **Start Backend:**
   ```bash
   cd PCM_Backend
   dotnet run
   ```
   Wait for: "Now listening on: http://localhost:5001"

2. **Test Authentication:**
   - Login with valid credentials
   - Check FlutterSecureStorage contains `auth_token`
   - Check token format (should be JWT with 3 parts separated by dots)

3. **Test Member List Endpoint:**
   - Navigate to Admin Dashboard
   - Should show member count (if no error)
   - If error shows, check backend console for detailed error message

4. **Test with Curl/Postman:**
   ```bash
   # Login
   curl -X POST http://localhost:5001/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"password"}'
   
   # Extract token from response
   # Use token in next request
   curl -X GET http://localhost:5001/api/admin/members \
     -H "Authorization: Bearer YOUR_TOKEN_HERE"
   ```

## Configuration Files to Check

### Backend (`PCM_Backend/appsettings.json`)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=PCM_Database;..."
  },
  "Jwt": {
    "Secret": "your-secret-key-change-this-to-a-long-random-string-in-production",
    "ExpirationMinutes": 1440  // 24 hours
  }
}
```

### Frontend (`PCM_Mobile/lib/utils/app_config.dart`)
```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:5001';
}
```

## Recent Improvements

### Admin Dashboard Error Display
- Added `_ErrorStatCard` widget that shows error messages instead of loading spinners
- Error messages are cleaned up and formatted in Vietnamese
- Both member and court loading errors are displayed separately

### API Service Error Handling
- Catches 401 Unauthorized and automatically clears token
- Catches 500 Server Error and passes error message to UI
- Catches network timeouts with "Kết nối bị gián đoạn" message
- All errors are logged to console for debugging

### Provider Error Management
- Both `CourtProvider` and `MemberProvider` capture error messages in `_errorMessage`
- Error messages are passed to UI through provider state
- UI can display errors without blocking the entire dashboard

## Next Steps to Fix Remaining Issues

1. **If getting 500 error:**
   - Check backend console logs (starting with `[GetMembers] ERROR:`)
   - Look for specific exception type (NullReferenceException, DbUpdateException, etc.)
   - Run SQL debugging steps above

2. **If getting 401 error:**
   - Log out completely and log back in
   - Ensure user has "Admin" role assigned
   - Check JWT secret in both frontend and backend matches

3. **If app still crashes:**
   - Check FlutterSecureStorage implementation
   - Verify Provider initialization in main.dart
   - Check for null pointer exceptions in error messages

## Files Modified in This Session

- ✅ `PCM_Mobile/lib/services/api_service.dart` - Enhanced error handling
- ✅ `PCM_Mobile/lib/screens/home/admin_dashboard.dart` - Added error display UI
- ✅ `PCM_Backend/Controllers/AdminMembersController.cs` - Added error logging
- ✅ `PCM_Mobile/lib/providers/providers.dart` - Already had error handling

## Support Commands

### View Backend Logs (While Running):
- Backend running in background terminal shows console output
- Look for lines starting with `[GetMembers]` for detailed error info

### Database Query Commands:
```sql
-- Check Members table structure
EXEC sp_help 'Members';

-- Check data integrity
SELECT TOP 10 Id, FullName, UserId, JoinDate FROM Members;

-- Check relationships
SELECT m.*, u.UserName FROM Members m 
INNER JOIN AspNetUsers u ON m.UserId = u.Id;
```

---

**Status**: Error handling framework is complete. Now diagnose specific backend issues using the debugging steps above.
