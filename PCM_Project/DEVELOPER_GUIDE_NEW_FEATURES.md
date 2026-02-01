# 👨‍💻 PCM Mobile - Developer Guide (New Features)

## 📖 Tài liệu kỹ thuật

Ngày: 01/02/2026
Version: 1.0.0

---

## 🏗️ Architecture Overview

```
lib/
├── main.dart                    # App entry + Router + Providers
├── models/
│   ├── models.dart             # Entities (User, Court, Booking, etc)
│   └── notification_model.dart  # NEW: Notification model
├── providers/
│   ├── providers.dart           # AuthProvider, CourtProvider, etc
│   ├── notification_provider.dart # NEW: Notification management
│   └── theme_provider.dart      # NEW: Dark mode management
├── services/
│   └── api_service.dart         # HTTP + JWT interceptor
├── screens/
│   ├── auth/
│   ├── home/
│   ├── bookings/
│   ├── tournaments/
│   └── wallet/
├── widgets/
│   ├── court_search_filter.dart # NEW: Search & filter UI
│   └── notification_center.dart # NEW: Notification panel
└── utils/
    ├── app_config.dart
    └── app_theme.dart           # NEW: Theme definitions
```

---

## 1️⃣ Auth & Navigation Fix

### Problem:
```
main_layout.dart methods:
- _navigateToBookings() calls context.go() in build()
- Returns SizedBox() → blank screen
- Auth state not checked
```

### Solution:

**File:** `lib/screens/home/main_layout.dart`

```dart
// BEFORE (Wrong):
Widget _buildBody() {
  switch (_selectedIndex) {
    case 0:
      return const UserDashboard();
    case 1:
      return _navigateToBookings();  // ❌ calls context.go in build
    ...
  }
}

Widget _navigateToBookings() {
  context.go('/home/bookings');
  return const SizedBox();  // ❌ blank screen
}

// AFTER (Correct):
Widget _buildBody(bool isAdmin) {
  switch (_selectedIndex) {
    case 0:
      return const UserDashboard();
    case 1:
      return const BookingsScreen();  // ✅ direct widget
    ...
  }
}
```

### Key Changes:
1. Wrap MainLayout in `Consumer<AuthProvider>`
2. Check `!authProvider.isTokenValid` before build
3. Return actual screens instead of calling `context.go()`
4. Check auth in initState before loading data

### Code Example:
```dart
@override
Widget build(BuildContext context) {
  return Consumer<AuthProvider>(
    builder: (context, authProvider, _) {
      // Check if user is still logged in
      if (!authProvider.isTokenValid) {
        // Force logout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      // Build UI if logged in
      return Scaffold(...);
    },
  );
}
```

---

## 2️⃣ Search & Filter Feature

### Model Changes:

**File:** `lib/providers/providers.dart` (CourtProvider)

```dart
class CourtProvider extends ChangeNotifier {
  // Existing
  List<Court> _courts = [];
  
  // NEW
  List<Court> _filteredCourts = [];
  String _searchQuery = '';
  double? _maxPrice;
  double? _minRating;
  bool _sortByPrice = false;

  // Return filtered or original list
  List<Court> get courts => 
    _filteredCourts.isEmpty ? _courts : _filteredCourts;
  
  // Getters for current filter state
  String get searchQuery => _searchQuery;
  double? get maxPrice => _maxPrice;
  double? get minRating => _minRating;
  bool get sortByPrice => _sortByPrice;
}
```

### Methods:

```dart
// Search by name/location
void searchCourts(String query) {
  _searchQuery = query;
  _applyFilters();
  notifyListeners();
}

// Filter by max price
void filterByPrice(double? maxPrice) {
  _maxPrice = maxPrice;
  _applyFilters();
  notifyListeners();
}

// Filter by min rating
void filterByRating(double? minRating) {
  _minRating = minRating;
  _applyFilters();
  notifyListeners();
}

// Sort by price (asc)
void setSortByPrice(bool enable) {
  _sortByPrice = enable;
  _applyFilters();
  notifyListeners();
}

// Core filtering logic
void _applyFilters() {
  _filteredCourts = _courts.where((court) {
    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      if (!court.name.toLowerCase().contains(query) &&
          !(court.location?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }

    // Price filter
    if (_maxPrice != null && court.pricePerHour > _maxPrice!) {
      return false;
    }

    // Rating filter (future)
    // if (_minRating != null && (court.rating ?? 0) < _minRating!) {
    //   return false;
    // }

    return true;
  }).toList();

  // Sort by price if enabled
  if (_sortByPrice) {
    _filteredCourts.sort((a, b) => 
      a.pricePerHour.compareTo(b.pricePerHour)
    );
  }
}

// Clear all filters
void clearFilters() {
  _searchQuery = '';
  _maxPrice = null;
  _minRating = null;
  _sortByPrice = false;
  _filteredCourts = [];
  notifyListeners();
}
```

