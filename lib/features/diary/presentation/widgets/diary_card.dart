import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';

class DiaryCard extends StatelessWidget {
  final MoodDiaryModel item;
  final VoidCallback onDelete;

  const DiaryCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final moodColor = AppColors.getMoodColor(item.score);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tc.isDark ? const Color(0xFF39334D) : const Color(0xFFEFE8FB),
        ),
        boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(item.moodEmoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppColors.getMoodText(item.score),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: moodColor),
                        ),
                        Text(
                          "${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')} ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(fontSize: 12, color: tc.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: tc.textSecondary.withOpacity(0.6), size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (item.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(item.content, style: TextStyle(fontSize: 15, color: tc.textPrimary, height: 1.4)),
            ],
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C52EE).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF8C52EE).withOpacity(0.3), width: 0.5),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8C52EE), fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
