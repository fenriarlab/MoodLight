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
  final VoidCallback onReload;

  const RecentDiariesCard({
    super.key,
    required this.diaries,
    this.selectedDate,
    required this.onDeleteDiary,
    this.onEditDiary,
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

    final String cardTitle = '${targetDate.month}月${targetDate.day}日的心情';

    // Outer card ONLY displays 1 entry if available for target date,
    // otherwise fallback to 1 entry for recent diaries
    final List<MoodDiaryModel> displayList = selectedDateDiaries.isNotEmpty
        ? selectedDateDiaries.take(1).toList()
        : diaries.take(1).toList();

    final int dateEntriesCount = selectedDateDiaries.length;
    final String actionText = dateEntriesCount > 1
        ? '当日记录 (${dateEntriesCount}条)'
        : '当日记录';

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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
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
                      const Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: Color(0xFF8C52EE),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (displayList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  '🌱 ${targetDate.month}月${targetDate.day}日还没有记录心情，写第一篇吧！',
                  style: TextStyle(color: tc.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: displayList.map((item) {
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
