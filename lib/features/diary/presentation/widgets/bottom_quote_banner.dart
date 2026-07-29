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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Layer: Speech Bubble & Cat Mascot Leaning Over
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Speech Bubble "想对我说点什么吗？"
                  Container(
                    margin: const EdgeInsets.only(left: 12, bottom: 6),
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

                  // Cat Header Mascot (Paws overlapping top edge of purple button)
                  Transform.translate(
                    offset: const Offset(-20, 10), // Push down so paws overlap the button border
                    child: Image.asset(
                      'assets/images/cat_header.png',
                      height: 65,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              // Bottom Layer: Large Purple Pill CTA Button "✏️ 记录心情"
              GestureDetector(
                onTap: onRecordTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                        color: const Color(0xFF8E4BF6).withOpacity(0.5),
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
            ],
          ),
        ],
      ),
    );
  }
}
