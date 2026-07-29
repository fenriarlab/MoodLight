import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../data/models/mood_diary_model.dart';
import 'diary_card.dart';

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

  Gradient? _getPastelGradientForDiaries(List<MoodDiaryModel> dayDiaries, bool isDark) {
    if (dayDiaries.isEmpty) return null;

    if (dayDiaries.length == 1) {
      final score = dayDiaries.first.score;
      if (score >= 4) {
        return LinearGradient(
          colors: isDark
              ? [const Color(0xFF6B4A1D), const Color(0xFF8D5B28)]
              : [const Color(0xFFFFF1A8), const Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
      if (score >= 2) {
        return LinearGradient(
          colors: isDark
              ? [const Color(0xFF225024), const Color(0xFF388E3C)]
              : [const Color(0xFFC8E6C9), const Color(0xFFA5D6A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
      if (score >= 0) {
        return LinearGradient(
          colors: isDark
              ? [const Color(0xFF4A3464), const Color(0xFF673AB7)]
              : [const Color(0xFFE1BEE7), const Color(0xFFCE93D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
      if (score >= -2) {
        return LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E4160), const Color(0xFF2196F3)]
              : [const Color(0xFFBBDEFB), const Color(0xFF90CAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
      return LinearGradient(
        colors: isDark
            ? [const Color(0xFF5E271D), const Color(0xFFE64A19)]
            : [const Color(0xFFFFCCBC), const Color(0xFFFFAB91)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    // Multiple diaries per date: Combine colors for smooth gradient
    final colors = dayDiaries.map((d) => AppColors.getMoodColor(d.score)).toList();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
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

    final selectedDateKey = MoodCalculator.formatDateKey(selectedDate);
    final selectedDayDiaries = groupedMap[selectedDateKey] ?? [];

    final monthYearFormat = Localizations.localeOf(context).languageCode == 'en' ? 'MMMM yyyy' : 'yyyy 年 MM 月';
    final dayDateFormat = Localizations.localeOf(context).languageCode == 'en' ? 'MMM dd' : 'MM月dd日';

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
                          lastDate: DateTime(2035),
                          initialDatePickerMode: DatePickerMode.year,
                        );
                        if (picked != null) {
                          onMonthChanged(DateTime(picked.year, picked.month));
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Text(
                        DateFormat(monthYearFormat).format(selectedMonth),
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: tc.textPrimary),
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

          // 3. 7-Column Calendar Cells
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: firstWeekday + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.22,
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

                final cellGradient = _getPastelGradientForDiaries(dayDiaries, tc.isDark);
                Color cellColor = tc.isDark ? const Color(0xFF242831) : const Color(0xFFFAF8FD);

                return InkWell(
                  onTap: () {
                    onDateSelected(thisDate);
                  },
                  onDoubleTap: () {
                    onDateSelected(thisDate);
                    onRetroactiveRecord(thisDate);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: cellGradient == null ? cellColor : null,
                      gradient: cellGradient,
                      borderRadius: BorderRadius.circular(16),
                      // Soft Outer Glow Halo for Selected Date (No Hard Line Border)
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (dayDiaries.isNotEmpty
                                        ? AppColors.getMoodColor(dayDiaries.last.score)
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
                        Positioned(
                          top: 4,
                          left: 6,
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                              color: dayDiaries.isNotEmpty
                                  ? (tc.isDark ? Colors.white : const Color(0xFF332057))
                                  : tc.textSecondary,
                            ),
                          ),
                        ),
                        Center(
                          child: dayDiaries.isNotEmpty
                              ? Text(
                                  dayDiaries.last.moodEmoji,
                                  style: const TextStyle(fontSize: 18),
                                )
                              : null,
                        ),
                        if (dayDiaries.length > 1)
                          Positioned(
                            top: 3,
                            right: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${dayDiaries.length}',
                                style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
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

          // 4. Selected Date Entries Detail List (Only rendered if entries exist)
          if (selectedDayDiaries.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: tc.divider)),
              ),
              child: Column(
                children: selectedDayDiaries
                    .map((diary) => DiaryCard(
                          item: diary,
                          onDelete: () => onDeleteDiary(diary),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
