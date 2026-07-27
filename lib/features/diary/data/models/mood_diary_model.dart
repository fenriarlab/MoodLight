import 'dart:convert';
import '../../../../core/constants/app_colors.dart';

class MoodDiaryModel {
  final String id;
  final int score; // -5 to +5
  final String moodEmoji;
  final String content;
  final String themeColor;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MoodDiaryModel({
    required this.id,
    required this.score,
    required this.moodEmoji,
    required this.content,
    required this.themeColor,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'mood_emoji': moodEmoji,
      'content': content,
      'theme_color': themeColor,
      'tags': jsonEncode(tags),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory MoodDiaryModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'].toString().isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(map['tags']);
        parsedTags = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    final scoreVal = (map['score'] as num).toInt();

    return MoodDiaryModel(
      id: map['id'] as String,
      score: scoreVal,
      moodEmoji: map['mood_emoji'] as String? ?? AppColors.getMoodEmoji(scoreVal),
      content: map['content'] as String,
      themeColor: map['theme_color'] as String? ?? '#4F7FFF',
      tags: parsedTags,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int) : null,
    );
  }
}
