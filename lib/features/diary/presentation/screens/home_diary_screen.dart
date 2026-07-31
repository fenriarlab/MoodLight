import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../../data/diary_repository.dart';
import '../dialogs/record_diary_sheet.dart';
import '../tabs/diaries_tab.dart';
import '../tabs/stats_tab.dart';
import '../tabs/settings_tab.dart';
import '../widgets/bottom_quote_banner.dart';

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
    '💼 工作', '📚 学习', '🏠 家庭', '❤️ 恋爱', '🌱 成长',
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

  Future<void> _saveCustomTag(String tag) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (!_defaultPresetTags.contains(trimmed) && !_userCustomTags.contains(trimmed)) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userCustomTags.add(trimmed);
      });
      await prefs.setStringList('user_custom_tags', _userCustomTags);
    }
  }

  Future<void> _loadDefaultViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCalendarView = prefs.getBool('default_home_view_is_calendar') ?? true;
    });
  }

  Future<void> _loadDiaries() async {
    setState(() => _isLoading = true);
    final data = await _repository.getAllDiaries();
    setState(() {
      _diaries = data;
      _isLoading = false;
    });
  }

  void _showRecordSheet({DateTime? defaultDate, MoodDiaryModel? existingDiary}) {
    showRecordDiarySheet(
      context,
      defaultDate: defaultDate,
      existingDiary: existingDiary,
      defaultPresetTags: _defaultPresetTags,
      userCustomTags: _userCustomTags,
      onCustomTagAdded: _saveCustomTag,
      onSaved: _loadDiaries,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: tc.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: tc.surface,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  '✨ ${l10n?.appTitle ?? "MoodLight"}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              l10n?.appSubtitle ?? '我的心情，有光照亮',
              style: TextStyle(
                fontSize: 11,
                color: tc.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Privacy Badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tc.isDark ? const Color(0xFF2C243B) : const Color(0xFFF2EAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: tc.isDark ? const Color(0xFF4A3B63) : const Color(0xFFE5D5F5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 12, color: Color(0xFF8C52EE)),
                const SizedBox(width: 4),
                Text(
                  l10n?.offlineBadge ?? '100% 本地隐私留存',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8C52EE),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Cat Avatar Icon
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF8C52EE).withOpacity(0.18),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/cat_avatar.png',
                  errorBuilder: (ctx, err, stack) => const Text('🐱', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: tc.isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF14121A), Color(0xFF191724), Color(0xFF111017)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFF9F4FE), Color(0xFFF5EEFF), Color(0xFFFAFAFE)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            child: IndexedStack(
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
                  onEditDiary: (diary) => _showRecordSheet(existingDiary: diary),
                  onReload: _loadDiaries,
                  onTrendTap: () => setState(() => _currentIndex = 1),
                ),
                StatsTab(diaries: _diaries),
                SettingsTab(
                  isCalendarView: _isCalendarView,
                  diaries: _diaries,
                  onDefaultViewChanged: (val) => setState(() => _isCalendarView = val),
                ),
              ],
            ),
          ),
          // True Floating Cat Paws Button (Only on Home/Diaries Tab)
          if (_currentIndex == 0)
            Positioned(
              right: 16,
              bottom: 16,
              child: BottomQuoteBanner(
                selectedDate: _calendarSelectedDate,
                onRecordTap: () => _showRecordSheet(
                  defaultDate: _isCalendarView ? _calendarSelectedDate : null,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: tc.isDark ? const Color(0xFF191724) : Colors.white,
        indicatorColor: const Color(0xFF8C52EE).withOpacity(0.18),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: tc.textSecondary),
            selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF8C52EE)),
            label: l10n?.tabHome ?? '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined, color: tc.textSecondary),
            selectedIcon: const Icon(Icons.show_chart_rounded, color: Color(0xFF8C52EE)),
            label: l10n?.tabStats ?? '趋势',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined, color: tc.textSecondary),
            selectedIcon: const Icon(Icons.pets_rounded, color: Color(0xFF8C52EE)),
            label: l10n?.tabProfile ?? '我的',
          ),
        ],
      ),
    );
  }
}
