import 'package:flutter/material.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../data/models/mood_diary_model.dart';

class EmotionWeatherCard extends StatelessWidget {
  final DateTime selectedMonth;
  final List<MoodDiaryModel> diaries;

  const EmotionWeatherCard({
    super.key,
    required this.selectedMonth,
    required this.diaries,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final monthDiaries = diaries
        .where((d) => d.createdAt.year == selectedMonth.year && d.createdAt.month == selectedMonth.month)
        .toList();

    final avgScore = MoodCalculator.calculateOverallAverage(monthDiaries);

    // Extract weather emoji and text
    String weatherEmoji = '⛅';
    String weatherText = '多云转晴';
    if (avgScore >= 3.0) {
      weatherEmoji = '☀️';
      weatherText = '晴空万里';
    } else if (avgScore >= 1.5) {
      weatherEmoji = '⛅';
      weatherText = '多云转晴';
    } else if (avgScore >= 0.0) {
      weatherEmoji = '🌤️';
      weatherText = '微风拂面';
    } else if (avgScore >= -2.0) {
      weatherEmoji = '🌧️';
      weatherText = '偶尔阵雨';
    } else {
      weatherEmoji = '🌩️';
      weatherText = '阴雨连绵';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: tc.isDark
            ? LinearGradient(
                colors: [const Color(0xFF282239), const Color(0xFF1E1A2C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [const Color(0xFFFFFFFF), const Color(0xFFFFF8F0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFF3E7DB),
          width: 1,
        ),
        boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Top Title (e.g. "7月情绪天气")
          Text(
            '${selectedMonth.month}月情绪天气',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Center Hero Weather Graphic
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tc.isDark
                  ? const Color(0xFF382F4E).withOpacity(0.5)
                  : const Color(0xFFFFF3E0).withOpacity(0.6),
            ),
            child: Center(
              child: Text(
                weatherEmoji,
                style: const TextStyle(fontSize: 44),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Bottom Main Weather Conclusion (e.g. "多云转晴")
          Text(
            weatherText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: tc.isDark ? Colors.white : const Color(0xFF2D1F47),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
