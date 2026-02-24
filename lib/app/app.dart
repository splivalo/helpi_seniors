import 'package:flutter/material.dart';

import 'package:helpi_senior/app/main_shell.dart';
import 'package:helpi_senior/app/theme.dart';
import 'package:helpi_senior/core/l10n/app_strings.dart';

/// Root widget aplikacije Helpi Senior.
class HelpiApp extends StatelessWidget {
  const HelpiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: HelpiTheme.light,
      home: const MainShell(),
    );
  }
}
