import 'package:flutter/material.dart';
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
    final DateTime targetDate = selectedDate ?? DateTime.now();

    // Filter diaries for the selected date
    final selectedDateDiaries = diaries.where((d) {
      return d.createdAt.year == targetDate.year &&
          d.createdAt.month == targetDate.month &&
          d.createdAt.day == targetDate.day;
    }).toList();

    final bool hasEntries = selectedDateDiaries.isNotEmpty;
    // Show only the date in top left title to prevent "心情" word clutter
    final String cardTitle = '${targetDate.month}月${targetDate.day}日';

    final int dateEntriesCount = selectedDateDiaries.length;
    final String actionText = hasEntries
        ? (dateEntriesCount > 1 ? '当日记录 (${dateEntriesCount}条)' : '当日记录')
        : '补记';

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
          // Header Bar
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
              InkWell(
                onTap: () async {
                  if (hasEntries) {
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
                  } else {
                    if (onRetroactiveRecord != null) {
                      onRetroactiveRecord!(targetDate);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C52EE).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        actionText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C52EE),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        hasEntries ? Icons.chevron_right : Icons.add,
                        size: 14,
                        color: const Color(0xFF8C52EE),
                      ),
                    ],
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
                    '🌱 ${targetDate.month}月${targetDate.day}日还没有记录',
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
