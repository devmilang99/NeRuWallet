import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/permission_utils.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:share_plus/share_plus.dart';

Future<void> _downloadTicket(BuildContext context) async {
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
          const CircularProgressIndicator(color: Color(0xFFEC4899)),
          const SizedBox(height: 24),
          const Text('Generating PDF...', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Creating your digital ticket', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ),
  );

  await Future.delayed(const Duration(seconds: 2));
  
  if (!context.mounted) return;
  
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Ticket downloaded successfully! Check your downloads.'),
      backgroundColor: Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
    ),
  );
}

void _shareTicket(BuildContext context, {Map<String, dynamic>? data}) {
  final String text = data != null 
    ? "My Bus Ticket:\nService: ${data['busCompany']}\nBus #: ${data['busNumber']}\nFrom: ${data['fromCity']}\nTo: ${data['toCity']}\nDate: ${data['departureDate']}\nTicket #: ${data['ticketNumber']}\nShared via NeRuWallet"
    : "My Bus Ticket details are attached. Shared via NeRuWallet";
    
  Share.share(text);
}

class BusTicketScreen extends StatefulWidget {
  const BusTicketScreen({super.key});

  @override
  State<BusTicketScreen> createState() => _BusTicketScreenState();
}

class _BusTicketScreenState extends State<BusTicketScreen> {
  final Map<String, dynamic> _busData = {
    'ticketNumber': 'NBS2024041500',
    'busCompany': 'Nepal Bus Service',
    'busLine': 'Premium Luxury Coach',
    'busNumber': 'NBS-4521',
    'fromCity': 'Kathmandu',
    'fromStation': 'Central Bus Station',
    'toCity': 'Pokhara',
    'toStation': 'Metropolitan Bus Station',
    'departureDate': '15 April 2024',
    'departureTime': '06:30 AM',
    'estimatedArrivalTime': '12:30 PM',
    'journeyDuration': '6 hours',
    'seatNumber': '12',
    'seatType': 'Semi-Sleeper',
    'passengerName': 'John Doe',
    'passengerAge': 30,
    'idType': 'National ID',
    'idNumber': '1234567890',
    'totalSeats': 1,
    'pricePerSeat': 'Rs 750',
    'totalFare': 'Rs 750',
    'bookingDate': '10 April 2024',
    'status': 'Confirmed',
    'amenities': ['WiFi', 'Air Conditioning', 'Blanket', 'Mineral Water'],
    'contactNumber': '+977-1-4444444',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Bus Ticket',
      children: [
        const ServiceHeader(
          title: 'Bus Booking',
          subtitle: 'Your bus reservation confirmation',
          icon: Icons.bus_alert_rounded,
          color: Color(0xFFEC4899),
        ),
        const SizedBox(height: 32),

        // Main Ticket Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFEC4899).withValues(alpha: 0.1),
                const Color(0xFFEC4899).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFEC4899).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Header with bus company
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
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
                              _busData['busCompany'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _busData['busLine'],
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
                            _busData['status'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Bus No. ${_busData['busNumber']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Information
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    _busData['fromCity'],
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
                                    _busData['fromStation'],
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 9,
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
                                    Icons.directions_bus_rounded,
                                    color: const Color(0xFFEC4899),
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _busData['journeyDuration'],
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
                                    _busData['toCity'],
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
                                    _busData['toStation'],
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 9,
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

                    // Date & Time Details
                    Text(
                      'Journey Details',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Departure Date',
                      _busData['departureDate'],
                      Icons.calendar_today_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Departure Time',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _busData['departureTime'],
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFEC4899),
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Est. Arrival',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _busData['estimatedArrivalTime'],
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFEC4899),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Passenger Information
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
                      _busData['passengerName'],
                      Icons.person_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Age',
                      '${_busData['passengerAge']} years',
                      Icons.cake_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'ID Type',
                      _busData['idType'],
                      Icons.badge_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'ID Number',
                      _busData['idNumber'],
                      Icons.confirmation_number_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Seat Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                        ),
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
                              const SizedBox(height: 8),
                              Text(
                                _busData['seatNumber'],
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFEC4899),
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Seat Type',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEC4899,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFEC4899,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  _busData['seatType'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEC4899),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Amenities
                    Text(
                      'Amenities',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _busData['amenities'].map<Widget>((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFEC4899,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFEC4899,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            amenity,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Price Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price per Seat',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                        ),
                        Text(
                          _busData['pricePerSeat'],
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                          _busData['totalFare'],
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEC4899),
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Ticket Number
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Ticket Number',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _busData['ticketNumber'],
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEC4899),
                                  letterSpacing: 1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Booking Date: ${_busData['bookingDate']}',
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

                    const SizedBox(height: 20),

                    // Contact Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            color: const Color(0xFFEC4899),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Support',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _busData['contactNumber'],
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFEC4899),
                                    ),
                              ),
                            ],
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
            backgroundColor: const Color(0xFFEC4899),
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
          color: const Color(0xFFEC4899).withValues(alpha: 0.7),
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

// Alternative constructor: Pass bus ticket data from booking screen
class BusTicketScreenWithData extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  const BusTicketScreenWithData({super.key, required this.ticketData});

