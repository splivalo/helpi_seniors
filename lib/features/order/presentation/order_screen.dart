import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/features/booking/data/order_model.dart';
import 'package:helpi_senior/features/order/presentation/order_flow_screen.dart';

/// Naruči ekran — jednostavan prikaz s gumbom za novu narudžbu.
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key, required this.ordersNotifier});

  final OrdersNotifier ordersNotifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.navOrder)),
      body: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 80,
                  color: theme.colorScheme.secondary.withAlpha(100),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.orderTitle,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.orderSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            OrderFlowScreen(ordersNotifier: ordersNotifier),
                      ),
                    );
                  },
                  child: Text(AppStrings.newOrder),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
