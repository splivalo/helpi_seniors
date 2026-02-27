import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/features/booking/data/order_model.dart';
import 'package:helpi_senior/features/booking/presentation/orders_screen.dart';
import 'package:helpi_senior/features/chat/presentation/chat_list_screen.dart';
import 'package:helpi_senior/features/order/presentation/order_screen.dart';
import 'package:helpi_senior/features/profile/presentation/profile_screen.dart';

/// Glavni ekran s BottomNavigationBar — 4 taba.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final OrdersNotifier _ordersNotifier = OrdersNotifier();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      OrderScreen(ordersNotifier: _ordersNotifier),
      OrdersScreen(ordersNotifier: _ordersNotifier),
      const ChatScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _ordersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline, size: 28),
              label: AppStrings.navOrder,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_outlined, size: 28),
              label: AppStrings.navOrders,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline, size: 28),
              label: AppStrings.navMessages,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle_outlined, size: 28),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
