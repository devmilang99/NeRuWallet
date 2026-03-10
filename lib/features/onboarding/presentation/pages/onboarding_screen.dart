import 'package:flutter/material.dart';
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
      description: "Experience professional digital payments with high-level security protocols and enterprise scalability.",
      icon: Icons.security_rounded,
    ),
    OnboardingItem(
      title: "Real-time Transactions",
      description: "Send and receive money instantly with zero latency. Secure, fast, and simple.",
      icon: Icons.bolt_rounded,
    ),
    OnboardingItem(
      title: "Merchant Ecosystem",
      description: "Integrate with local and international merchants with simple APIs and effortless bill payments.",
      icon: Icons.account_balance_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            children: [
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
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      dotColor: AppTheme.textHintColor,
                      activeDotColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPageIndex == _items.length - 1) {
                        context.go('/auth/login');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPageIndex == _items.length - 1
                          ? "Get Started"
                          : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentPageIndex < _items.length - 1)
                    TextButton(
                      onPressed: () {
                        context.go('/auth/login');
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: AppTheme.textHintColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.icon,
            size: 100,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 60),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 28,
                color: AppTheme.textBodyColor,
              ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textHintColor,
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
