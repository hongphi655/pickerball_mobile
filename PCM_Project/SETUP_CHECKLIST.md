# PCM Project - Setup Checklist

Complete all items before starting development.

## ✅ Initial Setup

### 1. Clone/Download Project
- [ ] Ensure project is in: `d:\fi study\LapTrinhMobile\kiemtragiuaki\PCM_Project`
- [ ] Folder structure has `PCM_Backend` and `PCM_Mobile` folders

### 2. Identify Your Student ID (MSSV)
- [ ] Write down your full MSSV: `________________`
- [ ] Extract last 3 digits: `___`
- [ ] This will be used for database table names

---

## 🔧 Backend Setup

### 3. Update Database Table Prefix

**File:** `PCM_Backend/Data/ApplicationDbContext.cs`

Find line:
```csharp
private const string TablePrefix = "001";
```

Replace `001` with your Student ID's last 3 digits.

Example: If MSSV is `123456`, change to:
```csharp
private const string TablePrefix = "456";
```

- [ ] Table prefix updated in ApplicationDbContext.cs
- [ ] Confirmed correct (last 3 digits of MSSV)

### 4. SQL Server Configuration

**File:** `PCM_Backend/appsettings.json`

Verify connection string:
```json
"Server=localhost\\SQLEXPRESS;Database=PCM_Database;..."
```

- [ ] SQL Server is running (check Services or SQL Server Management Studio)
- [ ] Connection string matches your SQL Server instance
- [ ] Can access SQL Server from Visual Studio

### 5. Backend Build & Migration

```bash
cd PCM_Backend
dotnet restore
dotnet ef database update
dotnet run
```

- [ ] `dotnet restore` completed successfully
- [ ] `dotnet ef database update` created database and tables
- [ ] Database tables created with prefix (e.g., `456_Members`)
- [ ] Backend running at `https://localhost:5001`
- [ ] Swagger UI accessible at `https://localhost:5001/swagger`

### 6. Test Backend API

- [ ] Open Swagger UI: `https://localhost:5001/swagger`
- [ ] Try login with demo credentials:
  - Username: `admin`
  - Password: `Abc@123`
- [ ] Receive JWT token back
- [ ] Try accessing `/api/courts` (should work)

---

## 📱 Mobile Setup

### 7. Update API Configuration

**File:** `PCM_Mobile/lib/utils/app_config.dart`

Update:
```dart
static const String apiBaseUrl = 'https://localhost:5001';
```

**Choose based on your environment:**
- Android Emulator: `http://10.0.2.2:5001`
- iOS Simulator: `http://localhost:5001`
- Physical Device: `http://YOUR_PC_IP:5001` (e.g., `http://192.168.1.100:5001`)
- Deployed: `https://your-deployed-url.com`

- [ ] API URL configured for your development environment
- [ ] Backend is accessible from mobile (test with HTTP request)

### 8. Install Flutter Dependencies

```bash
cd PCM_Mobile
flutter clean
flutter pub get
```

- [ ] `flutter pub get` completed without errors
- [ ] All packages installed successfully
- [ ] No version conflicts

### 9. Run Mobile App

```bash
# For Android Emulator
flutter run

# For iOS Simulator
flutter emulator open
flutter run -d ios
```

- [ ] App builds successfully
- [ ] App launches on emulator/device
- [ ] App doesn't crash on startup

### 10. Test Mobile App Workflow

- [ ] **Login Screen** loads
- [ ] **Login** with demo credentials:
  - Username: `user123`
  - Password: `Abc@123`
- [ ] **Dashboard** shows wallet balance
- [ ] **Bookings** section loads with courts list
- [ ] **Wallet** section shows balance
- [ ] **Tournaments** section loads tournament list

---

## 🗄️ Database Verification

### 11. Confirm Database Tables

Open SQL Server Management Studio and verify tables:

- [ ] `456_Members` (or your prefix)
- [ ] `456_WalletTransactions`
- [ ] `456_Bookings`
- [ ] `456_Courts`
- [ ] `456_Tournaments`
- [ ] `456_TournamentParticipants`
- [ ] `456_Matches`
- [ ] `456_Notifications`
- [ ] `456_News`
- [ ] `456_TransactionCategories`

- [ ] All tables created with correct prefix
- [ ] Tables have proper relationships (foreign keys)

---

## 🧪 Integration Test

### 12. End-to-End Flow

1. **Backend Running**: `https://localhost:5001` ✓
2. **Mobile App Running** on emulator/device ✓
3. **Complete User Flow**:
   - [ ] Login to mobile app
   - [ ] View dashboard with balance
   - [ ] View available courts
   - [ ] Test API communication (no connection errors)

---

## 📝 Documentation Review

### 13. Read Documentation

- [ ] Read `PCM_Backend/README.md` - API documentation
- [ ] Read `PCM_Mobile/README.md` - Mobile app documentation
- [ ] Read root `README.md` - Project overview
- [ ] Understand key features implemented
- [ ] Understand API endpoints available

---

## ⚙️ Optional Configuration

### 14. Production-Ready (Optional)

- [ ] Change JWT secret in `appsettings.json` (min 64 chars)
- [ ] Update CORS policy for specific domains
- [ ] Enable HTTPS in production
- [ ] Configure proper error logging
- [ ] Set up database backups

---

## 🚀 Ready for Development

### 15. Final Checklist

- [ ] Backend API running and accessible
- [ ] Mobile app connects to API successfully
- [ ] Database tables created with correct prefix
- [ ] Demo login works on both backend and mobile
- [ ] No console errors on startup
- [ ] Can perform basic operations (login, view data)

---

## 📞 Troubleshooting

If you encounter issues:

1. **API Connection Failed**
   - Verify backend is running: `dotnet run`
   - Check API URL in Flutter config
   - For emulator: Must use `10.0.2.2` for Android
   - Firewall might be blocking: Add exception for port 5001

2. **Database Connection Failed**
   - Verify SQL Server is running
   - Check connection string in appsettings.json
   - Ensure user has proper permissions
   - Try `dotnet ef database update` again

3. **Flutter Pub Get Failed**
   - Clear cache: `flutter clean`
   - Update packages: `flutter pub upgrade`
   - Check internet connection
   - Try again: `flutter pub get`

4. **App Crashes on Login**
   - Check backend is running and accessible
   - Verify API URL is correct
   - Check login credentials are correct
   - Review Flutter logs: `flutter logs`

---

## 📋 When You're Done

Once all checks pass, you're ready to:

1. **Develop features** as per requirements
2. **Test on real device** when available
3. **Prepare demo video** showing all features
4. **Package APK** for submission
5. **Submit project** with correct naming convention

---

## 🎯 Submission Preparation

### Final Steps Before Submission

- [ ] Replace all `001` with your Student ID's last 3 digits
- [ ] Test on at least one Android/iOS device
- [ ] Build release APK: `flutter build apk --release`
- [ ] Create README with setup instructions
- [ ] Record demo video (5-10 minutes)
- [ ] Push to GitHub/GitLab with clean commit history
- [ ] Naming: `MOBILE_FLUTTER_[MSSV]_[NAME]`

---

**Created**: January 2026
**Status**: Ready for Setup
**Next**: Complete all items and start development!
