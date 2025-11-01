import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_calculations_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class PortfolioChartsWidget extends ConsumerWidget {
  const PortfolioChartsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPortfoliosSummaryAsync = ref.watch(allPortfoliosSummaryProvider);

    return allPortfoliosSummaryAsync.when(
      data: (summary) {
        final portfoliosByType = summary['portfoliosByType'] as Map<String, int>;
        final topPerformers = summary['topPerformers'] as List<Map<String, dynamic>>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Analytics',
              style: Ts.semiBold20(AppColors.black),
            ),
            const SizedBox(height: 16),
            
            // Portfolio distribution by type
            _buildPortfolioDistributionChart(portfoliosByType),
            
            const SizedBox(height: 24),
            
            // Top performers chart
            if (topPerformers.isNotEmpty) _buildTopPerformersChart(topPerformers),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading portfolio analytics',
              style: Ts.regular18(Colors.red[600] ?? Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioDistributionChart(Map<String, int> portfoliosByType) {
    if (portfoliosByType.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Portfolio Distribution',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No portfolios to display',
                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalPortfolios = portfoliosByType.values.fold(0, (sum, count) => sum + count);
    final List<PieChartSectionData> sections = [];
    
    portfoliosByType.forEach((type, count) {
      final percentage = (count / totalPortfolios) * 100;
      sections.add(
        PieChartSectionData(
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: Ts.regular12(Colors.white),
          color: _getInvestmentTypeColor(type),
        ),
      );
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Portfolio Distribution by Type',
              style: Ts.semiBold16(AppColors.black),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(portfoliosByType, totalPortfolios),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> portfoliosByType, int totalPortfolios) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: portfoliosByType.entries.map((entry) {
        final type = entry.key;
        final count = entry.value;
        final percentage = (count / totalPortfolios) * 100;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getInvestmentTypeColor(type),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$type ($count, ${percentage.toStringAsFixed(1)}%)',
              style: Ts.regular12(Colors.grey[700] ?? Colors.grey),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTopPerformersChart(List<Map<String, dynamic>> topPerformers) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Top Performing Portfolios',
              style: Ts.semiBold16(AppColors.black),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topPerformers.isNotEmpty 
                      ? topPerformers
                          .map((p) => (p['performance']['totalReturnPercentage'] as double))
                          .reduce((a, b) => a > b ? a : b) * 1.2
                      : 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.grey[800] ?? Colors.grey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final portfolio = topPerformers[group.x.toInt()];
                        final name = portfolio['portfolio'].name as String;
                        final returnPercentage = portfolio['performance']['totalReturnPercentage'] as double;
                        return BarTooltipItem(
                          '$name\n${returnPercentage.toStringAsFixed(2)}%',
                          Ts.regular12(Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= topPerformers.length) {
                            return const SizedBox();
                          }
                          final portfolio = topPerformers[value.toInt()];
                          final name = portfolio['portfolio'].name as String;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              name.length > 8 ? '${name.substring(0, 8)}...' : name,
                              style: Ts.regular10(Colors.grey[600] ?? Colors.grey),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: Ts.regular10(Colors.grey[600] ?? Colors.grey),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: topPerformers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final portfolio = entry.value;
                    final returnPercentage = portfolio['performance']['totalReturnPercentage'] as double;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: returnPercentage,
                          color: returnPercentage >= 0 ? Colors.green : Colors.red,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getInvestmentTypeColor(String type) {
    switch (type) {
      case 'stocks':
        return Colors.blue;
      case 'crypto':
        return Colors.orange;
      case 'mutualFunds':
        return Colors.green;
      case 'commodities':
        return Colors.brown;
      case 'bonds':
        return Colors.purple;
      case 'realEstate':
        return Colors.teal;
      case 'custom':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}