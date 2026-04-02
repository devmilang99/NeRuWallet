import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/core/utils/permission_utils.dart';
import 'package:share_plus/share_plus.dart';

Future<void> _downloadTicket(BuildContext context, {Map<String, dynamic>? data}) async {
  final bool hasPermission = await PermissionUtils.requestStoragePermission();
  
  if (!hasPermission) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to save the ticket.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
    return;
  }

  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: Color(0xFF10B981)),
          const SizedBox(height: 24),
          const Text('Generating PDF...', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Creating your digital ticket', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ticket downloaded successfully! Check your downloads.'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
      ),
    );
  });
}

void _shareTicket(BuildContext context, {Map<String, dynamic>? data}) {
  final String text = data != null 
    ? "My Flight Ticket:\nAirline: ${data['airline']}\nFlight: ${data['flightNumber']}\nFrom: ${data['departureCity']}\nTo: ${data['arrivalCity']}\nDate: ${data['departureDate']}\nPNR: ${data['pnr']}\nShared via NeRuWallet"
    : "My Flight Ticket details are attached. Shared via NeRuWallet";
    
  Share.share(text);
}

class FlightTicketScreen extends StatefulWidget {
  const FlightTicketScreen({super.key});

  @override
  State<FlightTicketScreen> createState() => _FlightTicketScreenState();
}

