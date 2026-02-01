import 'package:flutter/material.dart';

class CourtSearchFilter extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<double?> onPriceFilterChanged;
  final ValueChanged<double?> onRatingFilterChanged;
  final ValueChanged<bool> onSortByPriceChanged;

  const CourtSearchFilter({
    Key? key,
    required this.onSearchChanged,
    required this.onPriceFilterChanged,
    required this.onRatingFilterChanged,
    required this.onSortByPriceChanged,
  }) : super(key: key);

  @override
  State<CourtSearchFilter> createState() => _CourtSearchFilterState();
}

class _CourtSearchFilterState extends State<CourtSearchFilter> {
  final _searchController = TextEditingController();
  double? _maxPrice;
  double? _minRating;
  bool _sortByPrice = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sân...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                widget.onSearchChanged(value);
                setState(() {});
              },
            ),
          ),

          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá tối đa (₫)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Slider(
                        value: _maxPrice ?? 500000,
                        min: 0,
                        max: 1000000,
                        divisions: 20,
                        label: _maxPrice != null
                            ? '₫${(_maxPrice ?? 0).toStringAsFixed(0)}'
                            : 'Tất cả',
                        onChanged: (value) {
                          setState(() {
                            _maxPrice = value > 500000 ? value : null;
                          });
                          widget.onPriceFilterChanged(_maxPrice);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rating Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đánh giá tối thiểu',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _minRating = (index + 1).toDouble();
                          });
                          widget.onRatingFilterChanged(_minRating);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _minRating == (index + 1).toDouble()
                              ? Colors.orange
                              : Colors.grey[300],
                        ),
                        child: Text(
                          '${index + 1}⭐',
                          style: TextStyle(
                            color: _minRating == (index + 1).toDouble()
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Sort Option
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Sắp xếp theo giá (thấp → cao)'),
                    value: _sortByPrice,
                    onChanged: (value) {
                      setState(() {
                        _sortByPrice = value ?? false;
                      });
                      widget.onSortByPriceChanged(_sortByPrice);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Reset Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _maxPrice = null;
                  _minRating = null;
                  _sortByPrice = false;
                });
                widget.onSearchChanged('');
                widget.onPriceFilterChanged(null);
                widget.onRatingFilterChanged(null);
                widget.onSortByPriceChanged(false);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Đặt lại bộ lọc'),
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
