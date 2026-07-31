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
      margin: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Background Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    width: 100,
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
                    width: 130,
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

                  // Content Row (|--- 2-Master Column Structure)
                  Row(
                    children: [
                      // Col 1: Weather (Left)
                      SizedBox(
                        width: 94,
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

                      // Divider Line
                      Container(
                        width: 1,
                        height: 60,
                        color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFF0E8FA),
                      ),

                      const SizedBox(width: 12),

                      // Col 2: Integrated Stats (2-Line Monthly Avg + Single Line Most Frequent)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 68),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Line 1: 月平均心情 (Title)
                              Text(
                                '月平均心情',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: tc.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),

                              // Line 2: Score + Emoji + Difference Badge
                              Row(
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
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFECE0),
                                      borderRadius: BorderRadius.circular(8),
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

                              const SizedBox(height: 8),

                              // Horizontal Separator Line
                              Container(
                                height: 1,
                                color: tc.isDark
                                    ? const Color(0xFF3C335A).withOpacity(0.6)
                                    : const Color(0xFFF3EDFC),
                              ),

                              const SizedBox(height: 8),

                              // Line 3: 最常出现
                              Row(
                                children: [
                                  Text(
                                    '最常出现：',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: tc.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _getMostTagEmoji(mostTag),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 4),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Cat Mascot Flush with Banner Bottom & Ears Popping Up Top
          Positioned(
            top: -20,
            bottom: 0,
            right: -2,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/cat_header.png',
                fit: BoxFit.fitHeight,
                errorBuilder: (ctx, err, stack) {
                  return Image.asset('assets/images/cat_footer.png', fit: BoxFit.fitHeight);
                },
              ),
            ),
          ),
        ],
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
