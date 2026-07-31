import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../screens/all_diaries_screen.dart';
import 'diary_card.dart';

class RecentDiariesCard extends StatelessWidget {
  final List<MoodDiaryModel> diaries;
  final DateTime? selectedDate;
  final Function(MoodDiaryModel) onDeleteDiary;
  final Function(MoodDiaryModel)? onEditDiary;
  final Function(DateTime)? onRetroactiveRecord;
  final VoidCallback onReload;

  const RecentDiariesCard({
    super.key,
    required this.diaries,
    this.selectedDate,
    required this.onDeleteDiary,
    this.onEditDiary,
    this.onRetroactiveRecord,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    final DateTime targetDate = selectedDate ?? DateTime.now();

    // Filter diaries for the selected date
    final selectedDateDiaries = diaries.where((d) {
      return d.createdAt.year == targetDate.year &&
          d.createdAt.month == targetDate.month &&
          d.createdAt.day == targetDate.day;
    }).toList();

    final bool hasEntries = selectedDateDiaries.isNotEmpty;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final String cardTitle = isEn
        ? '${targetDate.month}/${targetDate.day}'
        : '${targetDate.month}月${targetDate.day}日';

    final String noEntriesText = l10n?.noEntriesOnDate(targetDate.month.toString(), targetDate.day.toString()) ??
        '🌱 ${targetDate.month}月${targetDate.day}日还没有记录';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tc.isDark ? const Color(0xFF39334D) : const Color(0xFFEFE8FB),
        ),
        boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              if (hasEntries)
                InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => AllDiariesScreen(
                          diaries: diaries,
                          initialDate: targetDate,
                          onDeleteDiary: onDeleteDiary,
                          onEditDiary: onEditDiary,
                          onReload: onReload,
                        ),
                      ),
                    );
                    onReload();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: tc.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (!hasEntries)
            InkWell(
              onTap: () {
                if (onRetroactiveRecord != null) {
                  onRetroactiveRecord!(targetDate);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: tc.isDark ? const Color(0xFF221F2E) : const Color(0xFFF9F5FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tc.isDark ? const Color(0xFF332D45) : const Color(0xFFF0E8FC),
                  ),
                ),
                child: Center(
                  child: Text(
                    noEntriesText,
                    style: TextStyle(
                      color: tc.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          else
            Column(
              children: selectedDateDiaries.take(1).map((item) {
                return DiaryCard(
                  item: item,
                  onDelete: () => onDeleteDiary(item),
                  onEdit: onEditDiary != null ? () => onEditDiary!(item) : null,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
