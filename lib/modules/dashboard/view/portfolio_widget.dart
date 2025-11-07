import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/extensions/number_extension.dart';
import 'package:portfolio_plus/utils/ts.dart';

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Current Value', style: Ts.regular12(AppColors.black)),
                    4.height,
                    Text(100000.00.getAmount, style: Ts.medium14(AppColors.black)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Invested Amount',
                      style: Ts.regular12(AppColors.black),
                    ),
                    6.height,
                    Text(100000.00.getAmount, style: Ts.medium14(AppColors.black)),
                  ],
                ),
              ],
            ),
            12.height,
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          'Today\'s PnL',
                          style: Ts.regular14(AppColors.black),
                        ),
                        4.width,
                        const Icon(Icons.arrow_drop_up, color: AppColors.green),
                      ],
                    ),
                    6.height,
                    Row(
                      children: [
                        Text(1000.00.getAmount, style: Ts.medium14(AppColors.black)),
                        4.width,
                        Text('(+10.00%)', style: Ts.regular12(AppColors.green)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Overall Return',
                      style: Ts.regular12(AppColors.black),
                    ),
                    6.height,
                    Row(
                      children: [
                        Text(10000.00.getAmount, style: Ts.medium14(AppColors.black)),
                        4.width,
                        Text('(+10.00%)', style: Ts.regular12(AppColors.green)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            4.height,
            Text(
              "PnL is calculated based on LTP.",
              style: Ts.regular12(AppColors.grey),
            ),
            4.height,
          ],
        ),
      ),
    );
  }
}
