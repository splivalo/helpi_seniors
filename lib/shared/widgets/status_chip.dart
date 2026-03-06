import 'package:flutter/material.dart';

import 'package:helpi_senior/core/constants/colors.dart';
import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/features/booking/data/order_model.dart';

/// Chip koji prikazuje status narudžbe (processing / active / completed).
///
/// Zamjenjuje duplicirane _statusChip() iz orders_screen.dart
/// i order_detail_screen.dart.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case OrderStatus.processing:
        bg = AppColors.statusBlueBg;
        fg = AppColors.info;
        label = AppStrings.orderProcessing;
      case OrderStatus.active:
        bg = AppColors.statusGreenBg;
        fg = AppColors.success;
        label = AppStrings.orderActive;
      case OrderStatus.completed:
        bg = AppColors.statusGreenBg;
        fg = AppColors.success;
        label = AppStrings.orderCompleted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
