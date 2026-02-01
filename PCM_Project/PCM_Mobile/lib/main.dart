import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_config.dart';
import 'utils/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/main_layout.dart';
import 'screens/bookings/bookings_screen.dart';
import 'screens/tournaments/tournaments_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/bookings/admin_bookings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
        ChangeNotifierProvider(create: (_) => CourtProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: AppConfig.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  redirect: (context, state) async {
    final authProvider = context.read<AuthProvider>();

    // Only check login status on auth routes, not on every navigation
    final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
    final isValidToken = authProvider.isTokenValid;
    
    // If user is already logged in, check if auth is still valid
    if (isValidToken) {
      // Block access to admin route if not in Admin role
      if (state.matchedLocation == '/home/admin') {
        final roles = authProvider.currentUser?.roles ?? [];
        if (!roles.contains('Admin')) {
          return '/home';
        }
      }
      
      if (isAuthRoute) {
        return '/home';
      }
    } else {
      // Not logged in
      if (!isAuthRoute) {
        // Try to restore from token one more time before redirecting
        await authProvider.checkLoginStatus();
        if (authProvider.isTokenValid) {
          // Successfully restored, allow navigation
          return null;
        }
        return '/login';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainLayout(),
      routes: [
        GoRoute(
          path: 'bookings',
          builder: (context, state) {
            final authProvider = context.read<AuthProvider>();
            final isAdmin = authProvider.currentUser?.roles.contains('Admin') ?? false;
            return isAdmin ? const AdminBookingsScreen() : const BookingsScreen();
          },
        ),
        GoRoute(
          path: 'tournaments',
          builder: (context, state) => const TournamentsScreen(),
        ),
        GoRoute(
          path: 'wallet',
          builder: (context, state) => const WalletScreen(),
        ),
        GoRoute(
          path: 'admin',
          builder: (context, state) => const AdminDashboard(),
        ),
      ],
    ),
  ],
  initialLocation: '/home',
);
