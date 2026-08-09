import 'package:flutter/material.dart';

import '../core/theme.dart';

class CategoryBadge extends StatelessWidget {
  final String label;
  final String colorKey;

  const CategoryBadge({super.key, required this.label, required this.colorKey});

  @override
  Widget build(BuildContext context) {
    final color = BadgeColors.fromTailwindClasses(colorKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
