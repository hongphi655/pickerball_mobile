import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../admin/admin_courts_management.dart';
import '../admin/admin_members_management.dart';
import '../admin/create_tournament_screen.dart';
import '../admin/admin_revenue_report.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    
    final courtProvider = context.read<CourtProvider>();
    final memberProvider = context.read<MemberProvider>();
    
    try {
      await Future.wait([
        courtProvider.getCourts(forceRefresh: true),
        memberProvider.getMembers(forceRefresh: true),
      ]);
    } catch (e) {
      // Handle any errors during initialization
      if (mounted) {
        _showErrorDialog(context, 'Lỗi tải dữ liệu', e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    // Clean up message for display
    String cleanMessage = message
        .replaceAll('Exception: ', '')
        .replaceAll('AuthException: ', '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(cleanMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _initializeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo[400]!, Colors.indigo[700]!],
                ),

                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xin chào,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.currentUser?.username ?? 'Admin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chào mừng đến bảng điều khiển quản trị',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Stats Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thống kê hệ thống',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Courts Stats
                  Consumer<CourtProvider>(
                    builder: (context, courtProvider, _) {
                      if (courtProvider.isLoading) {
                        return const _StatCardSkeleton();
                      }
                      if (courtProvider.errorMessage != null) {
                        return _ErrorStatCard(
                          icon: Icons.sports_tennis,
                          title: 'Số Sân',
                          error: courtProvider.errorMessage!,
                          color: Colors.red,
                        );
                      }
                      return _StatCard(
                        icon: Icons.sports_tennis,
                        title: 'Số Sân',
                        value: courtProvider.courts.length.toString(),
                        subtitle: 'Tổng số sân',
                        color: Colors.blue,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Members Stats
                  Consumer<MemberProvider>(
                    builder: (context, memberProvider, _) {
                      if (memberProvider.isLoading) {
                        return const _StatCardSkeleton();
                      }
                      if (memberProvider.errorMessage != null) {
                        return _ErrorStatCard(
                          icon: Icons.people,
                          title: 'Thành viên',
                          error: memberProvider.errorMessage!,
                          color: Colors.red,
                        );
                      }
                      return _StatCard(
                        icon: Icons.people,
                        title: 'Thành viên',
                        value: memberProvider.members.length.toString(),
                        subtitle: 'Tổng người dùng',
                        color: Colors.green,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản lý',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AdminActionCard(
                    icon: Icons.sports_tennis,
                    title: 'Quản lý sân',
                    description: 'Thêm, sửa, xóa sân',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminCourtsManagementScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminActionCard(
                    icon: Icons.people_outline,
                    title: 'Quản lý thành viên',
                    description: 'Xem thông tin thành viên',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminMembersManagementScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminActionCard(
                    icon: Icons.emoji_events,
                    title: 'Tạo giải đấu',
                    description: 'Tạo và quản lý giải đấu mới',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTournamentScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminActionCard(
                    icon: Icons.assessment,
                    title: 'Báo cáo doanh thu',
                    description: 'Xem thống kê doanh thu',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRevenueReportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Recent Activity
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hoạt động gần đây',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _initializeData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer2<MemberProvider, CourtProvider>(
                    builder: (context, memberProvider, courtProvider, _) {
                      final hasData = memberProvider.members.isNotEmpty || courtProvider.courts.isNotEmpty;
                      
                      if (memberProvider.isLoading || courtProvider.isLoading) {
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!hasData) {
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('Không có hoạt động nào'),
                            ),
                          ),
                        );
                      }

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue[100],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        [Icons.person_add, Icons.attach_money, Icons.sports_tennis, Icons.check_circle][index % 4],
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          [
                                            'Thành viên mới đăng ký',
                                            'Nạp tiền: ₫500.000',
                                            'Thêm sân mới',
                                            'Đặt sân được xác nhận'
                                          ][index],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          memberProvider.members.isNotEmpty && index < memberProvider.members.length
                                              ? memberProvider.members[index].fullName
                                              : [
                                                  'Nguyễn Thành Long',
                                                  'Trần Minh Hoàng',
                                                  'Sân Hoàn Kiếm',
                                                  'Bảo Linh - Sân Mỹ Đình'
                                                ][index],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    [
                                      '2 giờ trước',
                                      '4 giờ trước',
                                      '1 ngày trước',
                                      '2 ngày trước'
                                    ][index],
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 60,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.05),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String error;
  final Color color;

  const _ErrorStatCard({
    required this.icon,
    required this.title,
    required this.error,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String cleanError = error
        .replaceAll('Exception: ', '')
        .replaceAll('AuthException: ', '')
        .split('\n')
        .first; // Get only first line
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cleanError,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
