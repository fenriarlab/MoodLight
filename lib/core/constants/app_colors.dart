import 'package:flutter/material.dart';

/// Calm Mood Design System Colors
class AppColors {
  // Brand Primary & Surfaces (Dark Theme First)
  static const Color primary = Color(0xFF4F7FFF); // Calm Blue
  static const Color primaryLight = Color(0xFF7CA0FF);

  // Curated Preset Accent Colors
  static const List<Color> presetAccentColors = [
    Color(0xFF4F7FFF), // 静谧蓝
    Color(0xFFFFB84D), // 温暖橙
    Color(0xFF2ECC71), // 极光绿
    Color(0xFF9B59B6), // 梦幻紫
    Color(0xFFFF6B6B), // 玫瑰粉
  ];
  
  static const Color darkBackground = Color(0xFF111214); // Primary Background
  static const Color darkSurface = Color(0xFF191C22);    // Cards & Lists
  static const Color darkElevated = Color(0xFF22262E);   // Bottom Sheets & Modals

  // Mood Score Palette (-5 to +5)
  static const Color moodVeryHappy = Color(0xFFFF6B6B);  // +3 to +5 (Red/Warm)
  static const Color moodHappy = Color(0xFFFFB84D);      // +1 to +2 (Orange/Gold)
  static const Color moodNeutral = Color(0xFF95A5A6);    // 0 (Neutral Gray)
  static const Color moodSad = Color(0xFF7EA1C4);        // -1 to -2 (Soft Blue)
  static const Color moodVerySad = Color(0xFF5D8AA8);    // -3 to -5 (Deep Blue)

  // Neutral Typography
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF9297A5);
  static const Color textMuted = Color(0xFF656B78);
  static const Color divider = Color(0xFF292E38);

  static Color getMoodColor(int score) {
    if (score >= 3) return moodVeryHappy;
    if (score >= 1) return moodHappy;
    if (score == 0) return moodNeutral;
    if (score >= -2) return moodSad;
    return moodVerySad;
  }

  static String getMoodEmoji(int score) {
    switch (score) {
      case 5: return '🤩';
      case 4: return '😁';
      case 3: return '😄';
      case 2: return '😊';
      case 1: return '🙂';
      case 0: return '😐';
      case -1: return '😕';
      case -2: return '😞';
      case -3: return '😔';
      case -4: return '😢';
      case -5: return '😭';
      default: return '😐';
    }
  }

  static String getMoodText(int score) {
    if (score >= 4) return '非常开心';
    if (score >= 2) return '开心';
    if (score >= 1) return '还不错';
    if (score == 0) return '平淡';
    if (score >= -2) return '有点不开心';
    if (score >= -4) return '不开心';
    return '很难过';
  }
}
