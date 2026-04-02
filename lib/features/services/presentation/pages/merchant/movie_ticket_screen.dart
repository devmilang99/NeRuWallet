import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/permission_utils.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:share_plus/share_plus.dart';

Future<void> _downloadTicket(BuildContext context, {required String provider, Map<String, dynamic>? data}) async {
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
          const Text('Generating Ticket PDF...', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Preparing your movie pass', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Movie ticket downloaded! Save it to your gallery.'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
      ),
    );
  });
}

void _shareTicket(BuildContext context, {required String provider, Map<String, dynamic>? data}) {
  final String text = data != null 
    ? "My Movie Ticket ($provider):\nMovie: ${data['movieName']}\nCinema: ${data['cinema']}\nShow: ${data['date']} at ${data['time']}\nSeats: ${(data['seatsBooked'] as List).join(', ')}\nRef: ${data['bookingRef']}\nShared via NeRuWallet"
    : "My Movie Ticket details are attached. Shared via NeRuWallet";
    
  Share.share(text);
}

class MovieTicketScreen extends StatefulWidget {
  final String provider; // 'QFX' or 'FCube'

  const MovieTicketScreen({super.key, required this.provider});

  @override
  State<MovieTicketScreen> createState() => _MovieTicketScreenState();
}

class _MovieTicketScreenState extends State<MovieTicketScreen> {
  // Sample ticket data
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
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: '${widget.provider} Tickets',
      children: [
        const ServiceHeader(
          title: 'Movie Ticket',
          subtitle: 'Your cinema booking details and e-ticket',
          icon: Icons.movie_rounded,
          color: AppTheme.warningColor,
        ),
        const SizedBox(height: 32),

        // Main Ticket Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(
                  widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
                ).withValues(alpha: 0.1),
                Color(
                  widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
                ).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color(
                widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
              ).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Header with logo and provider
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(
                    widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.provider,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ticketData['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Movie Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie Name
                    Text(
                      _ticketData['movieName'],
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Genre, Language, Format
                    Row(
                      children: [
                        _buildBadge(
                          _ticketData['genre'],
                          const Color(0xFF10B981),
                          isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          _ticketData['language'],
                          const Color(0xFFF59E0B),
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildBadge(
                      _ticketData['format'],
                      Color(widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9),
                      isDark,
                    ),
                    const SizedBox(height: 20),

                    // Divider with dashed line
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Cinema & Location Details
                    _buildDetailRow(
                      'Cinema',
                      _ticketData['cinema'],
                      Icons.location_on_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Screen',
                      '${_ticketData['screen']} (${_ticketData['format']})',
                      Icons.tv_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Date & Time
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
                              _ticketData['date'],
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              _ticketData['time'],
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _ticketData['duration'],
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Seats Booked
                    _buildDetailRow(
                      'Seats',
                      _ticketData['seatsBooked'].join(', '),
                      Icons.event_seat_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Total Seats',
                      '${_ticketData['totalSeats']} seats',
                      Icons.confirmation_number_rounded,
                      isDark,
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
                          _ticketData['pricePerSeat'],
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
                          'Total Price',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                        Text(
                          _ticketData['totalPrice'],
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  widget.provider == 'QFX'
                                      ? 0xFF6366F1
                                      : 0xFF0EA5E9,
                                ),
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Booking Reference
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Booking Reference',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _ticketData['bookingRef'],
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Color(
                                    widget.provider == 'QFX'
                                        ? 0xFF6366F1
                                        : 0xFF0EA5E9,
                                  ),
                                  letterSpacing: 1,
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
                                    'QR Code',
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
                            'Show this QR code at the cinema',
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
          onPressed: () => _downloadTicket(context, provider: widget.provider, data: _ticketData),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download Ticket (PDF)'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Color(widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9),
          ),
        ).animate(delay: 200.ms).slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 16),

        // Share Button
        OutlinedButton.icon(
          onPressed: () => _shareTicket(context, provider: widget.provider, data: _ticketData),
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

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
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
          color: AppTheme.primaryColor.withValues(alpha: 0.7),
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

// Alternative constructor: Pass ticket data from booking screen
class MovieTicketScreenWithData extends StatefulWidget {
  final String provider;
  final Map<String, dynamic> ticketData;

  const MovieTicketScreenWithData({
    super.key,
    required this.provider,
    required this.ticketData,
  });

  @override
  State<MovieTicketScreenWithData> createState() =>
      _MovieTicketScreenWithDataState();
}

class _MovieTicketScreenWithDataState extends State<MovieTicketScreenWithData> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: '${widget.provider} Tickets',
      children: [
        const ServiceHeader(
          title: 'Movie Ticket',
          subtitle: 'Your cinema booking details and e-ticket',
          icon: Icons.movie_rounded,
          color: AppTheme.warningColor,
        ),
        const SizedBox(height: 32),

        // Main Ticket Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(
                  widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
                ).withValues(alpha: 0.1),
                Color(
                  widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
                ).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color(
                widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
              ).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Header with logo and provider
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(
                    widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.provider,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.ticketData['status'] ?? 'Confirmed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Movie Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie Name
                    Text(
                      widget.ticketData['movieName'] ?? 'Movie Name',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Cinema & Location Details
                    _buildDetailRow(
                      'Cinema',
                      widget.ticketData['cinema'] ?? 'Cinema Name',
                      Icons.location_on_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Screen',
                      '${widget.ticketData['screen'] ?? 'Screen 1'} (${widget.ticketData['format'] ?? '2D'})',
                      Icons.tv_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Date & Time
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
                              widget.ticketData['date'] ?? 'Date',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              widget.ticketData['time'] ?? 'Time',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Seats Information
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seats Booked',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (String seat
                                in (widget.ticketData['seatsBooked'] as List? ??
                                    []))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    widget.provider == 'QFX'
                                        ? 0xFF6366F1
                                        : 0xFF0EA5E9,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(
                                      widget.provider == 'QFX'
                                          ? 0xFF6366F1
                                          : 0xFF0EA5E9,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  seat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(
                                      widget.provider == 'QFX'
                                          ? 0xFF6366F1
                                          : 0xFF0EA5E9,
                                    ),
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

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                        Text(
                          widget.ticketData['totalPrice'] ?? 'Rs 0',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  widget.provider == 'QFX'
                                      ? 0xFF6366F1
                                      : 0xFF0EA5E9,
                                ),
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDashedDivider(isDark),
                    const SizedBox(height: 20),

                    // Booking Reference
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Booking Reference',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.ticketData['bookingRef'] ?? 'REF123456',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Color(
                                    widget.provider == 'QFX'
                                        ? 0xFF6366F1
                                        : 0xFF0EA5E9,
                                  ),
                                  letterSpacing: 1,
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
                                    'QR Code',
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
                            'Show this QR code at the cinema',
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
          onPressed: () => _downloadTicket(context, provider: widget.provider, data: widget.ticketData),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download Ticket (PDF)'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Color(widget.provider == 'QFX' ? 0xFF6366F1 : 0xFF0EA5E9),
          ),
        ).animate(delay: 200.ms).slideY(begin: 0.3, end: 0).fadeIn(),

        const SizedBox(height: 16),

        // Share Button
        OutlinedButton.icon(
          onPressed: () => _shareTicket(context, provider: widget.provider, data: widget.ticketData),
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
          color: AppTheme.primaryColor.withValues(alpha: 0.7),
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
