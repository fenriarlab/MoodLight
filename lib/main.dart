import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_colors.dart';
import 'features/diary/presentation/screens/home_diary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoodLightApp());
}

class MoodLightApp extends StatefulWidget {
  const MoodLightApp({super.key});

  static _MoodLightAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MoodLightAppState>();

  @override
  State<MoodLightApp> createState() => _MoodLightAppState();
}

class _MoodLightAppState extends State<MoodLightApp> {
  Color _accentColor = AppColors.primary;
  String _language = 'system'; // 'system', 'zh', 'en'
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final colorVal = prefs.getInt('user_accent_color');
    final lang = prefs.getString('user_language') ?? 'system';
    final modeStr = prefs.getString('user_theme_mode') ?? 'dark';

    setState(() {
      if (colorVal != null) {
        _accentColor = Color(colorVal);
      }
      _language = lang;
      _themeMode = modeStr == 'light'
          ? ThemeMode.light
          : modeStr == 'system'
              ? ThemeMode.system
              : ThemeMode.dark;
    });
  }

  void updateAccentColor(Color color) {
    setState(() {
      _accentColor = color;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('user_accent_color', color.value);
    });
  }

  void updateLanguage(String lang) {
    setState(() {
      _language = lang;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_language', lang);
    });
  }

  void updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    SharedPreferences.getInstance().then((prefs) {
      final modeStr = mode == ThemeMode.light ? 'light' : mode == ThemeMode.system ? 'system' : 'dark';
      prefs.setString('user_theme_mode', modeStr);
    });
  }

  Locale? _getLocale() {
    if (_language == 'zh') return const Locale('zh', 'CN');
    if (_language == 'en') return const Locale('en', 'US');
    return null; // System default
  }

  Color get accentColor => _accentColor;
  String get language => _language;
  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodLight 心情日记',
      debugShowCheckedModeBanner: false,
      locale: _getLocale(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        colorScheme: ColorScheme.light(
          primary: _accentColor,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8FA),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE1E4E8), width: 1),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.dark(
          primary: _accentColor,
          surface: AppColors.darkSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
      ),
      home: const HomeDiaryScreen(),
    );
  }
}
