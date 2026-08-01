import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../../../core/utils/tag_helper.dart';
import '../../data/models/mood_diary_model.dart';

class StatsTab extends StatefulWidget {
  final List<MoodDiaryModel> diaries;

  const StatsTab({
    super.key,
    required this.diaries,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _selectedPeriod = 0; // 0: 7天, 1: 30天, 2: 本月
  int _touchedPieIndex = -1;

  int get _daysCount {
    if (_selectedPeriod == 0) return 7;
    if (_selectedPeriod == 1) return 30;
    return DateTime.now().day; // 本月至今天数
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    final days = _daysCount;

    // Filter diaries for selected timeframe
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    final filteredDiaries = widget.diaries.where((d) => d.createdAt.isAfter(startDate.subtract(const Duration(days: 1)))).toList();

    final avgScore = MoodCalculator.calculateOverallAverage(filteredDiaries);
    final trendPoints = MoodCalculator.getMoodTrendForDays(widget.diaries, days);

    // Weather text mapping with l10n
    String weatherText = l10n?.weatherClear ?? '多云转晴 · 平稳向好';
    if (avgScore >= 3.0) {
      weatherText = l10n?.weatherSunny ?? '晴空万里 · 阳光璀璨';
    } else if (avgScore >= 1.5) {
      weatherText = l10n?.weatherClear ?? '多云转晴 · 平稳向好';
    } else if (avgScore >= 0.0) {
      weatherText = l10n?.weatherBreeze ?? '微风拂面 · 平静恬淡';
    } else if (avgScore >= -2.0) {
      weatherText = l10n?.weatherRain ?? '偶尔阵雨 · 小有波折';
    } else {
      weatherText = l10n?.weatherStorm ?? '阴雨连绵 · 释放压力';
    }

    // Mood Distribution Calculation
    int posCount = 0;
    int neuCount = 0;
    int negCount = 0;
    for (var d in filteredDiaries) {
      if (d.score >= 1) {
        posCount++;
      } else if (d.score >= -1) {
        neuCount++;
      } else {
        negCount++;
      }
    }
    final totalCount = filteredDiaries.isEmpty ? 1 : filteredDiaries.length;
    final double posRatio = posCount / totalCount;
    final double neuRatio = neuCount / totalCount;
    final double negRatio = negCount / totalCount;

    // Tag Frequencies Ranking
    final Map<String, int> tagCounts = {};
    for (var d in filteredDiaries) {
      for (var t in d.tags) {
        tagCounts[t] = (tagCounts[t] ?? 0) + 1;
      }
    }
    final sortedTags = tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(4).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Timeframe Segmented Control Bar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: tc.isDark ? const Color(0xFF282239) : const Color(0xFFF3ECFE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildSegmentBtn(0, l10n?.period7Days ?? '近 7 天', tc),
              _buildSegmentBtn(1, l10n?.period30Days ?? '近 30 天', tc),
              _buildSegmentBtn(2, l10n?.periodThisMonth ?? '本月至今', tc),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Hero Overview Stat Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: tc.isDark
                ? LinearGradient(
                    colors: [const Color(0xFF2B243F), const Color(0xFF201B2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [const Color(0xFFFFFFFF), const Color(0xFFFAF5FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFEFE8FB),
            ),
            boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.moodIndexTitle ?? '情绪气象指数',
                    style: TextStyle(
                      color: tc.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        avgScore > 0 ? "+${avgScore.toStringAsFixed(1)}" : avgScore.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getMoodColor(avgScore.round()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.scoreUnit ?? '分',
                        style: TextStyle(
                          fontSize: 13,
                          color: tc.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C52EE).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      weatherText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C52EE),
                      ),
                    ),
                  ),
                ],
              ),

              // Glowing Emoji Circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tc.isDark
                      ? const Color(0xFF382F4E).withOpacity(0.6)
                      : const Color(0xFFF5EFFF),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getMoodColor(avgScore.round()).withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    AppColors.getMoodEmoji(avgScore.round()),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Lux Smooth Curve Chart Card
        Container(
          height: 270,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFEFE8FB),
            ),
            boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.moodTrendCurveTitle ?? '心情波动趋势曲线',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: tc.textPrimary,
                    ),
                  ),
                  Text(
                    l10n?.baselineZero ?? '基准线 (0分)',
                    style: TextStyle(
                      fontSize: 11,
                      color: tc.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (val) {
                        if (val == 0) {
                          return FlLine(
                            color: const Color(0xFF8C52EE).withOpacity(0.35),
                            strokeWidth: 1.5,
                            dashArray: [4, 4],
                          );
                        }
                        return FlLine(
                          color: tc.isDark ? const Color(0xFF332D45) : const Color(0xFFF0E8FA),
                          strokeWidth: 0.8,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) {
                            if (val == 5) return Text('+5', style: TextStyle(fontSize: 10, color: tc.textSecondary));
                            if (val == 0) return Text(' 0', style: TextStyle(fontSize: 10, color: tc.textSecondary));
                            if (val == -5) return Text('-5', style: TextStyle(fontSize: 10, color: tc.textSecondary));
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: (days / 6).clamp(1.0, 10.0),
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
                            if (idx >= 0 && idx < trendPoints.length) {
                              final dt = trendPoints[idx].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${dt.month}/${dt.day}',
                                  style: TextStyle(fontSize: 10, color: tc.textSecondary),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: -5.5,
                    maxY: 5.5,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: const Color(0xFF2D1F47),
                        tooltipRoundedRadius: 12,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            if (idx >= 0 && idx < trendPoints.length) {
                              final p = trendPoints[idx];
                              final emoji = AppColors.getMoodEmoji(p.avgScore.round());
                              final valStr = p.avgScore > 0 ? "+${p.avgScore.toStringAsFixed(1)}" : p.avgScore.toStringAsFixed(1);
                              final ptsUnit = l10n?.scoreUnit ?? '分';
                              return LineTooltipItem(
                                '${p.date.month}/${p.date.day}\n$emoji $valStr$ptsUnit',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: trendPoints.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.avgScore);
                        }).toList(),
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: const Color(0xFF8C52EE),
                        barWidth: 3.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2.5,
                              strokeColor: const Color(0xFF8C52EE),
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8C52EE).withOpacity(0.35),
                              const Color(0xFF8C52EE).withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Mood Distribution Doughnut Chart Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFEFE8FB),
            ),
            boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.moodDistributionTitle ?? '情绪构成分布',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: tc.textPrimary,
                    ),
                  ),
                  Text(
                    '共 ${filteredDiaries.length} 篇',
                    style: TextStyle(
                      fontSize: 12,
                      color: tc.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (filteredDiaries.isEmpty)
                Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    '暂无当前时间段的心情记录',
                    style: TextStyle(color: tc.textSecondary, fontSize: 13),
                  ),
                )
              else
                Row(
                  children: [
                    // Left: Doughnut PieChart with Center Halo Mascot
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      _touchedPieIndex = -1;
                                      return;
                                    }
                                    _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              startDegreeOffset: 270,
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: [
                                // Section 0: 欢快 (Sunny)
                                PieChartSectionData(
                                  color: const Color(0xFFFFB74D),
                                  value: posCount > 0 ? posCount.toDouble() : 0.001,
                                  title: '',
                                  radius: _touchedPieIndex == 0 ? 22 : 16,
                                ),
                                // Section 1: 平静 (Calm)
                                PieChartSectionData(
                                  color: const Color(0xFF8C52EE),
                                  value: neuCount > 0 ? neuCount.toDouble() : 0.001,
                                  title: '',
                                  radius: _touchedPieIndex == 1 ? 22 : 16,
                                ),
                                // Section 2: 低落 (Rainy)
                                PieChartSectionData(
                                  color: const Color(0xFF5C6BC0),
                                  value: negCount > 0 ? negCount.toDouble() : 0.001,
                                  title: '',
                                  radius: _touchedPieIndex == 2 ? 22 : 16,
                                ),
                              ],
                            ),
                          ),

                          // Center Mascot Emoji & Dynamic Ratio
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _touchedPieIndex == 0
                                    ? '🌞'
                                    : (_touchedPieIndex == 1
                                        ? '🌿'
                                        : (_touchedPieIndex == 2
                                            ? '🌧️'
                                            : (posCount >= neuCount && posCount >= negCount
                                                ? '🌞'
                                                : (neuCount >= negCount ? '🌿' : '🌧️')))),
                                style: const TextStyle(fontSize: 26),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _touchedPieIndex == 0
                                    ? '${(posRatio * 100).toStringAsFixed(0)}%'
                                    : (_touchedPieIndex == 1
                                        ? '${(neuRatio * 100).toStringAsFixed(0)}%'
                                        : (_touchedPieIndex == 2
                                            ? '${(negRatio * 100).toStringAsFixed(0)}%'
                                            : '${((posCount >= neuCount && posCount >= negCount ? posRatio : (neuCount >= negCount ? neuRatio : negRatio)) * 100).toStringAsFixed(0)}%')),
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
                    const SizedBox(width: 20),

                    // Right: Rich Vertical Legend Rows
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRichLegendRow(
                            label: l10n?.distributionSunny ?? '🌞 欢快',
                            ratioStr: '${(posRatio * 100).toStringAsFixed(0)}%',
                            countStr: '$posCount 篇',
                            color: const Color(0xFFFFB74D),
                            isSelected: _touchedPieIndex == 0,
                            tc: tc,
                            onTap: () => setState(() => _touchedPieIndex = _touchedPieIndex == 0 ? -1 : 0),
                          ),
                          const SizedBox(height: 10),
                          _buildRichLegendRow(
                            label: l10n?.distributionCalm ?? '🌿 平静',
                            ratioStr: '${(neuRatio * 100).toStringAsFixed(0)}%',
                            countStr: '$neuCount 篇',
                            color: const Color(0xFF8C52EE),
                            isSelected: _touchedPieIndex == 1,
                            tc: tc,
                            onTap: () => setState(() => _touchedPieIndex = _touchedPieIndex == 1 ? -1 : 1),
                          ),
                          const SizedBox(height: 10),
                          _buildRichLegendRow(
                            label: l10n?.distributionRainy ?? '🌧️ 低落',
                            ratioStr: '${(negRatio * 100).toStringAsFixed(0)}%',
                            countStr: '$negCount 篇',
                            color: const Color(0xFF5C6BC0),
                            isSelected: _touchedPieIndex == 2,
                            tc: tc,
                            onTap: () => setState(() => _touchedPieIndex = _touchedPieIndex == 2 ? -1 : 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. Tag Factors Ranking & AI Insights Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: tc.isDark ? const Color(0xFF3C335A) : const Color(0xFFEFE8FB),
            ),
            boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.moodFactorTitle ?? '情绪影响因素',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: tc.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (topTags.isEmpty)
                Text(
                  l10n?.noTagData ?? '🌱 暂无足够标签记录，快去记一笔吧！',
                  style: TextStyle(color: tc.textSecondary, fontSize: 13),
                )
              else
                Column(
                  children: topTags.map((entry) {
                    final tagRatio = entry.value / (filteredDiaries.isEmpty ? 1 : filteredDiaries.length);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              TagHelper.getLocalizedTag(context, entry.key),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tc.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: tagRatio.clamp(0.05, 1.0),
                                backgroundColor: tc.isDark ? const Color(0xFF332D45) : const Color(0xFFF3EDFC),
                                color: const Color(0xFF8C52EE),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n?.timesCount(entry.value.toString()) ?? '${entry.value}次',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tc.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 14),

              // Warm Psychological Insight Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tc.isDark ? const Color(0xFF262036) : const Color(0xFFF9F5FE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF8C52EE).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getInsightMessage(context, avgScore, topTags),
                        style: TextStyle(
                          fontSize: 12,
                          color: tc.isDark ? const Color(0xFFC7BEDE) : const Color(0xFF6E5D90),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSegmentBtn(int index, String label, ThemeColors tc) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = index;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8C52EE) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8C52EE).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String percent, Color color, ThemeColors tc) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: tc.textSecondary),
        ),
        const SizedBox(width: 4),
        Text(
          percent,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tc.textPrimary),
        ),
      ],
    );
  }

  Widget _buildRichLegendRow({
    required String label,
    required String ratioStr,
    required String countStr,
    required Color color,
    required bool isSelected,
    required ThemeColors tc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: tc.textPrimary,
                ),
              ),
            ),
            Text(
              ratioStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($countStr)',
              style: TextStyle(
                fontSize: 11,
                color: tc.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInsightMessage(BuildContext context, double avgScore, List<MapEntry<String, int>> topTags) {
    final l10n = AppLocalizations.of(context);
    final rawTag = topTags.isNotEmpty ? topTags.first.key : (l10n?.tagLife ?? '生活');
    final topTagStr = TagHelper.getLocalizedTag(context, rawTag);
    if (avgScore >= 2.0) {
      return l10n?.insightHigh(topTagStr) ?? '这段时间你的心情非常阳光欢快！在【$topTagStr】维度感受到了满满的喜悦与力量 🌟';
    } else if (avgScore >= 0.0) {
      return l10n?.insightNormal(topTagStr) ?? '这段时间你的心情平稳且充满秩序，在【$topTagStr】方面保持着极佳的节奏 🌿';
    } else {
      return l10n?.insightLow(topTagStr) ?? '这段时间小有波折，在【$topTagStr】方面可能有些压力，记得给自己放个假咖啡泡起来 ☕';
    }
  }
}
