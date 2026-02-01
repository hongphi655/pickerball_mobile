import 'package:flutter/material.dart';

class AdminMembersManagementScreen extends StatefulWidget {
  const AdminMembersManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminMembersManagementScreen> createState() =>
      _AdminMembersManagementScreenState();
}

class _AdminMembersManagementScreenState
    extends State<AdminMembersManagementScreen> {
  // Sample member data - replace with API call later
  final List<Map<String, dynamic>> members = [
    {
      'id': 1,
      'name': 'Nguyễn Văn A',
      'email': 'user1@example.com',
      'phone': '0123456789',
      'tier': 'Gold',
      'totalSpent': 5500000,
      'joinDate': '2025-06-15',
      'isActive': true,
    },
    {
      'id': 2,
      'name': 'Trần Thị B',
      'email': 'user2@example.com',
      'phone': '0987654321',
      'tier': 'Silver',
      'totalSpent': 2300000,
      'joinDate': '2025-08-20',
      'isActive': true,
    },
    {
      'id': 3,
      'name': 'Lê Văn C',
      'email': 'user3@example.com',
      'phone': '0912345678',
      'tier': 'Standard',
      'totalSpent': 800000,
      'joinDate': '2025-10-10',
      'isActive': true,
    },
    {
      'id': 4,
      'name': 'Phạm Thị D',
      'email': 'user4@example.com',
      'phone': '0934567890',
      'tier': 'Diamond',
      'totalSpent': 12000000,
      'joinDate': '2025-01-05',
      'isActive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Thành Viên'),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _MemberCard(member: member);
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;

  const _MemberCard({required this.member});

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Silver':
        return Colors.blue[300]!;
      case 'Gold':
        return Colors.amber[300]!;
      case 'Diamond':
        return Colors.purple[300]!;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['name'] ?? 'Không xác định',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member['email'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTierColor(member['tier']).withOpacity(0.2),
                    border: Border.all(color: _getTierColor(member['tier'])),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    member['tier'] ?? 'Standard',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getTierColor(member['tier']),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng chi tiêu',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        '₫${(member['totalSpent'] as int).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày tham gia',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        member['joinDate'] ?? 'N/A',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Trạng thái',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (member['isActive'] ?? false)
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        border: Border.all(
                          color: (member['isActive'] ?? false)
                              ? Colors.green
                              : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (member['isActive'] ?? false) ? 'Hoạt động' : 'Tắt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: (member['isActive'] ?? false)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showMemberDetailsDialog(null, member);
                  },
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Chi tiết'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetailsDialog(BuildContext? context, Map<String, dynamic> member) {
    showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: const Text('Thông Tin Thành Viên'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Tên:', member['name']),
              _buildDetailRow('Email:', member['email']),
              _buildDetailRow('Điện thoại:', member['phone']),
              _buildDetailRow('Hạng thành viên:', member['tier']),
              _buildDetailRow('Tổng chi tiêu:', '₫${member['totalSpent']}'),
              _buildDetailRow('Ngày tham gia:', member['joinDate']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
