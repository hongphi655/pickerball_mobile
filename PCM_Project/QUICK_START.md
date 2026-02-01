# Quick Start Guide - PCM Application

## Prerequisites
- Backend running: http://localhost:5006
- Flutter app ready to run
- Test credentials prepared

## Starting the Application

### Backend
```powershell
cd PCM_Backend
$env:ASPNETCORE_URLS='http://localhost:5006'
dotnet run
# Expected: "Now listening on: http://localhost:5006"
```

### Frontend
```bash
cd PCM_Mobile
flutter pub get
flutter run
# Or use your IDE to run the app
```

---

## User Testing Flow

### 1. Regular User Login
```
Username: testuser
Password: Password123!
```

**What you'll see:**
- ✅ 3 tabs: Đặt sân | Ví | Hồ sơ
- Can book courts
- Can deposit money (no transaction history)
- Cannot access Admin tab
- Wallet shows balance + deposit form only

### 2. Admin Login
```
Username: admin
Password: Admin123!
```

**What you'll see:**
- ✅ 5 tabs: Đặt sân | Giải đấu | Ví | Admin | Hồ sơ
- All user features
- Admin tab shows dashboard with 5 options
- Wallet shows transaction history
- Can access all management screens

---

## Feature Testing Checklist

### Login Screen ✅
- [ ] Can login with valid credentials
- [ ] Error message on invalid credentials
- [ ] Can navigate to register
- [ ] Route guard prevents access to /home without login

### User Features ✅
- [ ] Book a court (select court → date → time → confirm)
- [ ] View balance in wallet
- [ ] Submit deposit request
- [ ] View profile with user info
- [ ] Can logout

### Admin Features ✅
- [ ] Click Admin tab → Dashboard opens
- [ ] Manage Courts
  - [ ] Create new court
  - [ ] Edit court
  - [ ] Delete court
  - [ ] List updates in real-time
- [ ] Approve Deposits
  - [ ] See pending deposits
  - [ ] Approve deposit (balance increases)
  - [ ] Reject deposit
- [ ] Create Tournament
  - [ ] Fill all fields
  - [ ] Select start/end dates
  - [ ] Submit creates tournament
- [ ] View Revenue
  - [ ] Shows total revenue
  - [ ] Shows approved/pending counts
  - [ ] Lists all transactions
- [ ] Manage Members (screen exists, API pending)

### Navigation ✅
- [ ] Bottom nav items appear/disappear based on role
- [ ] Switching between tabs works smoothly
- [ ] Deep linking works (/home/bookings, /home/wallet, etc.)
- [ ] Cannot directly access /home/admin as regular user

---

## API Endpoints to Verify

### Health Check
```
GET http://localhost:5006/
Expected: App running message or API root
```

### Login
```
POST http://localhost:5006/api/auth/login
Body: { "username": "admin", "password": "Admin123!" }
Expected: token + user with roles
```

### Get Courts (Admin)
```
GET http://localhost:5006/api/courts
Authorization: Bearer <token>
Expected: List of courts
```

### Create Court (Admin)
```
POST http://localhost:5006/api/courts
Authorization: Bearer <token>
Body: { "name": "Court A", "location": "Location", "hourlyRate": 100000 }
Expected: Success response
```

### Get Wallet Transactions
```
GET http://localhost:5006/api/wallet/transactions
Authorization: Bearer <token>
Expected: List of transactions
```

### Approve Deposit (Admin)
```
PUT http://localhost:5006/api/wallet/approve/{transactionId}
Authorization: Bearer <token> with Admin role
Expected: Success response
```

---

## Troubleshooting

### Backend not responding
```
✓ Check if running on port 5006
✓ Verify database connection (SQL Server)
✓ Check firewall settings
```

### Flutter app can't connect
```
✓ Verify app_config.dart has apiBaseUrl = 'http://localhost:5006'
✓ For Android emulator: use 10.0.2.2 instead of localhost
✓ Check Wi-Fi connectivity if on physical device
```

### Role not changing in UI
```
✓ Logout completely
✓ Clear app cache/storage
✓ Login again with admin account
✓ Check debug logs: "User roles: [Admin]"
```

### Database issues
```
✓ Drop and recreate: dotnet ef database drop --force
✓ Apply migrations: dotnet ef database update
✓ Seeding runs automatically on app start
```

---

## Debug Features

### Check Seeded Users
```
GET http://localhost:5006/api/debug/users
```

### Check User Roles
```
GET http://localhost:5006/api/debug/user/admin
GET http://localhost:5006/api/debug/user/testuser
```

### View Token Contents
1. Login and get token
2. Go to jwt.io
3. Paste token in "Encoded" section
4. Verify role claim is present

---

## Performance Tips

- First app load: May take 10-15 seconds
- Database queries are cached in providers
- Refresh manually by tapping nav items again
- Check Flutter DevTools for performance analysis

---

## Known Limitations

- ⚠️ Member management API not fully integrated
- ⚠️ Photo upload for deposits is local path only (for demo)
- ⚠️ No real payment processing (demo only)
- ⚠️ Tournament scheduling pending

---

## Support

If you encounter issues:
1. Check logs in IDE output/terminal
2. Verify backend is running
3. Check authentication token validity
4. Ensure database is accessible
5. Review error messages in app snackbars

Enjoy testing the PCM application! 🎾
