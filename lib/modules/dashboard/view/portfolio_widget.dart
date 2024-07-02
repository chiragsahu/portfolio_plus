import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                'Current Value',
                style: Ts.regular14(AppColors.black),
              ),
              8.height,
              Text(
                '₹ 100000.00',
                style: Ts.bold20(AppColors.black),
              ),
            ],
          ),
          Spacer(),
          Column(
            children: <Widget>[
              Text(
                'Invested Amount',
                style: Ts.regular14(AppColors.black),
              ),
              8.height,
              Text(
                '₹ 100000.00',
                style: Ts.bold20(AppColors.black),
              ),
            ],
          ),
        ],
      ),
    ]);
  }
}
