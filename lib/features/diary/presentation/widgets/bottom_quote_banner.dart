import 'package:flutter/material.dart';
import '../../../../core/constants/theme_colors.dart';

class BottomQuoteBanner extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onRecordTap;

  const BottomQuoteBanner({
    super.key,
    required this.selectedDate,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      height: 95,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Speech Bubble on Left
          Positioned(
            left: 4,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: tc.isDark ? const Color(0xFF2C253B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9D75F0).withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '想对我说点什么吗？',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary,
                ),
              ),
            ),
          ),

          // 2. Right-Aligned Floating Purple Pill Button (Rendered EARLIER than Cat)
          Positioned(
            right: 0,
            bottom: 4,
            child: GestureDetector(
              onTap: onRecordTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.45),
                      width: 1.2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E4BF6).withOpacity(0.52),
                      blurRadius: 18,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '记录心情',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TOP-MOST LAYER: Cat Mascot Leaning Over Purple Button
          // Rendered LAST in Stack so its paws are painted ON TOP of the purple button border!
          Positioned(
            right: 14,
            bottom: 42,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/cat_header.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
