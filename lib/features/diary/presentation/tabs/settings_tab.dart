import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../main.dart';
import '../../data/models/mood_diary_model.dart';
import '../dialogs/export_data_dialog.dart';
import '../widgets/user_avatar.dart';

class SettingsTab extends StatelessWidget {
  final bool isCalendarView;
  final List<MoodDiaryModel> diaries;
  final Function(bool) onDefaultViewChanged;
  final String avatarType;
  final String avatarValue;
  final VoidCallback onChangeAvatar;

  const SettingsTab({
    super.key,
    required this.isCalendarView,
    required this.diaries,
    required this.onDefaultViewChanged,
    required this.avatarType,
    required this.avatarValue,
    required this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final appState = MoodLightApp.of(context);
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);
    final currentLang = appState?.language ?? 'system';
    final currentThemeMode = appState?.themeMode ?? ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 0. User Profile Header Card with Interactive Avatar
        Card(
          margin: const EdgeInsets.only(bottom: 20),
          color: tc.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: tc.isDark ? const Color(0xFF332D45) : const Color(0xFFEFE8FB), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                UserAvatar(
                  avatarType: avatarType,
                  avatarValue: avatarValue,
                  size: 64,
                  showCameraBadge: true,
                  onTap: onChangeAvatar,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.appTitle ?? 'MoodLight',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n?.appSubtitle ?? '我的心情，有光照亮',
                        style: TextStyle(
                          fontSize: 12,
                          color: tc.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8C52EE).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '已记录 ${diaries.length} 篇心情日记',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C52EE),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 1. Appearance Section
        _buildSectionHeader(l10n?.sectionAppearance ?? '个性化与外观', Icons.palette_outlined, tc),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: tc.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tc.divider, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent Color Palette Selector
                Text(l10n?.accentColor ?? '应用主题色', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: AppColors.presetAccentColors.map((color) {
                    final isSelected = tc.accent.value == color.value;
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
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 32),

                // Theme Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n?.themeMode ?? '主题模式', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
                    SegmentedButton<ThemeMode>(
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return const Color(0xFF8C52EE);
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return tc.textSecondary;
                        }),
                      ),
                      segments: [
                        ButtonSegment(value: ThemeMode.light, label: Text(l10n?.themeModeLight ?? '浅色')),
                        ButtonSegment(value: ThemeMode.dark, label: Text(l10n?.themeModeDark ?? '暗黑')),
                        ButtonSegment(value: ThemeMode.system, label: Text(l10n?.themeModeSystem ?? '跟随系统')),
                      ],
                      selected: {currentThemeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        appState?.updateThemeMode(newSelection.first);
                      },
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n?.language ?? '应用语言', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
                    DropdownButton<String>(
                      value: currentLang,
                      dropdownColor: tc.surface,
                      style: TextStyle(color: tc.textPrimary, fontSize: 14),
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: tc.textSecondary),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          appState?.updateLanguage(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(value: 'system', child: Text(l10n?.langSystem ?? '跟随系统')),
                        DropdownMenuItem(value: 'zh', child: Text(l10n?.langZh ?? '简体中文')),
                        DropdownMenuItem(value: 'en', child: Text(l10n?.langEn ?? 'English')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2. Preferences Section
        _buildSectionHeader(l10n?.sectionPreferences ?? '偏好设置', Icons.tune_outlined, tc),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: tc.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tc.divider, width: 1),
          ),
          child: ListTile(
            title: Text(l10n?.defaultHomeView ?? '默认主页视图', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
            subtitle: Text(
              isCalendarView ? (l10n?.viewCalendar ?? '日历视图') : (l10n?.viewTimeline ?? '列表视图'),
              style: TextStyle(fontSize: 12, color: tc.textSecondary),
            ),
            trailing: Switch(
              value: isCalendarView,
              activeColor: const Color(0xFF8C52EE),
              onChanged: (val) {
                onDefaultViewChanged(val);
              },
            ),
          ),
        ),

        // 3. Data Management Section
        _buildSectionHeader(l10n?.sectionData ?? '数据管理', Icons.storage_outlined, tc),
        Card(
          color: tc.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tc.divider, width: 1),
          ),
          child: ListTile(
            leading: const Icon(Icons.download_rounded, color: Color(0xFF8C52EE)),
            title: Text(l10n?.exportData ?? '导出日记数据 (JSON)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
            subtitle: Text(l10n?.exportDataSubtitle ?? '一键备份本地所有心情日记，方便导入或迁移。', style: TextStyle(fontSize: 11, color: tc.textSecondary)),
            trailing: Icon(Icons.chevron_right, color: tc.textSecondary),
            onTap: () {
              showExportDataDialog(context, diaries: diaries);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeColors tc) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: tc.textSecondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: tc.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
