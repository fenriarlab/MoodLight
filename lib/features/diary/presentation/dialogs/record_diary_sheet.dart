import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../../data/diary_repository.dart';
import 'custom_tag_dialog.dart';

void showRecordDiarySheet(
  BuildContext context, {
  DateTime? defaultDate,
  required List<String> defaultPresetTags,
  required List<String> userCustomTags,
  required Function(String) onCustomTagAdded,
  required VoidCallback onSaved,
}) {
  double selectedScore = 0;
  final contentController = TextEditingController();
  final targetDate = defaultDate ?? DateTime.now();
  final List<String> selectedTags = [];
  final tc = ThemeColors.of(context);
  final repository = DiaryRepository();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tc.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

          final titleText = isRetroactive
              ? '补记 ${defaultDate.year}年${defaultDate.month}月${defaultDate.day}日 心情'
              : '今天心情怎么样？';

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titleText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tc.textPrimary)),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 4),
                        Text(moodText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: moodColor)),
                        Text("分数: ${currentScoreInt > 0 ? '+$currentScoreInt' : '$currentScoreInt'}", style: TextStyle(fontSize: 12, color: tc.textSecondary)),
                      ],
                    ),
                  ),
                  Slider(
                    value: selectedScore,
                    min: -5,
                    max: 5,
                    divisions: 10,
                    activeColor: moodColor,
                    onChanged: (val) {
                      setModalState(() {
                        selectedScore = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('关联标签 (可多选):', style: TextStyle(fontSize: 13, color: tc.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...allAvailableTags.map((tag) {
                        final isSelected = selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          selectedColor: tc.accent,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : tc.textSecondary,
                          ),
                          backgroundColor: tc.elevated,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (bool selected) {
                            setModalState(() {
                              if (selected) {
                                selectedTags.add(tag);
                              } else {
                                selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                      ActionChip(
                        avatar: Icon(Icons.add, size: 14, color: tc.accent),
                        label: Text('+ 自定义', style: TextStyle(fontSize: 12, color: tc.accent)),
                        backgroundColor: tc.elevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: tc.accent, width: 0.8),
                        ),
                        onPressed: () {
                          showAddCustomTagDialog(context, (newTag) async {
                            onCustomTagAdded(newTag);
                            setModalState(() {
                              if (!selectedTags.contains(newTag)) {
                                selectedTags.add(newTag);
                              }
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    style: TextStyle(color: tc.textPrimary),
                    decoration: InputDecoration(
                      hintText: '写下此刻的心情与故事...',
                      hintStyle: TextStyle(color: tc.textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tc.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
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
                        Navigator.pop(ctx);
                        onSaved();
                      },
                      child: Text(
                        isRetroactive ? '保存 ${defaultDate.month}月${defaultDate.day}日 心情' : '保存心情日记',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
