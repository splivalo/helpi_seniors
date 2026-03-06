import 'package:flutter/material.dart';

import 'package:helpi_senior/app/theme.dart';
import 'package:helpi_senior/core/constants/colors.dart';

/// Informacijska kartica s ikonom i tekstom (plava pozadina).
///
/// Zamjenjuje duplicirane escort info card i overtime disclaimer card
/// iz order_flow_screen.dart.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.text,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  final String text;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor ?? HelpiTheme.cardBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: iconColor ?? AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? const Color(0xFF1565C0),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
