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
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                Icons.sentiment_satisfied_alt,
                size: 14,
                color: selectedFilterTag == null ? Colors.white : tc.accent,
              ),
              label: Text(l10n?.filterAll ?? '全部'),
              selected: selectedFilterTag == null,
              onSelected: (bool selected) {
                onTagSelected(null);
              },
              selectedColor: tc.accent,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                color: selectedFilterTag == null ? Colors.white : tc.textPrimary,
                fontWeight: selectedFilterTag == null ? FontWeight.bold : FontWeight.w500,
              ),
              backgroundColor: tc.isDark ? const Color(0xFF2A2E37) : const Color(0xFFFAF6FF),
              side: BorderSide(
                color: selectedFilterTag == null ? tc.accent : (tc.isDark ? const Color(0xFF3F3B54) : const Color(0xFFEADBFF)),
                width: 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          ...allAvailableTags.map((tag) {
            final isSelected = selectedFilterTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (bool selected) {
                  onTagSelected(selected ? tag : null);
                },
                selectedColor: tc.accent,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : tc.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                backgroundColor: tc.isDark ? const Color(0xFF2A2E37) : const Color(0xFFFAF6FF),
                side: BorderSide(
                  color: isSelected ? tc.accent : (tc.isDark ? const Color(0xFF3F3B54) : const Color(0xFFEADBFF)),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
