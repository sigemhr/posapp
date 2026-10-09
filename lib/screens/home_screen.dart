import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pos/pos_screen.dart';
import 'inventory/inventory_screen.dart';
import 'credit/credit_book_screen.dart';
import 'modules/modules_screen.dart';
import 'reports/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PosScreen(onNavigateToModules: () => _navigateToIndex(4)),
          const InventoryScreen(),
          const CreditBookScreen(),
          const ReportsScreen(),
          const ModulesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToIndex,
        indicatorColor: const Color(0xFFEEF2FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale, color: Color(0xFF4F46E5)),
            label: 'Caja',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: Color(0xFF4F46E5)),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFFDC2626)),
            label: 'Fiados',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: Color(0xFF4F46E5)),
            label: 'Corte Z',
          ),
          NavigationDestination(
            icon: Icon(Icons.stars_outlined),
            selectedIcon: Icon(Icons.stars, color: Color(0xFF4F46E5)),
            label: 'Módulos',
          ),
        ],
      ),
    );
  }
}
