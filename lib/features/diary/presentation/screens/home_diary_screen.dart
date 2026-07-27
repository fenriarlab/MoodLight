import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../data/models/mood_diary_model.dart';
import '../../data/diary_repository.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeDiaryScreen extends StatefulWidget {
  const HomeDiaryScreen({super.key});

  @override
  State<HomeDiaryScreen> createState() => _HomeDiaryScreenState();
}

class _HomeDiaryScreenState extends State<HomeDiaryScreen> {
  int _currentIndex = 0;
  final DiaryRepository _repository = DiaryRepository();
  List<MoodDiaryModel> _diaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final list = await _repository.getAllDiaries();
    setState(() {
      _diaries = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('✨ MoodLight 心情日记'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.moodVeryHappy.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.moodVeryHappy.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 12, color: AppColors.moodVeryHappy),
                  SizedBox(width: 4),
                  Text(
                    '100% 离线安全',
                    style: TextStyle(fontSize: 11, color: AppColors.moodVeryHappy, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDiariesTab(),
          _buildStatsTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordDiaryDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('记心情', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.book, color: AppColors.primaryLight),
            label: '日记',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.show_chart, color: AppColors.primaryLight),
            label: '趋势',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.settings, color: AppColors.primaryLight),
            label: '设置',
          ),
        ],
      ),
    );
  }

  Widget _buildDiariesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_diaries.isEmpty) {
      return const Center(
        child: Text(
          '还没有记录心情，点击右下角按钮写第一篇吧！',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _diaries.length,
      itemBuilder: (ctx, idx) {
        final item = _diaries[idx];
        final moodColor = AppColors.getMoodColor(item.score);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                      onPressed: () async {
                        await _repository.deleteDiary(item.id);
                        _loadDiaries();
                      },
                    ),
                  ],
                ),
                if (item.content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(item.content, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    final avgScore = MoodCalculator.calculateOverallAverage(_diaries);
    final trendPoints = MoodCalculator.getMoodTrendForDays(_diaries, 7);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overview Stat Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('近 7 天平均心情指数', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    avgScore > 0 ? "+${avgScore.toStringAsFixed(1)}" : avgScore.toStringAsFixed(1),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.getMoodColor(avgScore.round())),
                  ),
                ],
              ),
              Text(
                AppColors.getMoodEmoji(avgScore.round()),
                style: const TextStyle(fontSize: 48),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Trend Chart Card
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('近 7 天心情波动趋势', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: -5,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: trendPoints.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.avgScore);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
            title: const Text('数据隐私声明'),
            subtitle: const Text('所有日记均保存在本机 SQLite 数据库，无服务器通信。'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.moodVeryHappy),
            title: const Text('清空所有日记数据', style: TextStyle(color: AppColors.moodVeryHappy)),
            onTap: () async {
              await _repository.clearAllDiaries();
              _loadDiaries();
            },
          ),
        ),
      ],
    );
  }

  void _showRecordDiaryDialog(BuildContext context) {
    double selectedScore = 0;
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkElevated,
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

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('今天心情怎么样？', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 4),
                        Text(moodText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: moodColor)),
                        Text("分数: ${currentScoreInt > 0 ? '+$currentScoreInt' : '$currentScoreInt'}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '写下此刻的心情与故事...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final newDiary = MoodDiaryModel(
                          id: "mood_${DateTime.now().millisecondsSinceEpoch}",
                          score: currentScoreInt,
                          moodEmoji: emoji,
                          content: contentController.text.trim(),
                          themeColor: '#4F7FFF',
                          createdAt: DateTime.now(),
                        );
                        await _repository.insertDiary(newDiary);
                        Navigator.pop(ctx);
                        _loadDiaries();
                      },
                      child: const Text('保存心情日记', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
