import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({Key? key}) : super(key: key);

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MemberProvider>().getMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Thành Viên')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thành viên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, memberProvider, _) {
                if (memberProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (memberProvider.members.isEmpty) {
                  return const Center(child: Text('Không có thành viên nào'));
                }

                return ListView.builder(
                  itemCount: memberProvider.members.length,
                  itemBuilder: (context, index) {
                    final member = memberProvider.members[index];
                    return ListTile(
                      title: Text(member.fullName),
                      subtitle: Text('${member.email ?? "N/A"} | Wallet: ₫${member.walletBalance.toStringAsFixed(0)}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Show member details
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
