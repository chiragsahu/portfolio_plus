import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/custom_extensions.dart';
import 'package:portfolio_plus/utils/ts.dart';

import '../../dashboard/view/dashboard_screen.dart';
import '../../portfolio/view/portfolio_view.dart';
import '../../profile/view/profile_screen.dart';
import '../provider/bottomnav_ctrl.dart';

class CustomBottomNavBarItem extends StatelessWidget {
  final IconData? icon;
  final bool isSelected;
  final String label;
  const CustomBottomNavBarItem(
      {super.key,
      required this.icon,
      required this.label,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(
          icon,
          color: isSelected ? AppColors.primaryColor : AppColors.grey2,
        ),
        // icon,
        Text(
          label,
          style: Ts.regular14(AppColors.grey),
        ),
      ],
    );
  }
}

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  final bottomNavigationBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Portfolio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Analysis',
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
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavProvider = ref.watch(bottomNavStateProvider);
    final isAssetSelected = bottomNavProvider.index == 5;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primaryWhite,
        bottomNavigationBar: BottomAppBar(
          height: 75,
          shape: const CircularNotchedRectangle(),
          notchMargin: 15,
          color: AppColors.primaryWhite,
          clipBehavior: Clip.antiAlias,
          // child: SizedBox(
          //   height: 50,
          //   child: BottomNavigationBar(
          //     type: BottomNavigationBarType.fixed,
          //     backgroundColor: AppColors.primaryWhite,
          //     unselectedIconTheme: const IconThemeData(color: AppColors.grey2),
          //     selectedIconTheme: isAssetSelected
          //         ? const IconThemeData(color: AppColors.grey2)
          //         : const IconThemeData(color: AppColors.primaryColor),
          //     showSelectedLabels: true,
          //     items: bottomNavigationBarItems,
          //     onTap: (index) {
          //       ref.read(bottomNavStateProvider.notifier).updateBottomBar(
          //           PageModel(NavigationBarEvent.values[index], index));
          //     },
          //     currentIndex: isAssetSelected ? 0 : bottomNavProvider.index,
          //   ),
          // ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            // children: [
            //  const CustomBottomNavBarItem(icon: Icons.home, label: 'Home', isSelected: true),
            //  const CustomBottomNavBarItem(icon: Icons.home, label: 'Home', isSelected: false),
            //  const CustomBottomNavBarItem(icon: Icons.home, label: 'Home', isSelected: false),
            //  const CustomBottomNavBarItem(icon: Icons.home, label: 'Home', isSelected: false),
            // ],
            children: bottomNavigationBarItems
                .asMap()
                .entries
                .map((e) => CustomBottomNavBarItem(
                      icon: (e.value.icon as Icon).icon,
                      label: e.value.label.value(),
                      isSelected: e.key == bottomNavProvider.index,
                    ).onTap(() {
                      ref.read(bottomNavStateProvider.notifier).updateBottomBar(
                          PageModel(NavigationBarEvent.values[e.key], e.key));
                    }))
                .toList(),
          ),
        ),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Transform.scale(
          scale: 1.25,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              ref.read(bottomNavStateProvider.notifier).updateBottomBar(
                  const PageModel(NavigationBarEvent.assets, 5));
            },
            backgroundColor: isAssetSelected
                ? AppColors.primaryColor
                : AppColors.primaryWhite,
            child: Icon(
              Icons.cases_outlined,
              color: isAssetSelected
                  ? AppColors.primaryWhite
                  : AppColors.primaryColor,
            ),
          ),
        ),
        body: Center(
          child: isAssetSelected
              ? const PortfolioScreen()
              : pages[bottomNavProvider.index],
        ),
      ),
    );
  }
}
