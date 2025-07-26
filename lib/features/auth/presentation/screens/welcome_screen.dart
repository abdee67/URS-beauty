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
  List<IntroModel> pages(BuildContext context) {
    return [
      IntroModel(
        title: Text(
          'Discover Beauty Services',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF880E4F),
            fontFamily: 'PlayfairDisplay',
          ),
          textAlign: TextAlign.center,
        ),
        description: Text(
          'Explore our premium salon treatments\nfrom expert stylists',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF880E4F),
            fontFamily: 'PlayfairDisplay',
          ),
          textAlign: TextAlign.center,
        ),
        image: _buildImageWidget(context, 'assets/images/welcome.png'),
      ),
      IntroModel(
        title: Text(
          'Book Instantly',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF880E4F),
            fontFamily: 'PlayfairDisplay',
          ),
          textAlign: TextAlign.center,
        ),
        description: Text(
          'Schedule appointments with\ntop-rated professionals in seconds',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.black87),
        ),
        image: _buildImageWidget(context, 'assets/images/image2.png'),
      ),

      IntroModel(
        title: Text(
          'Personalized Experience',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF880E4F),
            fontFamily: 'PlayfairDisplay',
          ),
          textAlign: TextAlign.center,
        ),
        description: Text(
          'Get recommendations based\non your beauty preferences',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.black87),
        ),
        image: _buildImageWidget(context, 'assets/images/image1.png'),
      ),
    ];
  }

  Widget _buildImageWidget(BuildContext context, String assetPath) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child:
            Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.4,
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale()
                .move(
                  duration: 500.ms,
                  curve: Curves.easeInOut,
                  begin: const Offset(0, 50),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                    begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink.shade100,
                  Colors.pink.shade200,
                ],
              ),
            ),
          ),
      FlutterOnBoarding(
        pages: pages(context),
        onDone: () async{
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('hasSeenOnboarding', true);
          if(context.mounted){
 context.go('/login');
          }
          },
          skipButtonText:'Skip',
          nextButtonText: 'Next',
          doneButtonText: 'Get Started',
          skipButtonColor: const Color(0xFF880E4F),
          nextButtonColor: const Color(0xFF880E4F),
          indicatorActiveColor: const Color.fromARGB(255, 133, 33, 86),
          indicatorInactiveColor: Colors.pink.shade300,
          
      ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
         child: Text(
                'Welcome to URS BEAUTY',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.pink.shade700,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                  shadows: [
                    Shadow(
                      color: Colors.pink.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
          ),
    );
  }
}
