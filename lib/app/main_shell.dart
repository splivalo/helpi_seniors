import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/features/booking/presentation/orders_screen.dart';
import 'package:helpi_senior/features/chat/presentation/chat_list_screen.dart';
import 'package:helpi_senior/features/marketplace/presentation/marketplace_screen.dart';
import 'package:helpi_senior/features/profile/presentation/profile_screen.dart';

/// Glavni ekran s BottomNavigationBar — 4 taba.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const <Widget>[
    MarketplaceScreen(),
    OrdersScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.search, size: 28),
            label: AppStrings.navStudents,
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
    );
  }
}
