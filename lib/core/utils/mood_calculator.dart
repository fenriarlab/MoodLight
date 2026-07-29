import '../../features/diary/data/models/mood_diary_model.dart';

class DateMoodPoint {
  final DateTime date;
  final double avgScore;
  final int count;

  DateMoodPoint({
    required this.date,
    required this.avgScore,
    required this.count,
  });
}

class MoodCalculator {
  static List<DateMoodPoint> getMoodTrendForDays(List<MoodDiaryModel> diaries, int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));

    final Map<String, List<int>> grouped = {};

    for (var diary in diaries) {
      if (diary.createdAt.isAfter(startDate.subtract(const Duration(days: 1)))) {
        final dateKey = "${diary.createdAt.year}-${diary.createdAt.month.toString().padLeft(2, '0')}-${diary.createdAt.day.toString().padLeft(2, '0')}";
        grouped.putIfAbsent(dateKey, () => []).add(diary.score);
      }
    }

    final List<DateMoodPoint> result = [];
    for (int i = 0; i < days; i++) {
      final d = startDate.add(Duration(days: i));
      final dateKey = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

      if (grouped.containsKey(dateKey)) {
        final scores = grouped[dateKey]!;
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        result.add(DateMoodPoint(date: d, avgScore: avg, count: scores.length));
      } else {
        result.add(DateMoodPoint(date: d, avgScore: 0.0, count: 0));
      }
    }

    return result;
  }

  static double calculateOverallAverage(List<MoodDiaryModel> diaries) {
    if (diaries.isEmpty) return 0.0;
    final total = diaries.fold(0, (sum, item) => sum + item.score);
    return (total / diaries.length);
  }

  static String formatDateKey(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  static Map<String, List<MoodDiaryModel>> groupDiariesByDate(List<MoodDiaryModel> diaries) {
    final Map<String, List<MoodDiaryModel>> result = {};
    for (var diary in diaries) {
      final key = formatDateKey(diary.createdAt);
      result.putIfAbsent(key, () => []).add(diary);
    }
    return result;
  }

  static String getEmotionWeatherTitle(double avgScore) {
    if (avgScore >= 3.0) return '☀️ 晴空万里';
    if (avgScore >= 1.5) return '⛅ 多云转晴';
    if (avgScore >= 0.0) return '🌤️ 微风拂面';
    if (avgScore >= -2.0) return '🌧️ 偶尔阵雨';
    return '🌩️ 阴雨连绵';
  }

  static String getEmotionWeatherSubtitle(double avgScore) {
    if (avgScore >= 3.0) return '整体心情非常阳光欢快 🌟';
    if (avgScore >= 1.5) return '整体心情平稳向好 ✨';
    if (avgScore >= 0.0) return '整体心情平静恬淡 🌿';
    if (avgScore >= -2.0) return '小有波折，记得多休息 ☕';
    return '释放压力，抱抱自己 🫂';
  }

  static String getMostFrequentTag(List<MoodDiaryModel> diaries) {
    if (diaries.isEmpty) return '🌱 平静';
    final Map<String, int> counts = {};
    for (var d in diaries) {
      for (var t in d.tags) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return '🌱 平静';
    var sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}
