import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/view/dashboard_screen.dart';
import '../../portfolio/view/portfolio_view.dart';
import '../../profile/view/profile_screen.dart';
import '../../tools/view/tools_screen.dart';
import '../provider/bottomnav_ctrl.dart';

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  final bottomNavigationBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.pie_chart),
      label: 'Portfolio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet),
      label: 'Assets',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.build),
      label: 'Tools',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  final List<Widget> pages = const [
    DashboardScreen(),
    PortfolioScreen(),
    ProfileScreen(),
    ToolsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavProvider = ref.watch(bottomNavStateProvider);
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: bottomNavigationBarItems,
          onTap: (index) {
            print('index: $index');
            ref.read(bottomNavStateProvider.notifier).updateBottomBar(
                PageModel(NavigationBarEvent.values[index], index));
          },
          currentIndex: bottomNavProvider.index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: true,
        ),
        body: Center(child: pages[bottomNavProvider.index]),
      ),
    );
  }
}
