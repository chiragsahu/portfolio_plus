import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_calculations_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class PortfolioAnalyticsView extends ConsumerWidget {
  final int portfolioId;
  final String portfolioName;

  const PortfolioAnalyticsView({
    super.key,
    required this.portfolioId,
    required this.portfolioName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider(portfolioId));
    final performanceAsync = ref.watch(portfolioPerformanceProvider(portfolioId));
    final allocationAsync = ref.watch(portfolioAllocationProvider(portfolioId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$portfolioName - Analytics'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary
            _buildSection(
              'Portfolio Summary',
              [
                _buildSummaryCard(
                  summaryAsync,
                  'Total Value',
                  'totalValue',
                  '₹',
                  Colors.blue,
                ),
                _buildSummaryCard(
                  summaryAsync,
                  'Invested Amount',
                  'investedAmount',
                  '₹',
                  Colors.green,
                ),
                _buildSummaryCard(
                  summaryAsync,
                  'Total P&L',
                  'totalPnL',
                  '₹',
                  Colors.orange,
                  showPercentage: true,
                ),
                _buildSummaryCard(
                  summaryAsync,
                  'Return %',
                  'totalPnLPercentage',
                  '',
                  Colors.purple,
                  isPercentage: true,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Performance Metrics
            _buildSection(
              'Performance Metrics',
              [
                _buildPerformanceCard(
                  performanceAsync,
                  'Best Performer',
                  'bestPerformer',
                  Colors.green,
                ),
                _buildPerformanceCard(
                  performanceAsync,
                  'Worst Performer',
                  'worstPerformer',
                  Colors.red,
                ),
                _buildPerformanceCard(
                  performanceAsync,
                  'Total Return',
                  'totalReturn',
                  Colors.blue,
                  prefix: '₹',
                ),
                _buildPerformanceCard(
                  performanceAsync,
                  'Return %',
                  'totalReturnPercentage',
                  Colors.purple,
                  isPercentage: true,
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Realized vs Unrealized
            _buildSection(
              'Realized vs Unrealized Gains',
              [
                _buildRealizedUnrealizedCard(summaryAsync),
              ],
            ),

            const SizedBox(height: 20),
            
            // Asset Allocation
            _buildSection(
              'Asset Allocation',
              [
                _buildAllocationCard(allocationAsync),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Transaction Analysis
            _buildSection(
              'Transaction Analysis',
              [
                _buildTransactionCard(summaryAsync),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Ts.semiBold20(AppColors.black),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSummaryCard(
    AsyncValue<Map<String, dynamic>> summaryAsync,
    String title,
    String key,
    String prefix,
    Color color, {
    bool showPercentage = false,
    bool isPercentage = false,
  }) {
    return summaryAsync.when(
      data: (summary) {
        final value = summary[key] as double;
        final displayValue = isPercentage
            ? '${value.toStringAsFixed(2)}%'
            : '$prefix${value.toStringAsFixed(2)}';
        
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
                  title,
                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      displayValue,
                      style: Ts.semiBold24(color),
                    ),
                    if (showPercentage && summary['investedAmount'] > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '(${((value / summary['investedAmount']) * 100).toStringAsFixed(1)}%)',
                          style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
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
                title,
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
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
                title,
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading data',
                style: Ts.regular14(Colors.red[600] ?? Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
    AsyncValue<Map<String, dynamic>> performanceAsync,
    String title,
    String key,
    Color color, {
    String prefix = '',
    bool isPercentage = false,
  }) {
    return performanceAsync.when(
      data: (performance) {
        final value = performance[key];
        final displayValue = isPercentage
            ? '${value?.toStringAsFixed(2)}%'
            : '$prefix${value ?? 'N/A'}';
        
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
                  title,
                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  displayValue,
                  style: Ts.semiBold24(color),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
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
                title,
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
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
                title,
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading data',
                style: Ts.regular14(Colors.red[600] ?? Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllocationCard(AsyncValue<Map<String, dynamic>> allocationAsync) {
    return allocationAsync.when(
      data: (allocation) {
        final allocationData = allocation['allocation'] as Map<String, double>;
        final totalValue = allocation['totalValue'] as double;
        
        if (allocationData.isEmpty) {
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
                    'Asset Allocation',
                    style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No assets to display',
                    style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        
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
                  'Asset Allocation',
                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                ),
                const SizedBox(height: 16),
                ...sortedAssets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final asset = entry.value;
                  final assetName = asset.key;
                  final percentage = asset.value;
                  final value = (percentage / 100) * totalValue;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Asset name
                        Expanded(
                          flex: 2,
                          child: Text(
                            assetName,
                            style: Ts.regular14(AppColors.black),
                          ),
                        ),
                        
                        // Progress bar
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${value.toStringAsFixed(2)}',
                                style: Ts.semiBold14(AppColors.black),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(_getAssetColor(index)),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                              ),
                            ],
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
      },
      loading: () => Card(
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
                'Asset Allocation',
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
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
                'Asset Allocation',
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading data',
                style: Ts.regular14(Colors.red[600] ?? Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(AsyncValue<Map<String, dynamic>> summaryAsync) {
    return summaryAsync.when(
      data: (summary) {
        final buyTransactions = summary['buyTransactions'] as int;
        final sellTransactions = summary['sellTransactions'] as int;
        final dividendTransactions = summary['dividendTransactions'] as int;
        final totalTransactions = summary['transactionCount'] as int;
        
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
                  'Transaction Analysis',
                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.6,
                  children: [
                    _buildTransactionStat(
                      'Total Transactions',
                      totalTransactions.toString(),
                      Colors.blue,
                    ),
                    _buildTransactionStat(
                      'Buy Transactions',
                      buyTransactions.toString(),
                      Colors.green,
                    ),
                    _buildTransactionStat(
                      'Sell Transactions',
                      sellTransactions.toString(),
                      Colors.red,
                    ),
                    _buildTransactionStat(
                      'Dividend Transactions',
                      dividendTransactions.toString(),
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
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
                'Transaction Analysis',
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
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
                'Transaction Analysis',
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading data',
                style: Ts.regular14(Colors.red[600] ?? Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealizedUnrealizedCard(AsyncValue<Map<String, dynamic>> summaryAsync) {
    return summaryAsync.when(
      data: (summary) {
        final realizedTrades = (summary['realizedTrades'] as double?) ?? 0.0;
        final realizedDividends = (summary['realizedDividends'] as double?) ?? 0.0;
        final realizedTotal = (summary['realizedTotal'] as double?) ?? 0.0;
        final unrealizedPnL = (summary['unrealizedPnL'] as double?) ?? 0.0;

        Color trendColor(double v) => v >= 0 ? Colors.green : Colors.red;

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
                  'Realized vs Unrealized Gains',
                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [
                    // Realized Gains tile
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: trendColor(realizedTotal).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (Colors.grey[300])!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Realized Gains', style: Ts.regular12(Colors.grey[700] ?? Colors.grey)),
                          const SizedBox(height: 6),
                          Text('₹${realizedTotal.toStringAsFixed(2)}', style: Ts.semiBold20(trendColor(realizedTotal))),
                          const Spacer(),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Trades: ₹${realizedTrades.toStringAsFixed(2)}', style: Ts.regular12(Colors.blue)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Dividends: ₹${realizedDividends.toStringAsFixed(2)}', style: Ts.regular12(Colors.purple)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Unrealized PnL tile
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: trendColor(unrealizedPnL).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (Colors.grey[300])!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unrealized P&L', style: Ts.regular12(Colors.grey[700] ?? Colors.grey)),
                          const SizedBox(height: 6),
                          Text('₹${unrealizedPnL.toStringAsFixed(2)}', style: Ts.semiBold20(trendColor(unrealizedPnL))),
                          const Spacer(),
                          Text(
                            'Based on current average cost',
                            style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[400]),
              const SizedBox(width: 8),
              Text('Error loading gains', style: Ts.regular14(Colors.red[600] ?? Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Ts.semiBold20(color),
          ),
        ],
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