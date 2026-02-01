import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import 'manage_courts_screen.dart';
import 'approve_deposits_screen.dart';
import 'manage_members_screen.dart';
import 'create_tournament_screen.dart';
import 'revenue_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isAdmin = authProvider.currentUser?.roles.contains('Admin') ?? false;
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Unauthorized')),
            body: const Center(
              child: Text('Bạn không có quyền truy cập trang này'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(title: const Text('Bảng điều khiển Admin')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quản lý CLB',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Admin Functions
                _buildAdminCard(
                  title: 'Quản lý Sân',
                  icon: Icons.sports_tennis,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageCourtsScreen()),
                    );
                  },
                ),
                _buildAdminCard(
                  title: 'Duyệt Nạp Tiền',
                  icon: Icons.account_balance_wallet,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ApproveDepositsScreen()),
                    );
                  },
                ),
                _buildAdminCard(
                  title: 'Xem Doanh Thu',
                  icon: Icons.trending_up,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RevenueScreen()),
                    );
                  },
                ),
                _buildAdminCard(
                  title: 'Quản lý Thành Viên',
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageMembersScreen()),
                    );
                  },
                ),
                _buildAdminCard(
                  title: 'Tạo Giải Đấu',
                  icon: Icons.sports_basketball,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateTournamentScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.purple),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
