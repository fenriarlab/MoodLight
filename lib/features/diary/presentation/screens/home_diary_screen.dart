import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../../data/diary_repository.dart';
import '../widgets/bottom_quote_banner.dart';
import '../widgets/recent_diaries_card.dart';
import '../widgets/user_avatar.dart';
import '../dialogs/record_diary_sheet.dart';
import '../dialogs/export_data_dialog.dart';
import '../dialogs/change_avatar_sheet.dart';
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
  bool _isCalendarView = true;
  DateTime _calendarSelectedMonth = DateTime.now();
  DateTime _calendarSelectedDate = DateTime.now();
  String? _selectedFilterTag;
  List<MoodDiaryModel> _diaries = [];
  bool _isLoading = true;
  final DiaryRepository _repository = DiaryRepository();

  // Custom Tags State
  static const List<String> _defaultPresetTags = [
    '💼 工作', '📚 学习', '🏠 家庭', '❤️ 恋爱', '🌱 成长',
    '🍔 美食', '🏃 运动', '🎮 娱乐', '😴 睡眠',
  ];
  List<String> _userCustomTags = [];

  // Avatar State
  String _avatarType = 'preset';
  String _avatarValue = 'cat_avatar.png';

  @override
  void initState() {
    super.initState();
    _loadCustomTags();
    _loadDefaultViewPreference();
    _loadAvatarPreference();
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

  Future<void> _deleteCustomTag(String tag) async {
    final trimmed = tag.trim();
    if (_userCustomTags.contains(trimmed)) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userCustomTags.remove(trimmed);
        if (_selectedFilterTag == trimmed) {
          _selectedFilterTag = null;
        }
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

  Future<void> _loadAvatarPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarType = prefs.getString('user_avatar_type') ?? 'preset';
      _avatarValue = prefs.getString('user_avatar_value') ?? 'cat_avatar.png';
    });
  }

  Future<void> _updateAvatar(String type, String value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarType = type;
      _avatarValue = value;
    });
    await prefs.setString('user_avatar_type', type);
    await prefs.setString('user_avatar_value', value);
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
      onCustomTagDeleted: _deleteCustomTag,
      onSaved: _loadDiaries,
    );
  }

  void _openAvatarSheet() {
    showChangeAvatarSheet(
      context,
      currentAvatarType: _avatarType,
      currentAvatarValue: _avatarValue,
      onAvatarChanged: _updateAvatar,
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
          // Dynamic Header User Avatar (Tap to switch to Profile Tab)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: UserAvatar(
              avatarType: _avatarType,
              avatarValue: _avatarValue,
              size: 36,
              onTap: () {
                setState(() => _currentIndex = 2);
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    DiariesTab(
                      isLoading: _isLoading,
                      diaries: _diaries,
                      isCalendarView: _isCalendarView,
                      calendarSelectedMonth: _calendarSelectedMonth,
                      calendarSelectedDate: _calendarSelectedDate,
                      selectedFilterTag: _selectedFilterTag,
                      defaultPresetTags: _defaultPresetTags,
                      userCustomTags: _userCustomTags,
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
                      avatarType: _avatarType,
                      avatarValue: _avatarValue,
                      onChangeAvatar: _openAvatarSheet,
                    ),
                  ],
                ),
              ),
              if (_currentIndex == 0)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 16),
                    child: BottomQuoteBanner(
                      selectedDate: _calendarSelectedDate,
                      onRecordTap: () => _showRecordSheet(defaultDate: _calendarSelectedDate),
                    ),
                  ),
                ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF8C52EE)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: tc.isDark ? const Color(0xFF2D273A) : const Color(0xFFEFE8FB),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: tc.surface,
          selectedItemColor: const Color(0xFF8C52EE),
          unselectedItemColor: tc.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_rounded),
              label: l10n?.tabHome ?? '首页',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_rounded),
              label: l10n?.tabStats ?? '趋势',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tune_rounded),
              label: l10n?.tabSettings ?? '设置',
            ),
          ],
        ),
      ),
    );
  }
}
