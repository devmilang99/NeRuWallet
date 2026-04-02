import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:intl/intl.dart';
import 'flight_ticket_screen.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _passengerNameController;
  late TextEditingController _passengerAgeController;
  late TextEditingController _departureController;
  late TextEditingController _arrivalController;
  late TextEditingController _dateController;
  late TextEditingController _seatController;
  late TextEditingController _priceController;

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
    _passengerNameController = TextEditingController();
    _passengerAgeController = TextEditingController();
    _departureController = TextEditingController(text: _departments[0]);
    _arrivalController = TextEditingController(text: _arrivals[0]);
    _dateController = TextEditingController();
    _seatController = TextEditingController(text: _seatClasses[0]);
    _priceController = TextEditingController(text: '8500');
  }

  @override
  void dispose() {
    _passengerNameController.dispose();
    _passengerAgeController.dispose();
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
              const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF10B981)),
              const SizedBox(height: 32),
              const Text(
                'Fetching your flight info...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait while we process your payment securely.',
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
          'pnr': 'PNR${DateTime.now().millisecondsSinceEpoch % 1000000}',
          'airline': 'Nepal Airways',
          'flightNumber':
              'NA${(DateTime.now().millisecond % 900 + 100).toString()}',
          'departureCity': _departureController.text.split('(')[0].trim(),
          'departureCode': _departureController.text
              .split('(')[1]
              .replaceAll(')', ''),
          'arrivalCity': _arrivalController.text.split('(')[0].trim(),
          'arrivalCode': _arrivalController.text
              .split('(')[1]
              .replaceAll(')', ''),
          'departureDate': _dateController.text,
          'departureTime': '08:15 AM',
          'arrivalTime': '02:30 PM',
          'duration': '6h 15m',
          'passengerName': _passengerNameController.text,
          'passengerAge': _passengerAgeController.text,
          'seatNumber': 'A${12 + (DateTime.now().millisecond % 30)}',
          'seatClass': _seatController.text,
          'aircraft': 'Airbus A320',
          'baggage': '20 kg',
          'gate': 'A-${(DateTime.now().millisecond % 20 + 1).toString()}',
          'terminal': 'Terminal 1',
          'boardingTime': '07:45 AM',
          'totalPrice': 'Rs ${_priceController.text}',
          'status': 'Confirmed',
        };

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FlightTicketScreenWithData(ticketData: ticketData),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const providerColor = Color(0xFF10B981);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Nepal Airways',
      children: [
        const ServiceHeader(
          title: 'Premium Flights',
          subtitle: 'Flying you across the Himalayas and beyond',
          icon: Icons.flight_takeoff_rounded,
          color: providerColor,
        ),
        const SizedBox(height: 24),

        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                  borderRadius: AppTheme.radiusLarge,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.radiusLarge,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                        ),
                        alignment: Alignment.center,
                        child: const Text('One Way', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: providerColor)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text('Round Trip', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: AppTheme.radiusLarge,
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _routeInput(
                      label: 'From',
                      value: _departureController.text,
                      icon: Icons.flight_takeoff_rounded,
                      onTap: () => _showSelectionDialog('Departure City', _departments, (val) {
                        setState(() => _departureController.text = val);
                      }),
                    ),
                    const Divider(height: 1, indent: 60),
                    _routeInput(
                      label: 'To',
                      value: _arrivalController.text,
                      icon: Icons.flight_land_rounded,
                      onTap: () => _showSelectionDialog('Arrival City', _arrivals, (val) {
                        setState(() => _arrivalController.text = val);
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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

              ServiceInputSection(
                label: 'Departure Date',
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_month_rounded),
                    suffixIcon: Icon(Icons.arrow_right_alt_rounded),
                    hintText: 'Select travel date',
                  ),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Please select date' : null,
                ),
              ),
              const SizedBox(height: 24),

              const Text('Travel Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: _seatClasses.map((sClass) {
                  final isSelected = _seatController.text == sClass;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _seatController.text = sClass;
                        if (sClass == 'Premium Economy') _priceController.text = '11500';
                        else if (sClass == 'Business') _priceController.text = '18000';
                        else _priceController.text = '8500';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? providerColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
                        borderRadius: AppTheme.radiusMedium,
                        border: Border.all(color: isSelected ? providerColor : Colors.transparent),
                      ),
                      child: Text(
                        sClass,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              _buildSummaryCard(providerColor, isDark),
              const SizedBox(height: 32),

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
                    Icon(Icons.lock_outline_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Secure Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _routeInput({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
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
                  const Text('Total Fare', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Rs ${_priceController.text}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Class', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_seatController.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _dottedLine(isDark),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Price includes taxes and basic baggage fees.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
