import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';

void showExportDataDialog(BuildContext context, List<MoodDiaryModel> diaries) {
  final tc = ThemeColors.of(context);
  final l10n = AppLocalizations.of(context);
  final jsonList = diaries.map((d) => d.toMap()).toList();
  final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: tc.surface,
        title: Row(
          children: [
            Icon(Icons.file_download, color: tc.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.exportTitle ?? '导出 JSON 日记数据备份',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: tc.textPrimary),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 260,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tc.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tc.divider),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: tc.textSecondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.close ?? '关闭', style: TextStyle(color: tc.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: tc.accent),
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
