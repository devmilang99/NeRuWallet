import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/transaction_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';
import 'package:neruwallet/features/services/presentation/widgets/booking_verification_sheet.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

import 'movie_ticket_screen.dart';

class MovieBookingScreen extends ConsumerStatefulWidget {
  final String provider; // 'QFX' or 'FCube'

  const MovieBookingScreen({required this.provider, super.key});

  @override
  ConsumerState<MovieBookingScreen> createState() => _MovieBookingScreenState();
}

class _MovieBookingScreenState extends ConsumerState<MovieBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _seatsController;
  late TextEditingController _pricePerSeatController;

  final List<String> _timeSlots = [
    '09:30 AM',
    '12:30 PM',
    '03:30 PM',
    '06:30 PM',
    '09:30 PM',
  ];

  late List<DateTime> _dates;
  int _selectedDateIndex = 0;
  String? _selectedTime;

  final List<String> _movies = [
    'The Ultimate Adventure',
    'Love in the City',
    'Sci-Fi: Future World',
    'Comedy Express',
    'Thriller Night',
  ];

  final List<String> _moviePosters = [
    'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542204172-3c138fd95886?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1485846234645-a62644ff7467?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=1000&auto=format&fit=crop',
  ];

  final List<String> _cinemas = [
    'City Center Cinema',
    'Metro Mall Theater',
    'Grand Plaza Cinema',
    'Downtown Cineplex',
  ];

  final List<String> _screens = [
    'Screen 1',
    'Screen 2',
    'Screen 3',
    'Screen 4',
    'Screen 5',
  ];

  @override
  void initState() {
    super.initState();
    _seatsController = TextEditingController(text: '1');
    _pricePerSeatController = TextEditingController(text: '450');
    _dates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    _selectedTime = _timeSlots[1]; // Default selection
  }

  @override
  void dispose() {
    _seatsController.dispose();
    _pricePerSeatController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    final seats = int.tryParse(_seatsController.text) ?? 1;
    final price = double.tryParse(_pricePerSeatController.text) ?? 450;
    return seats * price;
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a show time')),
        );
        return;
      }

      final providerColor = widget.provider == 'QFX'
          ? const Color(0xFF6366F1)
          : const Color(0xFF0EA5E9);

      final isVoucherActive = ref.read(balanceProvider).isVoucherActive;
      final fee = TransactionService.getServiceCharge(
        TransactionType.movie,
        _totalPrice,
        isVoucherActive: isVoucherActive,
      );
      final tax = TransactionService.getTax(
        TransactionType.movie,
        _totalPrice,
        isVoucherActive: isVoucherActive,
      );
      final totalPayable = _totalPrice + fee + tax;
      final currentBalance = ref.read(balanceProvider).totalBalance;

      if (totalPayable > currentBalance) {
        GlassDialog.showError(
          context,
          'Insufficient balance to complete this transaction.\n\nRequired: Rs. ${totalPayable.toStringAsFixed(2)}\nAvailable: Rs. ${currentBalance.toStringAsFixed(2)}',
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
          title: 'Movie',
          provider: '${widget.provider} Cinemas',
          color: providerColor,
          details: {
            'Movie': _movies[_selectedMovieIndex],
            'Cinema': _cinemas[_selectedCinemaIndex],
            'Show':
                '${DateFormat('dd MMM').format(_dates[_selectedDateIndex])}, $_selectedTime',
            'Seats': _seatsController.text,
            'Rate': 'Rs ${_pricePerSeatController.text}/seat',
            if (isVoucherActive) 'Voucher': 'Applied (Free Fees)',
          },
          amount: _totalPrice,
          fee: fee,
          tax: tax,
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionPinScreen(
                  mode: PinMode.verify,
                  onSuccess: _completeBooking,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> _completeBooking() async {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context); // Pop PIN screen
    }
    final isVoucherActive = ref.read(balanceProvider).isVoucherActive;

    // Deduct balance here (as the transaction is now completed successfully)
    await ref
        .read(balanceProvider.notifier)
        .deductQuickAction(
          title: '${widget.provider} Ticket',
          amount: _totalPrice,
          fee: TransactionService.getServiceCharge(
            TransactionType.movie,
            _totalPrice,
            isVoucherActive: isVoucherActive,
          ),
          tax: TransactionService.getTax(
            TransactionType.movie,
            _totalPrice,
            isVoucherActive: isVoucherActive,
          ),
          icon: Icons.movie_rounded,
          color: widget.provider == 'QFX'
              ? const Color(0xFF6366F1)
              : const Color(0xFF0EA5E9),
          category: 'Movie',
          type: TransactionType.movie,
          metadata: {
            'movie': _movies[_selectedMovieIndex],
            'cinema': _cinemas[_selectedCinemaIndex],
            'seats': _seatsController.text,
            'showTime': _selectedTime,
          },
          isVoucherApplied: isVoucherActive,
        );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            CircularProgressIndicator(
              strokeWidth: 3,
              color: widget.provider == 'QFX'
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF0EA5E9),
            ),
            const SizedBox(height: 32),
            Text(
              'Securing your seats...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirming payment for ${_movies[_selectedMovieIndex]}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      final ticketData = <String, dynamic>{
        'bookingRef': 'MOV${DateTime.now().millisecondsSinceEpoch % 1000000}',
        'movieName': _movies[_selectedMovieIndex],
        'cinema': _cinemas[_selectedCinemaIndex],
        'screen': _screens[_selectedScreenIndex],
        'date': DateFormat('dd MMM yyyy').format(_dates[_selectedDateIndex]),
        'time': _selectedTime,
        'duration': '2h 45m',
        'genre': 'Action/Adventure',
        'language': 'English',
        'format': '4K IMAX',
        'seatsBooked': List.generate(
          int.parse(_seatsController.text),
          (i) => String.fromCharCode(65 + (i ~/ 5)) + (12 + (i % 5)).toString(),
        ),
        'totalSeats': int.parse(_seatsController.text),
        'pricePerSeat': 'Rs ${_pricePerSeatController.text}',
        'totalPrice': 'Rs ${_totalPrice.toStringAsFixed(0)}',
        'bookingDate': DateFormat('dd MMM yyyy').format(DateTime.now()),
        'status': 'Confirmed',
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MovieTicketScreenWithData(
            provider: widget.provider,
            ticketData: ticketData,
          ),
        ),
      );
    });
  }

  int _selectedMovieIndex = 0;
  int _selectedCinemaIndex = 0;
  int _selectedScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final providerColor = widget.provider == 'QFX'
        ? const Color(0xFF6366F1)
        : const Color(0xFF0EA5E9);

    return BaseServicePage(
      title: '${widget.provider} Booking',
      children: [
        // ServiceHeader(
        //   title: '${widget.provider} Cinema',
        //   subtitle: 'Book your favorite movies instantly',
        //   icon: Icons.movie_filter_rounded,
        //   color: providerColor,
        // ),
        // const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Horizontal Gallery
              _sectionTitle('Popular Now'),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedMovieIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMovieIndex = index),
                      child:
                          Container(
                                width: 130,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  borderRadius: AppTheme.radiusMedium,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isSelected
                                        ? [
                                            providerColor,
                                            providerColor.withValues(
                                              alpha: 0.7,
                                            ),
                                          ]
                                        : [
                                            isDark
                                                ? Colors.grey[850]!
                                                : Colors.grey[200]!,
                                            isDark
                                                ? Colors.grey[900]!
                                                : Colors.white,
                                          ],
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: providerColor.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    // Movie Poster Image
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: AppTheme.radiusMedium,
                                        child: Image.network(
                                          _moviePosters[index],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: isDark
                                                        ? Colors.grey[850]
                                                        : Colors.grey[200],
                                                  ),
                                        ),
                                      ),
                                    ),
                                    // Gradient Overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: AppTheme.radiusMedium,
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(
                                                alpha: 0.8,
                                              ),
                                            ],
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: providerColor,
                                                  width: 2.5,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.play_circle_fill_rounded,
                                            color: isSelected
                                                ? providerColor
                                                : Colors.white70,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _movies[index],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate(target: isSelected ? 1 : 0)
                              .scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1.0, 1.0),
                              ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Cinema & Screen - Modern Cards
              Row(
                children: [
                  Expanded(
                    child: _modernSelector(
                      label: 'Cinema',
                      value: _cinemas[_selectedCinemaIndex],
                      icon: Icons.location_on_rounded,
                      color: providerColor,
                      onTap: () => _showSelectionDialog(
                        'Select Cinema',
                        _cinemas,
                        _selectedCinemaIndex,
                        (i) => setState(() => _selectedCinemaIndex = i),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _modernSelector(
                      label: 'Screen',
                      value: _screens[_selectedScreenIndex],
                      icon: Icons.tv_rounded,
                      color: providerColor,
                      onTap: () => _showSelectionDialog(
                        'Select Screen',
                        _screens,
                        _selectedScreenIndex,
                        (i) => setState(() => _selectedScreenIndex = i),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Date Selection
              _sectionTitle('Show Date'),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final isSelected = _selectedDateIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDateIndex = index),
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? providerColor
                              : (isDark ? Colors.grey[900] : Colors.grey[100]),
                          borderRadius: AppTheme.radiusMedium,
                          border: Border.all(
                            color: isSelected
                                ? providerColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('MMM').format(date).toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat('dd').format(date),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Time Slots
              _sectionTitle('Available Time'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _timeSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTime = time),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? providerColor
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white),
                        borderRadius: AppTheme.radiusSmall,
                        border: Border.all(
                          color: isSelected
                              ? providerColor
                              : (isDark ? Colors.white12 : Colors.grey[300]!),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: providerColor.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Seats & Receipt Summary
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: AppTheme.radiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seats',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Rs ${_pricePerSeatController.text} / seat',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.grey[100],
                              borderRadius: AppTheme.radiusFull,
                            ),
                            child: Row(
                              children: [
                                _miniCountButton(Icons.remove, () {
                                  final seats = int.parse(
                                    _seatsController.text,
                                  );
                                  if (seats > 1) {
                                    setState(
                                      () => _seatsController.text = (seats - 1)
                                          .toString(),
                                    );
                                  }
                                }, providerColor),
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _seatsController.text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                _miniCountButton(Icons.add, () {
                                  final seats = int.parse(
                                    _seatsController.text,
                                  );
                                  if (seats < 10) {
                                    setState(
                                      () => _seatsController.text = (seats + 1)
                                          .toString(),
                                    );
                                  }
                                }, providerColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _dottedLine(isDark),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payment',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Rs ${_totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: providerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Proceed Button
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: providerColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  elevation: 8,
                  shadowColor: providerColor.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate().shimmer(delay: 2.seconds, duration: 1.5.seconds),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _modernSelector({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey[50],
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog(
    String title,
    List<String> options,
    int current,
    Function(int) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    options[index],
                    style: TextStyle(
                      fontWeight: index == current
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: index == current
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: widget.provider == 'QFX'
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF0EA5E9),
                        )
                      : null,
                  onTap: () {
                    onSelect(index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _miniCountButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _dottedLine(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: index.isEven
                  ? (isDark ? Colors.white10 : Colors.grey[300])
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
