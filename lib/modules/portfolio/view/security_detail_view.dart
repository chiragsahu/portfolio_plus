import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/asset.dart';
import 'package:portfolio_plus/modules/portfolio/provider/transaction_provider.dart';
import 'package:portfolio_plus/modules/portfolio/view/add_transaction_view.dart';
import 'package:portfolio_plus/modules/portfolio/view/portfolio_detail_view.dart' show TransactionCard;
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class SecurityDetailView extends ConsumerStatefulWidget {
  final int portfolioId;
  final Asset asset;

  const SecurityDetailView({
    super.key,
    required this.portfolioId,
    required this.asset,
  });

  @override
  ConsumerState<SecurityDetailView> createState() => _SecurityDetailViewState();
}

class _SecurityDetailViewState extends ConsumerState<SecurityDetailView> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider(widget.portfolioId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asset.name.isNotEmpty ? widget.asset.name : widget.asset.symbol),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('buy', 'Buy'),
                  const SizedBox(width: 8),
                  _buildFilterChip('sell', 'Sell'),
                  const SizedBox(width: 8),
                  _buildFilterChip('dividend', 'Dividend'),
                  const SizedBox(width: 8),
                  _buildFilterChip('deposit', 'Deposit'),
                  const SizedBox(width: 8),
                  _buildFilterChip('withdrawal', 'Withdrawal'),
                ],
              ),
            ),
          ),
          
          // Transactions list
          Expanded(
            child: transactionsAsync.when(
              data: (allTransactions) {
                // Filter by asset and optionally by type (if type filter is handled locally for now or relies on provider)
                // Note: The provider filterTransactionsByType fetches from DB and replaces state,
                // but if we do that, we get transactions for ALL assets of that type.
                // It's better to just filter locally here.
                var transactions = allTransactions.where((t) => t.assetId == widget.asset.id).toList();
                
                if (_selectedFilter != 'all') {
                  transactions = transactions.where((t) => t.type.name.toLowerCase() == _selectedFilter).toList();
                }

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () {
                        // View details if needed
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error loading transactions: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionView(
                portfolioId: widget.portfolioId,
                defaultSymbol: widget.asset.symbol,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.grey[200],
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
