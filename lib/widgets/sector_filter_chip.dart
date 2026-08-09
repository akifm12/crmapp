import 'package:flutter/material.dart';

import '../core/theme.dart';

class SectorFilterRow extends StatelessWidget {
  final Map<String, String> sectors;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const SectorFilterRow({
    super.key,
    required this.sectors,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(context, label: 'All', value: null),
          const SizedBox(width: 8),
          for (final entry in sectors.entries) ...[
            _chip(context, label: entry.value, value: entry.key),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, {required String label, required String? value}) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: BrandColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
    );
  }
}
