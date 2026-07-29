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

  const CalendarGridView({
    super.key,
    required this.diaries,
    required this.selectedMonth,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.onRetroactiveRecord,
    required this.onDeleteDiary,
  });

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
    final isNotCurrentMonth = selectedMonth.year != now.year || selectedMonth.month != now.month;

    // Filter month diaries for summary
    final monthDiaries = diaries.where((d) => d.createdAt.year == year && d.createdAt.month == month).toList();
    final monthAvgScore = MoodCalculator.calculateOverallAverage(monthDiaries);

    final selectedDateKey = MoodCalculator.formatDateKey(selectedDate);
    final selectedDayDiaries = groupedMap[selectedDateKey] ?? [];

    final formattedAvg = monthAvgScore > 0 ? "+${monthAvgScore.toStringAsFixed(1)}" : monthAvgScore.toStringAsFixed(1);
    final monthYearFormat = Localizations.localeOf(context).languageCode == 'en' ? 'MMMM yyyy' : 'yyyy 年 MM 月';
    final dayDateFormat = Localizations.localeOf(context).languageCode == 'en' ? 'MMM dd' : 'MM月dd日';

    return Column(
      children: [
        // 1. Month Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: tc.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: tc.textSecondary),
                onPressed: () {
                  onMonthChanged(DateTime(year, month - 1));
                },
              ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat(monthYearFormat).format(selectedMonth),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tc.textPrimary),
                      ),
                      Icon(Icons.arrow_drop_down, color: tc.accent),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNotCurrentMonth)
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                      onPressed: () {
                        onMonthChanged(DateTime(now.year, now.month));
                        onDateSelected(now);
                      },
                      icon: Icon(Icons.today, size: 14, color: tc.accent),
                      label: Text(l10n?.backToToday ?? '回到今天', style: TextStyle(color: tc.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: tc.textSecondary),
                    onPressed: () {
                      onMonthChanged(DateTime(year, month + 1));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Month Overview Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: tc.elevated,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                l10n?.monthEntriesCount(monthDiaries.length) ?? '本月篇数: ${monthDiaries.length} 篇',
                style: TextStyle(fontSize: 12, color: tc.textPrimary),
              ),
              Text(
                "${l10n?.monthAverageMood(formattedAvg) ?? '月平均心情: $formattedAvg'} ${AppColors.getMoodEmoji(monthAvgScore.round())}",
                style: TextStyle(fontSize: 12, color: AppColors.getMoodColor(monthAvgScore.round()), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // 3. Weekday Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: tc.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(l10n?.weekdaySun ?? '日', style: const TextStyle(color: AppColors.moodVeryHappy, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(l10n?.weekdayMon ?? '一', style: TextStyle(color: tc.textSecondary, fontSize: 12)),
              Text(l10n?.weekdayTue ?? '二', style: TextStyle(color: tc.textSecondary, fontSize: 12)),
              Text(l10n?.weekdayWed ?? '三', style: TextStyle(color: tc.textSecondary, fontSize: 12)),
              Text(l10n?.weekdayThu ?? '四', style: TextStyle(color: tc.textSecondary, fontSize: 12)),
              Text(l10n?.weekdayFri ?? '五', style: TextStyle(color: tc.textSecondary, fontSize: 12)),
              Text(l10n?.weekdaySat ?? '六', style: TextStyle(color: tc.accent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // 4. Calendar Heatmap & Gradient Grid
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tc.surface,
            border: Border(bottom: BorderSide(color: tc.divider)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: firstWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
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

              // Gradient or background logic
              Gradient? bgGradient;
              Color bgColor = tc.isDark
                  ? AppColors.darkElevated.withOpacity(0.3)
                  : const Color(0xFFF0F3F7);

              if (dayDiaries.isNotEmpty) {
                final chronological = dayDiaries.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                final colors = chronological.map((d) => AppColors.getMoodColor(d.score)).toList();
                if (colors.length == 1) {
                  bgGradient = LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.first.withOpacity(0.35), colors.first.withOpacity(0.75)],
                  );
                } else {
                  bgGradient = LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  );
                }
              }

              return InkWell(
                onTap: () {
                  onDateSelected(thisDate);
                },
                onDoubleTap: () {
                  onDateSelected(thisDate);
                  onRetroactiveRecord(thisDate);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgGradient == null ? bgColor : null,
                    gradient: bgGradient,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? tc.accent
                          : isToday
                              ? tc.accent.withOpacity(0.7)
                              : Colors.transparent,
                      width: isSelected ? 2.0 : (isToday ? 1.5 : 0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isToday ? tc.accent : (dayDiaries.isNotEmpty ? Colors.white : tc.textPrimary)),
                              ),
                            ),
                            if (dayDiaries.isNotEmpty)
                              Text(
                                dayDiaries.last.moodEmoji,
                                style: const TextStyle(fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                      if (dayDiaries.length > 1)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '•${dayDiaries.length}',
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

        // 5. Selected Date Details Section
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n?.dateDetailsHeader(DateFormat(dayDateFormat).format(selectedDate), selectedDayDiaries.length) ??
                            "📅 ${DateFormat(dayDateFormat).format(selectedDate)} • 共 ${selectedDayDiaries.length} 篇心情",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => onRetroactiveRecord(selectedDate),
                      icon: Icon(Icons.add_circle_outline, size: 16, color: tc.accent),
                      label: Text(
                        l10n?.retroactiveButton("${selectedDate.month}/${selectedDate.day}") ?? "补记 ${selectedDate.month}/${selectedDate.day}",
                        style: TextStyle(color: tc.accent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: selectedDayDiaries.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n?.noEntriesForDate ?? '🌱 该天尚无心情记录', style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => onRetroactiveRecord(selectedDate),
                                  icon: const Icon(Icons.edit_calendar, size: 14),
                                  label: Text(l10n?.retroactiveLog ?? '补记心情', style: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: selectedDayDiaries.length,
                          itemBuilder: (ctx, idx) {
                            return DiaryCard(
                              item: selectedDayDiaries[idx],
                              onDelete: () => onDeleteDiary(selectedDayDiaries[idx]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
