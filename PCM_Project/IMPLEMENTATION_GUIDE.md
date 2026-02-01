# PCM Implementation Guide

**Complete guide to implement the Pickleball Club Management System**

---

## 📌 Executive Summary

You have received a complete, production-ready codebase for a mobile + backend pickleball club management system. This includes:

✅ **Backend**: ASP.NET Core Web API with Entity Framework Core  
✅ **Mobile**: Flutter app with Provider state management  
✅ **Database**: SQL Server schema with relationships  
✅ **Features**: Wallet, Bookings, Tournaments, Admin Panel  
✅ **Documentation**: Comprehensive READMEs and guides  

**Status**: Ready to run. Just needs configuration for your environment.

---

## 🎯 What's Included

### Backend (ASP.NET Core)
```
✅ Authentication (JWT + Identity)
✅ Wallet System (Deposit/Withdraw/Payment)
✅ Booking System (Calendar, Recurring, Cancellation)
✅ Tournament Management (Round-robin, Knockout)
✅ Admin Controls (Member management, Revenue tracking)
✅ API Documentation (Swagger UI)
✅ Database Migrations (Entity Framework)
✅ SignalR Hub (Real-time ready)
```

### Mobile (Flutter)
```
✅ Authentication Screen (Login/Register)
✅ Dashboard (Wallet, Member info, Bookings)
✅ Booking Screen (Calendar, Time slots)
✅ Wallet Screen (Balance, Deposits, History)
✅ Tournament Screen (Browse, Join, Leave)
✅ Admin Dashboard (Basic controls)
✅ State Management (Provider)
✅ Navigation (GoRouter)
✅ API Client (Dio with interceptors)
```

### Database
```
✅ Members (with Tier system)
✅ Wallet Transactions
✅ Bookings (with Recurring support)
✅ Courts
✅ Tournaments
✅ Matches
✅ Notifications
✅ News/Announcements
✅ Full relationships & constraints
```

---

## 🚀 Quick Start (5 minutes)

### Step 1: Backend
```bash
cd PCM_Backend

# 1. Update table prefix in Data/ApplicationDbContext.cs (replace "001")
# 2. Update connection string in appsettings.json

# 3. Create database
dotnet restore
dotnet ef database update

# 4. Run API
dotnet run
# Check: https://localhost:5001/swagger
```

### Step 2: Mobile
```bash
cd PCM_Mobile

# 1. Update API URL in lib/utils/app_config.dart
# 2. Install dependencies
flutter pub get

# 3. Run app
flutter run
```

### Step 3: Test
- Login with demo credentials
- View dashboard
- Try booking a court
- Test wallet deposit

---

## ⚙️ Critical Configuration (DO THIS FIRST!)

### 1️⃣ Database Table Prefix
**Why**: Requirement specifies tables should use student ID prefix

**Location**: `PCM_Backend/Data/ApplicationDbContext.cs`

```csharp
// Line 12 - CHANGE THIS:
private const string TablePrefix = "001";

// To (if your MSSV is 123456):
private const string TablePrefix = "456";
```

**Action Required**:
- [ ] Extract last 3 digits from your MSSV
- [ ] Replace `001` in the code
- [ ] Run migration again: `dotnet ef database update`
- [ ] Verify tables in SQL Server have correct prefix

### 2️⃣ Database Connection String
**Location**: `PCM_Backend/appsettings.json`

```json
"DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=PCM_Database;..."
```

**Adjust for your environment**:
```
Windows Auth: Server=YOUR_SERVER\INSTANCE;Database=PCM_DB;Trusted_Connection=True;
SQL Auth:     Server=YOUR_SERVER;Database=PCM_DB;User Id=sa;Password=xxx;
```

### 3️⃣ API Base URL (Mobile)
**Location**: `PCM_Mobile/lib/utils/app_config.dart`

```dart
// Current:
static const String apiBaseUrl = 'https://localhost:5001';

// Change to:
// Android Emulator:  'http://10.0.2.2:5001'
// iOS Simulator:     'http://localhost:5001'
// Physical Device:   'http://YOUR_PC_IP:5001'
// Deployed:          'https://your-domain.com'
```

---

## 📖 How to Use Each Feature

### 🔐 Authentication

**Backend API**:
```
POST /api/auth/login
{
  "username": "user123",
  "password": "Abc@123"
}

Returns: JWT token + User info
```

**Mobile App**:
1. Run `flutter run`
2. See Login Screen
3. Enter credentials
4. Token automatically saved in secure storage
5. Redirected to Dashboard

### 💳 Wallet System

**User Flow**:
1. **Request Deposit**
   - Go to Wallet screen
   - Enter amount
   - Take photo of transfer (demo)
   - Tap "Submit"
   - Status: Pending

