import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../data/models/mood_diary_model.dart';

class StatsTab extends StatelessWidget {
  final List<MoodDiaryModel> diaries;

  const StatsTab({
    super.key,
    required this.diaries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);

    final avgScore = MoodCalculator.calculateOverallAverage(diaries);
    final trendPoints = MoodCalculator.getMoodTrendForDays(diaries, 7);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overview Stat Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tc.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n?.averageMood ?? '近 7 天平均心情指数', style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    avgScore > 0 ? "+${avgScore.toStringAsFixed(1)}" : avgScore.toStringAsFixed(1),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.getMoodColor(avgScore.round())),
                  ),
                ],
              ),
              Text(
                AppColors.getMoodEmoji(avgScore.round()),
                style: const TextStyle(fontSize: 48),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Trend Chart Card
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tc.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n?.trendChartTitle ?? '近 7 天心情波动趋势', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: tc.textPrimary)),
              const SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: -5,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: trendPoints.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.avgScore);
                        }).toList(),
                        isCurved: true,
                        color: tc.accent,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
