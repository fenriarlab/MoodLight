import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    final weatherTitle = MoodCalculator.getEmotionWeatherTitle(avgScore);
    final weatherSubtitle = MoodCalculator.getEmotionWeatherSubtitle(avgScore);
    final mostTag = MoodCalculator.getMostFrequentTag(diaries);

    final avgFormatted = avgScore > 0 ? "+${avgScore.toStringAsFixed(1)}" : avgScore.toStringAsFixed(1);
    final progressValue = ((avgScore + 5) / 10).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: tc.isDark
                  ? LinearGradient(
                      colors: [const Color(0xFF26203B), const Color(0xFF1F1B2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [const Color(0xFFF3ECFE), const Color(0xFFECE2FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFE5D8FF),
                width: 1,
              ),
              boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column: Weather Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedMonth.month}月情绪天气',
                        style: TextStyle(
                          fontSize: 12,
                          color: tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              weatherTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: tc.isDark ? Colors.white : const Color(0xFF332057),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weatherSubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: tc.isDark ? const Color(0xFF9E95BD) : const Color(0xFF8C7DAE),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 80), // Space for Cat Mascot in middle

                // Right Column: Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '月平均心情',
                              style: TextStyle(
                                fontSize: 10,
                                color: tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(AppColors.getMoodEmoji(avgScore.round()), style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  avgFormatted,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: tc.isDark ? Colors.white : const Color(0xFF332057),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '最常出现',
                              style: TextStyle(
                                fontSize: 10,
                                color: tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ECC71).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                mostTag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF27AE60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rounded Progress Bar
                    Container(
                      width: 110,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFE2D4FF),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressValue,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9B59B6), Color(0xFF4F7FFF)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Overlapping Cat Mascot Leaning Top
          Positioned(
            top: -26,
            left: 115,
            child: Image.asset(
              'assets/images/cat_header.png',
              height: 72,
              fit: BoxFit.contain,
              colorBlendMode: tc.isDark ? BlendMode.dstIn : BlendMode.multiply,
              color: tc.isDark ? null : Colors.white.withOpacity(0.95),
              errorBuilder: (ctx, err, stack) {
                return const Text('🐱', style: TextStyle(fontSize: 40));
              },
            ),
          ),
        ],
      ),
    );
  }
}
