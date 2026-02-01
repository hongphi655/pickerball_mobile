# PCM - Pickleball Club Management System

**Hệ thống Quản lý CLB Pickleball "Vợt Thủ Phố Núi" - Mobile Edition**

---

## 📋 Project Overview

PCM is a complete mobile and backend solution for managing a Pickleball club. It includes:
- **Flutter Mobile App** for Android/iOS with real-time features
- **ASP.NET Core Web API** backend with complete business logic
- **SQL Server Database** with comprehensive schema
- **SignalR** for real-time notifications and updates
- **Wallet System** for member payments and transactions
- **Booking System** for court reservations
- **Tournament Management** with automatic scheduling

## 🎯 Key Features

### Members & Wallet
- Digital profile management
- Wallet system with balance tracking
- Automatic tier assignment (Standard → Silver → Gold → Diamond)
- Transaction history and financial tracking

### Court Bookings
- Real-time calendar booking system
- Conflict detection (no double-booking)
- Recurring bookings for VIP members
- 5-minute hold slot system
- 24-hour cancellation refund policy

### Tournaments
- Round-robin and knockout formats
- Automatic schedule generation
- Entry fee and prize pool management
- Real-time bracket updates

### Admin Panel
- Member management
- Wallet deposit approval/rejection
- Court management (add/edit/delete)
- Revenue tracking
- Tournament creation

---

## 📁 Project Structure

```
PCM_Project/
├── PCM_Backend/                 # ASP.NET Core Web API
│   ├── Models/                  # Entity models
│   ├── Data/                    # DbContext and migrations
│   ├── Controllers/             # API endpoints
│   ├── Services/                # Business logic
│   ├── DTOs/                    # Data transfer objects
│   ├── Program.cs               # Main configuration
│   ├── appsettings.json         # Configuration
│   ├── PCM.API.csproj           # Project file
│   └── README.md                # Backend documentation
│
└── PCM_Mobile/                  # Flutter Mobile App
    ├── lib/
    │   ├── main.dart            # App entry point
    │   ├── models/              # Data models
    │   ├── services/            # API client
    │   ├── providers/           # State management
    │   ├── screens/             # UI screens
    │   ├── widgets/             # Reusable widgets
    │   └── utils/               # Utilities and config
    ├── pubspec.yaml             # Dependencies
    ├── README.md                # Mobile documentation
    └── android/ios/             # Platform-specific code
```

---

## 🚀 Quick Start

### Backend Setup

1. **Prerequisites**
   - .NET 8.0 SDK
   - SQL Server (with SQLEXPRESS)

2. **Setup Database**
   ```bash
   cd PCM_Backend
   dotnet restore
   dotnet ef database update
   ```

3. **Run API**
   ```bash
   dotnet run
   ```
   - API runs at: `https://localhost:5001`
   - Swagger UI: `https://localhost:5001/swagger`

### Mobile Setup

1. **Prerequisites**
   - Flutter 3.0+
   - Android Emulator or physical device

2. **Install Dependencies**
   ```bash
   cd PCM_Mobile
   flutter pub get
   ```

3. **Configure API**
   - Edit `lib/utils/app_config.dart`
   - Set `apiBaseUrl` to your backend URL
   - For Android emulator: `http://10.0.2.2:5001`

4. **Run App**
   ```bash
   flutter run
   ```

---

## ⚠️ IMPORTANT SETUP INSTRUCTIONS

### 1. **Database Table Naming**
All business tables use the prefix format: `XXX_TableName`
- Replace `XXX` with the **last 3 digits of your Student ID (MSSV)**
- Currently using placeholder `001`
- Example: If your MSSV is `123456`, use `456_Members`, `456_Bookings`, etc.

**Location to change:**
- File: `PCM_Backend/Data/ApplicationDbContext.cs`
- Change: `private const string TablePrefix = "001";` to your MSSV's last 3 digits

### 2. **Database Connection String**
Edit `PCM_Backend/appsettings.json`:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=PCM_Database;Trusted_Connection=True;TrustServerCertificate=True;"
}
```
- Change `localhost\SQLEXPRESS` to your SQL Server instance
- Ensure Windows Authentication or provide credentials

### 3. **API Base URL (Flutter)**
Edit `PCM_Mobile/lib/utils/app_config.dart`:
```dart
static const String apiBaseUrl = 'https://localhost:5001';
```
- **For Android Emulator**: Use `http://10.0.2.2:5001`
- **For iOS Simulator**: Use `http://localhost:5001`
- **For Physical Device**: Use your machine's IP address (e.g., `http://192.168.x.x:5001`)

### 4. **First-Time Setup**

**Backend:**
```bash
cd PCM_Backend
dotnet restore
dotnet ef migrations add InitialCreate
dotnet ef database update
dotnet run
```

**Mobile:**
```bash
cd PCM_Mobile
flutter clean
flutter pub get
flutter run
```

---

## 🔑 Demo Credentials

