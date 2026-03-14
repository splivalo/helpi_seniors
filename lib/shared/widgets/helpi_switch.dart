import 'package:flutter/material.dart';

import 'package:helpi_senior/core/constants/colors.dart';

/// Teal-themed Switch with consistent Helpi styling.
class HelpiSwitch extends StatelessWidget {
  const HelpiSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.teal,
      inactiveThumbColor: AppColors.teal,
      trackOutlineColor: WidgetStateProperty.all(AppColors.teal),
    );
  }
}
