import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:intl/intl.dart';
import 'bus_ticket_screen.dart';

class BusBookingScreen extends StatefulWidget {
  const BusBookingScreen({super.key});

  @override
  State<BusBookingScreen> createState() => _BusBookingScreenState();
}

class _BusBookingScreenState extends State<BusBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _passengerNameController;
  late TextEditingController _passengerAgeController;
  late TextEditingController _passengerIDController;
  late TextEditingController _departureController;
  late TextEditingController _arrivalController;
  late TextEditingController _dateController;
  late TextEditingController _seatController;
  late TextEditingController _priceController;

  final List<String> _departures = ['Kathmandu', 'Pokhara', 'Bhairahawa'];
  final List<String> _arrivals = ['Chitwan', 'Narayanghat', 'Ilam'];
  final List<String> _seatTypes = [
    'First Seat',
    'Semi-Sleeper',
    'Sleeper',
    'Window Seat',
  ];

  @override
  void initState() {
    super.initState();
    _passengerNameController = TextEditingController();
    _passengerAgeController = TextEditingController();
    _passengerIDController = TextEditingController();
    _departureController = TextEditingController(text: _departures[0]);
    _arrivalController = TextEditingController(text: _arrivals[0]);
    _dateController = TextEditingController();
    _seatController = TextEditingController(text: _seatTypes[1]);
    _priceController = TextEditingController(text: '650');
  }

  @override
  void dispose() {
    _passengerNameController.dispose();
    _passengerAgeController.dispose();
    _passengerIDController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    _dateController.dispose();
    _seatController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 20,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFEC4899)),
              const SizedBox(height: 32),
              const Text(
                'Confirming Bus Route...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Securing your preferred seat. One moment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context);

        Map<String, dynamic> ticketData = {
          'ticketNumber':
              'BUS${DateTime.now().millisecondsSinceEpoch % 1000000}',
          'busCompany': 'Nepal Bus Service',
          'busLine':
              '${_departureController.text} - ${_arrivalController.text}',
          'busNumber':
              'NBS-${(DateTime.now().millisecond % 100 + 100).toString()}',
          'departureCity': _departureController.text,
          'arrivalCity': _arrivalController.text,
          'travelDate': _dateController.text,
          'departureTime': '06:00 AM',
          'arrivalTime': '12:00 PM',
          'duration': '6h',
          'passengerName': _passengerNameController.text,
          'passengerAge': _passengerAgeController.text,
          'passengerID': _passengerIDController.text,
          'seatNumber': 'A${12 + (DateTime.now().millisecond % 20)}',
          'seatType': _seatController.text,
          'amenities': ['WiFi', 'Air Conditioning', 'Blanket', 'Mineral Water'],
          'pricePerSeat': 'Rs ${_priceController.text}',
          'totalFare': 'Rs ${_priceController.text}',
          'supportContact': '+977-1-4123456',
          'status': 'Confirmed',
        };

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BusTicketScreenWithData(ticketData: ticketData),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const providerColor = Color(0xFFEC4899);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Nepal Bus',
      children: [
        const ServiceHeader(
          title: 'Regional Travel',
          subtitle: 'Connecting cities with comfort and safety',
          icon: Icons.directions_bus_filled_rounded,
          color: providerColor,
        ),
        const SizedBox(height: 24),

        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route Selection Group
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: AppTheme.radiusLarge,
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _routeInput(
                      label: 'Departure',
                      value: _departureController.text,
                      icon: Icons.my_location_rounded,
                      color: providerColor,
                      onTap: () => _showSelectionDialog('Departure City', _departures, (val) {
                        setState(() => _departureController.text = val);
                      }),
                    ),
                    const Divider(height: 1, indent: 60),
                    _routeInput(
                      label: 'Destination',
                      value: _arrivalController.text,
                      icon: Icons.location_on_rounded,
                      color: providerColor,
                      onTap: () => _showSelectionDialog('Arrival City', _arrivals, (val) {
                        setState(() => _arrivalController.text = val);
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Passenger Details Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ServiceInputSection(
                      label: 'Full Name',
                      child: TextFormField(
                        controller: _passengerNameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_rounded),
                          hintText: 'Full Name',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ServiceInputSection(
                      label: 'Age',
                      child: TextFormField(
                        controller: _passengerAgeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                          hintText: 'Age',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Req' : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ID Row
              ServiceInputSection(
                label: 'Citizenship / ID Number',
                child: TextFormField(
                  controller: _passengerIDController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined),
                    hintText: 'Enter ID number',
                  ),
                  validator: (value) => (value?.isEmpty ?? true) ? 'ID is required for travel' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Travel Date
              ServiceInputSection(
                label: 'Journey Date',
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_month_rounded),
                    suffixIcon: Icon(Icons.keyboard_arrow_right_rounded),
                    hintText: 'Select journey date',
                  ),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Please select date' : null,
                ),
              ),
              const SizedBox(height: 24),

              // Seat Type Chips
              const Text('Seat Preference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _seatTypes.map((sType) {
                  final isSelected = _seatController.text == sType;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _seatController.text = sType;
                        if (sType == 'First Seat') _priceController.text = '800';
                        else if (sType == 'Sleeper') _priceController.text = '1000';
                        else if (sType == 'Window Seat') _priceController.text = '750';
                        else _priceController.text = '650';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? providerColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
                        borderRadius: AppTheme.radiusMedium,
                        border: Border.all(color: isSelected ? providerColor : Colors.transparent),
                      ),
                      child: Text(
                        sType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Summary Receipt
              _buildSummaryCard(providerColor, isDark),
              const SizedBox(height: 32),

              // Proceed Button
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: providerColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
                  elevation: 8,
                  shadowColor: providerColor.withValues(alpha: 0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Secure Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _routeInput({required String label, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Rs ${_priceController.text}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Booking Type', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(_seatController.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _dottedLine(isDark),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.verified_user_rounded, size: 14, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Insurance covered for all passengers throughout the journey.',
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dottedLine(bool isDark) {
    return Row(
      children: List.generate(
        40,
        (index) => Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            color: index.isEven ? (isDark ? Colors.white12 : Colors.grey[300]) : Colors.transparent,
          ),
        ),
      ),
    );
  }

  void _showSelectionDialog(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
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
