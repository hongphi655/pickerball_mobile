# PCM Project - Test Accounts

## Verified Working Accounts

### Admin Account
- **Username**: `admin`
- **Password**: `Test123!`
- **Role**: Admin
- **Features**: Dashboard, Court Management, Member Management, Tournaments, Reports
- **Status**: ✅ **VERIFIED WORKING**

### Regular User Account (Created for Testing)
- **Username**: `testuser2`
- **Email**: `test2@example.com`
- **Password**: `Test123!`
- **Role**: User
- **Features**: Dashboard, Bookings, Wallet, Tournaments
- **Status**: ✅ **VERIFIED WORKING**

## Backend Status
- **Server**: Running on `http://localhost:5001`
- **Health Endpoint**: ✅ **WORKING**
- **Login Endpoint**: ✅ **WORKING** (both admin and users)
- **Registration Endpoint**: ✅ **WORKING**

## How Authentication Works
1. User enters username and password
2. Backend validates against database (or hardcoded admin account)
3. Backend returns JWT token valid for user's session
4. Mobile app stores token in secure storage
5. On app restart, token is automatically restored from secure storage
6. User can access protected routes without re-logging in

## Troubleshooting
If you experience login issues:
1. Make sure backend is running: `dotnet run` in PCM_Backend folder
2. Check that you're using the correct credentials
3. Clear app cache and retry login
4. Register a new account if needed (registration → auto-login flow)
