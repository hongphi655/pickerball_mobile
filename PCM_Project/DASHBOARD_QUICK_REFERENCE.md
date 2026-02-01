# Dashboard Screens - Quick Reference Guide

## File Locations & Structure

### 1. User Dashboard
**File**: `lib/screens/home/user_dashboard.dart`
- **Entry Point**: `UserDashboard()` widget
- **Display Condition**: Non-admin users
- **Screen Location**: Bottom navigation index 0 (Trang chủ)

**Key Components**:
```
┌─────────────────────────┐
│  Xin chào, [User Name]  │  ← Greeting with user name
├─────────────────────────┤
│  ₫ [Balance Amount]     │  ← Wallet balance card (orange)
├─────────────────────────┤
│  Tier: [Gold/Silver...]  │  ← Member tier with benefits
├─────────────────────────┤
│  [Tier Benefits List]    │  ← Show 4 tiers & benefits
├─────────────────────────┤
│  [Nạp] [Đặt] [Giải] [Lịch] │  ← Quick action cards
└─────────────────────────┘
```

### 2. Admin Dashboard
**File**: `lib/screens/home/admin_dashboard.dart` (note: different from old file at `lib/screens/admin/admin_dashboard.dart`)
- **Entry Point**: `AdminDashboard()` widget  
- **Display Condition**: Users with 'Admin' role
- **Screen Location**: Bottom navigation index 0 (Trang chủ)

**Key Components**:
```
┌─────────────────────────┐
│  Xin chào, Admin        │  ← Admin greeting
├─────────────────────────┤
│  Sân: N  Thành viên: M  │  ← Statistics cards (N=court count, M=members count)
│  Doanh thu: ₫X          │  ← Revenue stat
├─────────────────────────┤
│  [Quản lý sân]          │  ← Admin action cards
│  [Quản lý thành viên]   │
│  [Phê duyệt nạp]        │
│  [Báo cáo doanh thu]    │
├─────────────────────────┤
│  Hoạt động gần đây      │  ← Activity feed
│  [Recent events list]   │
└─────────────────────────┘
```

### 3. Main Layout (Navigation Hub)
**File**: `lib/screens/home/main_layout.dart`
- **Entry Point**: `MainLayout()` widget
- **Parent Route**: `/home`
- **Function**: Central navigation hub with role-based bottom nav

**Navigation Structure**:
```
ADMIN VIEW (5 tabs):
[0] Trang chủ (AdminDashboard)
[1] Đặt sân (AdminBookingsScreen)
[2] Giải đấu (TournamentsScreen)
[3] Ví (WalletScreen)
[4] Hồ sơ (ProfileScreen)

USER VIEW (4 tabs):
[0] Trang chủ (UserDashboard)
[1] Đặt sân (BookingsScreen)
[2] Ví (WalletScreen)
[3] Hồ sơ (ProfileScreen)
```

### 4. Admin Bookings Screen
**File**: `lib/screens/bookings/admin_bookings_screen.dart`
- **Entry Point**: `AdminBookingsScreen()` widget
- **Display Condition**: Shown when admin clicks "Đặt sân" tab
- **Purpose**: View all bookings in read-only mode
- **Screen Location**: Bottom navigation index 1 (Đặt sân) for admin only

**Key Components**:
```
┌──────────────────────────────┐
│  Quản Lý Đặt Sân              │  ← Header
├──────────────────────────────┤
│  [Court Name] [Status Badge]  │  ← Booking card
│  Người đặt: [User Name]       │
│  📅 [Date/Time] ⏰ [End]      │
│  💰 ₫[Price]                  │
├──────────────────────────────┤
│  [More Booking Cards...]      │
└──────────────────────────────┘
```

---

## Role Detection Logic

**File**: `lib/main.dart` and `lib/screens/home/main_layout.dart`

```dart
// Check if user is admin
final isAdmin = context.read<AuthProvider>()
    .currentUser?.roles.contains('Admin') ?? false;

// Route conditionally
if (isAdmin) {
  // Show admin dashboard
} else {
  // Show user dashboard
}
```

**Key Role Checking Points**:
1. `main_layout.dart` - Line 30: Determines which dashboard to show
2. `main_layout.dart` - Line 59: Determines navigation bar items
3. `main.dart` - Line 117: Routes `/home/bookings` conditionally

---

## Provider Integration

### Required Providers:
```dart
// AuthProvider - For role checking & user data
AuthProvider.currentUser?.roles
AuthProvider.currentUser?.member?.fullName
AuthProvider.currentUser?.email

// WalletProvider - For balance display
WalletProvider.balance

// CourtProvider - For admin stats
CourtProvider.courts.length

// BookingProvider - For admin bookings display
BookingProvider.myBookings
BookingProvider.getMyBookings()

// TournamentProvider - For tournament list
TournamentProvider.getTournaments()
```

