import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/tools/models/mutual_fund.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/extensions/number_extension.dart';

class ComparisonMetricsWidget extends StatelessWidget {
  final List<MutualFund> funds;

  const ComparisonMetricsWidget({super.key, required this.funds});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key Metrics', style: Ts.semiBold18(AppColors.black)),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        _buildMetricRow('Current NAV', funds.map((f) => f.nav.getAmount).toList()),
        _buildMetricRow('AUM (₹ Cr)', funds.map((f) => f.aum.toStringAsFixed(2)).toList()),
        _buildMetricRow('Expense Ratio (%)', funds.map((f) => f.expenseRatio.toStringAsFixed(2)).toList()),
        _buildMetricRow('Risk Rating', funds.map((f) => '${f.riskRating}/5').toList()),
        _buildMetricRow('1Y Return (%)', funds.map((f) => '${f.returns['1Y']?.toStringAsFixed(2)}').toList()),
        _buildMetricRow('3Y Return (%)', funds.map((f) => '${f.returns['3Y']?.toStringAsFixed(2)}').toList()),
        _buildMetricRow('5Y Return (%)', funds.map((f) => '${f.returns['5Y']?.toStringAsFixed(2)}').toList()),
      ],
    );
  }

  Widget _buildMetricRow(String label, List<String> values) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Ts.semiBold14(AppColors.black),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: values.map((value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: Ts.regular12(AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}