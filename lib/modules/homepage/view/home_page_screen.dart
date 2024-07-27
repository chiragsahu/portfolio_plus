import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

import '../../dashboard/view/dashboard_screen.dart';
import '../../portfolio/view/portfolio_view.dart';
import '../../profile/view/profile_screen.dart';
import '../provider/bottomnav_ctrl.dart';

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  final bottomNavigationBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Portfolio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Assets',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
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
    ProfileScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavProvider = ref.watch(bottomNavStateProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primaryWhite,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryWhite,
          unselectedIconTheme: const IconThemeData(color: AppColors.grey2),
          unselectedLabelStyle: const TextStyle(color: AppColors.green),
          selectedIconTheme: const IconThemeData(color: AppColors.primaryColor),
          selectedLabelStyle: Ts.regular10(AppColors.black),
          showSelectedLabels: true,
          items: bottomNavigationBarItems,
          onTap: (index) {
            print('index: $index');
            ref.read(bottomNavStateProvider.notifier).updateBottomBar(
                PageModel(NavigationBarEvent.values[index], index));
          },
          currentIndex: bottomNavProvider.index,
        ),
        body: Center(
          child: pages[bottomNavProvider.index],
        ),
      ),
    );
  }
}
