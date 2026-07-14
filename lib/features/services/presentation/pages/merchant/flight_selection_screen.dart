import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

import 'passenger_details_screen.dart';

class FlightSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> searchData;

  const FlightSelectionScreen({super.key, required this.searchData});

  @override
  State<FlightSelectionScreen> createState() => _FlightSelectionScreenState();
}

class _FlightSelectionScreenState extends State<FlightSelectionScreen> {
  double _maxPrice = 25000;
  final List<String> _selectedAirlines = [];
  final List<String> _selectedPlanes = [];

  final List<String> _airlines = [
    'Nepal Airways',
    'Himalaya Airlines',
    'Buddha Air',
    'Yeti Airlines',
  ];
  final List<String> _planes = [
    'Airbus A320',
    'Boeing 737',
    'ATR 72',
    'Bombardier Q400',
  ];

  late List<Map<String, dynamic>> _flights;

  @override
  void initState() {
    super.initState();
    // Generate dummy flights
    _flights = List.generate(10, (index) {
      final airline = _airlines[index % _airlines.length];
      final plane = _planes[index % _planes.length];
      final price = 5000 + (index * 1500);
      return {
        'airline': airline,
        'plane': plane,
        'price': price,
        'departure': '08:${(index * 5).toString().padLeft(2, '0')} AM',
        'arrival': '10:${(index * 5 + 30).toString().padLeft(2, '0')} AM',
        'duration': '2h ${(index * 5) % 60}m',
        'flightNumber': 'NA-${100 + index}',
      };
    });
  }

  List<Map<String, dynamic>> get _filteredFlights {
    return _flights.where((f) {
      final priceMatch = f['price'] <= _maxPrice;
      final airlineMatch =
          _selectedAirlines.isEmpty || _selectedAirlines.contains(f['airline']);
      final planeMatch =
          _selectedPlanes.isEmpty || _selectedPlanes.contains(f['plane']);
      return priceMatch && airlineMatch && planeMatch;
    }).toList();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Max Price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _maxPrice,
                min: 5000,
                max: 30000,
                divisions: 25,
                activeColor: const Color(0xFF10B981),
                label: 'Rs. ${_maxPrice.round()}',
                onChanged: (val) {
                  setModalState(() => _maxPrice = val);
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Airlines',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _airlines.map((a) {
                  final isSelected = _selectedAirlines.contains(a);
                  return FilterChip(
                    label: Text(
                      a,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF10B981),
                    onSelected: (val) {
                      setModalState(() {
                        val
                            ? _selectedAirlines.add(a)
                            : _selectedAirlines.remove(a);
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Planes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _planes.map((p) {
                  final isSelected = _selectedPlanes.contains(p);
                  return FilterChip(
                    label: Text(
                      p,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF10B981),
                    onSelected: (val) {
                      setModalState(() {
                        val
                            ? _selectedPlanes.add(p)
                            : _selectedPlanes.remove(p);
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLarge,
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = const Color(0xFF10B981);

    return BaseServicePage(
      title: 'Select Flight',
      actions: [
        IconButton(
          onPressed: _showFilters,
          icon: const Icon(Icons.filter_list_rounded),
        ),
      ],
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppTheme.radiusLarge,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.searchData['from']} to ${widget.searchData['to']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.searchData['departureDate']} • ${widget.searchData['adults']} Adult, ${widget.searchData['children']} Child',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.searchData['class'],
                textAlign: TextAlign.end,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_filteredFlights.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 48),
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No flights match your filters',
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _maxPrice = 25000;
                    _selectedAirlines.clear();
                    _selectedPlanes.clear();
                  }),
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredFlights.length,
            itemBuilder: (context, index) {
              final flight = _filteredFlights[index];
              return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: AppTheme.radiusLarge,
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey[200]!,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerDetailsScreen(
                              searchData: widget.searchData,
                              flightData: flight,
                            ),
                          ),
                        );
                      },
                      borderRadius: AppTheme.radiusLarge,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: AppTheme.radiusSmall,
                                        ),
                                        child: Icon(
                                          Icons.flight_rounded,
                                          color: color,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          flight['airline'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Rs. ${flight['price']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      flight['departure'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      widget.searchData['from']
                                          .split('(')
                                          .last
                                          .replaceAll(')', ''),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      flight['duration'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Container(
                                      width: 80,
                                      height: 1,
                                      color: Colors.grey[300],
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                    ),
                                    Icon(
                                      Icons.flight_takeoff_rounded,
                                      size: 14,
                                      color: color.withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      flight['arrival'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      widget.searchData['to']
                                          .split('(')
                                          .last
                                          .replaceAll(')', ''),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    flight['plane'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Non-stop',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (index * 100).ms)
                  .slideX(begin: 0.1, end: 0);
            },
          ),
      ],
    );
  }
}
