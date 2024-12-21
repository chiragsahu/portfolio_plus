import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/components/custom_app_bar.dart';
import 'package:portfolio_plus/modules/dashboard/view/portfolio_widget.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAppBar(
          title: 'My Portfolio',
          isBackButton: false,
        ),
        const PortfolioWidget(),
        Column(
          children: [
            Text(
              "Stocks",
              style: Ts.medium16(AppColors.black),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Stock Name"),
                  subtitle: Text("Stock Price"),
                );
              },
            ).withHeight(200),
          ],
        ).paddingSymmetric(horizontal: 16)
      ],
    );
  }
}
