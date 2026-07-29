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

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8C52EE), Color(0xFFA259FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> cardAmbientShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.35) : const Color(0xFF9D75F0).withOpacity(0.18),
        blurRadius: 24,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> purpleGlowShadow() {
    return [
      BoxShadow(
        color: const Color(0xFF8C52EE).withOpacity(0.38),
        blurRadius: 14,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
