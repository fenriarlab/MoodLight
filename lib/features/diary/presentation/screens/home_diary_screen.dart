import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../../data/diary_repository.dart';
import '../dialogs/record_diary_sheet.dart';
import '../tabs/diaries_tab.dart';
import '../tabs/stats_tab.dart';
import '../tabs/settings_tab.dart';

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

  void _showRecordSheet({DateTime? defaultDate}) {
    showRecordDiarySheet(
      context,
      defaultDate: defaultDate,
      defaultPresetTags: _defaultPresetTags,
      userCustomTags: _userCustomTags,
      onCustomTagAdded: _saveCustomTag,
      onSaved: _loadDiaries,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);

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
                color: tc.accent,
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
          DiariesTab(
            isLoading: _isLoading,
            isCalendarView: _isCalendarView,
            diaries: _diaries,
            defaultPresetTags: _defaultPresetTags,
            userCustomTags: _userCustomTags,
            selectedFilterTag: _selectedFilterTag,
            calendarSelectedMonth: _calendarSelectedMonth,
            calendarSelectedDate: _calendarSelectedDate,
            onTagSelected: (tag) => setState(() => _selectedFilterTag = tag),
            onMonthChanged: (month) => setState(() => _calendarSelectedMonth = month),
            onDateSelected: (date) => setState(() => _calendarSelectedDate = date),
            onRetroactiveRecord: (date) => _showRecordSheet(defaultDate: date),
            onDeleteDiary: (diary) async {
              await _repository.deleteDiary(diary.id);
              _loadDiaries();
            },
          ),
          StatsTab(diaries: _diaries),
          SettingsTab(
            isCalendarView: _isCalendarView,
            diaries: _diaries,
            onDefaultViewChanged: (val) => setState(() => _isCalendarView = val),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordSheet(defaultDate: _isCalendarView ? _calendarSelectedDate : null),
        backgroundColor: tc.accent,
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
        backgroundColor: tc.surface,
        indicatorColor: tc.accent.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.book_outlined, color: tc.textSecondary),
            selectedIcon: Icon(Icons.book, color: tc.accent),
            label: l10n?.tabDiaries ?? '日记',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined, color: tc.textSecondary),
            selectedIcon: Icon(Icons.show_chart, color: tc.accent),
            label: l10n?.tabStats ?? '趋势',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: tc.textSecondary),
            selectedIcon: Icon(Icons.settings, color: tc.accent),
            label: l10n?.tabSettings ?? '设置',
          ),
        ],
      ),
    );
  }
}
