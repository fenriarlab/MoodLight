import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';

class DiaryCard extends StatelessWidget {
  final MoodDiaryModel item;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const DiaryCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.onEdit,
  });

  String _formatHumanizedTime(DateTime dt) {
    final now = DateTime.now();
    final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "今天 $timeStr";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return "昨天 $timeStr";
    }
    return "${dt.month}月${dt.day}日 $timeStr";
  }

  void _showOptionsSheet(BuildContext context) {
    final tc = ThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: tc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              if (onEdit != null)
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Color(0xFF8C52EE)),
                  title: Text('编辑日记', style: TextStyle(color: tc.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onEdit!();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                title: const Text('删除日记', style: TextStyle(color: Color(0xFFFF6B6B))),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final moodColor = AppColors.getMoodColor(item.score);

    return InkWell(
      onLongPress: () => _showOptionsSheet(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF262A33) : const Color(0xFFFAF7FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soft Circle Emoji Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: moodColor.withOpacity(0.18),
              ),
              child: Center(
                child: Text(
                  item.moodEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content & Time Layout
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatHumanizedTime(item.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: tc.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        AppColors.getMoodText(item.score),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: moodColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.content.isEmpty ? '（未填写心情感悟）' : item.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: tc.textPrimary,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8C52EE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8C52EE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
