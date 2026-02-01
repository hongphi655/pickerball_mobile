import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_config.dart';
import '../../widgets/notification_center.dart';
import 'user_dashboard.dart';
import 'admin_dashboard.dart';
import '../bookings/bookings_screen.dart';
import '../bookings/admin_bookings_screen.dart';
import '../tournaments/tournaments_screen.dart';
import '../wallet/wallet_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data on app start
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      // Only load if user is logged in
      if (auth.isTokenValid) {
        context.read<CourtProvider>().getCourts();
        context.read<TournamentProvider>().getTournaments();
        context.read<WalletProvider>().getBalance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if user is still logged in
        if (!authProvider.isTokenValid) {
          // Force logout and redirect
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAdmin = authProvider.currentUser?.roles.contains('Admin') ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppConfig.appName),
            elevation: 0,
            actions: [
              const NotificationCenter(),
              if (!isAdmin)
                Consumer<WalletProvider>(
                  builder: (context, walletProvider, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          '₫ ${walletProvider.balance.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: _buildBody(isAdmin),
          bottomNavigationBar: _buildNavigationBar(isAdmin),
        );
      },
    );
  }

  Widget _buildBody(bool isAdmin) {
    if (isAdmin) {
      // Admin navigation
      switch (_selectedIndex) {
        case 0:
          return const AdminDashboard();
        case 1:
          return const AdminBookingsScreen();
        case 2:
          return const TournamentsScreen();
        case 3:
          return const WalletScreen();
        case 4:
          return _buildProfileScreen();
        default:
          return const AdminDashboard();
      }
    } else {
      // User navigation
      switch (_selectedIndex) {
        case 0:
          return const UserDashboard();
        case 1:
          return const BookingsScreen();
        case 2:
          return const WalletScreen();
        case 3:
          return _buildProfileScreen();
        default:
          return const UserDashboard();
      }
    }
  }

  Widget _buildNavigationBar(bool isAdmin) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavigationTap,
      selectedItemColor: Colors.purple[400],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: isAdmin
          ? const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 22),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list, size: 22),
                label: 'Đặt sân',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_tennis, size: 22),
                label: 'Giải đấu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet, size: 22),
                label: 'Ví',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 22),
                label: 'Hồ sơ',
              ),
            ]
          : const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 22),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month, size: 22),
                label: 'Đặt sân',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet, size: 22),
                label: 'Ví',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 22),
                label: 'Hồ sơ',
              ),
            ],
    );
  }

  void _onNavigationTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle, size: 80, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.currentUser?.member?.fullName ?? 'Unknown',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(authProvider.currentUser?.email ?? ''),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 12),
                child: Text(
                  'Cài đặt',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              // Dark Mode Toggle
              Card(
                child: ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Chế độ tối'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.setDarkMode(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Notifications Toggle
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Thông báo'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification preference
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 12),
                child: Text(
                  'Tài khoản',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Thông tin ứng dụng'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'PCM',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 PCM. All rights reserved.',
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              authProvider.logout();
                              context.go('/login');
                            },
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
