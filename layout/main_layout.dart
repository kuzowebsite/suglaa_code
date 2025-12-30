import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; 
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../utils/app_colors.dart';
import '../screens/wallet_screen.dart';
import '../screens/winners_screen.dart';
import '../screens/others_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // UI нуух/гаргах функцуудыг бүгдийг нь хассан (Normal mode)

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Дэлгэцүүд
    final List<Widget> screens = [
      const HomeScreen(),
      const WalletScreen(),
      // WinnersScreen-д одоо toggle дамжуулах шаардлагагүй болсон
      const WinnersScreen(), 
      const OthersScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // 1. ГОЛ ДЭЛГЭЦ
          Positioned.fill(
            child: screens[_currentIndex],
          ),

          // 2. HEADER (Дээд цэс)
          // Одоо WinnersScreen (index 2) дээр ч бас Header харагдана
          if (_currentIndex != 3) // Profile-аас бусад бүх цэсэнд Header харагдана
            const Positioned(
              top: 0, left: 0, right: 0,
              child: CustomAppBar(),
            ),

          // 3. BOTTOM NAV (Доод цэс) - Хөдөлгөөнгүй, тогтмол
          Positioned(
            left: 0, 
            right: 0,
            bottom: 0, // Үргэлж доор байрлана, алга болохгүй
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap,
            ),
          ),
        ],
      ),
    );
  }
}