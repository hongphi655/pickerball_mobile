# 📑 PCM Project - Complete File Index

## Quick Navigation

### 🎯 START HERE
1. **COMPLETION_SUMMARY.md** ← Read this first!
2. **SETUP_CHECKLIST.md** ← Follow these steps
3. **IMPLEMENTATION_GUIDE.md** ← Understand features
4. **README.md** ← Project overview

---

## 📁 Directory Structure

```
PCM_Project/
│
├── 📄 README.md                    (Project overview)
├── 📄 SETUP_CHECKLIST.md          (Step-by-step setup)
├── 📄 IMPLEMENTATION_GUIDE.md      (Features explained)
├── 📄 COMPLETION_SUMMARY.md        (What you received)
└── 📄 FILE_INDEX.md               (This file)
│
├── 🗂️ PCM_Backend/
│   │
│   ├── 📄 README.md               (Backend documentation)
│   ├── 📄 Program.cs              (Main configuration)
│   ├── 📄 appsettings.json        (⚠️ Change: DB connection)
│   ├── 📄 PCM.API.csproj          (Project file)
│   ├── 📄 .gitignore
│   │
│   ├── Models/
│   │   └── 📄 Entities.cs         (All database models)
│   │
│   ├── Data/
│   │   └── 📄 ApplicationDbContext.cs  (⚠️ Change: Table prefix!)
│   │
│   ├── Controllers/
│   │   ├── 📄 AuthController.cs        (Login/Register)
│   │   ├── 📄 WalletController.cs      (Wallet APIs)
│   │   ├── 📄 BookingsController.cs    (Booking APIs)
│   │   ├── 📄 TournamentsController.cs (Tournament APIs)
│   │   ├── 📄 CourtsController.cs      (Court CRUD)
│   │   └── 📄 AdminMembersController.cs (Admin APIs)
│   │
│   ├── Services/
│   │   ├── 📄 AuthService.cs           (Login logic)
│   │   ├── 📄 WalletService.cs         (Wallet logic)
│   │   ├── 📄 BookingService.cs        (Booking logic)
│   │   └── 📄 TournamentService.cs     (Tournament logic)
│   │
│   ├── DTOs/
│   │   └── 📄 ApiDtos.cs               (Request/Response models)
│   │
│   └── Migrations/
│       └── (Auto-generated - don't edit)
│
└── 🗂️ PCM_Mobile/
    │
    ├── 📄 README.md                (Mobile documentation)
    ├── 📄 pubspec.yaml             (Dependencies)
    ├── 📄 analysis_options.yaml    (Lint rules)
    │
    ├── lib/
    │   │
    │   ├── 📄 main.dart            (App entry point & routing)
    │   │
    │   ├── models/
    │   │   └── 📄 models.dart      (Data models)
    │   │
    │   ├── services/
    │   │   └── 📄 api_service.dart (HTTP client)
    │   │
    │   ├── providers/
    │   │   └── 📄 providers.dart   (State management)
    │   │
    │   ├── screens/
    │   │   ├── auth/
    │   │   │   ├── 📄 login_screen.dart
    │   │   │   └── 📄 register_screen.dart
    │   │   ├── home/
    │   │   │   ├── 📄 main_layout.dart
    │   │   │   └── 📄 home_screen.dart
    │   │   ├── bookings/
    │   │   │   └── 📄 bookings_screen.dart
    │   │   ├── wallet/
    │   │   │   └── 📄 wallet_screen.dart
    │   │   ├── tournaments/
    │   │   │   └── 📄 tournaments_screen.dart
    │   │   └── admin/
    │   │       └── 📄 admin_dashboard.dart
    │   │
    │   ├── widgets/
    │   │   └── (For future reusable components)
    │   │
    │   └── utils/
    │       └── 📄 app_config.dart  (⚠️ Change: API URL!)
    │
    └── android/ios/
        └── (Platform-specific code)
```

