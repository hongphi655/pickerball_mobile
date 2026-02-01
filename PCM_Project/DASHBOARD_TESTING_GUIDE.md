# Dashboard Testing Guide

## How to Test the New Dashboards

### Prerequisites
- Flutter app running on Chrome, Android emulator, or iOS simulator
- Backend API running on `http://localhost:5000`
- Test user accounts created in the database

### Test Accounts

**Regular User Account:**
```
Email: user@example.com
Password: User@123456
Role: None (Regular User)
```

**Admin Account:**
```
Email: admin@example.com
Password: Admin@123456
Role: Admin
```

---

## Test Case 1: User Dashboard Display

### Steps:
1. Launch the Flutter app
2. Login with regular user credentials (user@example.com)
3. Observe the home screen (index 0 in bottom navigation)

### Expected Results:
- ✅ See "Xin chào, [User Name]" greeting with purple gradient
- ✅ Orange card showing wallet balance in ₫
- ✅ Member tier card displaying current tier (Gold/Silver/Diamond/Standard)
- ✅ Tier benefits section showing benefits for all 4 tiers
- ✅ Four quick action cards visible (Nạp tiền, Đặt sân, Giải đấu, Lịch đặt)
- ✅ Bottom navigation showing 4 items (Trang chủ, Đặt sân, Ví, Hồ sơ)
- ✅ Wallet balance in AppBar showing user's current balance

---

## Test Case 2: Admin Dashboard Display

### Steps:
1. Launch the Flutter app
2. Login with admin credentials (admin@example.com)
3. Observe the home screen (index 0 in bottom navigation)

### Expected Results:
- ✅ See "Xin chào, Admin" greeting with indigo gradient
- ✅ Three statistics cards showing:
  - Courts count (should match number in database)
  - Members count (hardcoded 1,248 for now)
  - Revenue (hardcoded ₫45.2M for now)
- ✅ Four admin action cards visible:
  - Quản lý sân
  - Quản lý thành viên
  - Phê duyệt nạp tiền
  - Báo cáo doanh thu
- ✅ Activity feed showing sample activities
- ✅ Bottom navigation showing 5 items (Trang chủ, Đặt sân, Giải đấu, Ví, Hồ sơ)
- ✅ No wallet balance in AppBar (admin only)

---

## Test Case 3: User Navigation Between Tabs

### Steps (as Regular User):
1. Login as regular user
2. Click "Đặt sân" (index 1) in bottom navigation
3. Click "Ví" (index 2)
4. Click "Hồ sơ" (index 3)
5. Return to "Trang chủ" (index 0)

### Expected Results:
- ✅ "Đặt sân" shows list of available courts for booking
- ✅ "Ví" shows wallet balance and transaction history
- ✅ "Hồ sơ" shows user profile with logout button
- ✅ Can navigate freely between all tabs
- ✅ Bottom navigation highlight follows current tab

---

## Test Case 4: Admin Navigation Between Tabs

### Steps (as Admin User):
1. Login as admin
2. Click "Đặt sân" (index 1) in bottom navigation
3. Click "Giải đấu" (index 2)
4. Click "Ví" (index 3)
5. Click "Hồ sơ" (index 4)
6. Return to "Trang chủ" (index 0)

### Expected Results:
- ✅ "Đặt sân" shows **AdminBookingsScreen** (read-only booking list with user names)
- ✅ "Giải đấu" shows tournament list
- ✅ "Ví" shows wallet/transaction info
- ✅ "Hồ sơ" shows admin profile with logout button
- ✅ Admin sees 5 navigation items, not 4 like users

---

## Test Case 5: Admin Bookings Screen

### Steps (as Admin User):
1. Login as admin
2. Click "Đặt sân" tab (should show AdminBookingsScreen)
3. Scroll through the booking list (if bookings exist)
4. Check booking card details

### Expected Results:
- ✅ See "Quản Lý Đặt Sân" as header
- ✅ Each booking card shows:
  - Court name
  - Person who booked it ("Người đặt: [Name]")
  - Booking status badge (Confirmed/Pending/Cancelled)
  - Start date/time and end time
  - Total price in ₫
- ✅ Status badges show proper colors:
  - Green for Confirmed ✓
  - Orange for Pending ⏱
  - Red for Cancelled ✕
- ✅ If no bookings, see "Không có đặt sân nào" message
- ✅ Loading spinner appears while fetching data

---

## Test Case 6: Wallet Balance Updates

### Steps:
1. Login as regular user
2. Note the wallet balance displayed in:
   - AppBar (top right)
   - User Dashboard orange card
3. Go to "Ví" tab and perform a wallet operation (if available)
4. Return to "Trang chủ" tab
5. Check if balance updated

### Expected Results:
- ✅ Initial balance displays correctly
- ✅ Balance format: ₫ [Amount] (e.g., ₫500,000)
- ✅ AppBar shows balance even on other tabs
- ✅ Dashboard updates when balance changes

