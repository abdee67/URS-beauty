import 'package:flutter/material.dart';
import 'package:flutter_onboarding/flutter_onboarding.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Adjust the import based on your package structure
// If you are using a different onboarding package, update the import accordingly, e.g.:
// import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
   List<IntroModel> pages(BuildContext context){
    return[
    IntroModel(
      title: Text( 'Discover Beauty Services',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF880E4F),
        fontFamily: 'PlayfairDisplay',
      ),
      textAlign: TextAlign.center,
      ),  
      description: Text( 'Explore our premium salon treatments\nfrom expert stylists',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF880E4F),
        fontFamily: 'PlayfairDisplay',
      ),
      textAlign: TextAlign.center,
      ),
      image: _buildImageWidget(context,'assets/images/onboarding1.png'),
    ),
    IntroModel(
      title: Text( 'Book Instantly',
      style:Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF880E4F),
        fontFamily: 'PlayfairDisplay',
      ),
      textAlign: TextAlign.center,
      ),
      description: Text( 'Schedule appointments with\ntop-rated professionals in seconds',
     textAlign: TextAlign.center,
     style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87,),
      ),
      image: _buildImageWidget(context,'assets/images/onboarding2.png'),
    ),

    IntroModel(
      title: Text( 'Personalized Experience',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF880E4F),
        fontFamily: 'PlayfairDisplay',
      ),
      textAlign: TextAlign.center,
      ),
      description: Text ('Get recommendations based\non your beauty preferences',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87,),
      ),
      image: _buildImageWidget(context,'assets/images/onboarding3.png'),
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
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          height:MediaQuery.of(context).size.height * 0.5,
        ).animate()
          .fadeIn(duration: const Duration(milliseconds: 500))
          .scale().move(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            begin: const Offset(0, 50),
      ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterOnBoarding(
        pages: pages(context),
        onDone: () {
         context.go('/login');
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool('showOnboarding', false);
          });
        },
      ),
    );
  }
}