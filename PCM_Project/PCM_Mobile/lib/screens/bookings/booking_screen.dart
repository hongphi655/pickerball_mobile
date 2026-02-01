import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int? _selectedCourtId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtProvider>().getCourts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt Sân')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn Sân', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Consumer<CourtProvider>(
              builder: (context, courtProvider, _) {
                if (courtProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (courtProvider.courts.isEmpty) {
                  return const Text('Không có sân nào');
                }
                return DropdownButton<int>(
                  value: _selectedCourtId,
                  hint: const Text('Chọn sân'),
                  isExpanded: true,
                  items: courtProvider.courts
                      .map((court) => DropdownMenuItem(
                            value: court.id,
                            child: Text('${court.name} - ₫${court.pricePerHour.toStringAsFixed(0)}/giờ'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCourtId = value),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Chọn Ngày', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Chọn ngày'
                      : _selectedDate.toString().substring(0, 10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Giờ Bắt Đầu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _selectedStartTime = time);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedStartTime == null
                      ? 'Chọn giờ'
                      : _selectedStartTime!.format(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Giờ Kết Thúc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _selectedEndTime = time);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedEndTime == null
                      ? 'Chọn giờ'
                      : _selectedEndTime!.format(context),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Consumer<BookingProvider>(
              builder: (context, bookingProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: bookingProvider.isLoading
                        ? null
                        : () async {
                            if (_selectedCourtId == null || _selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng chọn đầy đủ thông tin')),
                              );
                              return;
                            }

                            final startDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedStartTime!.hour,
                              _selectedStartTime!.minute,
                            );

                            final endDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedEndTime!.hour,
                              _selectedEndTime!.minute,
                            );

                            final success = await bookingProvider.createBooking(
                              _selectedCourtId!,
                              startDateTime,
                              endDateTime,
                            );

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đặt sân thành công')),
                              );
                              Navigator.pop(context);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    bookingProvider.errorMessage ?? 'Đặt sân thất bại',
                                  ),
                                ),
                              );
                            }
                          },
                    child: bookingProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Đặt Sân'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
