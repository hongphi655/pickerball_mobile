# Quick Start Guide - Member Management System

## System Overview

The PCM (Badminton Court Management) system now includes complete member management with admin tracking and user booking features.

### Architecture
```
User (Flutter Web) 
    ↓
  Dio HTTP Client (with JWT auth)
    ↓
  ASP.NET Core API (Port 5001)
    ↓
  SQL Server Database
```

---

## Running the System

### Step 1: Start Backend API

```powershell
cd PCM_Backend
dotnet run
```

**Expected Output**:
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5001
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
```

### Step 2: Start Flutter App

```powershell
cd PCM_Mobile
flutter run -d chrome
```

**Expected Output**:
```
Launching lib/main.dart on Chrome in debug mode...
...
Serving DevTools at http://127.0.0.1:52573
```

### Step 3: Login

1. **As Admin**:
   - Username: `admin` (or configured admin account)
   - Password: (as per your setup)
   - Navigate to "Quản Lý Thành Viên" (Member Management)

2. **As Regular User**:
   - Username: `user` (or any non-admin account)
   - Password: (as per your setup)
   - Navigate to "Đặt Sân" (Book Court)

---

## Feature Walkthrough

### Admin: View All Members

1. **Navigate**: Click "Admin Dashboard" → "Quản Lý Thành Viên"
2. **View**: List of all members with:
   - Member name
   - Email address
   - Join date
   - Wallet balance
3. **Details**: Click member card to see:
   - Full member profile (ID, email, join date, tier, rank)
   - Current wallet balance
   - Total money spent
   - View booking history button

### Admin: Check Member Booking History

1. From member detail dialog, click "Xem Bookings" (View Bookings)
2. See all bookings for that member:
   - Court name
   - Booking date & time
   - Total price paid
   - Booking status

### Admin: Monitor Member Wallets

- **Wallet Balance**: Current funds in member's account
- **Total Spent**: Sum of all debit transactions
- **Spending Ratio**: Balance / TotalSpent shows financial activity

### User: Book a Court

1. **Navigate**: Click "Đặt Sân" (Book Court)
2. **Select**:
   - Choose court from dropdown
   - Pick date using date picker
   - Set start time and end time
3. **Confirm**:
   - View calculated price
   - Click "Đặt Sân" to submit
4. **Verify**:
   - Success message confirms booking
   - Admin can see booking immediately

---

## Key Files

### Backend
```
PCM_Backend/
├── Controllers/AdminMembersController.cs     # Member endpoints
├── Data/ApplicationDbContext.cs              # EF Core context
├── Models/Entities.cs                        # DB models
├── Services/                                 # Business logic
└── Program.cs                                # Startup config
```

### Frontend
```
PCM_Mobile/
├── lib/
│   ├── models/models.dart                   # Dart models
│   ├── providers/providers.dart             # State management
│   ├── services/api_service.dart            # HTTP client
│   ├── screens/
│   │   ├── admin/admin_members_screen.dart  # Member list & details
│   │   ├── bookings/booking_screen.dart     # User booking form
│   │   └── ...
│   └── main.dart                            # Entry point
└── pubspec.yaml                             # Dependencies
```

---

## Database Schema (Relevant Tables)

### Members Table
```
Id (int, PK)
FullName (nvarchar)
Email (nvarchar)
JoinDate (datetime)
RankLevel (float)
IsActive (bit)
Tier (nvarchar)
WalletBalance (decimal)
TotalSpent (decimal)
```

### Bookings Table
```
Id (int, PK)
CourtId (int, FK)
MemberId (int, FK)
StartTime (datetime)
EndTime (datetime)
TotalPrice (decimal)
Status (nvarchar)
CreatedDate (datetime)
```

### WalletTransactions Table
```
Id (int, PK)
MemberId (int, FK)
Amount (decimal)
Type (nvarchar) - 'Deposit' or 'Debit'
Description (nvarchar)
TransactionDate (datetime)
Status (nvarchar) - 'Pending' or 'Completed'
```

---

## API Endpoints

### Authentication
```
POST /api/auth/login
Body: { username, password }
Response: { token, user, role }
```

### Member Management (Admin Only)
```
GET /api/admin/members
Response: List of members with wallet info