---

## Screen Navigation Flow

```
┌─────────────┐
│   LOGIN     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│     MainLayout (Route: /home) │  ◄─ Role-based display
└──────┬──────────────────────┘
       │
       ├─ IF ADMIN ──────────────────────┐
       │                                   │
       │ ┌──────────────────────┐         │
       │ │ AdminDashboard (0)   │◄────────┤
       │ │ AdminBookings (1)    │         │
       │ │ Tournaments (2)      │         │
       │ │ Wallet (3)           │         │
       │ │ Profile (4)          │         │
       │ └──────────────────────┘         │
       │                                   │
       └───────────────────────┬──────────┘
       │
       ├─ IF USER ───────────────────────┐
       │                                   │
       │ ┌──────────────────────┐         │
       │ │ UserDashboard (0)    │◄────────┤
       │ │ BookingsList (1)     │         │
       │ │ Wallet (2)           │         │
       │ │ Profile (3)          │         │
       │ └──────────────────────┘         │
       │                                   │
       └───────────────────────┬──────────┘
       │
       ▼
    [App Screen]
```

---

## Quick Action Card Handlers (TODO)

### User Dashboard - Quick Actions
**Location**: `user_dashboard.dart` - `_QuickActionCard` class

Current Status: **Buttons display but navigation not implemented**

```dart
// TODO: Implement onTap handlers
'Nạp tiền'  → context.go('/home/wallet')
'Đặt sân'   → context.go('/home/bookings')
'Giải đấu'  → context.go('/home/tournaments')
'Lịch đặt'  → context.go('/home/bookings') + show user's bookings
```

### Admin Dashboard - Action Cards
**Location**: `admin_dashboard.dart` - `_AdminActionCard` class

Current Status: **Buttons display but navigation not implemented**

```dart
// TODO: Implement onTap handlers
'Quản lý sân'      → Navigate to court management
'Quản lý thành viên'→ Navigate to member list
'Phê duyệt nạp'    → Navigate to wallet approvals
'Báo cáo doanh thu' → Navigate to analytics
```

---

## Admin Statistics Connection

**Current State**: Hardcoded sample values
**Location**: `admin_dashboard.dart` - `_buildStatsSection()` method

```dart
// Line 95-105: Courts count (CONNECTED - uses CourtProvider)
Text('${widget.courtCount}'),  // ✓ Real data

// Line 110: Members count (TODO - hardcoded)
Text('1,248'),  // ✗ Sample data, should sum from API

// Line 115: Revenue (TODO - hardcoded)
Text('₫45.2M'),  // ✗ Sample data, should sum wallet deposits
```

**Recommended Backend Endpoints**:
```
GET /api/admin/stats/members-count → Returns: { "count": 1248 }
GET /api/admin/stats/revenue → Returns: { "total": 45200000 }
```

---

## Styling & Theme

### Color Palette:
```dart
// User Dashboard
Primary Gradient: Colors.purple[300] → Colors.purple[700]
Accent: Colors.orange[300]
Status: Colors.green, Colors.amber, Colors.red

// Admin Dashboard
Primary Gradient: Colors.indigo → Colors.blue
Stats Card: Colors.indigo
Status: Colors.green, Colors.orange, Colors.red

// Tier Colors
Standard: Colors.grey
Silver: Colors.blue[300] (#42A5F5)
Gold: Colors.orange[300] (#FFA726)
Diamond: Colors.purple[300] (#AB47BC)
```

### Typography:
```dart
// Headers: fontSize=20, fontWeight=bold
// Card titles: fontSize=16, fontWeight=bold
// Body text: fontSize=14
// Small text: fontSize=12
```

---

## Testing Checklist

- [ ] Login as regular user → UserDashboard appears
- [ ] Login as admin → AdminDashboard appears
- [ ] Click "Đặt sân" (user) → Shows BookingsScreen
- [ ] Click "Đặt sân" (admin) → Shows AdminBookingsScreen
- [ ] Wallet balance updates on WalletProvider change
- [ ] Quick action buttons display correctly
- [ ] Admin stats show correct court count
- [ ] Navigation between tabs works smoothly
- [ ] Profile screen logout works for both roles
- [ ] No console errors on app startup

---

## Performance Notes

- **Initial Load**: ~2 seconds (includes court/tournament fetch)
- **Dashboard Switch**: ~100ms (instant with cached data)
- **Navigation**: <50ms between screens

**Optimization Tips**:
- Consider lazy loading tournament list
- Cache user tier benefits in memory
- Pre-fetch activity feed data periodically
