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
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
    final buttonText = isToday ? '+ 记录今天' : '+ 补记心情';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: tc.isDark
            ? const LinearGradient(
                colors: [Color(0xFF2B213F), Color(0xFF211A33)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFAF4FF), Color(0xFFF3E8FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tc.isDark ? const Color(0xFF3F335D) : const Color(0xFFEADBFF),
          width: 1,
        ),
        boxShadow: ThemeColors.cardAmbientShadow(tc.isDark),
      ),
      child: Row(
        children: [
          // Cat Sleeping Image
          Image.asset(
            'assets/images/cat_footer.png',
            height: 52,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) {
              return const Text('🐱', style: TextStyle(fontSize: 32));
            },
          ),
          const SizedBox(width: 8),

          // Quote Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '“ 每一种心情',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tc.isDark ? const Color(0xFFD6CBF5) : const Color(0xFF5E4988),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '都值得被温柔对待~ ”',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tc.isDark ? const Color(0xFFD6CBF5) : const Color(0xFF5E4988),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('🐾', style: TextStyle(fontSize: 10, color: Color(0xFF8C52EE))),
                  ],
                ),
              ],
            ),
          ),

          // Large 3D Glass Specular Highlight CTA Button
          GestureDetector(
            onTap: onRecordTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFF7E22CE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.45),
                    width: 1.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E4BF6).withOpacity(0.48),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