---

## Test Case 7: Member Tier Display

### Steps (as Regular User with different membership levels):
1. Test with a standard member account
2. Check displayed tier and color
3. Verify tier benefits match the tier level
4. Test with Gold/Silver/Diamond tier accounts

### Expected Results:
- ✅ Standard tier: Grey color, basic benefits
- ✅ Silver tier: Blue color, 5% discount benefit
- ✅ Gold tier: Amber color, 10% discount + priority
- ✅ Diamond tier: Purple color, 15% discount + VIP
- ✅ Tier icon matches tier level
- ✅ Total spent amount displays correctly

---

## Test Case 8: Quick Action Cards (User)

### Steps:
1. Login as user
2. Look at the four quick action cards at bottom of dashboard
3. Attempt to tap each card (if navigation implemented)

### Current Status:
- ⚠️ Buttons display but navigation not yet implemented
- Cards visible: Nạp tiền, Đặt sân, Giải đấu, Lịch đặt

### Expected Results (Future):
- ✅ "Nạp tiền" → Navigate to wallet screen
- ✅ "Đặt sân" → Navigate to court booking list
- ✅ "Giải đấu" → Navigate to tournaments
- ✅ "Lịch đặt" → Navigate to user's booking history

---

## Test Case 9: Admin Action Cards (Admin)

### Steps:
1. Login as admin
2. Look at the four admin action cards
3. Attempt to tap each card (if navigation implemented)

### Current Status:
- ⚠️ Buttons display but navigation not yet implemented
- Cards visible: Quản lý sân, Quản lý thành viên, Phê duyệt nạp, Báo cáo doanh thu

### Expected Results (Future):
- ✅ "Quản lý sân" → Navigate to court management
- ✅ "Quản lý thành viên" → Navigate to member list
- ✅ "Phê duyệt nạp" → Navigate to deposit approvals
- ✅ "Báo cáo doanh thu" → Navigate to revenue analytics

---

## Test Case 10: Logout Functionality

### Steps:
1. Login to any account (user or admin)
2. Click "Hồ sơ" tab (index 3 or 4)
3. Click "Đăng xuất" button
4. Verify redirection

### Expected Results:
- ✅ Logout button visible on profile screen
- ✅ Button shows red color (danger action)
- ✅ Clicking logout removes auth token
- ✅ Redirects to login screen
- ✅ Cannot access protected routes without re-login

---

## Test Case 11: Role-Based Routing (Security)

### Steps:
1. Login as regular user
2. Try to manually navigate to `/home/admin` (if your app has this route)
3. Verify access is denied
4. Login as admin
5. Try to access the same route

### Expected Results:
- ✅ Regular users cannot access admin routes
- ✅ App redirects to home if unauthorized access attempted
- ✅ Admin users can access admin-specific routes

---

## Test Case 12: Loading States

### Steps:
1. Login and observe dashboard loading
2. Watch for loading indicators while data fetches
3. Verify data appears after loading completes
4. Test on slow network (if possible)

### Expected Results:
- ✅ Loading spinner appears during initial load (~2 seconds)
- ✅ After loading, dashboard content displays
- ✅ Courts count updates from real database
- ✅ User data loads from AuthProvider
- ✅ Wallet balance fetches from API

---

## Known Issues & Limitations

### Current Implementation:
- ⚠️ Admin statistics partially hardcoded:
  - ✅ Courts count: Real data from CourtProvider
  - ❌ Members count: Hardcoded (1,248)
  - ❌ Revenue: Hardcoded (₫45.2M)

- ⚠️ Activity feed shows sample data only

- ⚠️ Quick action card navigation not implemented yet

### Workarounds:
- Admin can still see real courts count
- Member and revenue stats will be accurate after backend integration

---

## Debugging Tips

### If dashboard doesn't appear:
1. Check console for error messages
2. Verify AuthProvider.currentUser is not null
3. Check role is correctly set in token
4. Ensure CourtProvider has courts loaded

### If wrong dashboard shows:
1. Verify user role in database
2. Check AuthProvider.currentUser?.roles
3. Inspect role-checking logic in main_layout.dart

### If navigation doesn't work:
1. Verify GoRouter configuration in main.dart
2. Check route paths match
3. Ensure context.go() receives valid route

### If data doesn't load:
1. Verify backend API is running on :5000
2. Check network connection
3. Verify API endpoints are responding
4. Check authentication token is valid

---

## Success Criteria

All tests should pass without errors:
- [ ] User dashboard displays correctly
- [ ] Admin dashboard displays correctly
- [ ] Navigation between tabs works
- [ ] Both user and admin can logout
- [ ] Wallet balance displays and updates
- [ ] Member tier displays correctly
- [ ] No console errors
- [ ] App doesn't crash on screen transitions

✅ **If all tests pass, dashboard implementation is successful!**
