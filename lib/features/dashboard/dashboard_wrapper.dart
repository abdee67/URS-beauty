import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/shared/custom_bottom_nav_bar.dart';

class DashboardWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardWrapper({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when switching branches, for example in a bottom
      // navigation bar; if the user taps the item that is already selected,
      // navigate to the initial location of the branch (e.g. scroll to top).
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is the current branch (Home, Map, etc.)
      body: SizedBox.expand(child: navigationShell),
      // We overlay the custom nav bar using extendBody
      extendBody: true, 
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
      ),
    );
  }
}