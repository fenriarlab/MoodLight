import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/theme_colors.dart';

class UserAvatar extends StatelessWidget {
  final String avatarType;
  final String avatarValue;
  final double size;
  final VoidCallback? onTap;
  final bool showCameraBadge;

  const UserAvatar({
    super.key,
    required this.avatarType,
    required this.avatarValue,
    this.size = 48,
    this.onTap,
    this.showCameraBadge = false,
  });

  ImageProvider _getAvatarImage() {
    if (avatarType == 'file' && avatarValue.isNotEmpty) {
      final file = File(avatarValue);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    // Fallback or Preset assets
    final assetPath = avatarValue.startsWith('assets/')
        ? avatarValue
        : 'assets/images/${avatarValue.isNotEmpty ? avatarValue : "cat_avatar.png"}';
    return AssetImage(assetPath);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final imageProvider = _getAvatarImage();

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tc.isDark ? const Color(0xFF2C2738) : const Color(0xFFF3EBFB),
        border: Border.all(
          color: const Color(0xFF8C52EE).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C52EE).withOpacity(0.18),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );

    if (showCameraBadge && onTap != null) {
      avatarWidget = Stack(
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF8C52EE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: tc.surface,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
