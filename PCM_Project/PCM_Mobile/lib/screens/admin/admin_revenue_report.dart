import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminRevenueReportScreen extends StatefulWidget {
  const AdminRevenueReportScreen({Key? key}) : super(key: key);

  @override
  State<AdminRevenueReportScreen> createState() =>
      _AdminRevenueReportScreenState();
}

class _AdminRevenueReportScreenState extends State<AdminRevenueReportScreen> {
  // Sample data - replace with API call later
  final List<Map<String, dynamic>> monthlyRevenue = [
    {'month': 'Jan', 'revenue': 3500000, 'transactions': 45},
    {'month': 'Feb', 'revenue': 4200000, 'transactions': 52},
    {'month': 'Mar', 'revenue': 5100000, 'transactions': 61},
    {'month': 'Apr', 'revenue': 4800000, 'transactions': 58},
    {'month': 'May', 'revenue': 6200000, 'transactions': 72},
    {'month': 'Jun', 'revenue': 7100000, 'transactions': 85},
  ];

  @override
  Widget build(BuildContext context) {
    final totalRevenue =
        monthlyRevenue.fold<double>(0, (sum, item) => sum + (item['revenue'] as int));
    final totalTransactions =
        monthlyRevenue.fold<int>(0, (sum, item) => sum + (item['transactions'] as int));
    final avgMonthly = totalRevenue / monthlyRevenue.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo Doanh Thu'),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Tổng Doanh Thu',
                    value: '₫${(totalRevenue / 1000000).toStringAsFixed(1)}M',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Giao Dịch',
                    value: '$totalTransactions',
                    icon: Icons.receipt,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Trung Bình/Tháng',
                    value: '₫${(avgMonthly / 1000000).toStringAsFixed(1)}M',
                    icon: Icons.bar_chart,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Tháng Tốt Nhất',
                    value: '₫${(7100000 / 1000000).toStringAsFixed(1)}M',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Revenue Chart
            const Text(
              'Doanh Thu 6 Tháng Gần Đây',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: 8000000,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '₫${(rod.toY / 1000000).toStringAsFixed(1)}M',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₫${(value / 1000000).toStringAsFixed(0)}M',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    monthlyRevenue.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (monthlyRevenue[index]['revenue'] as int).toDouble(),
                          color: Colors.indigo[400],
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Detailed Revenue Table
            const Text(
              'Chi Tiết Doanh Thu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tháng',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Doanh Thu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'GD',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // Table Rows
                  ...List.generate(
                    monthlyRevenue.length,
                    (index) {
                      final item = monthlyRevenue[index];
                      final isLast = index == monthlyRevenue.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['month']),
                                Text(
                                  '₫${(item['revenue'] as int).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text('${item['transactions']}'),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(height: 1, color: Colors.grey[300]),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Revenue Sources
            const Text(
              'Nguồn Doanh Thu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _RevenueSourceCard(
                    title: 'Đặt Sân',
                    amount: 28500000,
                    percentage: 63,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RevenueSourceCard(
                    title: 'Nạp Tiền',
                    amount: 16700000,
                    percentage: 37,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueSourceCard extends StatelessWidget {
  final String title;
  final int amount;
  final int percentage;
  final Color color;

  const _RevenueSourceCard({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Text(
              '₫${(amount / 1000000).toStringAsFixed(1)}M',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
