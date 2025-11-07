import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/portfolio.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_provider.dart';
import 'package:portfolio_plus/modules/portfolio/view/add_portfolio_view.dart';
import 'package:portfolio_plus/modules/portfolio/view/portfolio_detail_view.dart';
import 'package:portfolio_plus/modules/portfolio/view/portfolio_comparison_view.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/enums/investment_type.dart';
import 'package:portfolio_plus/utils/ts.dart';

class PortfolioListView extends ConsumerStatefulWidget {
  const PortfolioListView({super.key});

  @override
  ConsumerState<PortfolioListView> createState() => _PortfolioListViewState();
}

class _PortfolioListViewState extends ConsumerState<PortfolioListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      ref.read(portfolioListProvider.notifier).searchPortfolios(_searchQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfoliosAsync = ref.watch(portfolioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolios'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PortfolioComparisonView(),
                ),
              );
            },
            tooltip: 'Compare Portfolios',
          ),
          IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProviderScope(child: AddPortfolioView()),
            ),
          );
        },
      ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search portfolios...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Portfolio list
          Expanded(
            child: portfoliosAsync.when(
              data: (portfolios) {
                if (portfolios.isEmpty) {
                  return Center(
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
                          _searchQuery.isEmpty
                              ? 'No portfolios yet'
                              : 'No portfolios found',
                          style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        if (_searchQuery.isEmpty)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProviderScope(child: AddPortfolioView()),
                                ),
                              );
                            },
                            child: const Text('Create Your First Portfolio'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: portfolios.length,
                  itemBuilder: (context, index) {
                    final portfolio = portfolios[index];
                    return PortfolioCard(
                      portfolio: portfolio,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PortfolioDetailView(
                              portfolioId: portfolio.id!,
                            ),
                          ),
                        );
                      },
                    );
                  },
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(portfolioListProvider.notifier).loadPortfolios();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PortfolioCard extends StatelessWidget {
  final Portfolio portfolio;
  final VoidCallback onTap;

  const PortfolioCard({
    super.key,
    required this.portfolio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Investment type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getInvestmentTypeColor(portfolio.investmentType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getInvestmentTypeIcon(portfolio.investmentType),
                  color: _getInvestmentTypeColor(portfolio.investmentType),
                  size: 24,
                ),
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
                      portfolio.investmentType.displayName,
                      style: Ts.regular14(AppColors.grey),
                    ),
                    if (portfolio.description != null && portfolio.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          portfolio.description!,
                          style: Ts.regular12(AppColors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Tags
              if (portfolio.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: portfolio.tags.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: Ts.regular10(AppColors.primaryColor),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
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