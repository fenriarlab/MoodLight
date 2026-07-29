import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';

void showAddCustomTagDialog(BuildContext context, Function(String) onAdded) {
  final tc = ThemeColors.of(context);
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: tc.surface,
        title: Text(l10n?.addCustomTagTitle ?? '添加自定义标签', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tc.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: tc.textPrimary),
          decoration: InputDecoration(
            hintText: l10n?.customTagHint ?? '如：✈️ 旅行、🎨 绘画...',
            hintStyle: TextStyle(color: tc.textSecondary),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? '取消', style: TextStyle(color: tc.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: tc.accent),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onAdded(text);
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n?.add ?? '添加', style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