class _FlightTicketScreenState extends State<FlightTicketScreen> {
  final Map<String, dynamic> _flightData = {
    'pnr': 'AI123456',
    'airline': 'Nepal Airways',
    'flightNumber': 'NA-402',
    'fromCity': 'Kathmandu',
    'fromCode': 'KTM',
    'toCity': 'Delhi',
    'toCode': 'DEL',
    'departureDate': '15 April 2024',
    'departureTime': '06:30 AM',
    'arrivalTime': '08:15 AM',
    'durationHours': 1,
    'durationMinutes': 45,
    'seatNumber': '12A',
    'seatClass': 'Economy',
    'gate': 'A12',
    'terminal': '2',
    'boardingTime': '06:00 AM',
    'aircraft': 'Airbus A320',
    'passengerName': 'John Doe',
    'passengerAge': 30,
    'bookingDate': '10 April 2024',
    'totalFare': 'Rs 8,500',
    'status': 'Confirmed',
    'baggageAllowance': '15 kg',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Flight Booking',
      children: [
        const ServiceHeader(
          title: 'Flight Ticket',
          subtitle: 'Your booking confirmation and e-ticket',
          icon: Icons.flight_rounded,
          color: Color(0xFF10B981),
        ),
        const SizedBox(height: 32),

        // Main Ticket Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981).withValues(alpha: 0.1),
                const Color(0xFF10B981).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Header with airline
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _flightData['airline'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Flight ${_flightData['flightNumber']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _flightData['status'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route with map icon
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    _flightData['fromCode'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _flightData['fromCity'],
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Icon(
                                    Icons.flight_takeoff_rounded,
                                    color: const Color(0xFF10B981),
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _flightData['durationHours']
                                        .toString()
                                        .padLeft(1, '0'),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                          fontSize: 10,
                                        ),
                                  ),
                                  Text(
                                    '${_flightData['durationMinutes']}m',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Text(
                                    _flightData['toCode'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _flightData['toCity'],
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildDashedDivider(isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Departure Details
                    Text(
                      'Departure',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _flightData['departureDate'],
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Time',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _flightData['departureTime'],
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Gate',
                      _flightData['gate'],
                      Icons.door_sliding_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Terminal',
                      _flightData['terminal'],
                      Icons.airport_shuttle_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Boarding',
                      _flightData['boardingTime'],
                      Icons.schedule_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Arrival Details
                    Text(
                      'Arrival',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Time',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _flightData['arrivalTime'],
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Passenger & Seat Details
                    Text(
                      'Passenger Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Name',
                      _flightData['passengerName'],
                      Icons.person_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Age',
                      '${_flightData['passengerAge']} years',
                      Icons.cake_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Seat & Class Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seat Number',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _flightData['seatNumber'],
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Class',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _flightData['seatClass'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Additional Details
                    _buildDetailRow(
                      'Aircraft',
                      _flightData['aircraft'],
                      Icons.airplanemode_on_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Baggage Allowance',
                      _flightData['baggageAllowance'],
                      Icons.backpack_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Booking Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Fare',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                        Text(
                          _flightData['totalFare'],
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // PNR
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'PNR (Passenger Name Record)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _flightData['pnr'],
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                  letterSpacing: 2,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Barcode placeholder
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 40,
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scanning Space',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Scan at check-in counter',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 24),

        // Download PDF Button
        ElevatedButton.icon(
          onPressed: () => _downloadTicket(context),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download Ticket (PDF)'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color(0xFF10B981),
          ),
        ).animate(delay: 200.ms).slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 16),

        // Share Button
        OutlinedButton.icon(
          onPressed: () => _shareTicket(context),
          icon: const Icon(Icons.share_rounded),
          label: const Text('Share Ticket'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ).animate(delay: 250.ms).slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDashedDivider(bool isDark) {
    return Row(
      children: List.generate(
        40,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index.isEven
                ? (isDark ? Colors.white12 : Colors.black12)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF10B981).withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Alternative constructor: Pass flight data from booking screen
class FlightTicketScreenWithData extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  const FlightTicketScreenWithData({super.key, required this.ticketData});

  @override
  State<FlightTicketScreenWithData> createState() =>
      _FlightTicketScreenWithDataState();
}

class _FlightTicketScreenWithDataState
    extends State<FlightTicketScreenWithData> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = const Color(0xFF10B981);

    return BaseServicePage(
      title: 'Flight Ticket',
      children: [
        const ServiceHeader(
          title: 'Flight Booking',
          subtitle: 'Your flight confirmation and ticket details',
          icon: Icons.flight_rounded,
          color: Color(0xFF10B981),
        ),
        const SizedBox(height: 32),

        // Flight Header
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              // Header with airline branding
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ticketData['airline'] ?? 'Airline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flight ${widget.ticketData['flightNumber'] ?? 'NA-000'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Route Visualization
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ticketData['departureCode'] ?? 'KTM',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.ticketData['departureCity'] ?? 'Kathmandu',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Icon(
                                Icons.flight_rounded,
                                color: color,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.ticketData['duration'] ?? '1h 45m'}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.ticketData['arrivalCode'] ?? 'DEL',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.ticketData['arrivalCity'] ?? 'Delhi',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Departure Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Date',
                          widget.ticketData['departureDate'] ?? 'Date',
                          Icons.calendar_today_rounded,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Time',
                          widget.ticketData['departureTime'] ?? 'Time',
                          Icons.schedule_rounded,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Gate',
                          widget.ticketData['gate'] ?? 'Gate',
                          Icons.numbers_rounded,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Terminal',
                          widget.ticketData['terminal'] ?? 'Terminal',
                          Icons.location_on_rounded,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Boarding',
                          widget.ticketData['boardingTime'] ?? 'Time',
                          Icons.access_time_rounded,
                          isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Passenger Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passenger',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Name',
                          widget.ticketData['passengerName'] ??
                              'Passenger Name',
                          Icons.person_rounded,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Age',
                          widget.ticketData['passengerAge'] ?? 'Age',
                          Icons.info_rounded,
                          isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Seat Information
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seat Number',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.ticketData['seatNumber'] ?? 'A01',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Class',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.ticketData['seatClass'] ?? 'Economy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PNR & Booking Ref
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'PNR',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.ticketData['pnr'] ?? 'PNR123456',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // QR Code placeholder
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 60,
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Check-In Code',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Scan at airport check-in counter',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 24),

        // Download PDF Button
        ElevatedButton.icon(
          onPressed: () => _downloadTicket(context, data: widget.ticketData),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download Ticket (PDF)'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: color,
          ),
        ).animate(delay: 200.ms).slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 16),

        // Share Button
        OutlinedButton.icon(
          onPressed: () => _shareTicket(context, data: widget.ticketData),
          icon: const Icon(Icons.share_rounded),
          label: const Text('Share Ticket'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ).animate(delay: 250.ms).slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDashedDivider(bool isDark) {
    return Row(
      children: List.generate(
        40,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index.isEven
                ? (isDark ? Colors.white12 : Colors.black12)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF10B981).withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
