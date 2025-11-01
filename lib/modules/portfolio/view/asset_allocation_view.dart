import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_calculations_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class AssetAllocationView extends ConsumerWidget {
  final int portfolioId;
  final String portfolioName;

  const AssetAllocationView({
    super.key,
    required this.portfolioId,
    required this.portfolioName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allocationAsync = ref.watch(portfolioAllocationProvider(portfolioId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$portfolioName - Asset Allocation'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: allocationAsync.when(
        data: (allocation) {
          final allocationData = allocation['allocation'] as Map<String, double>;
          final assetValues = allocation['assetValues'] as Map<String, double>;
          final totalValue = allocation['totalValue'] as double;

          if (allocationData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No assets to display',
                    style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total value card
                _buildTotalValueCard(totalValue),
                
                const SizedBox(height: 20),
                
                // Pie chart
                _buildPieChart(allocationData, assetValues, totalValue),
                
                const SizedBox(height: 20),
                
                // Asset list
                _buildAssetList(allocationData, assetValues, totalValue),
              ],
            ),
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
                'Error loading asset allocation',
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
      ),
    );
  }

  Widget _buildTotalValueCard(double totalValue) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${totalValue.toStringAsFixed(2)}',
              style: Ts.semiBold28(AppColors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, double> allocationData,
    Map<String, double> assetValues,
    double totalValue,
  ) {
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    
    allocationData.forEach((asset, percentage) {
      sections.add(
        PieChartSectionData(
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: Ts.regular12(Colors.white),
          color: _getAssetColor(colorIndex),
        ),
      );
      colorIndex++;
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
              'Asset Allocation',
              style: Ts.semiBold16(AppColors.black),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetList(
    Map<String, double> allocationData,
    Map<String, double> assetValues,
    double totalValue,
  ) {
    final sortedAssets = allocationData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Breakdown',
              style: Ts.semiBold16(AppColors.black),
            ),
            const SizedBox(height: 16),
            ...sortedAssets.asMap().entries.map((entry) {
              final index = entry.key;
              final asset = entry.value;
              final assetName = asset.key;
              final percentage = asset.value;
              final value = assetValues[assetName] ?? 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Color indicator
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getAssetColor(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Asset name
                    Expanded(
                      flex: 2,
                      child: Text(
                        assetName,
                        style: Ts.regular14(AppColors.black),
                      ),
                    ),
                    
                    // Value
                    Expanded(
                      child: Text(
                        '₹${value.toStringAsFixed(2)}',
                        style: Ts.semiBold14(AppColors.black),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    
                    // Percentage
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    
                    // Progress bar
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(_getAssetColor(index)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getAssetColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.brown,
      Colors.cyan,
    ];
    
    return colors[index % colors.length];
  }
}