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

    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    final prevMonthDiaries = diaries
        .where((d) => d.createdAt.year == prevMonth.year && d.createdAt.month == prevMonth.month)
        .toList();

    final avgScore = MoodCalculator.calculateOverallAverage(monthDiaries);
    final prevAvgScore = MoodCalculator.calculateOverallAverage(prevMonthDiaries);
    final scoreDiff = avgScore - prevAvgScore;
    final diffFormatted = scoreDiff >= 0 ? "↑ ${scoreDiff.toStringAsFixed(1)}" : "↓ ${(-scoreDiff).toStringAsFixed(1)}";

    final avgFormatted = avgScore > 0 ? "+${avgScore.toStringAsFixed(1)}" : avgScore.toStringAsFixed(1);
    final mostTag = MoodCalculator.getMostFrequentTag(diaries);

    // Weather mapping
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
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFEFE8FB),
          width: 1,
        ),
        boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Left Warm Ambient Glow Gradient Background
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 110,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tc.isDark
                        ? [const Color(0xFF33271F).withOpacity(0.5), Colors.transparent]
                        : [const Color(0xFFFFF4E5), Colors.white.withOpacity(0.0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Right Warm Sunbeam Ambient Glow Background for Cat Mascot
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 140,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tc.isDark
                        ? [Colors.transparent, const Color(0xFF382A45).withOpacity(0.6)]
                        : [Colors.white.withOpacity(0.0), const Color(0xFFFFF3E0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Content Columns Layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  // Col 1: Weather (Far Left)
                  Expanded(
                    flex: 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${selectedMonth.month}月情绪天气',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF5A4B7C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weatherEmoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          weatherText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: tc.isDark ? Colors.white : const Color(0xFF2D1F47),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider 1
                  Container(
                    width: 1,
                    height: 50,
                    color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFF0E8FA),
                  ),

                  // Col 2: Monthly Avg Score (Middle Left)
                  Expanded(
                    flex: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '月平均心情',
                          style: TextStyle(
                            fontSize: 11,
                            color: tc.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              avgFormatted,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8C52EE),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              AppColors.getMoodEmoji(avgScore.round()),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECE0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '较上月 $diffFormatted',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE67E22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider 2
                  Container(
                    width: 1,
                    height: 50,
                    color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFF0E8FA),
                  ),

                  // Col 3: Most Frequent Tag (Middle Right)
                  Expanded(
                    flex: 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '最常出现',
                          style: TextStyle(
                            fontSize: 11,
                            color: tc.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8C52EE).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getMostTagEmoji(mostTag),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mostTag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: tc.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Space for Cat Mascot on the Far Right
                  const SizedBox(width: 72),
                ],
              ),
            ),

            // Col 4: Far Right Cat Mascot (cat_header.png)
            Positioned(
              right: -6,
              bottom: -10,
              top: -6,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/cat_header.png',
                  height: 95,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) {
                    return Image.asset('assets/images/cat_footer.png', height: 95, fit: BoxFit.contain);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMostTagEmoji(String tag) {
    if (tag.contains('工作')) return '💼';
    if (tag.contains('学习')) return '📚';
    if (tag.contains('家庭')) return '🏠';
    if (tag.contains('恋爱')) return '❤️';
    if (tag.contains('平静')) return '🌿';
    return '✨';
  }
}
