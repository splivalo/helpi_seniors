import 'package:flutter/material.dart';

import 'package:helpi_senior/core/constants/colors.dart';

/// Soft selection chip — teal border kad je selektiran, sivi inače.
///
/// Zamjenjuje _buildChip() iz order_flow_screen.dart.
/// Koristi se za: time chips, minute chips, duration chips, day picker, tab-like selektori.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedChipBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.teal : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
