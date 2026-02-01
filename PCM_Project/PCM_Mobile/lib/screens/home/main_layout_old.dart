import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../utils/app_config.dart';

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
      context.read<CourtProvider>().getCourts();
      context.read<TournamentProvider>().getTournaments();
      context.read<WalletProvider>().getBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: [
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
      body: _buildBody(),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final isAdmin = authProvider.currentUser?.roles.contains('Admin') ?? false;
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavigationTap,
            selectedItemColor: Colors.purple[400],
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: isAdmin
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month, size: 22),
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
                      icon: Icon(Icons.admin_panel_settings, size: 22),
                      label: 'Admin',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person, size: 22),
                      label: 'Hồ sơ',
                    ),
                  ]
                : const [
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
        },
      ),
    );
  }

  Widget _buildBody() {
    final isAdmin = context.read<AuthProvider>().currentUser?.roles.contains('Admin') ?? false;
    if (isAdmin) {
      // Admin: Đặt sân (0), Giải đấu (1), Ví (2), Admin (3), Hồ sơ (4)
      switch (_selectedIndex) {
        case 0:
          return _navigateToBookings();
        case 1:
          return _navigateToTournaments();
        case 2:
          return _navigateToWallet();
        case 3:
          return _navigateToAdmin();
        case 4:
          return _navigateToProfile();
        default:
          return _navigateToBookings();
      }
    } else {
      // User: Đặt sân (0), Ví (1), Hồ sơ (2)
      switch (_selectedIndex) {
        case 0:
          return _navigateToBookings();
        case 1:
          return _navigateToWallet();
        case 2:
          return _navigateToProfile();
        default:
          return _navigateToBookings();
      }
    }
  }

  void _onNavigationTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _navigateToAdmin() {
    context.go('/home/admin');
    return const SizedBox();
  }

  Widget _navigateToBookings() {
    context.go('/home/bookings');
    return const SizedBox();
  }

  Widget _navigateToTournaments() {
    context.go('/home/tournaments');
    return const SizedBox();
  }

  Widget _navigateToWallet() {
    context.go('/home/wallet');
    return const SizedBox();
  }

  Widget _navigateToProfile() {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  authProvider.currentUser?.member?.fullName ?? 'Unknown',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(authProvider.currentUser?.email ?? ''),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    authProvider.logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
