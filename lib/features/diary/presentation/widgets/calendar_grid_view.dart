import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../data/models/mood_diary_model.dart';

class MoodPaletteInfo {
  final Color baseColor;
  final Color textColor;
  final Color dotColor;

  MoodPaletteInfo({
    required this.baseColor,
    required this.textColor,
    required this.dotColor,
  });
}

class CalendarGridView extends StatelessWidget {
  final List<MoodDiaryModel> diaries;
  final DateTime selectedMonth;
  final DateTime selectedDate;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onRetroactiveRecord;
  final Function(MoodDiaryModel) onDeleteDiary;
  final VoidCallback? onTrendTap;

  const CalendarGridView({
    super.key,
    required this.diaries,
    required this.selectedMonth,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.onRetroactiveRecord,
    required this.onDeleteDiary,
    this.onTrendTap,
  });

  MoodPaletteInfo? _getPastelPalette(List<MoodDiaryModel> dayDiaries, bool isDark) {
    if (dayDiaries.isEmpty) return null;

    final score = dayDiaries.last.score;

    switch (score) {
      case -5:
        return MoodPaletteInfo(
          baseColor: const Color(0xFF9FB7E8),
          textColor: isDark ? const Color(0xFFB8CDFA) : const Color(0xFF223B68),
          dotColor: isDark ? const Color(0xFFB8CDFA) : const Color(0xFF223B68),
        );
      case -4:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFAEC7EE),
          textColor: isDark ? const Color(0xFFC6DAFD) : const Color(0xFF2D4877),
          dotColor: isDark ? const Color(0xFFC6DAFD) : const Color(0xFF2D4877),
        );
      case -3:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFBFD5F3),
          textColor: isDark ? const Color(0xFFD4E5FF) : const Color(0xFF395687),
          dotColor: isDark ? const Color(0xFFD4E5FF) : const Color(0xFF395687),
        );
      case -2:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFC9DDF6),
          textColor: isDark ? const Color(0xFFDCEBFF) : const Color(0xFF456396),
          dotColor: isDark ? const Color(0xFFDCEBFF) : const Color(0xFF456396),
        );
      case -1:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFD8D8F6),
          textColor: isDark ? const Color(0xFFE4E3FE) : const Color(0xFF535388),
          dotColor: isDark ? const Color(0xFFE4E3FE) : const Color(0xFF535388),
        );
      case 0:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFE8E5EF),
          textColor: isDark ? const Color(0xFFEFE9FA) : const Color(0xFF605278),
          dotColor: isDark ? const Color(0xFFEFE9FA) : const Color(0xFF605278),
        );
      case 1:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFD9F0C8),
          textColor: isDark ? const Color(0xFFC7EBAE) : const Color(0xFF335E20),
          dotColor: isDark ? const Color(0xFFC7EBAE) : const Color(0xFF335E20),
        );
      case 2:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFC7EFA8),
          textColor: isDark ? const Color(0xFFB7EA92) : const Color(0xFF2A5418),
          dotColor: isDark ? const Color(0xFFB7EA92) : const Color(0xFF2A5418),
        );
      case 3:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFFFE79A),
          textColor: isDark ? const Color(0xFFFFDF80) : const Color(0xFF8C6500),
          dotColor: isDark ? const Color(0xFFFFDF80) : const Color(0xFF8C6500),
        );
      case 4:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFFFD36E),
          textColor: isDark ? const Color(0xFFFFCB5C) : const Color(0xFF875500),
          dotColor: isDark ? const Color(0xFFFFCB5C) : const Color(0xFF875500),
        );
      case 5:
      default:
        return MoodPaletteInfo(
          baseColor: const Color(0xFFFFC45C),
          textColor: isDark ? const Color(0xFFFFBB45) : const Color(0xFF804500),
          dotColor: isDark ? const Color(0xFFFFBB45) : const Color(0xFF804500),
        );
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);

    final year = selectedMonth.year;
    final month = selectedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sunday = 0

    final groupedMap = MoodCalculator.groupDiariesByDate(diaries);
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tc.isDark ? const Color(0xFF39334D) : const Color(0xFFEFE8FB),
        ),
        boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
      ),
      child: Column(
        children: [
          // 1. Header Bar with Month Picker & "情绪趋势" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: tc.textSecondary, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        onMonthChanged(DateTime(year, month - 1));
                      },
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedMonth,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          onMonthChanged(picked);
                        }
                      },
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'en'
                            ? '${_getMonthName(month)} $year'
                            : '$year 年 $month 月',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: tc.textSecondary, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        onMonthChanged(DateTime(year, month + 1));
                      },
                    ),
                  ],
                ),
                // "情绪趋势" Pill Button
                if (onTrendTap != null)
                  InkWell(
                    onTap: onTrendTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8C52EE).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.show_chart, size: 14, color: Color(0xFF8C52EE)),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.moodTrendButton ?? '情绪趋势',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8C52EE)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Weekday Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(l10n?.weekdaySun ?? '日', style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, fontWeight: FontWeight.bold)),
                Text(l10n?.weekdayMon ?? '一', style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                Text(l10n?.weekdayTue ?? '二', style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                Text(l10n?.weekdayWed ?? '三', style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                Text(l10n?.weekdayThu ?? '四', style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                Text(l10n?.weekdayFri ?? '五', style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                Text(l10n?.weekdaySat ?? '六', style: const TextStyle(color: Color(0xFF8C52EE), fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 3. 7-Column Calendar Cells (Watercolor Radial Glow Capsules)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: firstWeekday + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.38,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (ctx, index) {
                if (index < firstWeekday) {
                  return const SizedBox.shrink();
                }

                final dayNum = index - firstWeekday + 1;
                final thisDate = DateTime(year, month, dayNum);
                final dateKey = MoodCalculator.formatDateKey(thisDate);

                final isToday = now.year == year && now.month == month && now.day == dayNum;
                final isSelected = selectedDate.year == year && selectedDate.month == month && selectedDate.day == dayNum;

                final dayDiaries = groupedMap[dateKey] ?? [];
                final palette = _getPastelPalette(dayDiaries, tc.isDark);

                return InkWell(
                  onTap: () {
                    onDateSelected(thisDate);
                  },
                  onDoubleTap: () {
                    onDateSelected(thisDate);
                    onRetroactiveRecord(thisDate);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: dayDiaries.isNotEmpty
                          ? palette!.baseColor.withOpacity(tc.isDark ? 0.22 : 0.28)
                          : (tc.isDark ? const Color(0xFF1E212A) : const Color(0xFFFAFAFE)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dayDiaries.isNotEmpty
                            ? palette!.baseColor.withOpacity(tc.isDark ? 0.15 : 0.25)
                            : (tc.isDark ? const Color(0xFF2E323D) : const Color(0xFFF0ECF7)),
                        width: 0.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: (dayDiaries.isNotEmpty ? palette!.baseColor : const Color(0xFF8C52EE)).withOpacity(0.50),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          )
                        else if (dayDiaries.isNotEmpty)
                          BoxShadow(
                            color: palette!.baseColor.withOpacity(tc.isDark ? 0.08 : 0.14),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // 1. Radial Glow Halo Overlay (水彩径向柔光色晕)
                          if (dayDiaries.isNotEmpty)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0.45, 0.0),
                                    radius: 0.90,
                                    colors: [
                                      palette!.baseColor.withOpacity(tc.isDark ? 0.45 : 0.60),
                                      palette!.baseColor.withOpacity(tc.isDark ? 0.15 : 0.20),
                                      palette!.baseColor.withOpacity(0.0),
                                    ],
                                    stops: const [0.0, 0.55, 1.0],
                                  ),
                                ),
                              ),
                            ),

                          // 2. Date Number (Top-Left corner - Neutral Slate Gray, W500)
                          Positioned(
                            top: 5,
                            left: 7,
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF8C52EE)
                                    : (isToday
                                        ? const Color(0xFF8C52EE)
                                        : (thisDate.weekday == DateTime.sunday
                                            ? const Color(0xFFFF6B6B)
                                            : (thisDate.weekday == DateTime.saturday
                                                ? const Color(0xFF8C52EE)
                                                : (tc.isDark ? const Color(0xFFC0C7D5) : const Color(0xFF5A6275))))),
                              ),
                            ),
                          ),

                          // 3. Mood Accent Dot (Top-Right corner - Soft Semi-transparent Dot)
                          if (dayDiaries.isNotEmpty)
                            Positioned(
                              top: 6,
                              right: 7,
                              child: Container(
                                width: 4.5,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  color: palette!.baseColor.withOpacity(tc.isDark ? 0.70 : 0.60),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                          // 4. Mood Emoji (Right/Center-Right aligned gracefully with midline)
                          if (dayDiaries.isNotEmpty)
                            Positioned(
                              right: 7,
                              bottom: 4,
                              child: Text(
                                dayDiaries.last.moodEmoji,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