---

## 🔑 Critical Files to Update

### ⚠️ MUST CHANGE THESE:

1. **PCM_Backend/Data/ApplicationDbContext.cs**
   - Line 12: Change `"001"` to your Student ID's last 3 digits
   - Example: If MSSV=123456, change to `"456"`

2. **PCM_Backend/appsettings.json**
   - Update connection string for your SQL Server
   - Change `localhost\SQLEXPRESS` to your instance name

3. **PCM_Mobile/lib/utils/app_config.dart**
   - Update `apiBaseUrl` based on your environment
   - Android: `http://10.0.2.2:5001`
   - iOS: `http://localhost:5001`
   - Device: `http://YOUR_IP:5001`

---

## 📚 Documentation by Purpose

### For Setup
1. **SETUP_CHECKLIST.md** - Step-by-step with checkboxes
2. **README.md** - Quick start guide
3. **PCM_Backend/README.md** - Backend specific setup
4. **PCM_Mobile/README.md** - Mobile specific setup

### For Understanding
1. **COMPLETION_SUMMARY.md** - What you have
2. **IMPLEMENTATION_GUIDE.md** - How features work
3. **README.md** - Architecture overview
4. **Program.cs** (Backend) - Main configuration

### For Reference
1. **Models/Entities.cs** - Database schema
2. **DTOs/ApiDtos.cs** - API request/response format
3. **Services/** - Business logic
4. **Controllers/** - API endpoints

### For Troubleshooting
1. **README.md** - Common issues section
2. **PCM_Backend/README.md** - API troubleshooting
3. **PCM_Mobile/README.md** - Mobile troubleshooting
4. **IMPLEMENTATION_GUIDE.md** - Detailed troubleshooting

---

## 🚀 Common Tasks & Where to Find Code

### I want to...

**Login to the app**
- Look at: `PCM_Mobile/lib/screens/auth/login_screen.dart`
- Backend: `PCM_Backend/Controllers/AuthController.cs`

**Book a court**
- Look at: `PCM_Mobile/lib/screens/bookings/bookings_screen.dart`
- Backend: `PCM_Backend/Services/BookingService.cs`

**Manage wallet deposits**
- Look at: `PCM_Mobile/lib/screens/wallet/wallet_screen.dart`
- Backend: `PCM_Backend/Services/WalletService.cs`

**Join a tournament**
- Look at: `PCM_Mobile/lib/screens/tournaments/tournaments_screen.dart`
- Backend: `PCM_Backend/Services/TournamentService.cs`

**Add a new court**
- Look at: `PCM_Backend/Controllers/CourtsController.cs`
- Mobile: Add UI in `PCM_Mobile/lib/screens/admin/`

**Change database schema**
- Look at: `PCM_Backend/Models/Entities.cs`
- Update: `PCM_Backend/Data/ApplicationDbContext.cs`
- Run: `dotnet ef migrations add YourMigrationName`
- Run: `dotnet ef database update`

**Add new API endpoint**
- Create controller in: `PCM_Backend/Controllers/`
- Create service in: `PCM_Backend/Services/`
- Create DTOs in: `PCM_Backend/DTOs/`
- Add method to: `PCM_Mobile/lib/services/api_service.dart`

---

## 📊 File Responsibility Matrix

| Feature | Backend | Mobile | Database |
|---------|---------|--------|----------|
| Authentication | AuthController | login_screen | AspNetUsers |
| Wallet | WalletController, WalletService | wallet_screen, WalletProvider | WalletTransactions |
| Bookings | BookingsController, BookingService | bookings_screen, BookingProvider | Bookings, Courts |
| Tournaments | TournamentsController, TournamentService | tournaments_screen, TournamentProvider | Tournaments, Matches |
| Admin | AdminMembersController | admin_dashboard | Members |

---

## 🧪 Testing Files Location

- **Backend**: Use Swagger UI at `https://localhost:5001/swagger`
- **Mobile**: Use Flutter emulator/device
- **Database**: Use SQL Server Management Studio

---

## 📈 Code Statistics

```
Backend (ASP.NET Core):
├── Models:        ~200 lines (6 entities + enums)
├── Controllers:   ~600 lines (6 controllers)
├── Services:      ~800 lines (4 services)
├── DTOs:          ~300 lines (15+ DTO classes)
└── DbContext:     ~200 lines (relationships)
Total: ~2,100 lines

Mobile (Flutter):
├── Main & Routing:    ~150 lines
├── Models:            ~300 lines
├── API Service:       ~400 lines
├── Providers:         ~700 lines
├── Screens (6):       ~2,000 lines
└── Configuration:     ~50 lines
Total: ~3,600 lines

Database:
├── 10 tables
├── Multiple relationships
├── Enums for status fields
└── Full migration support
```

---

## 🔄 Development Workflow

### To Add New Feature:

1. **Database Schema**
   - Edit: `Models/Entities.cs`
   - Edit: `Data/ApplicationDbContext.cs`
   - Run: `dotnet ef migrations add FeatureName`
   - Run: `dotnet ef database update`

2. **Backend API**
   - Create: `Controllers/NewController.cs`
   - Create: `Services/NewService.cs`
   - Update: `DTOs/ApiDtos.cs` (add DTOs)
   - Test: Swagger UI

3. **Mobile App**
   - Update: `lib/models/models.dart`
   - Update: `lib/services/api_service.dart`
   - Create: `lib/screens/newfeature_screen.dart`
   - Update: `lib/providers/providers.dart`
   - Update: `lib/main.dart` (if new route)

4. **Test**
   - Backend: Swagger
   - Mobile: Flutter emulator
   - Integration: End-to-end flow

---

## 💾 Configuration Files

| File | Purpose | Change Needed |
|------|---------|----------------|
| appsettings.json | DB & JWT config | ✅ Yes |
| app_config.dart | API URL | ✅ Yes |
| ApplicationDbContext.cs | Table prefix | ✅ Yes |
| pubspec.yaml | Dependencies | ❌ No |
| PCM.API.csproj | Build config | ❌ No |

---

## 🎯 Quick Reference Commands

```bash
# Backend
cd PCM_Backend
dotnet restore          # Install packages
dotnet ef database update   # Apply migrations
dotnet run             # Start API
dotnet ef migrations add MigrationName  # Create migration

# Mobile
cd PCM_Mobile
flutter clean          # Clean build
flutter pub get        # Install packages
flutter run            # Run app
flutter build apk --release  # Build APK
```

---

## 🔗 File Dependencies

```
main.dart
├── Program.cs (backend startup)
├── appsettings.json (configuration)
├── All Controllers
├── All Services
├── ApplicationDbContext.cs
└── Entities.cs

main.dart (mobile)
├── app_config.dart (API URL)
├── api_service.dart
├── providers.dart (state)
└── All screens
```

---

## 📞 File Locations Summary

**Need to change database name?**
→ appsettings.json (DefaultConnection)

**Need to change API endpoint?**
→ app_config.dart (apiBaseUrl)

**Need to change table names?**
→ ApplicationDbContext.cs (TablePrefix)

**Need to add new API?**
→ Controllers/ + Services/

**Need to add new screen?**
→ screens/ + providers.dart

**Need to change database schema?**
→ Models/Entities.cs + ApplicationDbContext.cs

---

## ✅ Verification Checklist

- [ ] All documentation readable
- [ ] File structure matches this index
- [ ] Backend files in PCM_Backend/
- [ ] Mobile files in PCM_Mobile/
- [ ] README files in both folders
- [ ] Critical files identified
- [ ] Commands documented

---

**Last Updated**: January 31, 2026  
**Version**: 1.0 Complete  
**Status**: All files accounted for and documented
