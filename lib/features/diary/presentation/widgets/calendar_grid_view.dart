import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../data/models/mood_diary_model.dart';

class MoodPaletteInfo {
  final LinearGradient gradient;
  final Color textColor;
  final Color dotColor;

  MoodPaletteInfo({
    required this.gradient,
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

    if (score >= 4) {
      // Warm Amber / Yellow (Excited/Joy)
      return MoodPaletteInfo(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3D321A), const Color(0xFF4F4020)]
              : [const Color(0xFFFFF8DE), const Color(0xFFFFECC7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textColor: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE67E22),
        dotColor: isDark ? const Color(0xFFFFB74D) : const Color(0xFFF39C12),
      );
    }
    if (score >= 1) {
      // Soft Mint Green (Calm/Happy)
      return MoodPaletteInfo(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3824), const Color(0xFF28482F)]
              : [const Color(0xFFF0FAF0), const Color(0xFFE0F4E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textColor: isDark ? const Color(0xFF81C784) : const Color(0xFF27AE60),
        dotColor: isDark ? const Color(0xFF81C784) : const Color(0xFF2ECC71),
      );
    }
    if (score == 0) {
      // Soft Lavender Purple (Neutral/Bored)
      return MoodPaletteInfo(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF332342), const Color(0xFF432D56)]
              : [const Color(0xFFF6F0FA), const Color(0xFFEBE0F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textColor: isDark ? const Color(0xFFBA68C8) : const Color(0xFF8E44AD),
        dotColor: isDark ? const Color(0xFFBA68C8) : const Color(0xFF9B59B6),
      );
    }
    if (score >= -3) {
      // Soft Ice Blue (Sad/Low)
      return MoodPaletteInfo(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B2E3E), const Color(0xFF243B50)]
              : [const Color(0xFFEFF5FB), const Color(0xFFE0ECF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textColor: isDark ? const Color(0xFF64B5F6) : const Color(0xFF2980B9),
        dotColor: isDark ? const Color(0xFF64B5F6) : const Color(0xFF3498DB),
      );
    }
    // Angry / Anxious (-4 to -5 - Coral Pink)
    return MoodPaletteInfo(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF422125), const Color(0xFF552A2F)]
            : [const Color(0xFFFDF0ED), const Color(0xFFFADCD5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: isDark ? const Color(0xFFE57373) : const Color(0xFFC0392B),
      dotColor: isDark ? const Color(0xFFE57373) : const Color(0xFFE74C3C),
    );
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

    final monthYearFormat = Localizations.localeOf(context).languageCode == 'en' ? 'MMMM yyyy' : 'yyyy 年 MM 月';

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
                          const Text(
                            '情绪趋势',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8C52EE)),
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

          // 3. 7-Column Calendar Cells (Target Horizontal Capsules)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: firstWeekday + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.42,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
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
                Color cellColor = tc.isDark ? const Color(0xFF242831) : const Color(0xFFFAF8FD);

                return InkWell(
                  onTap: () {
                    onDateSelected(thisDate);
                  },
                  onDoubleTap: () {
                    onDateSelected(thisDate);
                    onRetroactiveRecord(thisDate);
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: palette == null ? cellColor : null,
                      gradient: palette?.gradient,
                      borderRadius: BorderRadius.circular(9),
                      // KEEP USER'S PREFERRED AMBIENT PURPLE / MOOD GLOW HALO FOR SELECTED DATE
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (dayDiaries.isNotEmpty
                                        ? palette!.textColor
                                        : const Color(0xFF8C52EE))
                                    .withOpacity(0.65),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Main Cell Content (Date Number + Emoji Row)
                        Center(
                          child: dayDiaries.isNotEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$dayNum',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: palette!.textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      dayDiaries.last.moodEmoji,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                )
                              : Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                                    color: isToday
                                        ? const Color(0xFF8C52EE)
                                        : tc.textSecondary,
                                  ),
                                ),
                        ),

                        // Top Right Dot Indicator for entries
                        if (dayDiaries.isNotEmpty)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: palette!.dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                        // Multiple Diaries Count Pill (Dark Grey/Purple Capsule Badge)
                        if (dayDiaries.length > 1)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: tc.isDark
                                    ? const Color(0xFF4A405A)
                                    : const Color(0xFF433B54),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${dayDiaries.length}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
