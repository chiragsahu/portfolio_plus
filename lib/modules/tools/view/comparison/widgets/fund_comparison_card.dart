import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/tools/models/mutual_fund.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/extensions/number_extension.dart';

class FundComparisonCard extends StatelessWidget {
  final MutualFund fund;
  final bool isSelected;
  final VoidCallback onTap;

  const FundComparisonCard({
    super.key,
    required this.fund,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fund.name,
                          style: Ts.semiBold16(AppColors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fund.fundHouse,
                          style: Ts.regular12(AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip('Category', fund.category),
                  const SizedBox(width: 8),
                  _buildInfoChip('Type', fund.type),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NAV',
                        style: Ts.regular10(AppColors.grey),
                      ),
                      Text(
                        fund.nav.getAmount,
                        style: Ts.semiBold14(AppColors.black),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '1Y Return',
                        style: Ts.regular10(AppColors.grey),
                      ),
                      Text(
                        '${fund.returns['1Y']?.toStringAsFixed(2)}%',
                        style: Ts.semiBold14(
                          (fund.returns['1Y'] ?? 0) >= 0 ? AppColors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Risk: ${_getRiskRatingText(fund.riskRating)}',
                    style: Ts.regular12(_getRiskColor(fund.riskRating)),
                  ),
                  Text(
                    'Expense: ${fund.expenseRatio.toStringAsFixed(2)}%',
                    style: Ts.regular12(AppColors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: Ts.regular10(AppColors.blueGrey),
      ),
    );
  }

  String _getRiskRatingText(double riskRating) {
    if (riskRating <= 1.5) return 'Very Low';
    if (riskRating <= 2.5) return 'Low';
    if (riskRating <= 3.5) return 'Moderate';
    if (riskRating <= 4.5) return 'High';
    return 'Very High';
  }

  Color _getRiskColor(double riskRating) {
    if (riskRating <= 1.5) return Colors.green;
    if (riskRating <= 2.5) return Colors.blue;
    if (riskRating <= 3.5) return Colors.orange;
    if (riskRating <= 4.5) return Colors.deepOrange;
    return Colors.red;
  }
}