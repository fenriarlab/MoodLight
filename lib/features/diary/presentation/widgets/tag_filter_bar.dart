import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../../../core/utils/tag_helper.dart';

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
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
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
                label: TagHelper.getLocalizedTag(context, tag),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8C52EE)
              : (tc.isDark ? const Color(0xFF282239) : const Color(0xFFF3ECFE)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8C52EE).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : (tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C)),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (tc.isDark ? const Color(0xFFB8B2D1) : const Color(0xFF7A6B9C)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
