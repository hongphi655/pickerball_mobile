import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class AdminCourtsManagementScreen extends StatefulWidget {
  const AdminCourtsManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminCourtsManagementScreen> createState() =>
      _AdminCourtsManagementScreenState();
}

class _AdminCourtsManagementScreenState
    extends State<AdminCourtsManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CourtProvider>().getCourts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Sân'),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: Consumer<CourtProvider>(
        builder: (context, courtProvider, _) {
          if (courtProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (courtProvider.courts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_tennis, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không có sân nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: courtProvider.courts.length,
            itemBuilder: (context, index) {
              final court = courtProvider.courts[index];
              return _CourtManagementCard(court: court);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          _showCreateCourtDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCourtDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo Sân Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sân'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Vị trí'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Giá/giờ (₫)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final location = locationController.text;
              final price = double.tryParse(priceController.text) ?? 0;

              if (name.isEmpty || location.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng điền tất cả thông tin')),
                );
                return;
              }

              final courtProvider = context.read<CourtProvider>();
              await courtProvider.createCourt(
                name,
                location,
                price,
              );

              if (context.mounted) {
                if (courtProvider.errorMessage != null && courtProvider.errorMessage!.contains('401')) {
                  // Auth error - let router handle redirect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session hết hạn. Vui lòng đăng nhập lại.')),
                  );
                } else if (courtProvider.errorMessage != null) {
                  // Other error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${courtProvider.errorMessage}')),
                  );
                } else {
                  // Success
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tạo sân thành công!')),
                  );
                }
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}

class _CourtManagementCard extends StatelessWidget {
  final dynamic court;

  const _CourtManagementCard({required this.court});

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
                        court.name ?? 'Không xác định',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              court.location ?? 'N/A',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (court.isActive ?? false)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: (court.isActive ?? false)
                          ? Colors.green
                          : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (court.isActive ?? false) ? 'Hoạt động' : 'Tắt',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (court.isActive ?? false)
                          ? Colors.green
                          : Colors.red,
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
                Row(
                  children: [
                    Icon(Icons.payments, size: 16, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      '₫${(court.pricePerHour ?? 0).toStringAsFixed(0)}/giờ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () {
                        _showEditCourtDialog(context, court);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        _showDeleteConfirmDialog(context, court);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCourtDialog(BuildContext context, court) {
    final nameController = TextEditingController(text: court.name);
    final locationController = TextEditingController(text: court.location);
    final descriptionController =
        TextEditingController(text: court.description);
    final priceController =
        TextEditingController(text: court.pricePerHour.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh Sửa Sân'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sân'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Vị trí'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Giá/giờ (₫)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final location = locationController.text;
              final price = double.tryParse(priceController.text) ?? 0;

              if (name.isEmpty || location.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng điền tất cả thông tin')),
                );
                return;
              }

              final courtProvider = context.read<CourtProvider>();
              await courtProvider.updateCourt(
                court.id,
                name,
                location,
                price,
              );

              if (context.mounted) {
                if (courtProvider.errorMessage != null && courtProvider.errorMessage!.contains('401')) {
                  // Auth error - let router handle redirect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session hết hạn. Vui lòng đăng nhập lại.')),
                  );
                } else if (courtProvider.errorMessage != null) {
                  // Other error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${courtProvider.errorMessage}')),
                  );
                } else {
                  // Success
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật sân thành công!')),
                  );
                }
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, court) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá sân "${court.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
               ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                 onPressed: () async {
                   await context.read<CourtProvider>().deleteCourt(court.id);
                   if (context.mounted) {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Xoá sân thành công!')),
                     );
                   }
                 },
                 child: const Text('Xoá'),
               ),
        ],
      ),
    );
  }
}
