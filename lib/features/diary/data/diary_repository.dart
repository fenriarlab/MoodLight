import '../../../../core/database/database_helper.dart';
import 'models/mood_diary_model.dart';

class DiaryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insertDiary(MoodDiaryModel diary) async {
    final db = await _dbHelper.database;
    await db.insert('mood_diaries', diary.toMap());
  }

  Future<List<MoodDiaryModel>> getAllDiaries() async {
    final db = await _dbHelper.database;
    final maps = await db.query('mood_diaries', orderBy: 'created_at DESC');
    return maps.map((m) => MoodDiaryModel.fromMap(m)).toList();
  }

  Future<void> updateDiary(MoodDiaryModel diary) async {
    final db = await _dbHelper.database;
    await db.update('mood_diaries', diary.toMap(), where: 'id = ?', whereArgs: [diary.id]);
  }

  Future<void> deleteDiary(String id) async {
    final db = await _dbHelper.database;
    await db.delete('mood_diaries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllDiaries() async {
    final db = await _dbHelper.database;
    await db.delete('mood_diaries');
  }
}
