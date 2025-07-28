import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Luxury Redefined',
      description: 'Experience premium beauty treatments\ncrafted just for you',
      image: 'assets/images/onboarding1.png',
      color: Color(0xFFE91E63),
    ),
    OnboardingPage(
      title: 'Instant Booking',
      description: 'Reserve with top stylists\nin just 3 taps',
      image: 'assets/images/onboarding2.png',
      color: Color(0xFF9C27B0),
    ),
    OnboardingPage(
      title: 'Your Style Profile',
      description: 'Personalized recommendations\nbased on your preferences',
      image: 'assets/images/onboarding3.png',
      color: Color(0xFF673AB7),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // White Background
          Container(color: Colors.white),

          // Main Content
          Column(
            children: [
              // Header with Left Logo and Skip Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo at Left
                      Hero(
                        tag: 'app-logo',
                        child:
                            Image.asset(
                                  'assets/images/logo.png',
                                  width: 80,
                                  height: 80,
                                )
                                .animate()
                                .scale(delay: 300.ms)
                                .move(
                                  duration: 300.ms,
                                  curve: Curves.easeInOut,
                                  begin: const Offset(0, 30),
                                ),
                      ),

                      // Skip Button
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _skipToEnd,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: _pages[_currentPage].color,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),

              // Bottom Navigation
              _buildBottomNavigation(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(flex: 3, child: _buildImageWidget(page.image, page.color)),

          // Text Content
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Animated Title
                if (_currentPage == index)
                  AnimatedTextKit(
                    key: ValueKey(page.title),
                    animatedTexts: [
                      TyperAnimatedText(
                        page.title,
                        textStyle: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: page.color,
                              fontFamily: 'BitcountPropSingle',
                              height: 1.2,
                            ),
                        speed: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                      ),
                    ],
                    isRepeatingAnimation: true,
                    repeatForever: true,
                    displayFullTextOnTap: true,
                    pause: Duration.zero,
                  )
                else
                  Text(
                    page.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: page.color,
                      fontFamily: 'BitcountPropSingle',
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PlayfairDisplay',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String assetPath, Color color) {
    return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $assetPath');
                print('Error: $error');
                return Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: color,
                  ),
                );
              },
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack)
        .move(
          duration: 600.ms,
          curve: Curves.easeInOut,
          begin: const Offset(0, 30),
        );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? _pages[_currentPage].color
                      : _pages[_currentPage].color.withOpacity(0.3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pages[_currentPage].color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: _pages[_currentPage].color.withOpacity(0.3),
              ),
              child: Text(
                _currentPage == _pages.length - 1
                    ? 'Begin Beauty Journey'
                    : 'Next',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
