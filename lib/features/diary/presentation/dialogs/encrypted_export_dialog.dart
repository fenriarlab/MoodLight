import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/encryption_helper.dart';
import '../../data/models/mood_diary_model.dart';

void showEncryptedExportDialog(BuildContext context, List<MoodDiaryModel> diaries) {
  showDialog(
    context: context,
    builder: (ctx) {
      return EncryptedExportModal(diaries: diaries);
    },
  );
}

class EncryptedExportModal extends StatefulWidget {
  final List<MoodDiaryModel> diaries;

  const EncryptedExportModal({super.key, required this.diaries});

  @override
  State<EncryptedExportModal> createState() => _EncryptedExportModalState();
}

class _EncryptedExportModalState extends State<EncryptedExportModal> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  String? _encryptedPayload;
  bool _isCopied = false;

  void _generateEncryptedBackup() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.length < 6) {
      setState(() {
        _errorMessage = '密码长度至少需要 6 个字符';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '两次输入的密码不一致！';
      });
      return;
    }

    final rawPayload = {
      'schema_version': 1,
      'app_name': 'MoodLight',
      'exported_at': DateTime.now().toIso8601String(),
      'total_count': widget.diaries.length,
      'diaries': widget.diaries.map((d) => d.toMap()).toList(),
    };

    final plainJson = const JsonEncoder.withIndent('  ').convert(rawPayload);

    try {
      final encryptedJson = EncryptionHelper.encryptPayload(
        plainJson,
        password,
        totalCount: widget.diaries.length,
      );

      setState(() {
        _encryptedPayload = encryptedJson;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加密失败：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: tc.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFF8C52EE), size: 22),
          const SizedBox(width: 8),
          Text(
            l10n?.exportEncryptedData ?? '导出加密备份 (JSON)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tc.textPrimary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_encryptedPayload == null) ...[
                Text(
                  '请设置导出解密密码。该密码仅保存在您的脑海中，迁移数据时必须输入该密码：',
                  style: TextStyle(fontSize: 12, color: tc.textSecondary),
                ),
                const SizedBox(height: 14),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: tc.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: l10n?.setPasswordTitle ?? '设置解密密码',
                    labelStyle: TextStyle(color: tc.textSecondary, fontSize: 13),
                    hintText: '至少 6 个字符',
                    prefixIcon: Icon(Icons.key_rounded, color: tc.textSecondary, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF8C52EE), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: tc.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: '确认解密密码',
                    labelStyle: TextStyle(color: tc.textSecondary, fontSize: 13),
                    prefixIcon: Icon(Icons.key_rounded, color: tc.textSecondary, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF8C52EE), width: 2),
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C52EE).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_rounded, color: Color(0xFF8C52EE), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AES-256 加密完成！请妥善保存或分享该加密备份文本。',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8C52EE)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Encrypted Code Snippet Display
                Container(
                  height: 160,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tc.isDark ? const Color(0xFF1E1B28) : const Color(0xFFF7F4FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tc.divider),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _encryptedPayload!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: tc.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            _encryptedPayload == null ? (l10n?.cancel ?? '取消') : (l10n?.close ?? '关闭'),
            style: TextStyle(color: tc.textSecondary),
          ),
        ),
        if (_encryptedPayload == null)
          ElevatedButton.icon(
            onPressed: _generateEncryptedBackup,
            icon: const Icon(Icons.lock_clock_rounded, size: 16),
            label: const Text('生成加密备份'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C52EE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _encryptedPayload!));
              setState(() => _isCopied = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔐 加密备份已复制到剪贴板！')),
              );
            },
            icon: Icon(_isCopied ? Icons.check : Icons.copy_rounded, size: 16),
            label: Text(_isCopied ? '已复制' : '复制加密数据'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C52EE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
      ],
    );
  }
}
