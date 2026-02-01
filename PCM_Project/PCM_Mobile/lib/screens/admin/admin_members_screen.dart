import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class AdminMembersScreen extends StatefulWidget {
  const AdminMembersScreen({Key? key}) : super(key: key);

  @override
  State<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends State<AdminMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().getMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Thành Viên')),
      body: Consumer<MemberProvider>(
        builder: (context, memberProvider, _) {
          if (memberProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (memberProvider.members.isEmpty) {
            return const Center(child: Text('Không có thành viên nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: memberProvider.members.length,
            itemBuilder: (context, index) {
              final member = memberProvider.members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(member.fullName),
                  subtitle: Text('ID: ${member.id} | Email: ${member.email}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _showMemberDetail(context, member),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showMemberDetail(BuildContext context, dynamic member) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(member.fullName),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${member.id}'),
                Text('Email: ${member.email}'),
                Text('Ngày tham gia: ${member.joinDate.toString().substring(0, 10)}'),
                Text('Rank: ${member.rankLevel}'),
                Text('Tier: ${member.tier}'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Ví:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Số tiền: ₫${member.walletBalance.toStringAsFixed(0)}'),
                Text('Đã chi tiêu: ₫${member.totalSpent.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Thao tác:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<MemberProvider>().getMemberBookings(member.id);
                    Navigator.pop(c);
                    _showMemberBookings(context, member.id, member.fullName);
                  },
                  child: const Text('Xem Bookings'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showMemberBookings(BuildContext context, int memberId, String memberName) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Bookings của $memberName'),
        content: SizedBox(
          width: 400,
          child: Consumer<MemberProvider>(
            builder: (context, memberProvider, _) {
              if (memberProvider.memberBookings.isEmpty) {
                return const Text('Không có booking nào');
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: memberProvider.memberBookings
                      .map((booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sân: ${booking.court?.name ?? "N/A"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Thời gian: ${booking.startTime.toString().substring(0, 16)} - ${booking.endTime.toString().substring(11, 16)}'),
                                  Text('Tổng tiền: ₫${booking.totalPrice.toStringAsFixed(0)}'),
                                  Text('Trạng thái: ${booking.status}'),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
