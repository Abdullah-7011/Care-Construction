import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'projects_screen.dart';
import 'labour_screen.dart';
import 'purchases_screen.dart';
import 'accounts_reports_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ProjectsScreen(),
    LabourScreen(),
    PurchasesScreen(),
    AccountsReportsScreen(),
  ];

  final List<String> _titles = [
    'CARE Construction Management',
    'Projects Directory',
    'Labour & Attendance',
    'Site Purchases',
    'Financials & P&L Reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Text(_titles[_currentIndex]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined),
                  tooltip: 'Alerts',
                  onPressed: () {},
                ),
              ],
            )
          : null, // Other screens have their own AppBars with specific action buttons/tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.domain_outlined),
              activeIcon: Icon(Icons.domain_rounded),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt_rounded),
              label: 'Labour',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Purchases',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance_rounded),
              label: 'Accounts',
            ),
          ],
        ),
      ),
    );
  }
}
