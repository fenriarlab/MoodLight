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

  Future<void> _cropAndSave(double cropRadius, Size viewportSize) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSaving = false);
        return;
      }

      const pixelRatio = 2.5;
      final fullImage = await boundary.toImage(pixelRatio: pixelRatio);

      final double diameter = cropRadius * 2;
      final double srcLeft = (viewportSize.width / 2 - cropRadius) * pixelRatio;
      final double srcTop = (viewportSize.height / 2 - cropRadius) * pixelRatio;
      final double srcSize = diameter * pixelRatio;

      final srcRect = Rect.fromLTWH(srcLeft, srcTop, srcSize, srcSize);
      final outputSize = srcSize.toInt();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Clip Canvas to Circle
      final path = Path()..addOval(Rect.fromLTWH(0, 0, srcSize, srcSize));
      canvas.clipPath(path);

      // Draw Sub-region from full viewport image
      canvas.drawImageRect(
        fullImage,
        srcRect,
        Rect.fromLTWH(0, 0, srcSize, srcSize),
        Paint()..filterQuality = FilterQuality.high,
      );

      final croppedPicture = recorder.endRecording();
      final croppedImage = await croppedPicture.toImage(outputSize, outputSize);
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);

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
    final screenSize = MediaQuery.of(context).size;
    final double cropRadius = (screenSize.width * 0.72) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Action Header
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () => _cropAndSave(cropRadius, Size(screenSize.width, screenSize.height - 140)),
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
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. Interactive Viewport & Semi-Transparent Mask Stack
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

                  return Stack(
                    children: [
                      // Layer A: Full Interactive Image Workspace (Captured by RepaintBoundary)
                      Positioned.fill(
                        child: RepaintBoundary(
                          key: _repaintKey,
                          child: Container(
                            color: Colors.black,
                            child: InteractiveViewer(
                              transformationController: _transformationController,
                              minScale: 1.0,
                              maxScale: 4.0,
                              panEnabled: true,
                              scaleEnabled: true,
                              child: Center(
                                child: Image.file(
                                  widget.imageFile,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Layer B: Semi-transparent Overlay Mask with Clear Circular Cutout Window
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: viewportSize,
                            painter: CircularCropMaskPainter(cropRadius: cropRadius),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 3. Bottom Tip Text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '拖动或双指缩放照片以微调位置',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
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

/// Custom Painter for Semi-transparent Dark Mask Overlay with Circular Cutout
class CircularCropMaskPainter extends CustomPainter {
  final double cropRadius;

  CircularCropMaskPainter({required this.cropRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Full Viewport Outer Path
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Circular Cutout Inner Path
    final innerPath = Path()..addOval(Rect.fromCircle(center: center, radius: cropRadius));

    // Semi-transparent Mask Path (Outer minus Inner)
    final maskPath = Path.combine(PathOperation.difference, outerPath, innerPath);

    final maskPaint = Paint()
      ..color = Colors.black.withOpacity(0.68)
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, maskPaint);

    // Crisp White Border Line around Circular Viewport
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, cropRadius, borderPaint);

    // Subtle Outer Glow Halo around Border Line
    final shadowPaint = Paint()
      ..color = const Color(0xFF8C52EE).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, cropRadius + 1, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CircularCropMaskPainter oldDelegate) {
    return oldDelegate.cropRadius != cropRadius;
  }
}
