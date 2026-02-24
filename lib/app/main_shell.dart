import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/utils/mock_data.dart';
import 'package:helpi_senior/features/chat/presentation/chat_list_screen.dart';
import 'package:helpi_senior/features/marketplace/presentation/home_screen.dart';
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

  final _marketplaceKey = GlobalKey<MarketplaceScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onCategoryTap: _onCategoryTap),
      MarketplaceScreen(key: _marketplaceKey),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  void _onCategoryTap(ServiceType type) {
    setState(() => _currentIndex = 1);
    // Daj frame da se MarketplaceScreen renderira ako je prvi put
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marketplaceKey.currentState?.applyServiceFilter(type);
    });
  }

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
            icon: const Icon(Icons.home, size: 28),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search, size: 28),
            label: AppStrings.navStudents,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble, size: 28),
            label: AppStrings.navMessages,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, size: 28),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
