import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/permission_utils.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:share_plus/share_plus.dart';

Future<void> _downloadTicket(
  BuildContext context, {
  required String provider,
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
  final color = Color(provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9);
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
          CircularProgressIndicator(color: color),
          const SizedBox(height: 24),
          const Text(
            'Generating Ticket PDF...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preparing your movie pass',
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
      content: const Text('Movie ticket downloaded! Save it to your gallery.'),
      backgroundColor: Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
    ),
  );
}

void _shareTicket(
  BuildContext context, {
  required String provider,
  Map<String, dynamic>? data,
}) {
  final text = data != null
      ? "My Movie Ticket ($provider):\nMovie: ${data['movieName']}\nCinema: ${data['cinema']}\nShow: ${data['date']} at ${data['time']}\nSeats: ${(data['seatsBooked'] as List).join(', ')}\nRef: ${data['bookingRef']}\nShared via NeRuWallet"
      : 'My Movie Ticket details are attached. Shared via NeRuWallet';

  Share.share(text);
}

class MovieTicketScreen extends StatefulWidget {
  final String provider; // 'QFX' or 'FCube'

  const MovieTicketScreen({required this.provider, super.key});

  @override
  State<MovieTicketScreen> createState() => _MovieTicketScreenState();
}

class _MovieTicketScreenState extends State<MovieTicketScreen> {
  final Map<String, dynamic> _ticketData = {
    'bookingRef': 'MOV2024041230',
    'movieName': 'The Ultimate Adventure',
    'cinema': 'City Center Cinema',
    'screen': 'Screen 5',
    'date': '15 April 2024',
    'time': '7:30 PM',
    'duration': '2h 45m',
    'genre': 'Action/Adventure',
    'language': 'English',
    'format': '4K IMAX',
    'seatsBooked': ['A12', 'A13', 'A14'],
    'totalSeats': 3,
    'pricePerSeat': 'Rs 450',
    'totalPrice': 'Rs 1,350',
    'bookingDate': '10 April 2024',
    'status': 'Confirmed',
    'posterUrl':
        'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=1000&auto=format&fit=crop',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: '${widget.provider} Tickets',
      children: [
        const SizedBox(height: 8),

        _buildTicketCard(context, isDark, widget.provider, _ticketData),

        const SizedBox(height: 40),

        _buildHomeButton(context, widget.provider),

        const SizedBox(height: 32),
      ],
    );
  }
}

class MovieTicketScreenWithData extends StatelessWidget {
  final String provider;
  final Map<String, dynamic> ticketData;

  const MovieTicketScreenWithData({
    required this.provider,
    required this.ticketData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: '$provider Tickets',
      children: [
        const SizedBox(height: 8),

        _buildTicketCard(context, isDark, provider, ticketData),

        const SizedBox(height: 20),

        _buildHomeButton(context, provider),

        const SizedBox(height: 32),
      ],
    );
  }
}

Widget _buildTicketCard(
  BuildContext context,
  bool isDark,
  String provider,
  Map<String, dynamic> data,
) {
  return Stack(
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            children: [
              // Header with Poster-style Gradient
              Container(
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const NetworkImage(
                      'https://images.unsplash.com/photo-1478720568477-152d9b164e26?q=80&w=1000&auto=format&fit=crop',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9),
                      Color(provider == 'QFX' ? 0xFF4338CA : 0xFF0284C7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TicketPatternPainter(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  provider,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildTopIconButton(
                                    icon: Icons.download_rounded,
                                    onTap: () => _downloadTicket(
                                      context,
                                      provider: provider,
                                      data: data,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildTopIconButton(
                                    icon: Icons.share_rounded,
                                    onTap: () => _shareTicket(
                                      context,
                                      provider: provider,
                                      data: data,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['movieName'] ?? 'Movie Name',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildModernBadge(
                                          data['genre'] ?? 'Genre',
                                          Colors.white24,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildModernBadge(
                                          data['format'] ?? 'Format',
                                          Colors.white24,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 80,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      data['posterUrl'] ??
                                          'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
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

              // Ticket Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildTicketInfo(
                            context,
                            'DATE',
                            data['date'] ?? 'N/A',
                            Icons.calendar_today_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildTicketInfo(
                            context,
                            'TIME',
                            data['time'] ?? 'N/A',
                            Icons.access_time_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildTicketInfo(
                            context,
                            'SCREEN',
                            data['screen'] ?? 'N/A',
                            Icons.tv_rounded,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildModernDashedDivider(isDark),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildTicketInfo(
                            context,
                            'SEATS',
                            (data['seatsBooked'] as List?)?.join(', ') ?? 'N/A',
                            Icons.event_seat_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildTicketInfo(
                            context,
                            'TOTAL',
                            data['totalPrice'] ?? 'N/A',
                            Icons.payments_rounded,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // QR Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 100,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['bookingRef'] ?? 'REF-000000',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: isDark ? Colors.white70 : Colors.black54,
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
      ),
      // Ticket Side Cutouts
      Positioned(
        left: -15,
        top: 205,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        right: -15,
        top: 205,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ],
  ).animate().slideY(begin: 0.2, end: 0).fadeIn(duration: 600.ms);
}

Widget _buildHomeButton(BuildContext context, String provider) {
  return ElevatedButton(
    onPressed: () => context.go('/dashboard'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9),
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

Widget _buildTopIconButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

Widget _buildModernBadge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildTicketInfo(
  BuildContext context,
  String label,
  String value,
  IconData icon,
  bool isDark,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white54 : Colors.black54,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    ],
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

class TicketPatternPainter extends CustomPainter {
  final Color color;

  TicketPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() + 10, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
