import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "Secure & Scalable",
      description:
          "Experience professional digital payments with high-level security protocols and enterprise scalability.",
      icon: Icons.security_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=2070&auto=format&fit=crop',
    ),
    OnboardingItem(
      title: "Real-time Transactions",
      description:
          "Send and receive money instantly with zero latency. Secure, fast, and simple.",
      icon: Icons.bolt_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070&auto=format&fit=crop',
    ),
    OnboardingItem(
      title: "Merchant Ecosystem",
      description:
          "Integrate with local and international merchants with simple APIs and effortless bill payments.",
      icon: Icons.account_balance_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=2026&auto=format&fit=crop',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/theme-selection'),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms),
              // Page View for Slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_items[index]);
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Indicator & Buttons
              Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _items.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 3,
                      dotColor: isDark ? Colors.white24 : Colors.black12,
                      activeDotColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPageIndex == _items.length - 1) {
                        context.go('/theme-selection');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.fastOutSlowIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusLarge,
                      ),
                    ),
                    child: Text(
                      _currentPageIndex == _items.length - 1
                          ? "Get Started"
                          : "Next",
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5, end: 0),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Icon(item.icon, size: 100, color: AppTheme.primaryColor)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                duration: 2.seconds,
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                curve: Curves.easeInOut,
              ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 60),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppTheme.textBodyColor,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
              height: 1.6,
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final String imageUrl;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.imageUrl,
  });
}
