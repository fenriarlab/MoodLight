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
}
