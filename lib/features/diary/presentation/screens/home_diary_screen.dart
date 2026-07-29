import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Calendar View State
  bool _isCalendarView = true;
  DateTime _calendarSelectedMonth = DateTime.now();
  DateTime _calendarSelectedDate = DateTime.now();

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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨ MoodLight 心情日记'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.moodVeryHappy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.moodVeryHappy.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 12, color: AppColors.moodVeryHappy),
                    SizedBox(width: 3),
                    Text(
                      '100% 离线安全',
                      style: TextStyle(fontSize: 10, color: AppColors.moodVeryHappy, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              tooltip: _isCalendarView ? '切换为列表视图' : '切换为日历视图',
              icon: Icon(
                _isCalendarView ? Icons.receipt_long : Icons.calendar_month,
                color: AppColors.primaryLight,
              ),
              onPressed: () {
                setState(() => _isCalendarView = !_isCalendarView);
              },
            ),
        ],
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
        onPressed: () => _showRecordDiaryDialog(context, defaultDate: _isCalendarView ? _calendarSelectedDate : null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _isCalendarView && (_calendarSelectedDate.year != DateTime.now().year || _calendarSelectedDate.month != DateTime.now().month || _calendarSelectedDate.day != DateTime.now().day)
              ? '补记心情'
              : '记心情',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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

    if (_isCalendarView) {
      return _buildCalendarView();
    } else {
      return _buildTimelineListView();
    }
  }

  Widget _buildTimelineListView() {
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
        return _buildDiaryCard(item);
      },
    );
  }

  Widget _buildDiaryCard(MoodDiaryModel item) {
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
  }

  Widget _buildCalendarView() {
    final year = _calendarSelectedMonth.year;
    final month = _calendarSelectedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sunday = 0

    final groupedMap = MoodCalculator.groupDiariesByDate(_diaries);
    final now = DateTime.now();
    final isNotCurrentMonth = _calendarSelectedMonth.year != now.year || _calendarSelectedMonth.month != now.month;

    // Filter month diaries for summary
    final monthDiaries = _diaries.where((d) => d.createdAt.year == year && d.createdAt.month == month).toList();
    final monthAvgScore = MoodCalculator.calculateOverallAverage(monthDiaries);

    final selectedDateKey = MoodCalculator.formatDateKey(_calendarSelectedDate);
    final selectedDayDiaries = groupedMap[selectedDateKey] ?? [];

    return Column(
      children: [
        // 1. Month Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: AppColors.darkSurface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    _calendarSelectedMonth = DateTime(year, month - 1);
                  });
                },
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _calendarSelectedMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDatePickerMode: DatePickerMode.year,
                  );
                  if (picked != null) {
                    setState(() {
                      _calendarSelectedMonth = DateTime(picked.year, picked.month);
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('yyyy 年 MM 月').format(_calendarSelectedMonth),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.primaryLight),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNotCurrentMonth)
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                      onPressed: () {
                        setState(() {
                          _calendarSelectedMonth = DateTime(now.year, now.month);
                          _calendarSelectedDate = now;
                        });
                      },
                      icon: const Icon(Icons.today, size: 14, color: AppColors.primaryLight),
                      label: const Text('回到今天', style: TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onPressed: () {
                      setState(() {
                        _calendarSelectedMonth = DateTime(year, month + 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Month Overview Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: AppColors.darkElevated,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('本月篇数: ${monthDiaries.length} 篇', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              Text(
                '月平均心情: ${monthAvgScore > 0 ? "+${monthAvgScore.toStringAsFixed(1)}" : monthAvgScore.toStringAsFixed(1)} ${AppColors.getMoodEmoji(monthAvgScore.round())}',
                style: TextStyle(fontSize: 12, color: AppColors.getMoodColor(monthAvgScore.round()), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // 3. Weekday Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: AppColors.darkSurface,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('日', style: TextStyle(color: AppColors.moodVeryHappy, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('一', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('二', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('三', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('四', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('五', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('六', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // 4. Calendar Heatmap & Gradient Grid
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: firstWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (ctx, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }

              final dayNum = index - firstWeekday + 1;
              final thisDate = DateTime(year, month, dayNum);
              final dateKey = MoodCalculator.formatDateKey(thisDate);

              final isToday = now.year == year && now.month == month && now.day == dayNum;
              final isSelected = _calendarSelectedDate.year == year && _calendarSelectedDate.month == month && _calendarSelectedDate.day == dayNum;

              final dayDiaries = groupedMap[dateKey] ?? [];

              // Gradient or background logic
              Gradient? bgGradient;
              Color bgColor = AppColors.darkElevated.withOpacity(0.3);

              if (dayDiaries.isNotEmpty) {
                // 按时间正序排列（早晨在上/左，晚间在下/右），使渐变方向从左上（时间靠前）平滑过渡至右下（时间靠后）
                final chronological = dayDiaries.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                final colors = chronological.map((d) => AppColors.getMoodColor(d.score)).toList();
                if (colors.length == 1) {
                  bgGradient = LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.first.withOpacity(0.35), colors.first.withOpacity(0.75)],
                  );
                } else {
                  bgGradient = LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  );
                }
              }

              return InkWell(
                onTap: () {
                  setState(() => _calendarSelectedDate = thisDate);
                },
                onDoubleTap: () {
                  setState(() => _calendarSelectedDate = thisDate);
                  _showRecordDiaryDialog(context, defaultDate: thisDate);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgGradient == null ? bgColor : null,
                    gradient: bgGradient,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primaryLight
                              : Colors.transparent,
                      width: isSelected ? 2.0 : (isToday ? 1.5 : 0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : (isToday ? AppColors.primaryLight : AppColors.textPrimary),
                              ),
                            ),
                            if (dayDiaries.isNotEmpty)
                              Text(
                                dayDiaries.last.moodEmoji,
                                style: const TextStyle(fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                      if (dayDiaries.length > 1)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '•${dayDiaries.length}',
                              style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 5. Selected Date Details Section
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "📅 ${DateFormat('MM月dd日').format(_calendarSelectedDate)} • 共 ${selectedDayDiaries.length} 篇心情",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => _showRecordDiaryDialog(context, defaultDate: _calendarSelectedDate),
                      icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primaryLight),
                      label: Text(
                        "补记 ${_calendarSelectedDate.month}/${_calendarSelectedDate.day}",
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: selectedDayDiaries.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🌱 该天尚无心情记录', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _showRecordDiaryDialog(context, defaultDate: _calendarSelectedDate),
                                  icon: const Icon(Icons.edit_calendar, size: 14),
                                  label: const Text('补记心情', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: selectedDayDiaries.length,
                          itemBuilder: (ctx, idx) {
                            return _buildDiaryCard(selectedDayDiaries[idx]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _showRecordDiaryDialog(BuildContext context, {DateTime? defaultDate}) {
    double selectedScore = 0;
    final contentController = TextEditingController();
    final targetDate = defaultDate ?? DateTime.now();

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titleText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          createdAt: recordTime,
                        );
                        await _repository.insertDiary(newDiary);
                        Navigator.pop(ctx);
                        _loadDiaries();
                      },
                      child: Text(
                        isRetroactive ? '保存 ${defaultDate.month}月${defaultDate.day}日 心情' : '保存心情日记',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
