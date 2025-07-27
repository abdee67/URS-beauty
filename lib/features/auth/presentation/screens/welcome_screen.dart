import 'package:flutter/material.dart';
import 'package:flutter_onboarding/flutter_onboarding.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<IntroModel> _buildPages(BuildContext context) {
    return [
      _buildPage(
        context,
        title: 'Luxury Redefined',
        description:
            'Experience premium beauty treatments\ncrafted just for you',
        image: 'assets/images/onboarding1.png',
      ),
      _buildPage(
        context,
        title: 'Instant Booking',
        description: 'Reserve with top stylists\nin just 3 taps',
        image: 'assets/images/onboarding2.png',
      ),
      _buildPage(
        context,
        title: 'Your Style Profile',
        description: 'Personalized recommendations\nbased on your preferences',
        image: 'assets/images/onboarding3.png',
      ),
    ];
  }

  IntroModel _buildPage(
    BuildContext context, {
    required String title,
    required String description,
    required String image,
  }) {
    return IntroModel(
      title: Text(
        title,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF880E4F),
          fontFamily: 'PlayfairDisplay',
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
      description: Text(
        description,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
        textAlign: TextAlign.center,
      ),
      image: _buildImageWidget(context, image),
    );
  }

  Widget _buildImageWidget(BuildContext context, String assetPath) {
    return Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.pink.shade50,
                Colors.pink.shade100,
                Colors.pink.shade200,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.9),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedContainer(
            duration: 1000.ms,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink.shade50,
                  Colors.pink.shade100,
                  Colors.pink.shade200,
                ],
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),
          // Floral Decoration Elements
          Positioned(
            top: -50,
            right: -50,
            child: Image.asset(
              'assets/images/floral.png',
              width: 200,
              color: Colors.white.withOpacity(0.15),
            ).animate().rotate(duration: 30.seconds),
          ),

          // Main Content
          Column(
            children: [
              // App Logo
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Hero(
                    tag: 'app-logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                    ).animate().scale(delay: 300.ms),
                  ),
                ),
              ),

              // Onboarding Pages
              Expanded(
                child: FlutterOnBoarding(
                  pageController: _pageController,
                  pages: _buildPages(context),
                  onDone: () => _completeOnboarding(context),
                  skipButtonText: 'SKIP',
                  nextButtonText: 'NEXT',
                  doneButtonText: 'BEGIN BEAUTY JOURNEY',
                  indicatorActiveColor: const Color(0xFF880E4F),
                  indicatorInactiveColor: Colors.pink.shade200,
                ),
              ),
            ],
          ),

          // Decorative Elements
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/wave.png', fit: BoxFit.cover)
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack)
                .move(
                  duration: 600.ms,
                  curve: Curves.easeInOut,
                  begin: const Offset(0, 30),
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (context.mounted) {
      context.go('/login');
    }
  }
}
