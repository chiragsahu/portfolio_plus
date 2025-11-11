import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/modules/dashboard/widgets/portfolio_summary_widget.dart';
import 'package:portfolio_plus/modules/dashboard/widgets/portfolio_charts_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PortfolioWidget(),
          // SizedBox(height: 20),
          PortfolioSummaryWidget(),
          SizedBox(height: 20),
          PortfolioChartsWidget(),
        ],
      ),
    );
  }
}
