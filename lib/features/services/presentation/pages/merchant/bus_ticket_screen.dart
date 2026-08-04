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
          CircularProgressIndicator(color: Color(0xFFEC4899)),
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
      ? "My Bus Ticket:\nService: ${data['busCompany']}\nBus #: ${data['busNumber']}\nFrom: ${data['fromCity']}\nTo: ${data['toCity']}\nDate: ${data['departureDate']}\nTicket #: ${data['ticketNumber']}\nShared via NeRuWallet"
      : 'My Bus Ticket details are attached. Shared via NeRuWallet';

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
    'toCity': 'Pokhara',
    'departureDate': '15 April 2024',
    'departureTime': '06:30 AM',
    'estimatedArrivalTime': '12:30 PM',
    'journeyDuration': '6 hours',
    'seatNumber': '12',
    'seatType': 'Semi-Sleeper',
    'passengerName': 'John Doe',
    'totalFare': 'Rs 750',
    'status': 'Confirmed',
    'amenities': ['WiFi', 'Air Conditioning', 'Blanket'],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Bus Ticket',
      children: [
        const SizedBox(height: 8),

        _buildTicketCard(context, isDark, _busData),

        const SizedBox(height: 40),

        _buildHomeButton(context),

        const SizedBox(height: 32),
      ],
    );
  }
}

class BusTicketScreenWithData extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const BusTicketScreenWithData({required this.ticketData, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Bus Ticket',
      children: [
        const SizedBox(height: 8),

        _buildTicketCard(context, isDark, ticketData),

        const SizedBox(height: 40),

        _buildHomeButton(context),

        const SizedBox(height: 32),
      ],
    );
  }
}

Widget _buildTicketCard(
  BuildContext context,
  bool isDark,
  Map<String, dynamic> data,
) {
  const color = Color(0xFFEC4899);

  return DecoratedBox(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF131517) : Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          // Header - More compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Color(0xFFDB2777)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['busCompany'] ?? 'Bus Service',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        data['busLine'] ?? 'LUXURY COACH',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildTopIconButton(
                      icon: Icons.download_rounded,
                      onTap: () => _downloadTicket(context, data: data),
                    ),
                    const SizedBox(width: 10),
                    _buildTopIconButton(
                      icon: Icons.share_rounded,
                      onTap: () => _shareTicket(context, data: data),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildRouteInfo(
                        data['fromCity'] ?? 'From',
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRouteInfo(
                        data['toCity'] ?? 'To',
                        isDark,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildModernDashedDivider(isDark),
                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildInfoItem(
                      'PASSENGER',
                      data['passengerName'] ?? 'Guest',
                      isDark,
                    ),
                    _buildInfoItem(
                      'TICKET NO',
                      data['ticketNumber'] ?? 'N/A',
                      isDark,
                    ),
                    _buildInfoItem(
                      'DEPARTURE',
                      data['departureTime'] ?? 'N/A',
                      isDark,
                      color: color,
                      isBold: true,
                    ),
                    _buildInfoItem(
                      'SEAT NO',
                      data['seatNumber'] ?? 'N/A',
                      isDark,
                      color: color,
                      isBold: true,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Amenities - Cleaner layout
                if (data['amenities'] != null)
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: (data['amenities'] as List)
                          .map((a) => _buildAmenityBadge(a.toString(), isDark))
                          .toList(),
                    ),
                  ),

                const SizedBox(height: 24),

                // Footer QR Code Section - More integrated
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          size: 50,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BOARDING PASS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data['ticketNumber'] ?? 'REF-000',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Scan at boarding gate',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? Colors.white30 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VALID',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
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
  ).animate().slideY(begin: 0.1, end: 0).fadeIn(duration: 400.ms);
}

Widget _buildHomeButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.go('/dashboard'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFEC4899),
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

Widget _buildRouteInfo(
  String city,
  bool isDark, {
  TextAlign textAlign = TextAlign.start,
}) {
  return Text(
    city.toUpperCase(),
    textAlign: textAlign,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: isDark ? Colors.white : Colors.black,
      letterSpacing: -0.5,
    ),
  );
}

Widget _buildInfoItem(
  String label,
  String value,
  bool isDark, {
  Color? color,
  bool isBold = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey[100]!,
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
            color: isDark ? Colors.white24 : Colors.black26,
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

Widget _buildAmenityBadge(String text, bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
