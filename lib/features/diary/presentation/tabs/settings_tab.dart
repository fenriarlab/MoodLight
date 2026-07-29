import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../main.dart';
import '../../data/models/mood_diary_model.dart';
import '../dialogs/export_data_dialog.dart';

class SettingsTab extends StatelessWidget {
  final bool isCalendarView;
  final List<MoodDiaryModel> diaries;
  final Function(bool) onDefaultViewChanged;

  const SettingsTab({
    super.key,
    required this.isCalendarView,
    required this.diaries,
    required this.onDefaultViewChanged,
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
                Divider(height: 24, color: tc.divider),

                // Theme Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n?.themeMode ?? '主题模式', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
                    DropdownButton<ThemeMode>(
                      value: currentThemeMode,
                      underline: const SizedBox(),
                      dropdownColor: tc.surface,
                      style: TextStyle(color: tc.textPrimary, fontSize: 14),
                      items: [
                        DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n?.themeModeDark ?? '暗黑', style: TextStyle(color: tc.textPrimary))),
                        DropdownMenuItem(value: ThemeMode.light, child: Text(l10n?.themeModeLight ?? '浅色', style: TextStyle(color: tc.textPrimary))),
                        DropdownMenuItem(value: ThemeMode.system, child: Text(l10n?.themeModeSystem ?? '跟随系统', style: TextStyle(color: tc.textPrimary))),
                      ],
                      onChanged: (mode) {
                        if (mode != null) appState?.updateThemeMode(mode);
                      },
                    ),
                  ],
                ),
                Divider(height: 24, color: tc.divider),

                // Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n?.language ?? '应用语言', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
                    DropdownButton<String>(
                      value: currentLang,
                      underline: const SizedBox(),
                      dropdownColor: tc.surface,
                      style: TextStyle(color: tc.textPrimary, fontSize: 14),
                      items: [
                        DropdownMenuItem(value: 'system', child: Text(l10n?.langSystem ?? '跟随系统', style: TextStyle(color: tc.textPrimary))),
                        DropdownMenuItem(value: 'zh', child: Text(l10n?.langZh ?? '简体中文', style: TextStyle(color: tc.textPrimary))),
                        DropdownMenuItem(value: 'en', child: Text(l10n?.langEn ?? 'English', style: TextStyle(color: tc.textPrimary))),
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
        _buildSectionHeader(l10n?.sectionPreferences ?? '偏好设置', Icons.tune_outlined, tc),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: tc.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tc.divider, width: 1),
          ),
          child: ListTile(
            leading: Icon(Icons.auto_awesome_mosaic_outlined, color: tc.accent),
            title: Text(l10n?.defaultHomeView ?? '默认主页视图', style: TextStyle(color: tc.textPrimary)),
            subtitle: Text(isCalendarView ? (l10n?.viewCalendar ?? '日历视图') : (l10n?.viewTimeline ?? '列表视图'), style: TextStyle(color: tc.textSecondary)),
            trailing: Switch(
              value: isCalendarView,
              activeColor: tc.accent,
              onChanged: (val) async {
                onDefaultViewChanged(val);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('user_default_view_calendar', val);
              },
            ),
          ),
        ),

        // 3. Data Management Section
        _buildSectionHeader(l10n?.sectionData ?? '数据管理', Icons.security_outlined, tc),
        Card(
          color: tc.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tc.divider, width: 1),
          ),
          child: ListTile(
            leading: Icon(Icons.file_download_outlined, color: tc.accent),
            title: Text(l10n?.exportData ?? '导出日记数据 (JSON)', style: TextStyle(color: tc.textPrimary)),
            subtitle: Text('一键备份本地所有心情日记，方便导入或迁移。', style: TextStyle(color: tc.textSecondary)),
            onTap: () {
              showExportDataDialog(context, diaries);
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
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: tc.textSecondary),
          ),
        ],
      ),
    );
  }
}