### Test Accounts
```
Admin Account:
- Username: admin
- Password: Abc@123

Regular User:
- Username: user123
- Password: Abc@123

Treasurer:
- Username: treasurer
- Password: Abc@123
```

### Demo Bank Account (for Wallet Deposit)
```
Bank: Techcombank
Account: 0123456789
Name: CLB Vợt Thủ Phố Núi
Amount: Any amount for testing
```

---

## 📱 Mobile App Workflow

### User Flow
1. **Login** → Enter credentials
2. **Dashboard** → View wallet balance and upcoming bookings
3. **Book Court** → Select court, date, time → Confirm payment
4. **Wallet** → Deposit money with proof image → Wait for approval
5. **Tournaments** → Browse and join tournaments
6. **Profile** → View member info and statistics

### Admin Flow
1. **Login** as admin
2. **Dashboard** → Access admin panel
3. **Manage Courts** → Add/Edit/Delete courts
4. **Approve Deposits** → Review and approve wallet requests
5. **View Revenue** → Track financial metrics

---

## 🔌 API Endpoints (Summary)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/register` | User registration |
| GET | `/api/courts` | List all courts |
| POST | `/api/bookings` | Create booking |
| DELETE | `/api/bookings/{id}` | Cancel booking |
| GET | `/api/wallet/balance` | Get wallet balance |
| POST | `/api/wallet/deposit` | Request deposit |
| GET | `/api/tournaments` | List tournaments |
| POST | `/api/tournaments/{id}/join` | Join tournament |
| PUT | `/api/admin/wallet/approve/{id}` | Admin: Approve deposit |

See backend README.md for complete API documentation.

---

## 💾 Database Schema

### Core Tables
- `001_Members` - User profiles
- `001_WalletTransactions` - Financial history
- `001_Bookings` - Court reservations
- `001_Courts` - Court information
- `001_Tournaments` - Tournament details
- `001_TournamentParticipants` - Tournament registrations
- `001_Matches` - Match records
- `001_Notifications` - Notifications
- `001_News` - Club news

Replace `001` with your student ID's last 3 digits.

---

## 🐛 Troubleshooting

### Backend Issues

**Database Connection Failed**
- Verify SQL Server is running
- Check connection string in appsettings.json
- Ensure database user has proper permissions

**API Won't Start**
```bash
dotnet clean
dotnet restore
dotnet run
```

**Migrations Not Applied**
```bash
dotnet ef migrations remove
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### Mobile Issues

**API Connection Failed**
- Verify backend is running at the configured URL
- Check firewall settings
- For emulator: Use `10.0.2.2` for Android, `localhost` for iOS
- Try `flutter clean && flutter pub get`

**Login Fails**
- Ensure backend is running
- Check API credentials
- Verify user exists in database

**Image Picker Not Working**
- Grant app permissions in settings
- Rebuild app: `flutter clean && flutter run`

---

## 📊 Features Implemented

### ✅ Completed
- Authentication (Login/Register)
- Member management
- Wallet system (Deposit/Withdraw)
- Court booking
- Booking cancellation
- Tournament browsing
- Tournament registration
- Transaction history
- Real-time balance updates
- Admin dashboard (basic)

### 🔄 In Progress / Future
- SignalR real-time notifications
- Push notifications (FCM)
- Match score updates
- Tournament bracket visualization
- Chat system
- Biometric login
- Offline caching
- Export reports

---

## 📝 Important Notes

1. **Student ID**: Replace `001` with your actual Student ID's last 3 digits EVERYWHERE
2. **API URL**: Update `apiBaseUrl` based on your environment (emulator/device/deployed)
3. **Database**: Ensure SQL Server is running before starting backend
4. **Permissions**: Grant camera permission for photo uploads
5. **SSL**: Use `TrustServerCertificate=True` for development (remove in production)
6. **JWT Secret**: Change to a strong value in production

---

## 📞 Support Resources

### Documentation
- Backend README: `PCM_Backend/README.md`
- Mobile README: `PCM_Mobile/README.md`
- API Docs: `https://localhost:5001/swagger` (when running)

### Debugging
- Backend logs: Check console output
- Mobile logs: `flutter logs`
- API responses: Check Swagger UI

---

## 🎓 Academic Requirements

### Submission Requirements
1. **Source Code**
   - Both backend and mobile code in GitHub/GitLab
   - Clear commit history
   - README files for both projects

2. **Video Demo** (5-10 minutes)
   - Login → Dashboard
   - Book a court → Wallet decreases
   - Request deposit → Admin approves → Wallet increases
   - Join tournament → Entry fee deducted
   - Admin panel operations

3. **Submission Format**
   - Naming: `MOBILE_FLUTTER_[MSSV]_[NAME]`
   - Example: `MOBILE_FLUTTER_123456_NguyenVanA`
   - Include APK for Android

---

## 📄 License

This project is developed as part of the Mobile Programming course.

---

**Created**: January 2026
**Last Updated**: January 31, 2026
**For**: Pickleball Club Management System - Mobile Edition
