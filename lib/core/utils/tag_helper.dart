import 'package:flutter/material.dart';

class TagHelper {
  static String getLocalizedTag(BuildContext context, String tag) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    if (!isEn) return tag;
    if (tag.contains('工作')) return '💼 Work';
    if (tag.contains('学习')) return '📚 Study';
    if (tag.contains('家庭')) return '🏠 Family';
    if (tag.contains('恋爱')) return '❤️ Love';
    if (tag.contains('成长')) return '🌱 Growth';
    if (tag.contains('美食')) return '🍔 Food';
    if (tag.contains('运动')) return '🏃 Sport';
    if (tag.contains('娱乐')) return '🎮 Game';
    if (tag.contains('睡眠')) return '😴 Sleep';
    if (tag.contains('平静')) return '🌿 Calm';
    return tag;
  }
}
