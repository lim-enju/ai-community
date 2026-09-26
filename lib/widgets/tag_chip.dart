import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '#$label',
          style: const TextStyle(fontSize: 12, color: AppColors.navy),
        ),
      ),
    );
  }
}
