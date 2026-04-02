import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'movie_ticket_screen.dart';
import 'flight_ticket_screen.dart';
import 'bus_ticket_screen.dart';
import 'movie_booking_screen.dart';
import 'flight_booking_screen.dart';
import 'bus_booking_screen.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Tickets & Flights',
      children: [
        const ServiceHeader(
          title: 'Easy Tickets',
          subtitle:
              'Book and pay for movies, flights, and bus tickets seamlessly.',
          icon: Icons.confirmation_number_rounded,
          color: AppTheme.warningColor,
        ),
        const SizedBox(height: 32),

        // Quick ticket booking cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildTicketCard(
              context,
              'QFX Cinemas',
              Icons.movie_rounded,
              const Color(0xFF6366F1),
              isDark,
              0,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MovieTicketScreen(provider: 'QFX'),
                ),
              ),
            ),
            _buildTicketCard(
              context,
              'FCube',
              Icons.theaters_rounded,
              const Color(0xFF0EA5E9),
              isDark,
              1,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MovieTicketScreen(provider: 'FCube'),
                ),
              ),
            ),
            _buildTicketCard(
              context,
              'Flight',
              Icons.flight_rounded,
              const Color(0xFF10B981),
              isDark,
              2,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlightTicketScreen(),
                ),
              ),
            ),
            _buildTicketCard(
              context,
              'Nepal Bus',
              Icons.bus_alert_rounded,
              const Color(0xFFEC4899),
              isDark,
              3,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusTicketScreen(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Top Providers Section
        Text(
          'Book Your Tickets',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Select a provider to start booking and fill in your details',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 20),

        // Top Providers Grid (Clickable)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildProviderCard(
              context,
              'QFX Cinemas',
              Icons.movie_rounded,
              const Color(0xFF6366F1),
              isDark,
              0,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MovieBookingScreen(provider: 'QFX'),
                ),
              ),
            ),
            _buildProviderCard(
              context,
              'FCube',
              Icons.theaters_rounded,
              const Color(0xFF0EA5E9),
              isDark,
              1,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MovieBookingScreen(provider: 'FCube'),
                ),
              ),
            ),
            _buildProviderCard(
              context,
              'Nepal Airways',
              Icons.flight_rounded,
              const Color(0xFF10B981),
              isDark,
              2,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlightBookingScreen(),
                ),
              ),
            ),
            _buildProviderCard(
              context,
              'Nepal Bus',
              Icons.bus_alert_rounded,
              const Color(0xFFEC4899),
              isDark,
              3,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusBookingScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isDark,
    int index,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withValues(alpha: 0.1), Colors.transparent],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (50 + index * 50).ms).slideY(begin: 0.2, end: 0).fadeIn();
  }

  Widget _buildProviderCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isDark,
    int index,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to book',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withValues(alpha: 0.12), Colors.transparent],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (100 + index * 80).ms).slideY(begin: 0.3, end: 0).fadeIn();
  }
}