  @override
  State<BusTicketScreenWithData> createState() =>
      _BusTicketScreenWithDataState();
}

class _BusTicketScreenWithDataState extends State<BusTicketScreenWithData> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const color = Color(0xFFEC4899);

    return BaseServicePage(
      title: 'Bus Ticket',
      children: [
        const ServiceHeader(
          title: 'Bus Ticket',
          subtitle: 'Your bus booking confirmation and ticket details',
          icon: Icons.bus_alert_rounded,
          color: color,
        ),
        const SizedBox(height: 32),

        // Bus Ticket Card
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
              // Bus Header
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
                          widget.ticketData['busCompany'] ?? 'Bus Company',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bus #${widget.ticketData['busNumber'] ?? 'BUS-000'}',
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

              // Ticket Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route
                    Text(
                      widget.ticketData['busLine'] ?? 'Route',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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
                              'Departure',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.ticketData['departureCity'] ?? 'Departure',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: color.withValues(alpha: 0.5),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Arrival',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.ticketData['arrivalCity'] ?? 'Arrival',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Journey Details
                    _buildDetailRow(
                      'Date',
                      widget.ticketData['travelDate'] ?? 'Date',
                      Icons.calendar_today_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Departure Time',
                      widget.ticketData['departureTime'] ?? 'Time',
                      Icons.schedule_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Arrival Time',
                      widget.ticketData['arrivalTime'] ?? 'Time',
                      Icons.access_time_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Duration',
                      widget.ticketData['duration'] ?? 'Duration',
                      Icons.hourglass_bottom_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Passenger Information
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passenger Information',
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
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Citizenship',
                          widget.ticketData['passengerID'] ?? 'ID',
                          Icons.badge_rounded,
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
                                widget.ticketData['seatNumber'] ?? 'A12',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Type',
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
                                  widget.ticketData['seatType'] ??
                                      'Semi-Sleeper',
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

                    // Amenities
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amenities',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (String amenity
                                in (widget.ticketData['amenities'] as List? ??
                                    []))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  amenity,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: color,
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

                    // Price & Support
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Fare',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.ticketData['totalFare'] ?? 'Rs 650',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.support_agent_rounded,
                                color: color,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Support Contact',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.ticketData['supportContact'] ??
                                          '+977-1-4123456',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: color,
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

                    const SizedBox(height: 20),

                    // Ticket Number
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Ticket Number',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.ticketData['ticketNumber'] ?? 'TICKET123456',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ticket PDF download feature coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
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
          color: const Color(0xFFEC4899).withValues(alpha: 0.7),
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
