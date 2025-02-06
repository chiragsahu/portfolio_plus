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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Stocks",
              style: Ts.medium16(AppColors.black),
            ),
            12.height,
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.currency_bitcoin,
                                size: 30,
                              ),
                            )
                          ],
                        ),
                        10.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Hdfc Bank Fund S&P 500",
                              maxLines: 2,
                              style: Ts.medium16(AppColors.black),
                            ),
                            Text(
                              "BTC",
                              style: Ts.semiBold14(AppColors.grey),
                            ),
                            5.height,
                            Row(
                              children: [
                                Text(
                                  "XIRR:",
                                  style: Ts.regular14(AppColors.grey),
                                ),
                                5.width,
                                Text(
                                  "12.5%",
                                  style: Ts.medium14(AppColors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        10.width,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹ 1,00,000",
                              style: Ts.bold16(AppColors.black),
                            ),
                            2.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "9353.85 ",
                                  style: Ts.regular14(AppColors.green),
                                ),
                                2.width,
                                Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "+31.98 %",
                                    style: Ts.semiBold14(AppColors.green),
                                  ),
                                ),
                              ],
                            ),
                            4.height,
                            PopupMenuButton(
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: Text("Edit"),
                                  ),
                                  PopupMenuItem(
                                    child: Text("Delete"),
                                  ),
                                ];
                              },
                            ).expand(),
                          ],
                        ).expand(),
                      ],
                    ).withHeight(100),
                    Divider(
                      color: AppColors.grey2,
                      thickness: 0.3,
                    ),
                  ],
                );
              },
            ),
          ],
        ).paddingSymmetric(horizontal: 16)
      ],
    );
  }
}
