import 'package:flutter/material.dart';
import 'package:qcraft/core/constants/app_colors.dart';

class AppTheme {
  static final mainTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.bg,
    useMaterial3: true,
    cardColor: AppColors.shade100,
    fontFamily: "ProximaNova",
    chipTheme: ChipThemeData(
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.white,
      filled: true,
      border: InputBorder.none,
      isDense: true,
      // hintStyle: AppTextStyles.hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(5),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(5),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppColors.bg),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primary,
        textStyle: TextStyle(
          color: AppColors.white,
        ),
      ),
    ),
  );
}
