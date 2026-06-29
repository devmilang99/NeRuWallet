import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

import 'flight_selection_screen.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _departureController;
  late TextEditingController _arrivalController;
  late TextEditingController _dateController;
  late TextEditingController _returnDateController;
  late TextEditingController _seatController;
  late TextEditingController _priceController;

  int _adults = 1;
  int _children = 0;

  bool _isRoundTrip = false;

  final List<String> _departments = [
    'Kathmandu (KTM)',
    'Pokhara (PKR)',
    'Bhairahawa (BHR)',
  ];
  final List<String> _arrivals = [
    'Delhi (DEL)',
    'Mumbai (BOM)',
    'Bangalore (BLR)',
  ];
  final List<String> _seatClasses = ['Economy', 'Premium Economy', 'Business'];

  @override
  void initState() {
    super.initState();
    _departureController = TextEditingController(text: _departments[0]);
    _arrivalController = TextEditingController(text: _arrivals[0]);
    _dateController = TextEditingController();
    _returnDateController = TextEditingController();
    _seatController = TextEditingController(text: _seatClasses[0]);
    _priceController = TextEditingController(text: '');
    _updatePrice();
  }

  void _updatePrice() {
    int basePrice = _seatController.text == 'Premium Economy'
        ? 11500
        : (_seatController.text == 'Business' ? 18000 : 8500);
    if (_isRoundTrip) basePrice = (basePrice * 1.8).round();
    int total = basePrice * (_adults + _children);
    _priceController.text = total.toString();
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _dateController.dispose();
    _returnDateController.dispose();
    _seatController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _selectDate(
    TextEditingController controller, {
    DateTime? firstDate,
  }) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  void _swapRoute() {
    setState(() {
      final temp = _departureController.text;
      _departureController.text = _arrivalController.text;
      _arrivalController.text = temp;
    });
  }

  void _initiateSearch() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightSelectionScreen(
            searchData: {
              'from': _departureController.text,
              'to': _arrivalController.text,
              'departureDate': _dateController.text,
              'returnDate': _isRoundTrip ? _returnDateController.text : null,
              'isRoundTrip': _isRoundTrip,
              'adults': _adults,
              'children': _children,
              'class': _seatController.text,
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const providerColor = Color(0xFF10B981);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Nepal Airways',
      children: [
        const SizedBox(height: 8),

        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[200],
                  borderRadius: AppTheme.radiusLarge,
                ),
                child: Row(
                  children: [
                    _buildTripTypeButton(
                      'One Way',
                      !_isRoundTrip,
                      isDark,
                      providerColor,
                    ),
                    _buildTripTypeButton(
                      'Round Trip',
                      _isRoundTrip,
                      isDark,
                      providerColor,
                    ),
                  ],
                ),
              ),

              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: AppTheme.radiusLarge,
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey[200]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        _routeInput(
                          label: 'From',
                          value: _departureController.text,
                          icon: Icons.flight_takeoff_rounded,
                          onTap: () => _showSelectionDialog(
                            'Departure City',
                            _departments,
                            (val) {
                              setState(() => _departureController.text = val);
                            },
                          ),
                        ),
                        const Divider(height: 1, indent: 60),
                        _routeInput(
                          label: 'To',
                          value: _arrivalController.text,
                          icon: Icons.flight_land_rounded,
                          onTap: () => _showSelectionDialog(
                            'Arrival City',
                            _arrivals,
                            (val) {
                              setState(() => _arrivalController.text = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    child: GestureDetector(
                      onTap: _swapRoute,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: providerColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: providerColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ).animate().rotate(duration: 300.ms),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Passengers',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCounter(
                      'Adults',
                      '12+ years',
                      _adults,
                      (val) => setState(() => _adults = val),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounter(
                      'Children',
                      '2-12 years',
                      _children,
                      (val) => setState(() => _children = val),
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ServiceInputSection(
                      label: 'Departure Date',
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(_dateController),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_month_rounded),
                          hintText: 'Date',
                        ),
                        validator: (value) =>
                            (value?.isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                  ),
                  if (_isRoundTrip) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ServiceInputSection(
                        label: 'Return Date',
                        child: TextFormField(
                          controller: _returnDateController,
                          readOnly: true,
                          onTap: () => _selectDate(_returnDateController),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.event_repeat_rounded),
                            hintText: 'Date',
                          ),
                          validator: (value) =>
                              (value?.isEmpty ?? true) ? 'Required' : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Travel Class',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: _seatClasses.map((sClass) {
                  final isSelected = _seatController.text == sClass;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _seatController.text = sClass;
                        _updatePrice();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? providerColor
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey[100]),
                        borderRadius: AppTheme.radiusMedium,
                        border: Border.all(
                          color: isSelected
                              ? providerColor
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        sClass,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _initiateSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: providerColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLarge,
                  ),
                  elevation: 8,
                  shadowColor: providerColor.withValues(alpha: 0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Search Flights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().shimmer(delay: 2.seconds, duration: 1.5.seconds),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildTripTypeButton(
    String label,
    bool isSelected,
    bool isDark,
    Color color,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isRoundTrip = label == 'Round Trip';
            _updatePrice();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white)
                : Colors.transparent,
            borderRadius: AppTheme.radiusLarge,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: isSelected
                  ? color
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _routeInput({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF10B981)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(
    String title,
    String subtitle,
    int value,
    Function(int) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _counterButton(Icons.remove, () {
                if (title == 'Adults' && value > 1) {
                  onChanged(value - 1);
                  _updatePrice();
                }
                if (title == 'Children' && value > 0) {
                  onChanged(value - 1);
                  _updatePrice();
                }
              }, isDark),
              Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _counterButton(Icons.add, () {
                onChanged(value + 1);
                _updatePrice();
              }, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void _showSelectionDialog(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(options[index]),
                  onTap: () {
                    onSelect(options[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
