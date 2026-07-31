import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
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

  String _formatHumanizedTime(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return l10n?.todayTime(timeStr) ?? "今天 $timeStr";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return l10n?.yesterdayTime(timeStr) ?? "昨天 $timeStr";
    }
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return isEn ? "${dt.month}/${dt.day} $timeStr" : "${dt.month}月${dt.day}日 $timeStr";
  }

  void _showOptionsSheet(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);

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
                  title: Text(l10n?.editDiary ?? '编辑日记', style: TextStyle(color: tc.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onEdit!();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                title: Text(l10n?.deleteDiary ?? '删除日记', style: const TextStyle(color: Color(0xFFFF6B6B))),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF221F2E) : const Color(0xFFF9F5FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tc.isDark ? const Color(0xFF332D45) : const Color(0xFFF0E8FC),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji Circular Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: moodColor.withOpacity(0.12),
              ),
              child: Center(
                child: Text(
                  item.moodEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time & Options Button Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatHumanizedTime(context, item.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: tc.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showOptionsSheet(context),
                        icon: Icon(Icons.more_horiz, size: 18, color: tc.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Diary Text Content (Omitted if empty)
                  if (item.content.trim().isNotEmpty) ...[
                    Text(
                      item.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: tc.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Tags Row
                  if (item.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8C52EE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C52EE),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
