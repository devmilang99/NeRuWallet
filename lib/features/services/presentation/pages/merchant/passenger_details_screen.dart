import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/booking_verification_sheet.dart';
import 'package:neruwallet/core/services/transaction_service.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'flight_ticket_screen.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

class PassengerDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> searchData;
  final Map<String, dynamic> flightData;

  const PassengerDetailsScreen({
    super.key,
    required this.searchData,
    required this.flightData,
  });

  @override
  ConsumerState<PassengerDetailsScreen> createState() =>
      _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState
    extends ConsumerState<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<PassengerController> _adultControllers;
  late List<PassengerController> _childControllers;

  @override
  void initState() {
    super.initState();
    _adultControllers = List.generate(
      widget.searchData['adults'] as int,
      (_) => PassengerController(),
    );
    _childControllers = List.generate(
      widget.searchData['children'] as int,
      (_) => PassengerController(),
    );
  }

  @override
  void dispose() {
    for (var c in _adultControllers) {
      c.dispose();
    }
    for (var c in _childControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _proceedToConfirmation() {
    if (_formKey.currentState!.validate()) {
      final List<Map<String, String>> allPassengers = [];
      for (var c in _adultControllers) {
        allPassengers.add({
          'title': c.title,
          'name': c.nameController.text,
          'type': 'Adult',
        });
      }
      for (var c in _childControllers) {
        allPassengers.add({
          'title': c.title,
          'name': c.nameController.text,
          'type': 'Child',
        });
      }

      final bool isVoucherActive = ref.read(balanceProvider).isVoucherActive;
      final double totalAmount =
          (widget.flightData['price'] as int) *
          (allPassengers.length).toDouble();
      final double fee = TransactionService.getServiceCharge(
        TransactionType.flight,
        totalAmount,
        isVoucherActive: isVoucherActive,
      );
      final double tax = TransactionService.getTax(
        TransactionType.flight,
        totalAmount,
        isVoucherActive: isVoucherActive,
      );
      final double totalPayable = totalAmount + fee + tax;
      final double currentBalance = ref.read(balanceProvider).totalBalance;

      if (totalPayable > currentBalance) {
        GlassDialog.showError(
          context,
          'Insufficient balance for flight booking.\n\nRequired: Rs. ${totalPayable.toStringAsFixed(2)}\nAvailable: Rs. ${currentBalance.toStringAsFixed(2)}',
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => BookingVerificationSheet(
          title: 'Flight',
          provider: widget.flightData['airline'],
          color: const Color(0xFF10B981),
          details: {
            'Flight':
                '${widget.flightData['airline']} (${widget.flightData['flightNumber']})',
            'Passengers': allPassengers.length.toString(),
            'Adult/Child':
                '${widget.searchData['adults']}A, ${widget.searchData['children']}C',
            'Route':
                '${widget.searchData['from']} → ${widget.searchData['to']}',
            'Type': widget.searchData['isRoundTrip'] == true
                ? 'Round Trip'
                : 'One Way',
            'Travel Date': widget.searchData['departureDate'],
            'Class': widget.searchData['class'],
            if (isVoucherActive) 'Voucher': 'Applied (Free Fees)',
            'Total Fare': 'Rs. $totalAmount',
          },
          passengers: allPassengers
              .map((p) => '${p['title']} ${p['name']}')
              .toList(),
          amount: totalAmount,
          fee: fee,
          tax: tax,
          onCancel: () {
            // Cancel booking and go back to flight selection
            Navigator.pop(context);
          },
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionPinScreen(
                  mode: PinMode.verify,
                  onSuccess: () => _completeBooking(allPassengers, totalAmount),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  void _completeBooking(List<Map<String, String>> passengers, double amount) {
    Navigator.pop(context); // Close PIN screen
    final bool isVoucherActive = ref.read(balanceProvider).isVoucherActive;

    // Deduct balance here (as the flight booking transaction is now completed successfully)
    ref
        .read(balanceProvider.notifier)
        .deductTravelTicket(
          mode: 'Flight',
          amount: amount,
          ref: 'FLI${DateTime.now().millisecondsSinceEpoch % 1000000}',
          fee: TransactionService.getServiceCharge(
            TransactionType.flight,
            amount,
            isVoucherActive: isVoucherActive,
          ),
          tax: TransactionService.getTax(TransactionType.flight, amount, isVoucherActive: isVoucherActive),
          metadata: {
            'from': widget.searchData['from'],
            'to': widget.searchData['to'],
            'date': widget.searchData['departureDate'],
            'passengers': passengers.map((p) => p['name']).toList(),
          },
          isVoucherApplied: isVoucherActive,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: 32),
            const Text(
              'Issuing your flight ticket...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      Map<String, dynamic> ticketData = {
        'pnr': 'PNR${DateTime.now().millisecondsSinceEpoch % 1000000}',
        'airline': widget.flightData['airline'],
        'flightNumber': widget.flightData['flightNumber'],
        'departureCity': widget.searchData['from'].split('(')[0].trim(),
        'departureCode': widget.searchData['from'].contains('(')
            ? widget.searchData['from'].split('(')[1].replaceAll(')', '')
            : 'N/A',
        'arrivalCity': widget.searchData['to'].split('(')[0].trim(),
        'arrivalCode': widget.searchData['to'].contains('(')
            ? widget.searchData['to'].split('(')[1].replaceAll(')', '')
            : 'N/A',
        'departureDate': widget.searchData['departureDate'],
        'departureTime': widget.flightData['departure'],
        'arrivalTime': widget.flightData['arrival'],
        'duration': widget.flightData['duration'],
        'passengerName':
            '${passengers[0]['title']} ${passengers[0]['name']}${passengers.length > 1 ? ' + ${passengers.length - 1} more' : ''}',
        'passengerAge': widget.searchData['adults'] > 0 ? 'Adult' : 'Child',
        'seatNumber': 'A-${(10 + DateTime.now().millisecond % 50)}',
        'seatClass': widget.searchData['class'],
        'aircraft': widget.flightData['plane'],
        'baggage': '20 kg',
        'totalPrice': 'Rs $amount',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = const Color(0xFF10B981);

    return BaseServicePage(
      title: 'Passenger Details',
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppTheme.radiusSmall,
              ),
              child: Icon(Icons.group_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Passenger Information',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              ..._buildPassengerList('Adults', _adultControllers, isDark),
              ..._buildPassengerList('Children', _childControllers, isDark),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _proceedToConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLarge,
                  ),
                ),
                child: const Text(
                  'Proceed to Confirmation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ).animate().shimmer(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPassengerList(
    String title,
    List<PassengerController> controllers,
    bool isDark,
  ) {
    if (controllers.isEmpty) return [];
    return [
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            '${controllers.length} Passenger(s)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ...List.generate(controllers.length, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: AppTheme.radiusLarge,
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey[300]!,
                      ),
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controllers[index].title,
                        isExpanded: true,
                        items: ['Mr.', 'Mrs.', 'Ms.']
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  t,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => controllers[index].title = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: controllers[index].nameController,
                      decoration: const InputDecoration(
                        hintText: 'Full Name',
                        hintStyle: TextStyle(fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
      }),
    ];
  }
}

class PassengerController {
  String title = 'Mr.';
  final TextEditingController nameController = TextEditingController();

  void dispose() {
    nameController.dispose();
  }
}
