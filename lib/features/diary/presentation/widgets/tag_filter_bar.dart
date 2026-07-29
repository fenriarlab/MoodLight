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
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: tc.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(l10n?.filterAll ?? '全部'),
              selected: selectedFilterTag == null,
              onSelected: (bool selected) {
                onTagSelected(null);
              },
              selectedColor: tc.accent,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                color: selectedFilterTag == null ? Colors.white : tc.textSecondary,
                fontWeight: selectedFilterTag == null ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: tc.elevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          ...allAvailableTags.map((tag) {
            final isSelected = selectedFilterTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
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
                  color: isSelected ? Colors.white : tc.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: tc.elevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