2. **Admin Approves**
   - Login as admin
   - View pending deposits
   - Approve deposit
   - User balance increased automatically

**Backend API**:
```
POST /api/wallet/deposit          # Request
GET  /api/wallet/balance          # Get balance
GET  /api/wallet/transactions     # History
PUT  /api/admin/wallet/approve/{id} # Admin approval
```

### 📅 Booking System

**User Flow**:
1. Go to Bookings screen
2. Select court from dropdown
3. Pick date from calendar
4. Click available time slot
5. Confirm booking
6. Wallet debited automatically
7. Booking appears in "My Bookings"

**Cancellation**:
- Within 24h: 100% refund
- After 24h: No refund (can customize)

**Backend API**:
```
POST   /api/bookings               # Create booking
POST   /api/bookings/recurring     # Recurring booking
DELETE /api/bookings/{id}          # Cancel booking
GET    /api/bookings/my-bookings   # Get my bookings
GET    /api/bookings/calendar?courtId=1&date=2024-02-01
```

### 🏆 Tournament System

**User Flow**:
1. Go to Tournaments screen
2. See all tournaments (Open/Ongoing/Finished)
3. Tap "Join" on Open tournament
4. Entry fee debited from wallet
5. Confirmation message
6. Member added to tournament

**Admin Functions**:
- Create new tournament
- Set format (Round-robin/Knockout)
- Generate schedule
- View brackets

**Backend API**:
```
GET    /api/tournaments            # List all
POST   /api/tournaments            # Admin: Create
GET    /api/tournaments/{id}       # Details
POST   /api/tournaments/{id}/join  # Join
DELETE /api/tournaments/{id}/leave # Leave
POST   /api/tournaments/{id}/generate-schedule # Admin
```

### 👥 Admin Panel

**Available Functions**:
- Manage Courts (Add/Edit/Delete)
- Manage Members
- Approve wallet deposits
- View revenue summary
- Create tournaments

**Access**:
- Login as `admin` / `Abc@123`
- Click "Admin" in main menu
- See available functions

---

## 🗄️ Database Schema Reference

### Table Naming
All tables use prefix: `[STUDENT_ID_LAST_3]_TableName`
Example: `456_Members`, `456_Bookings`, etc.

### Core Entities

**Members**
- Personal info
- Wallet balance
- Tier (Standard/Silver/Gold/Diamond)
- Rank points (DUPR)
- Total spent

**Wallet Transactions**
- Type: Deposit, Withdraw, Payment, Refund, Reward
- Status: Pending, Completed, Rejected, Failed
- Amount & timestamp
- Reference to booking/tournament

**Bookings**
- Court + Member
- Start/End time
- Price calculated
- Status: PendingPayment, Confirmed, Cancelled, Completed
- Supports recurring bookings

**Tournaments**
- Format: RoundRobin, Knockout, Hybrid
- Entry fee + Prize pool
- Status: Open, Registering, DrawCompleted, Ongoing, Finished

**Matches**
- Tournament match details
- Players (2v1 or 1v1)
- Score, result, details
- Round name

---

## 📱 Mobile App Architecture

### State Management (Provider)
```
AuthProvider      → Login/Logout/User info
WalletProvider    → Balance, Transactions, Deposits
BookingProvider   → My Bookings, Calendar
TournamentProvider → Tournaments, Registration
CourtProvider     → Available courts
```

### Screen Structure
```
main.dart
├── GoRouter (Navigation)
├── Authentication
│   ├── LoginScreen
│   └── RegisterScreen
├── Main Layout
│   ├── HomeScreen (Dashboard)
│   ├── BookingsScreen
│   ├── TournamentsScreen
│   ├── WalletScreen
│   └── AdminDashboard
└── Providers (State)
```

### Navigation
- GoRouter for navigation management
- Automatic redirect based on auth state
- Deep linking ready
- Proper back button handling

---

## 🧪 Testing the System

### Demo Test Flow

**1. Login**
```
Username: user123
Password: Abc@123
Expected: Dashboard with wallet balance
```

**2. View Courts**
```
Expected: List of 3 courts with prices
```

**3. Book a Court**
```
- Select court
- Pick date (tomorrow)
- Pick time (10:00)
- Confirm
- Check: Wallet decreased by booking price
```

**4. Deposit Wallet**
```
- Go to Wallet
- Enter 500,000 VND
- Take photo (demo)
- Submit
- Expected: Pending deposit request
```

**5. Admin Approves** (Login as admin)
```
Username: admin
Password: Abc@123
- View pending deposits
- Click approve
- Check user's wallet increased
```

**6. Join Tournament**
```
- View tournaments
- Join "Summer Open"
- Check: Entry fee deducted
- Confirmation message
```

