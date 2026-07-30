import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/services/coinmarketcap_service.dart';

import '../../dashboard/view/dashboard_screen.dart';
import '../../portfolio/provider/portfolio_provider.dart';
import '../../portfolio/view/portfolio_view.dart';
import '../../profile/view/profile_screen.dart';
import '../../tools/view/tools_screen.dart';
import '../provider/bottomnav_ctrl.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  const HomePageScreen({super.key});

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends ConsumerState<HomePageScreen> {
  final bottomNavigationBarItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
    BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  final List<NavigationBarEvent> navEvents = const [
    NavigationBarEvent.HOME,
    NavigationBarEvent.PORTFOLIO,
    NavigationBarEvent.TOOLS,
    NavigationBarEvent.PROFILE,
  ];

  final List<Widget> pages = const [
    DashboardScreen(),
    PortfolioScreen(),
    ToolsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoinMarketCapService().fetchListings().then((_) {
        if (mounted) {
          ref.read(portfolioListProvider.notifier).loadPortfolios();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = ref.watch(bottomNavStateProvider);
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: bottomNavigationBarItems,
          onTap: (index) {
            ref
                .read(bottomNavStateProvider.notifier)
                .updateBottomBar(
                  PageModel(navEvents[index], index),
                );
          },
          currentIndex: bottomNavProvider.index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 14,
          unselectedFontSize: 12,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await CoinMarketCapService().refreshAllCryptoPrices();
            await ref.read(portfolioListProvider.notifier).loadPortfolios();
          },
          child: Center(child: pages[bottomNavProvider.index]),
        ),
      ),
    );
  }
}
