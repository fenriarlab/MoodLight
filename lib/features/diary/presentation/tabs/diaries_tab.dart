import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../widgets/emotion_weather_card.dart';
import '../widgets/tag_filter_bar.dart';
import '../widgets/calendar_grid_view.dart';
import '../widgets/recent_diaries_card.dart';
import '../widgets/diary_card.dart';

class DiariesTab extends StatelessWidget {
  final bool isLoading;
  final bool isCalendarView;
  final List<MoodDiaryModel> diaries;
  final List<String> defaultPresetTags;
  final List<String> userCustomTags;
  final String? selectedFilterTag;
  final DateTime calendarSelectedMonth;
  final DateTime calendarSelectedDate;
  final Function(String?) onTagSelected;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onRetroactiveRecord;
  final Function(MoodDiaryModel) onDeleteDiary;
  final Function(MoodDiaryModel)? onEditDiary;
  final VoidCallback onReload;
  final VoidCallback? onTrendTap;

  const DiariesTab({
    super.key,
    required this.isLoading,
    required this.isCalendarView,
    required this.diaries,
    required this.defaultPresetTags,
    required this.userCustomTags,
    required this.selectedFilterTag,
    required this.calendarSelectedMonth,
    required this.calendarSelectedDate,
    required this.onTagSelected,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.onRetroactiveRecord,
    required this.onDeleteDiary,
    this.onEditDiary,
    required this.onReload,
    this.onTrendTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredDiaries = selectedFilterTag == null
        ? diaries
        : diaries.where((d) => d.tags.contains(selectedFilterTag)).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 1. Top Emotion Weather Card with Overlapping Cat
          EmotionWeatherCard(
            selectedMonth: calendarSelectedMonth,
            diaries: diaries,
          ),

          // 2. Pastel Tag Filter Bar
          TagFilterBar(
            defaultPresetTags: defaultPresetTags,
            userCustomTags: userCustomTags,
            selectedFilterTag: selectedFilterTag,
            onTagSelected: onTagSelected,
          ),

          // 3. Calendar View or Timeline List
          isCalendarView
              ? CalendarGridView(
                  diaries: filteredDiaries,
                  selectedMonth: calendarSelectedMonth,
                  selectedDate: calendarSelectedDate,
                  onMonthChanged: onMonthChanged,
                  onDateSelected: onDateSelected,
                  onRetroactiveRecord: onRetroactiveRecord,
                  onDeleteDiary: onDeleteDiary,
                  onTrendTap: onTrendTap,
                )
              : _buildTimelineListView(context, filteredDiaries, tc, l10n),

          // 4. "最近心情记录" + "全部记录 >" Container Card
          if (isCalendarView)
            RecentDiariesCard(
              diaries: filteredDiaries,
              onDeleteDiary: onDeleteDiary,
              onEditDiary: onEditDiary,
              onReload: onReload,
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTimelineListView(
      BuildContext context, List<MoodDiaryModel> list, ThemeColors tc, AppLocalizations? l10n) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            selectedFilterTag == null
                ? (l10n?.noDiariesYet ?? '还没有记录心情，点击下方按钮写第一篇吧！')
                : '没有找到标签为 "$selectedFilterTag" 的心情日记',
            style: TextStyle(color: tc.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final item = list[idx];
        return DiaryCard(
          item: item,
          onDelete: () => onDeleteDiary(item),
          onEdit: onEditDiary != null ? () => onEditDiary!(item) : null,
        );
      },
    );
  }
}
