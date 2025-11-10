import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/portfolio.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_provider.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_calculations_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/enums/investment_type.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/modules/settings/provider/settings_provider.dart';
import 'package:portfolio_plus/services/currency_conversion_service.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';

class PortfolioComparisonView extends ConsumerStatefulWidget {
  const PortfolioComparisonView({super.key});

  @override
  ConsumerState<PortfolioComparisonView> createState() => _PortfolioComparisonViewState();
}

class _PortfolioComparisonViewState extends ConsumerState<PortfolioComparisonView> {
  List<Portfolio> _selectedPortfolios = [];
  bool _isComparing = false;

  @override
  Widget build(BuildContext context) {
    final portfoliosAsync = ref.watch(portfolioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Portfolios'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedPortfolios.length >= 2)
            TextButton.icon(
              onPressed: _selectedPortfolios.length >= 2 ? _comparePortfolios : null,
              icon: const Icon(Icons.compare_arrows, color: Colors.white),
              label: Text(
                'Compare (${_selectedPortfolios.length})',
                style: Ts.regular14(Colors.white),
              ),
            ),
        ],
      ),
      body: _isComparing
          ? _buildComparisonView()
          : portfoliosAsync.when(
              data: (portfolios) {
                if (portfolios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.compare_arrows,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No portfolios to compare',
                          style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Selection info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Text(
                        _selectedPortfolios.isEmpty
                            ? 'Select 2 or more portfolios to compare'
                            : 'Selected ${_selectedPortfolios.length} portfolio${_selectedPortfolios.length > 1 ? 's' : ''}',
                        style: Ts.regular14(Colors.grey[700] ?? Colors.grey),
                      ),
                    ),
                    
                    // Portfolio list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: portfolios.length,
                        itemBuilder: (context, index) {
                          final portfolio = portfolios[index];
                          final isSelected = _selectedPortfolios.contains(portfolio);
                          
                          return PortfolioComparisonCard(
                            portfolio: portfolio,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedPortfolios.remove(portfolio);
                                } else {
                                  _selectedPortfolios.add(portfolio);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
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
            ),
    );
  }

  Widget _buildComparisonView() {
    return Column(
      children: [
        // Header with back button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isComparing = false;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Selection'),
              ),
              const Spacer(),
              Text(
                'Comparing ${_selectedPortfolios.length} Portfolios',
                style: Ts.semiBold16(AppColors.black),
              ),
            ],
          ),
        ),
        
        // Comparison content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portfolio names header
                _buildPortfolioNamesHeader(),
                
                const SizedBox(height: 16),
                
                // Comparison metrics
                _buildComparisonMetrics(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioNamesHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                'Portfolio',
                style: Ts.semiBold14(AppColors.black),
              ),
            ),
            ..._selectedPortfolios.map((portfolio) {
              return Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        portfolio.name,
                        style: Ts.semiBold14(AppColors.black),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        portfolio.investmentType.name,
                        style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonMetrics() {
    return Column(
      children: [
        // Total Value
        _buildMetricCard(
          'Total Value',
          (summary) => summary['totalValue'] as double,
          Colors.blue,
        ),
        
        // Invested Amount
        _buildMetricCard(
          'Invested Amount',
          (summary) => summary['investedAmount'] as double,
          Colors.green,
        ),
        
        // Total P&L
        _buildMetricCard(
          'Total P&L',
          (summary) => summary['totalPnL'] as double,
          Colors.orange,
          showPercentage: true,
        ),
        
        // P&L Percentage
        _buildMetricCard(
          'Return %',
          (summary) => summary['totalPnLPercentage'] as double,
          Colors.purple,
          isPercentage: true,
        ),
        
        // Transaction Count
        _buildMetricCard(
          'Transactions',
          (summary) => (summary['transactionCount'] as int).toDouble(),
          Colors.teal,
          isCurrency: false,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    double Function(Map<String, dynamic>) getValue,
    Color color, {
    bool isPercentage = false,
    bool showPercentage = false,
    bool isCurrency = true,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final summaries = _selectedPortfolios.map((portfolio) {
          return ref.watch(portfolioSummaryProvider(portfolio.id!));
        }).toList();

        final settingsAsync = ref.watch(settingsProvider);
        final base = settingsAsync.value?.baseCurrency ?? Currency.inr;
        final converter = CurrencyConversionService();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    title,
                    style: Ts.semiBold14(AppColors.black),
                  ),
                ),
                ...summaries.map((summaryAsync) {
                  return Expanded(
                    child: Center(
                      child: summaryAsync.when(
                        data: (summary) {
                          final value = getValue(summary);
                          final displayValue = isPercentage
                              ? '${value.toStringAsFixed(2)}%'
                              : (isCurrency
                                  ? converter.format(base, value)
                                  : value.toStringAsFixed(0));

                          return Column(
                            children: [
                              Text(
                                displayValue,
                                style: Ts.semiBold16(color),
                                textAlign: TextAlign.center,
                              ),
                              if (showPercentage && summary['investedAmount'] > 0)
                                Text(
                                  '${(value / summary['investedAmount'] * 100).toStringAsFixed(2)}%',
                                  style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                                ),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _comparePortfolios() {
    setState(() {
      _isComparing = true;
    });
  }
}

class PortfolioComparisonCard extends StatelessWidget {
  final Portfolio portfolio;
  final bool isSelected;
  final VoidCallback onTap;

  const PortfolioComparisonCard({
    super.key,
    required this.portfolio,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppColors.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryColor : Colors.grey[300],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Portfolio info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portfolio.name,
                      style: Ts.semiBold16(AppColors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      portfolio.investmentType.name,
                      style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                    ),
                    if (portfolio.description != null && portfolio.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          portfolio.description!,
                          style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Investment type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getInvestmentTypeColor(portfolio.investmentType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getInvestmentTypeIcon(portfolio.investmentType),
                  color: _getInvestmentTypeColor(portfolio.investmentType),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getInvestmentTypeColor(InvestmentType type) {
    switch (type) {
      case InvestmentType.stocks:
        return Colors.blue;
      case InvestmentType.crypto:
        return Colors.orange;
      case InvestmentType.mutualFunds:
        return Colors.green;
      case InvestmentType.commodities:
        return Colors.brown;
      case InvestmentType.bonds:
        return Colors.purple;
      case InvestmentType.realEstate:
        return Colors.teal;
      case InvestmentType.custom:
        return Colors.grey;
    }
  }

  IconData _getInvestmentTypeIcon(InvestmentType type) {
    switch (type) {
      case InvestmentType.stocks:
        return Icons.trending_up;
      case InvestmentType.crypto:
        return Icons.currency_bitcoin;
      case InvestmentType.mutualFunds:
        return Icons.account_balance;
      case InvestmentType.commodities:
        return Icons.bar_chart;
      case InvestmentType.bonds:
        return Icons.description;
      case InvestmentType.realEstate:
        return Icons.home;
      case InvestmentType.custom:
        return Icons.folder;
    }
  }
}