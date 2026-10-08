import 'package:flutter/material.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/core/constants/app_sizes.dart';

class AppButtonStyles {
  AppButtonStyles._();

  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.clay,
    foregroundColor: Colors.white,
    disabledBackgroundColor: AppColors.rose,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
    ),
  );

  static final ButtonStyle outlined = OutlinedButton.styleFrom(
    foregroundColor: AppColors.clay,
    side: const BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
    ),
  );
}
