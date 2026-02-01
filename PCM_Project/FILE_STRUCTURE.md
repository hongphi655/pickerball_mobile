# Project File Structure & Organization

## Backend (ASP.NET Core 8)

```
PCM_Backend/
├── Program.cs                          # App startup, DI config, seeding
├── appsettings.json                    # DB connection, JWT config
├── PCM.API.csproj                      # Project file
│
├── Controllers/
│   ├── AuthController.cs               # Login, Register endpoints
│   ├── BookingsController.cs           # Booking CRUD (user + admin)
│   ├── CourtsController.cs             # Court management (admin only)
│   ├── WalletController.cs             # Deposit, balance, transactions
│   ├── TournamentsController.cs        # Tournament management
│   ├── AdminMembersController.cs       # Member management (admin)
│   └── DebugController.cs              # Debug endpoints
│
├── Models/
│   └── Entities.cs                     # EF Core entity models
│       ├── IdentityUser (extends)
│       ├── Member
│       ├── Court
│       ├── Booking
│       ├── Tournament
│       ├── TournamentParticipant
│       └── WalletTransaction
│
├── Data/
│   └── ApplicationDbContext.cs         # EF Core DbContext
│
├── Services/
│   ├── IAuthService.cs                 # Auth interface
│   ├── AuthService.cs                  # Login, Register, JWT generation
│   ├── BookingService.cs               # Booking business logic
│   ├── TournamentService.cs            # Tournament logic
│   └── WalletService.cs                # Wallet transaction logic
│
├── DTOs/
│   └── ApiDtos.cs                      # Request/Response DTOs
│       ├── LoginRequest/Response
│       ├── RegisterRequest
│       ├── UserInfoDto
│       ├── MemberDto
│       ├── CourtDto
│       ├── BookingDto
│       ├── TournamentDto
│       ├── WalletTransactionDto
│       └── ApiResponse<T>
│
└── Migrations/
    ├── 20260131115534_InitialCreate.cs
    ├── 20260131115534_InitialCreate.Designer.cs
    └── ApplicationDbContextModelSnapshot.cs
```

## Frontend (Flutter)

```
PCM_Mobile/
├── pubspec.yaml                        # Dependencies
├── analysis_options.yaml               # Lint rules
├── lib/
│   ├── main.dart                       # App entry, router, theme
│   │
│   ├── models/
│   │   └── models.dart                 # All data models
│   │       ├── User
│   │       ├── Member
│   │       ├── Court
│   │       ├── Booking
│   │       ├── Tournament
│   │       ├── WalletTransaction
│   │       └── ApiResponse
│   │
│   ├── providers/
│   │   └── providers.dart              # State management
│   │       ├── AuthProvider            # Login, Register, Logout
│   │       ├── CourtProvider           # Courts CRUD
│   │       ├── WalletProvider          # Wallet operations
│   │       ├── BookingProvider         # Booking operations
│   │       └── TournamentProvider      # Tournament operations
│   │
│   ├── services/
│   │   └── api_service.dart            # HTTP client, API calls
│   │
│   ├── utils/
│   │   └── app_config.dart             # Constants, config
│   │
│   ├── widgets/
│   │   └── (custom widgets for reuse)
│   │
│   └── screens/
│       ├── auth/
│       │   ├── login_screen.dart       # Login UI
│       │   └── register_screen.dart    # Register UI
│       │
│       ├── home/
│       │   ├── main_layout.dart        # Bottom nav, role-based routing
│       │   └── home_screen.dart        # Home/dashboard
│       │
│       ├── bookings/
│       │   └── bookings_screen.dart    # Court booking UI
│       │
│       ├── tournaments/
│       │   └── tournaments_screen.dart # Tournament list
│       │
│       ├── wallet/
│       │   └── wallet_screen.dart      # Balance, deposit, history
│       │
│       └── admin/
│           ├── admin_dashboard.dart    # Main admin menu
│           ├── manage_courts_screen.dart   # Court CRUD
│           ├── approve_deposits_screen.dart # Deposit approval
│           ├── manage_members_screen.dart  # Member management
│           ├── create_tournament_screen.dart # Tournament creation
│           └── revenue_screen.dart     # Revenue dashboard
│
├── assets/
│   ├── images/
│   └── icons/
│
└── build/                              # Build output (generated)
```

---

## Key Files by Functionality

### Authentication Flow
```
User Input (LoginScreen)
    ↓
ApiService.login() [HTTP POST]
    ↓
AuthService (backend) validates & returns JWT
    ↓
AuthProvider stores token + user data
    ↓
Router redirects to /home
    ↓
MainLayout reads role from AuthProvider
    ↓
Conditional UI rendering (3 tabs for user, 5 for admin)
```

### Court Management (Admin)
```
AdminDashboard → ManageCourtsScreen
    ↓
CourtProvider.createCourt/updateCourt/deleteCourt
    ↓
ApiService → CourtsController (backend)
    ↓
Authorization check [Authorize(Roles="Admin")]
    ↓
Court CRUD via Entity Framework
    ↓
Response back to UI
    ↓
CourtProvider updates _courts list
    ↓
UI rebuilds via notifyListeners()
```

