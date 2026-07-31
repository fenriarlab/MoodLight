import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/tag_helper.dart';
import '../../data/models/mood_diary_model.dart';
import '../../data/diary_repository.dart';
import 'custom_tag_dialog.dart';

void showRecordDiarySheet(
  BuildContext context, {
  DateTime? defaultDate,
  MoodDiaryModel? existingDiary,
  required List<String> defaultPresetTags,
  required List<String> userCustomTags,
  required Function(String) onCustomTagAdded,
  required VoidCallback onSaved,
}) {
  double selectedScore = existingDiary != null ? existingDiary.score.toDouble() : 0;
  final contentController = TextEditingController(text: existingDiary?.content ?? '');
  final targetDate = existingDiary != null ? existingDiary.createdAt : (defaultDate ?? DateTime.now());
  final List<String> selectedTags = existingDiary != null ? List.from(existingDiary.tags) : [];
  final tc = ThemeColors.of(context);
  final l10n = AppLocalizations.of(context);
  final repository = DiaryRepository();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tc.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final currentScoreInt = selectedScore.round();
          final emoji = AppColors.getMoodEmoji(currentScoreInt);
          final moodText = AppColors.getMoodText(currentScoreInt);
          final moodColor = AppColors.getMoodColor(currentScoreInt);
          final allAvailableTags = [...defaultPresetTags, ...userCustomTags];

          final isRetroactive = defaultDate != null &&
              (defaultDate.year != DateTime.now().year ||
                  defaultDate.month != DateTime.now().month ||
                  defaultDate.day != DateTime.now().day);

          final isEn = Localizations.localeOf(context).languageCode == 'en';
          final dateStr = isEn ? "${targetDate.month}/${targetDate.day}" : "${targetDate.month}月${targetDate.day}日";
          final titleText = existingDiary != null
              ? (isEn ? 'Edit $dateStr Mood' : '编辑 $dateStr 心情')
              : (isRetroactive
                  ? (l10n?.retroactiveMoodTitle(dateStr) ?? '补记 $dateStr 心情')
                  : (l10n?.todayMoodTitle ?? '今天心情怎么样？'));

          final scoreVal = currentScoreInt > 0 ? '+$currentScoreInt' : '$currentScoreInt';

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle Indicator
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: tc.isDark ? const Color(0xFF423B5A) : const Color(0xFFE2D8F3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: tc.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mood Hero Selector Area
                  Center(
                    child: Column(
                      children: [
                        // Soft Ambient Glowing Emoji Circle
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tc.isDark
                                ? const Color(0xFF382F4E).withOpacity(0.6)
                                : const Color(0xFFF5EFFF),
                            boxShadow: [
                              BoxShadow(
                                color: moodColor.withOpacity(0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                emoji,
                                key: ValueKey<String>(emoji),
                                style: const TextStyle(fontSize: 46),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Mood Status Text & Score Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              moodText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: moodColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: moodColor.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n?.scoreText(scoreVal) ?? '分值 $scoreVal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: moodColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Custom Gradient Slider Track Theme
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF8C52EE),
                      inactiveTrackColor: tc.isDark ? const Color(0xFF39334D) : const Color(0xFFEFE8FB),
                      thumbColor: Colors.white,
                      overlayColor: const Color(0xFF8C52EE).withOpacity(0.15),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                    ),
                    child: Slider(
                      value: selectedScore,
                      min: -5,
                      max: 5,
                      divisions: 10,
                      onChanged: (val) {
                        setModalState(() {
                          selectedScore = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tags Section Header
                  Text(
                    l10n?.associateTags ?? '关联标签 (可多选):',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: tc.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Morandi Pastel Tag Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...allAvailableTags.map((tag) {
                        final isSelected = selectedTags.contains(tag);
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedTags.remove(tag);
                              } else {
                                selectedTags.add(tag);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8C52EE)
                                  : (tc.isDark ? const Color(0xFF282239) : const Color(0xFFF6F2FC)),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF8C52EE).withOpacity(0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              TagHelper.getLocalizedTag(context, tag),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF6E5D90)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      // Add Custom Tag Chip Button
                      InkWell(
                        onTap: () {
                          showAddCustomTagDialog(context, (newTag) {
                            final trimmed = newTag.trim();
                            if (trimmed.isNotEmpty) {
                              onCustomTagAdded(trimmed);
                              setModalState(() {
                                if (!selectedTags.contains(trimmed)) {
                                  selectedTags.add(trimmed);
                                }
                              });
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                          decoration: BoxDecoration(
                            color: tc.isDark ? const Color(0xFF252033) : const Color(0xFFF5EFFF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8C52EE).withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 14, color: Color(0xFF8C52EE)),
                              const SizedBox(width: 3),
                              Text(
                                l10n?.customTag ?? '+ 自定义',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8C52EE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Styled Content Text Box Card
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    style: TextStyle(color: tc.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l10n?.contentPlaceholder ?? '写下此刻的心情与故事...',
                      hintStyle: TextStyle(
                        color: tc.textSecondary.withOpacity(0.65),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: tc.isDark ? const Color(0xFF231E33) : const Color(0xFFF9F6FE),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: tc.isDark ? const Color(0xFF352F48) : const Color(0xFFF0E8FA),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: tc.isDark ? const Color(0xFF352F48) : const Color(0xFFF0E8FA),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF8C52EE),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // High-End Purple Gradient Primary Submit Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8C52EE), Color(0xFF6E28D9)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8C52EE).withOpacity(0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () async {
                        if (existingDiary != null) {
                          final updatedDiary = existingDiary.copyWith(
                            score: currentScoreInt,
                            moodEmoji: emoji,
                            content: contentController.text.trim(),
                            tags: selectedTags,
                          );
                          await repository.updateDiary(updatedDiary);
                        } else {
                          final now = DateTime.now();
                          final recordTime = DateTime(
                            targetDate.year,
                            targetDate.month,
                            targetDate.day,
                            now.hour,
                            now.minute,
                            now.second,
                          );

                          final newDiary = MoodDiaryModel(
                            id: "mood_${recordTime.millisecondsSinceEpoch}",
                            score: currentScoreInt,
                            moodEmoji: emoji,
                            content: contentController.text.trim(),
                            themeColor: '#4F7FFF',
                            tags: selectedTags,
                            createdAt: recordTime,
                          );
                          await repository.insertDiary(newDiary);
                        }
                        Navigator.pop(ctx);
                        onSaved();
                      },
                      child: Text(
                        existingDiary != null
                            ? (isEn ? 'Save Changes' : '保存修改')
                            : (isRetroactive
                                ? (l10n?.saveRetroactiveMood(dateStr) ?? '保存 $dateStr 心情')
                                : (l10n?.saveDiary ?? '保存心情日记')),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