GET /api/admin/members/{id}/bookings
Response: Member's booking history

GET /api/admin/members/{id}/wallet-transactions
Response: Member's wallet transactions
```

### Court Management (Admin)
```
GET /api/courts
GET /api/courts/{id}
POST /api/courts (admin only)
PUT /api/courts/{id} (admin only)
DELETE /api/courts/{id} (admin only)
```

### Booking Management
```
GET /api/bookings
GET /api/bookings/{id}
POST /api/bookings (create booking)
PUT /api/bookings/{id}
DELETE /api/bookings/{id}
```

---

## Configuration

### Backend Configuration
File: `PCM_Backend/appsettings.json`
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.\\SQLEXPRESS;Database=PCM_Database;Trusted_Connection=true;"
  },
  "Jwt": {
    "Key": "your-secret-key-here",
    "Issuer": "PCM",
    "Audience": "PCM_Users"
  }
}
```

### Frontend Configuration
File: `PCM_Mobile/lib/utils/app_config.dart`
```dart
const String baseUrl = 'http://localhost:5001';
const String apiVersion = '/api';
```

---

## Troubleshooting

### Backend Won't Start
```
Error: Failed to bind to address http://127.0.0.1:5001
Solution: Kill process on port 5001
Command: netstat -ano | find "5001"
         taskkill /PID <pid> /F
```

### Database Connection Failed
```
Error: Cannot open database 'PCM_Database'
Solution: Ensure SQL Server is running
Command: net start MSSQL$SQLEXPRESS
```

### Flutter Build Error
```
Error: Unable to locate Dart Plugins
Solution: Run flutter pub get
Command: cd PCM_Mobile && flutter pub get
```

### API Authentication Failed
```
Error: 401 Unauthorized
Solution: Ensure you're logged in with valid JWT
Action: Login again, token may have expired
```

---

## Performance Tips

1. **Pagination**: For large member lists, implement pagination
   ```dart
   getMembers({int page = 1, int pageSize = 10})
   ```

2. **Caching**: Member data is cached in provider
   - Clear cache after changes: `notifyListeners()`

3. **Lazy Loading**: Bookings load only when requested
   - Reduces initial load time

4. **Database Indexing**: Ensure indexing on:
   - `Members.Email`
   - `Bookings.MemberId`
   - `WalletTransactions.MemberId`

---

## Common Tasks

### Add a New Member (Admin)
- Currently: Use registration system
- Future: Add admin member creation form

### Deposit to Member Wallet
- Currently: Through separate wallet endpoint
- Future: Integrate into member detail dialog

### Cancel a Booking
- Available: `DELETE /api/bookings/{id}`
- Also removes related wallet transactions

### Export Member Report
- Currently: View individual members
- Future: Add CSV/Excel export functionality

---

## Support & Debugging

### Enable Debug Logging
**Flutter**:
```dart
// In api_service.dart
_dio.interceptors.add(LoggingInterceptor());
```

**Backend**:
```csharp
// In Program.cs
builder.Logging.SetMinimumLevel(LogLevel.Debug);
```

### Network Inspection
**Flutter Web**: 
- Open DevTools (F12)
- Network tab shows all API calls
- Check request/response bodies

**Backend**:
- Console output shows HTTP requests
- Enable SQL query logging for database calls

---

## Next Steps

1. ✅ **Completed**:
   - Member listing with wallet info
   - Booking history viewing
   - User booking creation
   - Admin member tracking

2. **Recommended Next**:
   - Add member statistics dashboard
   - Export member reports
   - Implement booking cancellation
   - Add wallet top-up functionality
   - Create tournament management for members

3. **Future Enhancements**:
   - Real-time wallet updates
   - Member ranking system
   - Booking notifications
   - Analytics & reporting

---

## Contact & Support

For issues or questions:
1. Check `INTEGRATION_TESTING_GUIDE.md` for testing procedures
2. Review `MEMBER_MANAGEMENT_IMPLEMENTATION.md` for technical details
3. Check backend logs for API errors
4. Check browser console (F12) for frontend errors
