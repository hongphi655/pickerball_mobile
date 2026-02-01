import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class ManageCourtsScreen extends StatefulWidget {
  const ManageCourtsScreen({Key? key}) : super(key: key);

  @override
  State<ManageCourtsScreen> createState() => _ManageCourtsScreenState();
}

class _ManageCourtsScreenState extends State<ManageCourtsScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  int? _editingCourtId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CourtProvider>().getCourts();
    });
  }

  void _showCourtDialog({Map<String, dynamic>? court}) {
    _nameController.clear();
    _locationController.clear();
    _priceController.clear();
    _editingCourtId = null;

    if (court != null) {
      _nameController.text = court['name'] ?? '';
      _locationController.text = court['location'] ?? '';
      _priceController.text = court['hourlyRate'].toString();
      _editingCourtId = court['id'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingCourtId == null ? 'Thêm Sân' : 'Sửa Sân'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên sân',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Vị trí',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá theo giờ (₫)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text;
              final location = _locationController.text;
              final price = double.tryParse(_priceController.text);

              if (name.isEmpty || location.isEmpty || price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }

              final courtProvider = context.read<CourtProvider>();
              if (_editingCourtId == null) {
                // Create new court
                await courtProvider.createCourt(name, location, price);
              } else {
                // Update existing court
                await courtProvider.updateCourt(_editingCourtId!, name, location, price);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(_editingCourtId == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Sân')),
      body: Consumer<CourtProvider>(
        builder: (context, courtProvider, _) {
          if (courtProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courtProvider.courts.length,
            itemBuilder: (context, index) {
              final court = courtProvider.courts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(court.name),
                  subtitle: Text('${court.location ?? 'N/A'} • ₫${court.pricePerHour.toStringAsFixed(0)}/h'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => _showCourtDialog(court: {
                          'id': court.id,
                          'name': court.name,
                          'location': court.location,
                          'hourlyRate': court.pricePerHour,
                        }),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xóa Sân'),
                              content: const Text('Bạn chắc chắn muốn xóa sân này?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await context.read<CourtProvider>().deleteCourt(court.id);
                                    if (mounted) Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourtDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
