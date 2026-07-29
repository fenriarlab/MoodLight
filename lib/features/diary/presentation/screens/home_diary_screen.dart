import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/mood_calculator.dart';
import '../../../../main.dart';
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

  // Custom Tags State
  static const List<String> _defaultPresetTags = [
    '💼 工作', '📚 学习', '🏠 家庭', '❤️ 恋爱',
    '🍔 美食', '🏃 运动', '🎮 娱乐', '😴 睡眠',
  ];
  List<String> _userCustomTags = [];
  String? _selectedFilterTag;

  @override
  void initState() {
    super.initState();
    _loadCustomTags();
    _loadDefaultViewPreference();
    _loadDiaries();
  }

  Future<void> _loadCustomTags() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCustomTags = prefs.getStringList('user_custom_tags') ?? [];
    });
  }

  Future<void> _loadDefaultViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultCalendar = prefs.getBool('user_default_view_calendar') ?? true;
    setState(() {
      _isCalendarView = defaultCalendar;
    });
  }

  Future<void> _saveCustomTag(String newTag) async {
    final trimmed = newTag.trim();
    if (trimmed.isEmpty) return;
    if (!_defaultPresetTags.contains(trimmed) && !_userCustomTags.contains(trimmed)) {
      final prefs = await SharedPreferences.getInstance();
      final updated = [..._userCustomTags, trimmed];
      await prefs.setStringList('user_custom_tags', updated);
      setState(() {
        _userCustomTags = updated;
      });
    }
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
    final l10n = AppLocalizations.of(context);
    final appState = MoodLightApp.of(context);
    final accentColor = appState?.accentColor ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✨ ${l10n?.appTitle ?? "MoodLight 心情日记"}'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.moodVeryHappy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.moodVeryHappy.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 12, color: AppColors.moodVeryHappy),
                    const SizedBox(width: 3),
                    Text(
                      l10n?.offlineBadge ?? '100% 离线安全',
                      style: const TextStyle(fontSize: 10, color: AppColors.moodVeryHappy, fontWeight: FontWeight.w500),
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
              tooltip: _isCalendarView
                  ? (l10n?.viewTimeline ?? '切换为列表视图')
                  : (l10n?.viewCalendar ?? '切换为日历视图'),
              icon: Icon(
                _isCalendarView ? Icons.receipt_long : Icons.calendar_month,
                color: accentColor,
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
        backgroundColor: accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _isCalendarView && (_calendarSelectedDate.year != DateTime.now().year || _calendarSelectedDate.month != DateTime.now().month || _calendarSelectedDate.day != DateTime.now().day)
              ? '补记心情'
              : (l10n?.recordMood ?? '记心情'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppColors.darkSurface,
        indicatorColor: accentColor.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.book_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.book, color: accentColor),
            label: l10n?.tabDiaries ?? '日记',
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.show_chart, color: accentColor),
            label: l10n?.tabStats ?? '趋势',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.settings, color: accentColor),
            label: l10n?.tabSettings ?? '设置',
          ),
        ],
      ),
    );
  }

  Widget _buildDiariesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredDiaries = _selectedFilterTag == null
        ? _diaries
        : _diaries.where((d) => d.tags.contains(_selectedFilterTag)).toList();

    return Column(
      children: [
        _buildTagFilterBar(),
        Expanded(
          child: _isCalendarView
              ? _buildCalendarView(filteredDiaries)
              : _buildTimelineListView(filteredDiaries),
        ),
      ],
    );
  }

  Widget _buildTagFilterBar() {
    final allAvailableTags = [..._defaultPresetTags, ..._userCustomTags];
    final accentColor = MoodLightApp.of(context)?.accentColor ?? AppColors.primary;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.darkSurface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: const Text('全部'),
              selected: _selectedFilterTag == null,
              onSelected: (bool selected) {
                setState(() => _selectedFilterTag = null);
              },
              selectedColor: accentColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                color: _selectedFilterTag == null ? Colors.white : AppColors.textSecondary,
                fontWeight: _selectedFilterTag == null ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.darkElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          ...allAvailableTags.map((tag) {
            final isSelected = _selectedFilterTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedFilterTag = selected ? tag : null;
                  });
                },
                selectedColor: accentColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.darkElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineListView(List<MoodDiaryModel> diaries) {
    final l10n = AppLocalizations.of(context);
    if (diaries.isEmpty) {
      return Center(
        child: Text(
          _selectedFilterTag == null
              ? (l10n?.noDiariesYet ?? '还没有记录心情，点击右下角按钮写第一篇吧！')
              : '没有找到标签为 "$_selectedFilterTag" 的心情日记',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diaries.length,
      itemBuilder: (ctx, idx) {
        final item = diaries[idx];
        return _buildDiaryCard(item);
      },
    );
  }

  Widget _buildDiaryCard(MoodDiaryModel item) {
    final moodColor = AppColors.getMoodColor(item.score);
    final accentColor = MoodLightApp.of(context)?.accentColor ?? AppColors.primary;

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
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withOpacity(0.3), width: 0.5),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<MoodDiaryModel> diaries) {
    final accentColor = MoodLightApp.of(context)?.accentColor ?? AppColors.primary;
    final year = _calendarSelectedMonth.year;
    final month = _calendarSelectedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sunday = 0

    final groupedMap = MoodCalculator.groupDiariesByDate(diaries);
    final now = DateTime.now();
    final isNotCurrentMonth = _calendarSelectedMonth.year != now.year || _calendarSelectedMonth.month != now.month;

    // Filter month diaries for summary
    final monthDiaries = diaries.where((d) => d.createdAt.year == year && d.createdAt.month == month).toList();
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
                      Icon(Icons.arrow_drop_down, color: accentColor),
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
                      icon: Icon(Icons.today, size: 14, color: accentColor),
                      label: Text('回到今天', style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('日', style: TextStyle(color: AppColors.moodVeryHappy, fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('一', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Text('二', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Text('三', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Text('四', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Text('五', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('六', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
                // 按时间正序排列（早晨在上/左，晚间在下/右）
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
                          ? accentColor
                          : isToday
                              ? accentColor.withOpacity(0.7)
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
                                color: isSelected ? Colors.white : (isToday ? accentColor : AppColors.textPrimary),
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
                      icon: Icon(Icons.add_circle_outline, size: 16, color: accentColor),
                      label: Text(
                        "补记 ${_calendarSelectedDate.month}/${_calendarSelectedDate.day}",
                        style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
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
    final l10n = AppLocalizations.of(context);
    final accentColor = MoodLightApp.of(context)?.accentColor ?? AppColors.primary;
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
                  Text(l10n?.averageMood ?? '近 7 天平均心情指数', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                        color: accentColor,
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
    final appState = MoodLightApp.of(context);
    final l10n = AppLocalizations.of(context);
    final currentAccent = appState?.accentColor ?? AppColors.primary;
    final currentLang = appState?.language ?? 'system';
    final currentThemeMode = appState?.themeMode ?? ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Appearance Section
        _buildSectionHeader(l10n?.sectionAppearance ?? '个性化与外观', Icons.palette_outlined),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent Color Palette Selector
                Text(l10n?.accentColor ?? '应用主题色', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: AppColors.presetAccentColors.map((color) {
                    final isSelected = currentAccent.value == color.value;
                    return InkWell(
                      onTap: () {
                        appState?.updateAccentColor(color);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 1),
                          ],
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 24),

                // Theme Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n?.themeMode ?? '主题模式', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    DropdownButton<ThemeMode>(
                      value: currentThemeMode,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.darkElevated,
                      items: [
                        DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n?.themeModeDark ?? '暗黑')),
                        DropdownMenuItem(value: ThemeMode.light, child: Text(l10n?.themeModeLight ?? '浅色')),
                        DropdownMenuItem(value: ThemeMode.system, child: Text(l10n?.themeModeSystem ?? '跟随系统')),
                      ],
                      onChanged: (mode) {
                        if (mode != null) appState?.updateThemeMode(mode);
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n?.language ?? '应用语言', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    DropdownButton<String>(
                      value: currentLang,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.darkElevated,
                      items: [
                        DropdownMenuItem(value: 'system', child: Text(l10n?.langSystem ?? '跟随系统')),
                        DropdownMenuItem(value: 'zh', child: Text(l10n?.langZh ?? '简体中文')),
                        DropdownMenuItem(value: 'en', child: Text(l10n?.langEn ?? 'English')),
                      ],
                      onChanged: (lang) {
                        if (lang != null) appState?.updateLanguage(lang);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2. Preferences Section
        _buildSectionHeader(l10n?.sectionPreferences ?? '偏好设置', Icons.tune_outlined),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(Icons.auto_awesome_mosaic_outlined, color: currentAccent),
            title: Text(l10n?.defaultHomeView ?? '默认主页视图'),
            subtitle: Text(_isCalendarView ? (l10n?.viewCalendar ?? '日历视图') : (l10n?.viewTimeline ?? '列表视图')),
            trailing: Switch(
              value: _isCalendarView,
              activeColor: currentAccent,
              onChanged: (val) async {
                setState(() => _isCalendarView = val);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('user_default_view_calendar', val);
              },
            ),
          ),
        ),

        // 3. Data Management Section
        _buildSectionHeader(l10n?.sectionData ?? '数据管理', Icons.security_outlined),
        Card(
          child: ListTile(
            leading: Icon(Icons.file_download_outlined, color: currentAccent),
            title: Text(l10n?.exportData ?? '导出日记数据 (JSON)'),
            subtitle: const Text('一键备份本地所有心情日记，方便导入或迁移。'),
            onTap: () {
              _showExportDataDialog(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final jsonList = _diaries.map((d) => d.toMap()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkElevated,
          title: Row(
            children: [
              const Icon(Icons.file_download, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.exportTitle ?? '导出 JSON 日记数据备份',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 260,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                jsonString,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('关闭', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.copy, size: 16, color: Colors.white),
              label: Text(l10n?.copyToClipboard ?? '复制到剪贴板', style: const TextStyle(color: Colors.white)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n?.copiedSuccess ?? '已成功复制到剪贴板！'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomTagDialog(BuildContext context, Function(String) onAdded) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkElevated,
          title: const Text('添加自定义标签', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '如：✈️ 旅行、🎨 绘画...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  onAdded(text);
                }
                Navigator.pop(ctx);
              },
              child: const Text('添加', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRecordDiaryDialog(BuildContext context, {DateTime? defaultDate}) {
    double selectedScore = 0;
    final contentController = TextEditingController();
    final targetDate = defaultDate ?? DateTime.now();
    final List<String> selectedTags = [];
    final accentColor = MoodLightApp.of(context)?.accentColor ?? AppColors.primary;

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
            final allAvailableTags = [..._defaultPresetTags, ..._userCustomTags];

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
                    const SizedBox(height: 8),
                    const Text('关联标签 (可多选):', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
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
                            selectedColor: accentColor,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                            backgroundColor: AppColors.darkSurface,
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
                          avatar: Icon(Icons.add, size: 14, color: accentColor),
                          label: Text('+ 自定义', style: TextStyle(fontSize: 12, color: accentColor)),
                          backgroundColor: AppColors.darkSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: accentColor, width: 0.8),
                          ),
                          onPressed: () {
                            _showAddCustomTagDialog(context, (newTag) async {
                              await _saveCustomTag(newTag);
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
                          backgroundColor: accentColor,
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
              ),
            );
          },
        );
      },
    );
  }
}
