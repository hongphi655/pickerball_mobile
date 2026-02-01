import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class ApproveDepositsScreen extends StatefulWidget {
  const ApproveDepositsScreen({Key? key}) : super(key: key);

  @override
  State<ApproveDepositsScreen> createState() => _ApproveDepositsScreenState();
}

class _ApproveDepositsScreenState extends State<ApproveDepositsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WalletProvider>().getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt Nạp Tiền')),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          if (walletProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter only pending transactions
          final pendingTransactions = walletProvider.transactions
              .where((tx) => tx.status == 'Pending')
              .toList();

          if (pendingTransactions.isEmpty) {
            return const Center(
              child: Text('Không có yêu cầu nạp tiền chờ duyệt'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingTransactions.length,
            itemBuilder: (context, index) {
              final tx = pendingTransactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Người dùng: ${tx.type}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Số tiền: ₫${tx.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ngày: ${tx.createdDate.toString().substring(0, 10)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Chip(
                            label: const Text('Chờ duyệt'),
                            backgroundColor: Colors.orange[100],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (tx.description != null && tx.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ghi chú:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(tx.description ?? ''),
                            const SizedBox(height: 16),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Từ chối'),
                                  content: const Text('Từ chối nạp tiền này?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // TODO: Implement reject endpoint in provider
                                        await context.read<WalletProvider>().rejectDeposit(tx.id);
                                        if (mounted) Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Từ chối'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Từ chối'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Duyệt nạp tiền'),
                                  content: Text('Duyệt nạp tiền ₫${tx.amount.toStringAsFixed(0)}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // TODO: Implement approve endpoint in provider
                                        await context.read<WalletProvider>().approveDeposit(tx.id);
                                        if (mounted) Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Duyệt'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Duyệt'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