### UI Component:

**File:** `lib/widgets/court_search_filter.dart`

```dart
class CourtSearchFilter extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<double?> onPriceFilterChanged;
  final ValueChanged<double?> onRatingFilterChanged;
  final ValueChanged<bool> onSortByPriceChanged;
  
  const CourtSearchFilter({
    required this.onSearchChanged,
    required this.onPriceFilterChanged,
    required this.onRatingFilterChanged,
    required this.onSortByPriceChanged,
  });

  @override
  State<CourtSearchFilter> createState() => _CourtSearchFilterState();
}

// Usage in BookingsScreen:
Consumer<CourtProvider>(
  builder: (context, courtProvider, _) {
    return CourtSearchFilter(
      onSearchChanged: (query) {
        context.read<CourtProvider>().searchCourts(query);
      },
      onPriceFilterChanged: (price) {
        context.read<CourtProvider>().filterByPrice(price);
      },
      onRatingFilterChanged: (rating) {
        context.read<CourtProvider>().filterByRating(rating);
      },
      onSortByPriceChanged: (enable) {
        context.read<CourtProvider>().setSortByPrice(enable);
      },
    );
  },
)
```

---

## 3️⃣ Notification System

### Model:

**File:** `lib/models/notification_model.dart`

```dart
class Notification {
  final String id;
  final String title;
  final String message;
  final String type; // info, success, warning, error, booking, payment
  final DateTime timestamp;
  bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.data,
  });
}
```

### Provider:

**File:** `lib/providers/notification_provider.dart`

```dart
class NotificationProvider extends ChangeNotifier {
  final List<notification_model.Notification> _notifications = [];
  int _unreadCount = 0;

  // Add notification
  void addNotification({
    required String title,
    required String message,
    required String type,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    final notification = notification_model.Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      actionUrl: actionUrl,
      data: data,
    );
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  // Mark as read
  void markAsRead(String notificationId) { ... }
  void markAllAsRead() { ... }
  void deleteNotification(String notificationId) { ... }
  void clearAll() { ... }

  // Get notifications
  List<Notification> getUnreadNotifications() { ... }
  List<Notification> getNotificationsByType(String type) { ... }

  // Snackbar helper
  static void showSnackbarNotification({
    required BuildContext context,
    required String message,
    String type = 'info',
    Duration duration = const Duration(seconds: 3),
  }) { ... }
}
```

### Usage:

```dart
// Add notification
context.read<NotificationProvider>().addNotification(
  title: 'Đặt sân thành công',
  message: 'Sân A lúc 10:00 - 11:00',
  type: 'success',
);

// Mark as read
context.read<NotificationProvider>().markAsRead(notificationId);

// Quick snackbar
NotificationProvider.showSnackbarNotification(
  context: context,
  message: 'Thao tác thành công',
  type: 'success',
);

// Get unread
final unread = context.read<NotificationProvider>()
  .getUnreadNotifications();
```

### UI:

**File:** `lib/widgets/notification_center.dart`

```dart
// Icon with badge
Widget build(BuildContext context) {
  return Consumer<NotificationProvider>(
    builder: (context, notificationProvider, _) {
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _showNotificationPanel(context),
          ),
          if (notificationProvider.unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  notificationProvider.unreadCount > 9 
                    ? '9+' 
                    : '${notificationProvider.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

// Draggable panel
void _showNotificationPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const NotificationPanel(),
  );
}
```

---

## 4️⃣ Dark Mode & Theme

### Theme Data:

**File:** `lib/utils/app_theme.dart`

