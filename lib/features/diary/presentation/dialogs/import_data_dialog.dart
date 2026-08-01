import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/encryption_helper.dart';
import '../../data/diary_repository.dart';
import '../../data/models/mood_diary_model.dart';

void showImportDataDialog(
  BuildContext context, {
  required VoidCallback onImportCompleted,
}) {
  showDialog(
    context: context,
    builder: (ctx) {
      return ImportDataModal(onImportCompleted: onImportCompleted);
    },
  );
}

class ImportDataModal extends StatefulWidget {
  final VoidCallback onImportCompleted;

  const ImportDataModal({super.key, required this.onImportCompleted});

  @override
  State<ImportDataModal> createState() => _ImportDataModalState();
}

class _ImportDataModalState extends State<ImportDataModal> {
  final TextEditingController _payloadController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DiaryRepository _repository = DiaryRepository();

  bool _isImporting = false;
  String? _errorMessage;
  int _importMode = 0; // 0: 追加合并 (Merge), 1: 覆盖还原 (Replace)

  Future<void> _processImport() async {
    final payloadText = _payloadController.text.trim();
    final password = _passwordController.text.trim();

    if (payloadText.isEmpty) {
      setState(() => _errorMessage = '请粘贴加密备份文本！');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = '请输入解密密码！');
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      String plainJson;
      // 1. Try decrypting payload
      try {
        plainJson = EncryptionHelper.decryptPayload(payloadText, password);
      } catch (e) {
        setState(() {
          _isImporting = false;
          _errorMessage = '解密失败：解密密码错误或备份文件被损坏！';
        });
        return;
      }

      // 2. Parse decrypted JSON payload
      final Map<String, dynamic> dataMap = jsonDecode(plainJson);
      final List<dynamic> rawDiaries = dataMap['diaries'] ?? [];

      final List<MoodDiaryModel> importedDiaries = rawDiaries.map((item) {
        return MoodDiaryModel.fromMap(item as Map<String, dynamic>);
      }).toList();

      if (importedDiaries.isEmpty) {
        setState(() {
          _isImporting = false;
          _errorMessage = '备份文件中未包含有效的日记记录！';
        });
        return;
      }

      // 3. Database restoration according to mode
      if (_importMode == 1) {
        // Overwrite mode: Clear all existing records first
        final existing = await _repository.getAllDiaries();
        for (var diary in existing) {
          await _repository.deleteDiary(diary.id);
        }
      }

      // Merge or Insert
      for (var diary in importedDiaries) {
        await _repository.saveDiary(diary);
      }

      widget.onImportCompleted();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 成功解密并恢复 ${importedDiaries.length} 篇心情日记！'),
            backgroundColor: const Color(0xFF8C52EE),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _errorMessage = '导入解析失败：$e';
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
          const Icon(Icons.file_download_rounded, color: Color(0xFF8C52EE), size: 22),
          const SizedBox(width: 8),
          Text(
            l10n?.importData ?? '解密恢复备份',
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
              Text(
                '请粘贴备份的加密文本（以 {.moodlight} 或包含 ciphertext_base64 格式）：',
                style: TextStyle(fontSize: 12, color: tc.textSecondary),
              ),
              const SizedBox(height: 10),

              // Payload Text Field
              TextField(
                controller: _payloadController,
                maxLines: 4,
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: tc.textPrimary),
                decoration: InputDecoration(
                  hintText: '粘贴包含 ciphertext_base64 的加密字符串...',
                  hintStyle: TextStyle(color: tc.textSecondary.withOpacity(0.6), fontSize: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF8C52EE), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Decryption Password Input Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: tc.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: l10n?.enterPasswordTitle ?? '输入解密密码',
                  labelStyle: TextStyle(color: tc.textSecondary, fontSize: 13),
                  prefixIcon: Icon(Icons.key_rounded, color: tc.textSecondary, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF8C52EE), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Restoration Mode Segmented Control
              Text(
                '恢复导入模式：',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tc.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(l10n?.mergeMode ?? '追加合并'),
                      selected: _importMode == 0,
                      selectedColor: const Color(0xFF8C52EE).withOpacity(0.2),
                      onSelected: (val) => setState(() => _importMode = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(l10n?.replaceMode ?? '覆盖还原'),
                      selected: _importMode == 1,
                      selectedColor: const Color(0xFF8C52EE).withOpacity(0.2),
                      onSelected: (val) => setState(() => _importMode = 1),
                    ),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? '取消', style: TextStyle(color: tc.textSecondary)),
        ),
        ElevatedButton.icon(
          onPressed: _isImporting ? null : _processImport,
          icon: _isImporting
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.lock_open_rounded, size: 16),
          label: Text(_isImporting ? '解密中...' : '解密并恢复'),
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