---

## 🔧 Troubleshooting Guide

### Backend Won't Start
```
Error: SQL connection failed
Fix: Check SQL Server is running, connection string correct

Error: Port 5001 already in use
Fix: netstat -ano | findstr :5001, kill process

Error: Migrations failed
Fix: dotnet ef migrations remove, dotnet ef migrations add InitialCreate
```

### Mobile App Won't Connect
```
Error: Connection refused
Fix: Backend must be running, check API URL

Error: Emulator can't reach 10.0.2.2
Fix: Ensure backend binds to 0.0.0.0 or localhost

Error: Login fails
Fix: Check username/password, ensure user exists in database
```

### Database Issues
```
Error: Tables don't exist
Fix: Run dotnet ef database update again

Error: Foreign key constraints
Fix: Ensure relationships are correct, no orphaned records

Error: Cannot connect
Fix: Verify Windows/SQL authentication, user permissions
```

---

## 📊 Key Metrics & Requirements

### ✅ Implemented Features
- [x] Member management with tier system
- [x] Digital wallet with transaction history
- [x] Real-time balance updates
- [x] Court booking with conflict detection
- [x] Recurring bookings
- [x] Tournament registration with fee deduction
- [x] Admin dashboard
- [x] API with Swagger documentation
- [x] JWT authentication
- [x] Role-based authorization

### 🔄 Ready for Enhancement
- [ ] SignalR real-time notifications
- [ ] Push notifications (FCM)
- [ ] Match score live updates
- [ ] Chat system
- [ ] Payment gateway (VNPay)
- [ ] Biometric login
- [ ] Offline caching
- [ ] Export reports

---

## 📝 Important Notes

1. **Student ID Prefix**: Replace `001` everywhere with your MSSV's last 3 digits
2. **API URL**: Update based on your environment (emulator/device/deployed)
3. **SQL Server**: Required - Download SQL Express if needed
4. **Flutter Version**: Requires 3.0+
5. **Network**: Device must reach backend API
6. **Permissions**: Grant camera permission for photo uploads

---

## 📋 Before Submission

### Code Quality
- [ ] Remove debug prints and console logs
- [ ] Proper error handling throughout
- [ ] Clean code structure
- [ ] Comments where needed
- [ ] No hardcoded values

### Testing
- [ ] Test on Android device/emulator
- [ ] Test on iOS simulator
- [ ] Test all main workflows
- [ ] Test error scenarios
- [ ] Verify admin functions

### Documentation
- [ ] README files complete
- [ ] API documented
- [ ] Setup instructions clear
- [ ] Include APK build
- [ ] Commit history clean

### Submission
- [ ] Naming: `MOBILE_FLUTTER_[MSSV]_[NAME]`
- [ ] Push to GitHub/GitLab
- [ ] Record demo video (5-10 min)
- [ ] Include APK file
- [ ] Provide Base URL for grading

---

## 🎓 Learning Outcomes

By completing this project, you'll have:

✅ Built a production-quality Flutter mobile app  
✅ Implemented REST API with ASP.NET Core  
✅ Designed database with Entity Framework  
✅ Managed authentication & authorization  
✅ Implemented business logic (wallet, booking, tournament)  
✅ Used state management best practices  
✅ Created responsive UI  
✅ Integrated real-time features (SignalR ready)  
✅ Documented code professionally  

---

## 📞 Quick Reference

### Important Files
```
Configuration:
- PCM_Backend/appsettings.json         (DB, JWT)
- PCM_Mobile/lib/utils/app_config.dart (API URL)

Models:
- PCM_Backend/Models/Entities.cs       (DB models)
- PCM_Mobile/lib/models/models.dart    (API models)

Services:
- PCM_Backend/Services/*.cs            (Business logic)
- PCM_Mobile/lib/services/api_service.dart (API client)

Database:
- PCM_Backend/Data/ApplicationDbContext.cs (Schema)
- PCM_Backend/Migrations/             (Migration files)
```

### Key Commands
```bash
# Backend
dotnet restore              # Install packages
dotnet ef database update  # Apply migrations
dotnet run                 # Start API

# Mobile
flutter pub get            # Install packages
flutter clean              # Clean build
flutter run                # Run app
flutter build apk --release # Build APK
```

---

**Ready to start?**

1. ✅ Verify all prerequisites installed
2. ✅ Configure database prefix & connection string
3. ✅ Configure API URL for mobile
4. ✅ Run backend: `dotnet run`
5. ✅ Run mobile: `flutter run`
6. ✅ Test with demo credentials
7. ✅ Start development!

---

**Created**: January 31, 2026  
**Last Updated**: January 31, 2026  
**Status**: Complete & Ready to Use