### Deposit Approval (Admin)
```
AdminDashboard → ApproveDepositsScreen
    ↓
WalletProvider.getTransactions() loads pending deposits
    ↓
Admin taps "Approve" button
    ↓
WalletProvider.approveDeposit(transactionId)
    ↓
ApiService → WalletController.Approve (backend)
    ↓
Authorization check [Authorize(Roles="Admin,Treasurer")]
    ↓
Update transaction status, add balance to user wallet
    ↓
Response back
    ↓
UI refreshes transaction list
```

### Booking Flow
```
User taps Đặt sân
    ↓
BookingsScreen loads courts from CourtProvider
    ↓
User selects court → Calendar shows availability
    ↓
BookingsScreen.getCalendar() fetches booked times
    ↓
User selects time slot
    ↓
BookingProvider.createBooking()
    ↓
ApiService → BookingsController.Create (backend)
    ↓
Check court availability, deduct wallet balance
    ↓
Create Booking record
    ↓
Confirm message to user
```

---

## Architecture Patterns

### State Management
- **ChangeNotifier + Provider**: Clean, decoupled, easy to test
- Each provider manages one domain (Auth, Courts, Wallet, etc.)
- Providers communicate via context.read<>()

### API Communication
- **Singleton ApiService**: One instance per app lifetime
- **Interceptor Pattern**: Automatic JWT injection, error handling
- **DTO Objects**: Type-safe request/response mapping

### Navigation
- **GoRouter**: Modern routing with named routes and guards
- **Route Guards**: Redirect unauthorized access
- **Deep Linking**: Support for direct URL navigation

### Authorization
- **3-Level Security**:
  1. **Backend**: [Authorize] attributes on controllers
  2. **Frontend Router**: Guards prevent unauthorized navigation
  3. **Frontend UI**: Hide/show based on roles

### Data Flow
```
UI Layer (Screens)
    ↓
Provider Layer (State)
    ↓
Service Layer (ApiService)
    ↓
Network Layer (Dio HTTP Client)
    ↓
Backend API
    ↓ (responses)
Database (SQL Server)
```

---

## Dependency Injection

### Backend (Program.cs)
```csharp
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<BookingService>();
builder.Services.AddScoped<TournamentService>();
builder.Services.AddScoped<WalletService>();
```

### Frontend (Providers)
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => CourtProvider()),
    ChangeNotifierProvider(create: (_) => WalletProvider()),
    // ...
  ],
)
```

---

## Database Schema (Simplified)

```
AspNetUsers (Identity)
├── Id (PK)
├── UserName
├── Email
├── PasswordHash
└── ConcurrencyStamp

AspNetUserRoles
├── UserId (FK)
├── RoleId (FK)
└── Role Name: "Admin", "User", etc.

Members
├── Id (PK)
├── UserId (FK → AspNetUsers)
├── FullName
├── JoinDate
├── WalletBalance
├── Tier
└── TotalSpent

Courts
├── Id (PK)
├── Name
├── Location
├── HourlyRate
└── IsActive

Bookings
├── Id (PK)
├── CourtId (FK → Courts)
├── MemberId (FK → Members)
├── StartTime
├── EndTime
└── TotalPrice

Tournaments
├── Id (PK)
├── Name
├── Description
├── StartDate
├── EndDate
├── EntryFee
├── MaxParticipants
└── IsActive

WalletTransactions
├── Id (PK)
├── MemberId (FK → Members)
├── Type
├── Amount
├── Status (Pending, Approved, Rejected)
├── Description
└── CreatedDate
```

---

## Configuration Files

### appsettings.json (Backend)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=PCM_Database;..."
  },
  "Jwt": {
    "Secret": "long-random-string",
    "Issuer": "PCM.API",
    "Audience": "PCM.Mobile",
    "ExpirationMinutes": 1440
  }
}
```

### app_config.dart (Frontend)
```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:5006';
  static const String appName = 'PCM - CLB Pickleball';
  static const String appVersion = '1.0.0';
}
```

---

## Build & Deployment

### Backend Build
```bash
cd PCM_Backend
dotnet build
dotnet publish -c Release
```

### Frontend Build
```bash
cd PCM_Mobile
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web
```

---

## Testing Entry Points

- **Login**: lib/screens/auth/login_screen.dart
- **Admin Dashboard**: lib/screens/admin/admin_dashboard.dart
- **Court Management**: lib/screens/admin/manage_courts_screen.dart
- **Deposit Approval**: lib/screens/admin/approve_deposits_screen.dart
- **Revenue View**: lib/screens/admin/revenue_screen.dart
- **API Layer**: lib/services/api_service.dart (mock for tests)

---

**Total Files: ~50+ (including models, controllers, services)**  
**Lines of Code: ~4,000+ (backend + frontend)**  
**Languages: C#, Dart, SQL**  
**Framework: .NET 8 + Flutter**  

✅ Production Ready
