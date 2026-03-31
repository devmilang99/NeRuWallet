import 'package:flutter/material.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';
import 'package:neruwallet/features/services/presentation/widgets/merchant_collection.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  final List<Map<String, dynamic>> _ticketProviders = const [
    {'name': 'QFX Cinemas', 'icon': Icons.movie_rounded, 'color': Color(0xFF6366F1), 'category': 'Movies'},
    {'name': 'FCube', 'icon': Icons.theaters_rounded, 'color': Color(0xFF0EA5E9), 'category': 'Movies'},
    {'name': 'Airlines Pay', 'icon': Icons.flight_rounded, 'color': Color(0xFF10B981), 'category': 'Travel'},
    {'name': 'Nepal Bus', 'icon': Icons.bus_alert_rounded, 'color': Color(0xFFEC4899), 'category': 'Travel'},
  ];

  @override
  Widget build(BuildContext context) {
    return BaseServicePage(
      title: 'Tickets & Flights',
      children: [
        const ServiceHeader(
          title: 'Easy Tickets',
          subtitle: 'Book and pay for movies, flights, and bus tickets seamlessly.',
          icon: Icons.confirmation_number_rounded,
          color: AppTheme.warningColor,
        ),
        const SizedBox(height: 32),
        MerchantCollection(title: 'Top Providers', merchants: _ticketProviders),
      ],
    );
  }
}
