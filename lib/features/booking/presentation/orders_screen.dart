import 'package:flutter/material.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';

/// Ekran s listom narudžbi (trenutno prazan — placeholder za buduće podatke).
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.myOrders)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 80,
                color: theme.colorScheme.secondary.withAlpha(100),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.noOrders, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                AppStrings.noOrdersSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
