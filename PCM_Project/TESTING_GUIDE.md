# Role-Based UI Testing Guide

## Quick Test Instructions

### Prerequisites
1. Backend running at `http://localhost:5006`
2. Flutter app ready to run
3. Two test accounts seeded:
   - Admin: username=`admin`, password=`Admin123!`
   - User: username=`testuser`, password=`Password123!`

## Test Scenario 1: Regular User Login

### Steps:
1. Launch app
2. Go to Login screen
3. Enter: username=`testuser`, password=`Password123!`
4. Tap "Đăng nhập" (Login)

### Expected Results:
✓ Login succeeds  
✓ Redirected to `/home`  
✓ BottomNavigationBar shows **3 items**:
  - 📅 Đặt sân (Bookings)
  - 💰 Ví (Wallet)
  - 👤 Hồ sơ (Profile)

✓ Try to access Admin Dashboard (cannot - redirected to home)  
✓ Open Wallet screen:
  - Shows balance
  - Shows deposit form
  - **NO Transaction History section visible**

### Navigation Test:
- Tap each tab - should switch between Bookings, Wallet, Profile
- All screens should be accessible

---

## Test Scenario 2: Admin Login

### Steps:
1. Clear login data (logout if logged in)
2. Go to Login screen
3. Enter: username=`admin`, password=`Admin123!`
4. Tap "Đăng nhập" (Login)

### Expected Results:
✓ Login succeeds  
✓ Redirected to `/home`  
✓ BottomNavigationBar shows **5 items**:
  - 📅 Đặt sân (Bookings)
  - 🏆 Giải đấu (Tournaments)
  - 💰 Ví (Wallet)
  - ⚙️ Admin (Admin Dashboard)
  - 👤 Hồ sơ (Profile)

✓ Tap Admin tab - opens Admin Dashboard  
✓ Admin Dashboard shows options:
  - Quản lý Sân (Manage Courts)
  - Duyệt Nạp Tiền (Approve Deposits)
  - Xem Doanh Thu (View Revenue)
  - Quản lý Thành Viên (Manage Members)
  - Tạo Giải Đấu (Create Tournament)

✓ Open Wallet screen:
  - Shows balance
  - Shows deposit form
  - **Transaction History section visible** with past transactions listed

### Navigation Test:
- Tap each of 5 tabs - should access all screens
- Admin Dashboard accessible from tab 3 (index 3 in admin menu)
- Bookings at index 0 for both admin and user

---

## Debug Checklist

If something doesn't work, check:

1. **Backend running?**
   ```powershell
   cd PCM_Backend
   dotnet run
   # Should show: "Now listening on: http://localhost:5006"
   ```

2. **Flutter dependencies installed?**
   ```bash
   cd PCM_Mobile
   flutter pub get
   ```

3. **Test accounts created?**
   - Call: `GET http://localhost:5006/api/debug/users`
   - Should return list with `admin` and `testuser`

4. **Login returns roles?**
   - After login, check console logs
   - Should see: `User roles: [Admin]` or `User roles: []`
   - Check Flutter debug output in IDE

5. **Role claims in JWT?**
   - Decode token at jwt.io
   - Look for `role` field with value `Admin` or `User`

---

## File Changes Summary

| File | Changes |
|------|---------|
| `lib/main.dart` | Removed unused home_screen import |
| `lib/screens/home/main_layout.dart` | Dynamic nav bar based on role |
| `lib/screens/wallet/wallet_screen.dart` | Hide transaction history for users |
| `lib/screens/admin/admin_dashboard.dart` | Add role check, Vietnamese labels |
| `lib/screens/bookings/bookings_screen.dart` | Removed unused import |

---

## Expected Behavior Summary

| Feature | Regular User | Admin |
|---------|--------------|-------|
| Book Court | ✓ | ✓ |
| View/Create Tournament | ✗ | ✓ |
| Access Wallet | ✓ | ✓ |
| See Transaction History | ✗ | ✓ |
| Access Admin Dashboard | ✗ | ✓ |
| View Profile | ✓ | ✓ |
| Bottom Nav Items | 3 | 5 |

---

## Important Notes

- Role checking happens at **3 levels**:
  1. **Router level**: `/home/admin` route guarded
  2. **UI level**: NavBar items and screens conditionally rendered
  3. **Backend level**: API endpoints have `[Authorize(Roles="Admin")]`

- All role checks use: `authProvider.currentUser?.roles.contains('Admin')`

- User with empty roles array `[]` is treated as regular user

- Admin role value is exactly `"Admin"` (case-sensitive)
