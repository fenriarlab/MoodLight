import 'package:flutter/material.dart';
import '../../main.dart';
import 'app_colors.dart';

class ThemeColors {
  final bool isDark;
  final Color surface;
  final Color elevated;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color accent;

  ThemeColors({
    required this.isDark,
    required this.surface,
    required this.elevated,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.accent,
  });

  factory ThemeColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = MoodLightApp.of(context);
    final accent = appState?.accentColor ?? AppColors.primary;

    if (isDark) {
      return ThemeColors(
        isDark: true,
        surface: AppColors.darkSurface,
        elevated: AppColors.darkElevated,
        background: AppColors.darkBackground,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        divider: AppColors.divider,
        accent: accent,
      );
    } else {
      return ThemeColors(
        isDark: false,
        surface: Colors.white,
        elevated: const Color(0xFFF0F3F7),
        background: const Color(0xFFF5F7FA),
        textPrimary: const Color(0xFF1E222A),
        textSecondary: const Color(0xFF6E7480),
        divider: const Color(0xFFE2E7ED),
        accent: accent,
      );
    }
  }
}
