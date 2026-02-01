# Quick Testing Guide

## Prerequisites
- Backend running: `dotnet run` in PCM_Backend folder (listening on http://localhost:5001)
- Flutter SDK installed
- Mobile device or emulator connected

## Testing Admin Account

1. **Start Backend**
   ```bash
   cd PCM_Backend
   dotnet run
   ```

2. **Run Flutter App**
   ```bash
   cd PCM_Mobile
   flutter run -d web  # or your device/emulator
   ```

3. **Login as Admin**
   - Username: `admin`
   - Password: `Test123!`

4. **Test Admin Features**
   - ✅ View Admin Dashboard (no redirect)
   - ✅ Access Courts Management
   - ✅ Access Members Management  
   - ✅ Create Tournaments
   - ✅ View Revenue Reports
   - ✅ Access Bookings Management

## Testing Regular User Account

### Option A: Use Pre-Made Test User
1. Login with:
   - Username: `testuser2`
   - Password: `Test123!`

2. Test User Features
   - ✅ View User Dashboard
   - ✅ Book courts (Đặt Sân)
   - ✅ View wallet
   - ✅ View tournaments
   - ✅ Pull-to-refresh works

### Option B: Create New User
1. Click "Đăng ký" (Register) on login screen
2. Fill in details:
   - Full Name: Any name
   - Username: Unique username
   - Email: Any email
   - Password: `Test123!`
3. Click Register
4. App automatically logs you in
5. Test all user features

## Troubleshooting

### Issue: Still getting redirected to login
**Solution**: 
1. Force refresh app (pull-to-refresh on home page)
2. Check that token is being stored (check secure storage)
3. Restart backend and app

### Issue: Registration fails
**Solution**:
1. Make sure username is unique
2. Check backend console for error messages
3. Verify backend is running

### Issue: Backend won't start
**Solution**:
1. Kill any existing processes: `taskkill /F /IM PCM.API.exe`
2. Clean build: `dotnet clean && dotnet build`
3. Run: `dotnet run`

## Key Features Verified

- [x] Admin can login
- [x] Admin can access all management features without redirects
- [x] Regular users can register
- [x] Regular users can login
- [x] User accounts can access their features
- [x] JWT tokens are properly generated
- [x] Tokens persist across app restarts
- [x] Auto-login after registration works
- [x] Role-based access control works

## Database Notes

- Users are stored in `AspNetUsers` table
- User roles are in `AspNetUserRoles` table
- Member info is in `001_Members` table
- New registrations automatically create member records
