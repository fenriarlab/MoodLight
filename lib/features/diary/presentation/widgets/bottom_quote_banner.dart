import 'package:flutter/material.dart';

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
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        // 1. Purple CTA Button "✏️ 记录心情"
        GestureDetector(
          onTap: onRecordTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
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
                  color: const Color(0xFF8E4BF6).withOpacity(0.45),
                  blurRadius: 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit, color: Colors.white, size: 17),
                SizedBox(width: 6),
                Text(
                  '记录心情',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. TOP-MOST LAYER: Cat Mascot Leaning Over Purple Button
        // Cat paws 100% overlaying top edge of purple button
        Positioned(
          right: 14,
          bottom: 44,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/cat_header.png',
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
