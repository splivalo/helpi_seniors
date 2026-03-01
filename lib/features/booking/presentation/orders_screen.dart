import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/features/booking/data/order_model.dart';
import 'package:helpi_senior/features/booking/presentation/order_detail_screen.dart';

/// Ekran s listom narudžbi — 3 taba: U obradi, Aktivne, Završene.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.ordersNotifier});

  final OrdersNotifier ordersNotifier;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    widget.ordersNotifier.addListener(_onOrdersChanged);
  }

  void _onOrdersChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.ordersNotifier.removeListener(_onOrdersChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.ordersNotifier;

    final tabs = [
      AppStrings.ordersProcessing,
      AppStrings.ordersActive,
      AppStrings.ordersCompleted,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.myOrders)),
      body: Column(
        children: [
          // ── Custom tab bar (coral underline, no black line) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (int i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTab = i);
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            tabs[i],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == i
                                  ? const Color(0xFFEF5B5B)
                                  : const Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: _selectedTab == i
                                  ? const Color(0xFFEF5B5B)
                                  : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Tab content ──
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildList(notifier.processing, _ActionType.cancel),
                _buildList(notifier.active, _ActionType.cancel),
                _buildList(notifier.completed, _ActionType.repeat),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ─────────────────────────────────
  Widget _buildEmpty(ThemeData theme) {
    return Center(
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
            Text(
              AppStrings.noOrdersInCategory,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Order list ──────────────────────────────────
  Widget _buildList(List<OrderModel> orders, _ActionType actionType) {
    final theme = Theme.of(context);

    if (orders.isEmpty) return _buildEmpty(theme);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(theme, order);
      },
    );
  }

  // ── Compact order card — tap to open detail ──
  Widget _buildOrderCard(ThemeData theme, OrderModel order) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              order: order,
              ordersNotifier: widget.ordersNotifier,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.orderNumber(order.id.toString()),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _statusChip(theme, order.status),
              ],
            ),
            const Divider(height: 24),

            // Frequency
            _cardSummaryRow(
              theme,
              AppStrings.orderSummaryFrequency,
              order.frequency,
            ),
            const Divider(height: 24),

            // Date
            _cardSummaryRow(
              theme,
              order.isOneTime
                  ? AppStrings.orderSummaryDate
                  : AppStrings.orderSummaryStartDate,
              order.date,
            ),

            // Tap hint
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.showMore,
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.secondary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card summary row ──
  Widget _cardSummaryRow(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF757575),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Status chip ──
  Widget _statusChip(ThemeData theme, OrderStatus status) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case OrderStatus.processing:
        bg = const Color(0xFFE8F1FB);
        fg = const Color(0xFF1976D2);
        label = AppStrings.orderProcessing;
      case OrderStatus.active:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF4CAF50);
        label = AppStrings.orderActive;
      case OrderStatus.completed:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF4CAF50);
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

enum _ActionType { cancel, repeat }