```dart
class AppTheme {
  // Light theme (default)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFDF5FB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[300],
        foregroundColor: Colors.white,
      ),
    ),
    // ... more
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
      ),
    ),
    // ... more
  );
}
```

### Provider:

**File:** `lib/providers/theme_provider.dart`

```dart
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
```

### Usage in main.dart:

```dart
@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      // ... other providers
    ],
    child: Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: AppConfig.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode 
            ? ThemeMode.dark 
            : ThemeMode.light,
          routerConfig: _router,
        );
      },
    ),
  );
}
```

### Toggle in Profile:

```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    return ListTile(
      title: const Text('Chế độ tối'),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.setDarkMode(value);
        },
      ),
    );
  },
)
```

---

## 📊 Performance Notes

### Caching Strategy:
```dart
// Court list cached 5 minutes
Future<void> getCourts({bool forceRefresh = false}) async {
  if (!forceRefresh && _lastFetchTime != null && 
      DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
      _courts.isNotEmpty) {
    return;
  }
  
  // Fetch from API...
  _lastFetchTime = DateTime.now();
}
```

### Filtering:
- Applied on client-side only
- No additional API calls
- O(n) complexity for filter, O(n log n) for sort

### Notifications:
- In-memory list
- No database queries
- Fast add/delete/read operations

---

## 🔐 Auth Flow

```
Login (username/password)
  ↓
API returns JWT token
  ↓
Store in FlutterSecureStorage
  ↓
Decode JWT to extract claims (roles, email)
  ↓
Set _isLoggedIn = true
Set _currentUser = User(...)
  ↓
isTokenValid = (_isLoggedIn && _currentUser != null && _token != null)
  ↓
If 401 error → _handleUnauthorized() → clear auth → redirect /login
```

---

## 🐛 Debugging Tips

### Enable logging:
```dart
// In api_service.dart
print('Request: $method $endpoint');
print('Response: $statusCode $response');
```

### Check auth state:
```dart
final auth = context.read<AuthProvider>();
print('isLoggedIn: ${auth.isLoggedIn}');
print('isTokenValid: ${auth.isTokenValid}');
print('currentUser: ${auth.currentUser?.username}');
print('roles: ${auth.currentUser?.roles}');
```

### Monitor notifications:
```dart
final notif = context.read<NotificationProvider>();
print('Notifications: ${notif.notifications.length}');
print('Unread: ${notif.unreadCount}');
```

### Theme debug:
```dart
final theme = context.read<ThemeProvider>();
print('isDarkMode: ${theme.isDarkMode}');
```

---

## 📦 Dependencies Used

```yaml
dio: ^5.3.1              # HTTP
provider: ^6.0.0         # State management
go_router: ^12.0.0       # Navigation
flutter_secure_storage:  # Token storage
shared_preferences:      # Theme preference
table_calendar:          # Calendar widget
fl_chart:                # Charts
signalr_netcore:         # Real-time
uuid: ^4.0.0             # Unique IDs
json_annotation:         # JSON serialization
```

---

## ✅ Quality Checklist

- ✅ No unused imports
- ✅ No unused variables
- ✅ Null-safe code
- ✅ Type-safe code
- ✅ Comments in Vietnamese
- ✅ Follows Dart conventions
- ✅ No deprecated usage (18 warnings are library deprecations, not code)

---

## 🚀 Next Development Steps

1. **Integrate BookingsScreen with search:**
   ```dart
   // In bookings_screen.dart
   Consumer<CourtProvider>(
     builder: (context, courtProvider, _) {
       return ListView(
         children: [
           CourtSearchFilter(...),
           ListView.builder(
             itemCount: courtProvider.courts.length,
             itemBuilder: (context, index) {
               final court = courtProvider.courts[index];
               // Build court card
             },
           ),
         ],
       );
     },
   )
   ```

2. **Add notifications to booking actions:**
   ```dart
   // When booking created
   context.read<NotificationProvider>().addNotification(
     title: 'Booking Confirmation',
     message: 'Your booking for ${court.name} is confirmed',
     type: 'booking',
     data: {'bookingId': booking.id},
   );
   ```

3. **Persist filtered state:**
   ```dart
   // Save last search/filter to SharedPreferences
   // Restore on next app launch
   ```

---

**Documentation Version:** 1.0.0
**Last Updated:** 01/02/2026
**Status:** ✅ Complete
