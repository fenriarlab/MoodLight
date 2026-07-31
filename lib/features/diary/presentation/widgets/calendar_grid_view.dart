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

    switch (score) {
      case -5:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1C273C), const Color(0xFF24324D)]
                : [const Color(0xFF9FB7E8), const Color(0xFFA8BDED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFB8CDFA) : const Color(0xFF223B68),
          dotColor: isDark ? const Color(0xFFB8CDFA) : const Color(0xFF223B68),
        );
      case -4:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF202B40), const Color(0xFF293752)]
                : [const Color(0xFFAEC7EE), const Color(0xFFB6CCF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFC6DAFD) : const Color(0xFF2D4877),
          dotColor: isDark ? const Color(0xFFC6DAFD) : const Color(0xFF2D4877),
        );
      case -3:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF242F46), const Color(0xFF2E3D59)]
                : [const Color(0xFFBFD5F3), const Color(0xFFC6DAF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFD4E5FF) : const Color(0xFF395687),
          dotColor: isDark ? const Color(0xFFD4E5FF) : const Color(0xFF395687),
        );
      case -2:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF27334B), const Color(0xFF324260)]
                : [const Color(0xFFC9DDF6), const Color(0xFFD0E1F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFDCEBFF) : const Color(0xFF456396),
          dotColor: isDark ? const Color(0xFFDCEBFF) : const Color(0xFF456396),
        );
      case -1:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2B324B), const Color(0xFF37405F)]
                : [const Color(0xFFD8D8F6), const Color(0xFFDDDCF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFE4E3FE) : const Color(0xFF535388),
          dotColor: isDark ? const Color(0xFFE4E3FE) : const Color(0xFF535388),
        );
      case 0:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF302E45), const Color(0xFF3D3A58)]
                : [const Color(0xFFE8E5EF), const Color(0xFFECE9F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFEFE9FA) : const Color(0xFF605278),
          dotColor: isDark ? const Color(0xFFEFE9FA) : const Color(0xFF605278),
        );
      case 1:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF273622), const Color(0xFF31452B)]
                : [const Color(0xFFD9F0C8), const Color(0xFFDDF3CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFC7EBAE) : const Color(0xFF335E20),
          dotColor: isDark ? const Color(0xFFC7EBAE) : const Color(0xFF335E20),
        );
      case 2:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF23351C), const Color(0xFF2B4323)]
                : [const Color(0xFFC7EFA8), const Color(0xFFCCF1B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFB7EA92) : const Color(0xFF2A5418),
          dotColor: isDark ? const Color(0xFFB7EA92) : const Color(0xFF2A5418),
        );
      case 3:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF3C341C), const Color(0xFF4C4223)]
                : [const Color(0xFFFFE79A), const Color(0xFFFFEA9F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFFFDF80) : const Color(0xFF8C6500),
          dotColor: isDark ? const Color(0xFFFFDF80) : const Color(0xFF8C6500),
        );
      case 4:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF3E2F16), const Color(0xFF4F3B1A)]
                : [const Color(0xFFFFD36E), const Color(0xFFFFD777)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFFFCB5C) : const Color(0xFF875500),
          dotColor: isDark ? const Color(0xFFFFCB5C) : const Color(0xFF875500),
        );
      case 5:
      default:
        return MoodPaletteInfo(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF402A12), const Color(0xFF523516)]
                : [const Color(0xFFFFC45C), const Color(0xFFFFC865)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: isDark ? const Color(0xFFFFBB45) : const Color(0xFF804500),
          dotColor: isDark ? const Color(0xFFFFBB45) : const Color(0xFF804500),
        );
    }
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
