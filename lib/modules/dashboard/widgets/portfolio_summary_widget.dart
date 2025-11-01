import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class PortfolioSummaryWidget extends ConsumerWidget {
  const PortfolioSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfoliosAsync = ref.watch(portfolioListProvider);
    
    return portfoliosAsync.when(
      data: (portfolios) {
        if (portfolios.isEmpty) {
          return _buildEmptyState();
        }
        
        return Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPortfolioCards(portfolios),
            const SizedBox(height: 16),
            _buildOverallStats(portfolios),
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
              'Error loading portfolios',
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No portfolios yet',
            style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first portfolio to start tracking your investments',
            style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueGrey,
            AppColors.blueGrey.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Overview',
            style: Ts.semiBold24(Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Track all your investments in one place',
            style: Ts.regular14(Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCards(List portfolios) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Portfolios',
                portfolios.length.toString(),
                Icons.folder,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Invested',
                '₹${_calculateTotalInvested(portfolios).toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Current Value',
                '₹${_calculateCurrentValue(portfolios).toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total P&L',
                '₹${_calculateTotalPnL(portfolios).toStringAsFixed(2)}',
                Icons.show_chart,
                _calculateTotalPnL(portfolios) >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'P&L %',
                '${_calculateTotalPnLPercentage(portfolios).toStringAsFixed(2)}%',
                Icons.percent,
                _calculateTotalPnL(portfolios) >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Ts.regular12(Colors.grey),
                    ),
                    Text(
                      value,
                      style: Ts.semiBold18(color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats(List portfolios) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Summary',
            style: Ts.semiBold18(AppColors.black),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceItem(
                  'Best Performer',
                  _getBestPerformer(portfolios),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceItem(
                  'Worst Performer',
                  _getWorstPerformer(portfolios),
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Portfolio Distribution',
            style: Ts.semiBold18(AppColors.black),
          ),
          const SizedBox(height: 12),
          _buildPortfolioDistribution(portfolios),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Ts.regular12(Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Ts.semiBold16(color),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioDistribution(List portfolios) {
    // Group portfolios by investment type
    Map<String, int> portfolioCountByType = {};
    for (final portfolio in portfolios) {
      final type = portfolio.investmentType.name;
      portfolioCountByType[type] = (portfolioCountByType[type] ?? 0) + 1;
    }

    return Column(
      children: portfolioCountByType.entries.map((entry) {
        final percentage = portfolios.isNotEmpty ? (entry.value / portfolios.length * 100) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  entry.key,
                  style: Ts.regular12(Colors.grey),
                ),
              ),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getInvestmentTypeColor(entry.key)),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '${entry.value}',
                  style: Ts.semiBold12(AppColors.black),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Ts.regular12(Colors.grey),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  double _calculateTotalInvested(List portfolios) {
    double total = 0.0;
    for (final portfolio in portfolios) {
      // This is a simplified calculation - in real app, you'd use the calculations service
      total += 10000.0; // Placeholder value
    }
    return total;
  }

  double _calculateCurrentValue(List portfolios) {
    double total = 0.0;
    for (final portfolio in portfolios) {
      // This is a simplified calculation - in real app, you'd use the calculations service
      total += 11000.0; // Placeholder value
    }
    return total;
  }

  double _calculateTotalPnL(List portfolios) {
    return _calculateCurrentValue(portfolios) - _calculateTotalInvested(portfolios);
  }

  double _calculateTotalPnLPercentage(List portfolios) {
    final invested = _calculateTotalInvested(portfolios);
    return invested > 0 ? (_calculateTotalPnL(portfolios) / invested) * 100 : 0.0;
  }

  String _getBestPerformer(List portfolios) {
    // Simplified - in real app, you'd use the calculations service
    return 'Stock Portfolio';
  }

  String _getWorstPerformer(List portfolios) {
    // Simplified - in real app, you'd use the calculations service
    return 'Crypto Portfolio';
  }
}