import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';

Future<String?> showAvatarCropDialog(BuildContext context, File imageFile) async {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.85),
    pageBuilder: (ctx, anim1, anim2) {
      return AvatarCropScreen(imageFile: imageFile);
    },
  );
}

class AvatarCropScreen extends StatefulWidget {
  final File imageFile;

  const AvatarCropScreen({super.key, required this.imageFile});

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();
  bool _isSaving = false;

  Future<void> _cropAndSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSaving = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        setState(() => _isSaving = false);
        return;
      }

      final buffer = byteData.buffer.asUint8List();
      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = 'avatar_cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = File('${appDocDir.path}/$fileName');
      await savedFile.writeAsBytes(buffer);

      if (mounted) {
        Navigator.pop(context, savedFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping avatar: $e');
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final cropRadius = (size.width * 0.72) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Action Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context, null),
                    child: Text(
                      l10n?.cancel ?? '取消',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  Text(
                    l10n?.cropAvatarTitle ?? '裁剪头像',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _cropAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C52EE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            l10n?.cropDone ?? '完成',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                  ),
                ],
              ),
            ),

            // Interactive Cropping Area
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cropRadius),
                  child: Container(
                    width: cropRadius * 2,
                    height: cropRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8C52EE).withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: ClipOval(
                        child: Container(
                          color: Colors.black,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 1.0,
                            maxScale: 4.0,
                            panEnabled: true,
                            scaleEnabled: true,
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.cover,
                              width: cropRadius * 2,
                              height: cropRadius * 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Tip Text
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                '拖动或双指缩放照片以微调位置',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
