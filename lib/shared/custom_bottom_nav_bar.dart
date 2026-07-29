import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        24,
        0,
        24,
        32,
      ), // Slightly higher bottom margin
      height: 76, // Slightly taller for comfortable touch targets
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        // A deep ambient shadow underneath the glass layer
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glassmorphic Background
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(
                    alpha: 0.65,
                  ), // Richer translucent black
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.12,
                    ), // The "glass shine" edge
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Iconsax.home_1, Iconsax.home, 'Home'),
                    _buildNavItem(
                      1,
                      Icons.room_service_rounded,
                      Icons.room_service_outlined,
                      'Services',
                    ),
                    const SizedBox(
                      width: 50,
                    ), // Spacing for the prominent center button
                    _buildNavItem(
                      3,
                      Icons.chat_bubble_rounded,
                      Icons.person_2_outlined,
                      'Stylist',
                    ),
                    _buildNavItem(
                      4,
                      Icons.settings_rounded,
                      Icons.settings_outlined,
                      'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Prominent Center Action Button
          Positioned(
            top: -20, // Floating out of the dock
            left: 0,
            right: 0,
            child: Center(child: _buildBookingButton(2)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppColors.surface : Colors.white54,
                size: isSelected ? 28 : 24, // Subtle scale bounce
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              style: TextStyle(
                color: isSelected
                    ? AppColors.surface
                    : Colors.transparent, // Hides text cleanly when inactive
                fontSize: isSelected ? 10 : 8,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton(int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 64, // Larger, more prominent touch target
        width: 64,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.clay : AppColors.sage,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppColors.clay : AppColors.sage).withValues(
                alpha: 0.4,
              ),
              blurRadius: 16,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.calendar_month_rounded,
          color: isSelected ? Colors.white : AppColors.surface,
          size: 30,
        ),
      ),
    );
  }
}
