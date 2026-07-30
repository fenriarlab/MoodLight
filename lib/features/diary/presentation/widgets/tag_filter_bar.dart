import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';

class TagFilterBar extends StatelessWidget {
  final List<String> defaultPresetTags;
  final List<String> userCustomTags;
  final String? selectedFilterTag;
  final Function(String?) onTagSelected;

  const TagFilterBar({
    super.key,
    required this.defaultPresetTags,
    required this.userCustomTags,
    required this.selectedFilterTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    final allAvailableTags = [...defaultPresetTags, ...userCustomTags];

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildGradientChip(
              context: context,
              label: l10n?.filterAll ?? '全部',
              icon: Icons.sentiment_satisfied_alt,
              isSelected: selectedFilterTag == null,
              onTap: () => onTagSelected(null),
              tc: tc,
            ),
          ),
          ...allAvailableTags.map((tag) {
            final isSelected = selectedFilterTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildGradientChip(
                context: context,
                label: tag,
                isSelected: isSelected,
                onTap: () => onTagSelected(isSelected ? null : tag),
                tc: tc,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGradientChip({
    required BuildContext context,
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeColors tc,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? ThemeColors.purpleGradient
              : null,
          color: isSelected
              ? null
              : (tc.isDark ? const Color(0xFF2A2E37) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? ThemeColors.purpleGlowShadow()
              : [
                  BoxShadow(
                    color: tc.isDark
                        ? Colors.black.withOpacity(0.2)
                        : const Color(0xFF9D75F0).withOpacity(0.12),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF8C52EE),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : tc.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
