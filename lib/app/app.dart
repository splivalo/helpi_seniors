import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:helpi_senior/app/main_shell.dart';
import 'package:helpi_senior/app/theme.dart';
import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/l10n/locale_notifier.dart';

/// Root widget aplikacije Helpi Senior.
class HelpiApp extends StatefulWidget {
  const HelpiApp({super.key});

  @override
  State<HelpiApp> createState() => _HelpiAppState();
}

class _HelpiAppState extends State<HelpiApp> {
  final LocaleNotifier _localeNotifier = LocaleNotifier();

  @override
  void dispose() {
    _localeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: HelpiTheme.light,
          locale: locale,
          supportedLocales: const [Locale('hr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MainShell(localeNotifier: _localeNotifier),
        );
      },
    );
  }
}
