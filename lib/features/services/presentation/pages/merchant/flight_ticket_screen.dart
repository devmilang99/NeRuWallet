import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/permission_utils.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:share_plus/share_plus.dart';

Future<void> _downloadTicket(
  BuildContext context, {
  Map<String, dynamic>? data,
}) async {
  final hasPermission = await PermissionUtils.requestStoragePermission();

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
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          CircularProgressIndicator(color: Color(0xFF10B981)),
          SizedBox(height: 24),
          Text(
            'Generating PDF...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Creating your digital ticket',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
  );

  await Future.delayed(const Duration(seconds: 2));

  if (!context.mounted) return;

  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text(
        'Ticket downloaded successfully! Check your downloads.',
      ),
      backgroundColor: Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
    ),
  );
}

void _shareTicket(BuildContext context, {Map<String, dynamic>? data}) {
  final text = data != null
      ? "My Flight Ticket:\nAirline: ${data['airline']}\nFlight: ${data['flightNumber']}\nFrom: ${data['departureCity']}\nTo: ${data['arrivalCity']}\nDate: ${data['departureDate']}\nPNR: ${data['pnr']}\nShared via NeRuWallet"
      : 'My Flight Ticket details are attached. Shared via NeRuWallet';

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
    'duration': '1h 45m',
    'seatNumber': '12A',
    'seatClass': 'Economy',
    'gate': 'A12',
    'terminal': '2',
    'boardingTime': '06:00 AM',
    'passengerName': 'John Doe',
    'totalFare': 'Rs 8,500',
    'status': 'Confirmed',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Flight Ticket',
      children: [
        const SizedBox(height: 8),

        _buildBoardingPass(context, isDark, _flightData),

        const SizedBox(height: 40),

        _buildHomeButton(context),

        const SizedBox(height: 32),
      ],
    );
  }
}

class FlightTicketScreenWithData extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const FlightTicketScreenWithData({required this.ticketData, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Flight Ticket',
      children: [
        const SizedBox(height: 8),

        _buildBoardingPass(context, isDark, ticketData),

        const SizedBox(height: 10),

        _buildHomeButton(context),

        const SizedBox(height: 32),
      ],
    );
  }
}

Widget _buildBoardingPass(
  BuildContext context,
  bool isDark,
  Map<String, dynamic> data,
) {
  const color = Color(0xFF10B981);

  return DecoratedBox(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A1C1E) : Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withRed(150)]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['airline'] ?? 'Airline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'FLIGHT ${data['flightNumber'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildTopIconButton(
                      icon: Icons.download_rounded,
                      onTap: () => _downloadTicket(context, data: data),
                    ),
                    const SizedBox(width: 12),
                    _buildTopIconButton(
                      icon: Icons.share_rounded,
                      onTap: () => _shareTicket(context, data: data),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Route Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildCityInfo(
                        data['fromCode'] ?? 'KTM',
                        data['fromCity'] ?? 'Kathmandu',
                        CrossAxisAlignment.start,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        const Icon(
                          Icons.flight_takeoff_rounded,
                          color: color,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['duration'] ?? '1h 45m',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCityInfo(
                        data['toCode'] ?? 'DEL',
                        data['toCity'] ?? 'Delhi',
                        CrossAxisAlignment.end,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildModernDashedDivider(isDark),
                const SizedBox(height: 22),

                // Flight Information Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.0,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildInfoColumn(
                      'PASSENGER',
                      data['passengerName'] ?? 'Guest',
                      isDark,
                    ),
                    _buildInfoColumn(
                      'PNR',
                      data['pnr'] ?? 'N/A',
                      isDark,
                      isBold: true,
                      color: color,
                    ),
                    _buildInfoColumn(
                      'DATE',
                      data['departureDate'] ?? 'N/A',
                      isDark,
                    ),
                    _buildInfoColumn(
                      'TIME',
                      data['departureTime'] ?? 'N/A',
                      isDark,
                    ),
                    _buildInfoColumn('GATE', data['gate'] ?? 'TBD', isDark),
                    _buildInfoColumn(
                      'SEAT',
                      data['seatNumber'] ?? 'N/A',
                      isDark,
                      isBold: true,
                      color: color,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Barcode Section
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(42, (index) {
                          return Container(
                            width: (index % 3 == 0) ? 4 : 2,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            color: isDark ? Colors.white70 : Colors.black87,
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['pnr'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.black54,
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
    ),
  ).animate().slideY(begin: 0.2, end: 0).fadeIn(duration: 600.ms);
}

Widget _buildHomeButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.go('/dashboard'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.home_rounded),
        SizedBox(width: 12),
        Text(
          'Continue to Home',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ).animate(delay: 400.ms).fadeIn().scale();
}

Widget _buildCityInfo(
  String code,
  String city,
  CrossAxisAlignment align,
  bool isDark,
) {
  return Column(
    crossAxisAlignment: align,
    children: [
      Text(
        code,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      Text(
        city,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _buildInfoColumn(
  String label,
  String value,
  bool isDark, {
  bool isBold = false,
  Color? color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey[200]!,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white30 : Colors.black38,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTopIconButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

Widget _buildModernDashedDivider(bool isDark) {
  return Row(
    children: List.generate(
      30,
      (index) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 2,
          decoration: BoxDecoration(
            color: index.isEven
                ? (isDark ? Colors.white12 : Colors.black12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ),
  );
}
