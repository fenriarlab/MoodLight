import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../widgets/user_avatar.dart';

void showChangeAvatarSheet(
  BuildContext context, {
  required String currentAvatarType,
  required String currentAvatarValue,
  required Function(String type, String value) onAvatarChanged,
}) {
  final tc = ThemeColors.of(context);
  final l10n = AppLocalizations.of(context);

  final List<Map<String, String>> presetAvatars = [
    {'name': '经典小猫', 'filename': 'cat_avatar.png'},
    {'name': '探头小猫', 'filename': 'cat_header.png'},
    {'name': '招手小猫', 'filename': 'cat_wave.png'},
    {'name': '软萌小猫', 'filename': 'cat_footer.png'},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: tc.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag Handle Bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tc.isDark ? const Color(0xFF4A4458) : const Color(0xFFE5DDF5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title
            Text(
              l10n?.changeAvatarTitle ?? '选择专属头像',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Preset Mascots Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n?.presetAvatars ?? '治愈预设形象',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: tc.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Preset Avatars Grid/Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: presetAvatars.map((preset) {
                final filename = preset['filename']!;
                final isSelected = currentAvatarType == 'preset' && currentAvatarValue == filename;

                return InkWell(
                  onTap: () {
                    onAvatarChanged('preset', filename);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF8C52EE) : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: UserAvatar(
                      avatarType: 'preset',
                      avatarValue: filename,
                      size: 54,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Section 2: Custom Photo Upload Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final picker = ImagePicker();
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 85,
                    );

                    if (pickedFile != null) {
                      final appDocDir = await getApplicationDocumentsDirectory();
                      final savedImage = await File(pickedFile.path).copy(
                        '${appDocDir.path}/user_avatar_custom.png',
                      );

                      onAvatarChanged('file', savedImage.path);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    }
                  } catch (e) {
                    debugPrint('Error picking image: $e');
                  }
                },
                icon: const Icon(Icons.photo_library_rounded, color: Color(0xFF8C52EE), size: 20),
                label: Text(
                  l10n?.chooseFromGallery ?? '📷 从相册选择照片',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C52EE),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF8C52EE).withOpacity(0.4), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
