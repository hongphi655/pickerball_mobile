# PCM Mobile App - Flutter

## 📱 Project Overview

PCM Mobile is a Flutter-based mobile application for the Pickleball Club Management system. It connects to the ASP.NET Core Web API backend to provide real-time court booking, wallet management, and tournament participation features for Android and iOS devices.

## 🛠️ Technology Stack

- **Flutter**: 3.x
- **Dart**: 3.x
- **State Management**: Provider
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Storage**: flutter_secure_storage
- **Real-time**: SignalR
- **UI Components**: Material Design 3

## 📦 Prerequisites

- Flutter SDK 3.0 or later
- Dart SDK 3.0 or later
- Android SDK / Xcode (for iOS)
- Android Emulator or physical device
- ASP.NET Core backend API running

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd PCM_Mobile
flutter pub get
```

### 2. Configure API Endpoint
Edit `lib/utils/app_config.dart`:
```dart
static const String apiBaseUrl = 'https://localhost:5001';
// For Android Emulator: 'http://10.0.2.2:5001'
// For iOS Emulator: 'http://localhost:5001'
// For physical device: 'http://your-api-server:5001'
```

### 3. Run the App
```bash
# For Android Emulator
flutter run

# For iOS Simulator
flutter run -d ios

# For physical device
flutter run -d <device-id>
```

### 4. Build APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 5. Build IPA (iOS)
```bash
flutter build ios --release
```

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point with routing
├── models/
│   └── models.dart          # Data models (User, Booking, etc.)
├── services/
│   └── api_service.dart     # API client with Dio
├── providers/
│   └── providers.dart       # State management (Provider)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── main_layout.dart
│   │   └── home_screen.dart
│   ├── bookings/
│   │   └── bookings_screen.dart
│   ├── wallet/
│   │   └── wallet_screen.dart
│   ├── tournaments/
│   │   └── tournaments_screen.dart
│   └── admin/
│       └── admin_dashboard.dart
├── widgets/                 # Reusable widgets
└── utils/
    └── app_config.dart      # Configuration constants
```

## 🔐 Authentication Flow

1. **Login**: User enters credentials → `POST /api/auth/login`
2. **Token Storage**: JWT token saved in secure storage
3. **Auto-logout**: 401 response triggers logout and redirect to login screen
4. **Interceptor**: All requests automatically include `Authorization: Bearer {token}`

## 💻 Features

### 1. Authentication
- Login with username/password
- Registration with email validation
- JWT token management
- Automatic logout on token expiration

### 2. Dashboard
- Real-time wallet balance display
- Member tier and rank information
- Upcoming bookings preview
- Total spending display

### 3. Court Booking
- Calendar view with date selection
- Hourly slot availability
- One-click booking
- Booking cancellation with refund
- Real-time slot updates via SignalR

### 4. Wallet Management
- View current balance
- Request deposits with proof image
- Transaction history with filtering
- Automatic deduction on bookings
- Demo bank account display

### 5. Tournaments
- View all tournaments (Open, Ongoing, Finished)
- Tournament details and prize pool information
- One-click registration
- Automatic entry fee deduction
- Leave tournament with refund

### 6. Admin Panel (Basic)
- Access admin dashboard
- Manage courts (add/edit/delete)
- Approve wallet deposits
- View revenue reports
- Create tournaments

## 🔌 API Integration

### Base Configuration
```dart
// In ApiService singleton
static const String apiBaseUrl = 'https://localhost:5001';
static const String apiTimeout = '30';
```

### Example API Call
```dart
// Login
final response = await apiService.login(username, password);

// Create Booking
final booking = await apiService.createBooking(
  courtId: 1,
  startTime: DateTime.now(),
  endTime: DateTime.now().add(Duration(hours: 1)),
);

// Deposit
final transaction = await apiService.depositWallet(
  amount: 500000,
  proofImageUrl: 'path/to/image',
);
```

## 📊 State Management

### Providers Used
- **AuthProvider**: User authentication state
- **WalletProvider**: Wallet balance and transactions
- **BookingProvider**: Bookings and calendar
- **TournamentProvider**: Tournaments and registrations
- **CourtProvider**: Available courts

### Example Usage
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text(authProvider.currentUser?.member?.fullName ?? '');
  },
)
```

## 🌐 Real-time Updates

SignalR integration for real-time features:
```dart
// In future implementation
connection.on('ReceiveNotification', (message) {
  // Update UI with notification
});

connection.on('UpdateCalendar', (data) {
  // Refresh calendar view
});

connection.on('UpdateMatchScore', (matchId, score) {
  // Update match score in real-time
});
```

## 💳 Demo Bank Account

For testing wallet deposits:
- **Bank**: Techcombank
- **Account**: 0123456789
- **Name**: CLB Vợt Thủ Phố Núi

Note: This is demo data. In production, use actual payment gateway.

## 🐛 Common Issues

### API Connection Failed
- Check if backend API is running
- Verify API base URL in `app_config.dart`
- For Android emulator: Use `10.0.2.2` instead of `localhost`
- Ensure device can reach the API server

### Image Picker Not Working
- Android: Grant camera permissions in `AndroidManifest.xml`
- iOS: Add camera usage description in `Info.plist`

### Token Issues
- Clear app cache: `flutter clean`
- Delete secure storage: Reinstall app
- Check token expiration time in backend

### Calendar Not Showing
- Ensure `table_calendar` package is installed
- Check Flutter version compatibility

## 📸 Screenshots

### Login Screen
- Username/Password input
- Register link
- Remember password option

### Home Dashboard
- Wallet balance card
- Member info card
- Upcoming bookings list

### Booking Screen
- Court selection dropdown
- Calendar widget
- Hourly time slots
- Booking confirmation

### Wallet Screen
- Current balance
- Bank account details (demo)
- Deposit amount input
- Camera button for proof
- Transaction history list

### Tournament Screen
- Tournament cards with details
- Join/Leave button
- Entry fee and prize pool display
- Participant count

## 🚀 Future Enhancements

1. **SignalR Real-time**: Complete implementation for push notifications
2. **Biometric Login**: Face ID / Fingerprint authentication
3. **Offline Mode**: Cache data for offline access
4. **Push Notifications**: Firebase Cloud Messaging integration
5. **Match Brackets**: Visualize tournament brackets
6. **Chat**: In-app messaging for tournaments
7. **Statistics**: Player stats and performance analytics
8. **Dark Mode**: Theme switcher

## 📱 Testing

### Test Accounts
```
Admin:
- Username: admin
- Password: password123

Regular User:
- Username: user1
- Password: password123
```

### Test Scenarios
1. Login → View Dashboard → Check Balance
2. Book Court → Cancel Booking → Check Refund
3. Request Deposit → Await Admin Approval → Check Balance
4. Join Tournament → View Details → Leave Tournament

## 📝 Build & Deploy

### Release Build (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Release Build (iOS)
```bash
flutter build ios --release
# Use Xcode to upload to App Store
```

## ⚙️ Configuration for Production

1. Change `apiBaseUrl` to production URL
2. Increase JWT token expiration if needed
3. Add real payment gateway integration
4. Enable HTTPS only
5. Add proper error logging
6. Set up Firebase for push notifications
7. Configure sign release keys for APK

## 📞 Support

For issues:
1. Check Flutter version: `flutter --version`
2. Check pub packages: `flutter pub get`
3. Review error logs: `flutter logs`
4. Clean build: `flutter clean && flutter pub get`

## 📄 License

This project is part of the Mobile Programming course.

---

**Last Updated**: January 2026
**Developed for**: Pickleball Club Management System (Mobile Edition)
