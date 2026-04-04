import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/permission_utils.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
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
        const ServiceHeader(
          title: 'Bus Booking',
          subtitle: 'Your bus reservation confirmation',
          icon: Icons.bus_alert_rounded,
          color: Color(0xFFEC4899),
        ),
        const SizedBox(height: 32),

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

  const BusTicketScreenWithData({super.key, required this.ticketData});

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

        _buildTicketCard(context, isDark, ticketData),

        const SizedBox(height: 40),

        _buildHomeButton(context),

        const SizedBox(height: 32),
      ],
    );
  }
}

Widget _buildTicketCard(BuildContext context, bool isDark, Map<String, dynamic> data) {
  const color = Color(0xFFEC4899);

  return Container(
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [color, Color(0xFFDB2777)]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['busCompany'] ?? 'Bus Service',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      data['busLine'] ?? 'Luxury Coach',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
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

          // Body
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRouteInfo(data['fromCity'] ?? 'From', isDark),
                    Icon(Icons.trending_flat_rounded, color: color, size: 32),
                    _buildRouteInfo(data['toCity'] ?? 'To', isDark),
                  ],
                ),
                const SizedBox(height: 32),
                _buildModernDashedDivider(isDark),
                const SizedBox(height: 32),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  mainAxisSpacing: 16,
                  children: [
                    _buildInfoItem('PASSENGER', data['passengerName'] ?? 'Guest', isDark),
                    _buildInfoItem('TICKET NO', data['ticketNumber'] ?? 'N/A', isDark),
                    _buildInfoItem('DEPARTURE', data['departureTime'] ?? 'N/A', isDark, color: color),
                    _buildInfoItem('SEAT NO', data['seatNumber'] ?? 'N/A', isDark, color: color),
                  ],
                ),

                const SizedBox(height: 32),
                
                // Amenities
                if (data['amenities'] != null)
                  Wrap(
                    spacing: 8,
                    children: (data['amenities'] as List).map((a) => _buildAmenityBadge(a.toString(), isDark)).toList(),
                  ),
                
                const SizedBox(height: 40),
                
                // Footer QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 80, color: isDark ? Colors.white70 : Colors.black87),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BOARDING PASS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 4),
                            Text(data['ticketNumber'] ?? 'REF-000', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Show this at boarding', style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54)),
                          ],
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

Widget _buildRouteInfo(String city, bool isDark) {
  return Text(
    city.toUpperCase(),
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: isDark ? Colors.white : Colors.black,
      letterSpacing: -0.5,
    ),
  );
}

Widget _buildInfoItem(String label, String value, bool isDark, {Color? color}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white24 : Colors.black26)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? (isDark ? Colors.white : Colors.black87))),
    ],
  );
}

Widget _buildAmenityBadge(String text, bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
  );
}

Widget _buildTopIconButton({required IconData icon, required VoidCallback onTap}) {
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
