import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/transaction.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_provider.dart';
import 'package:portfolio_plus/modules/portfolio/provider/transaction_provider.dart';
import 'package:portfolio_plus/modules/portfolio/view/add_transaction_view.dart';
import 'package:portfolio_plus/modules/portfolio/view/edit_transaction_view.dart';
import 'package:portfolio_plus/modules/portfolio/view/asset_allocation_view.dart';
import 'package:portfolio_plus/modules/portfolio/view/portfolio_analytics_view.dart';
import 'package:portfolio_plus/modules/portfolio/view/portfolio_export_view.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/enums/transaction.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_plus/modules/settings/provider/settings_provider.dart';
import 'package:portfolio_plus/services/currency_conversion_service.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';

class PortfolioDetailView extends ConsumerStatefulWidget {
  final int portfolioId;

  const PortfolioDetailView({
    super.key,
    required this.portfolioId,
  });

  @override
  ConsumerState<PortfolioDetailView> createState() => _PortfolioDetailViewState();
}

class _PortfolioDetailViewState extends ConsumerState<PortfolioDetailView> {
  String _selectedFilter = 'all';
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioProvider(widget.portfolioId));
    final transactionsAsync = ref.watch(transactionListProvider(widget.portfolioId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Details'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetAllocationView(
                    portfolioId: widget.portfolioId,
                    portfolioName: 'Portfolio', // Will be updated in the when data callback
                  ),
                ),
              );
            },
            tooltip: 'Asset Allocation',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PortfolioAnalyticsView(
                    portfolioId: widget.portfolioId,
                    portfolioName: 'Portfolio', // Will be updated in the when data callback
                  ),
                ),
              );
            },
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PortfolioExportView(
                    portfolioId: widget.portfolioId,
                    portfolioName: 'Portfolio', // Will be updated in the when data callback
                  ),
                ),
              );
            },
            tooltip: 'Export',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionView(
                    portfolioId: widget.portfolioId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_selectionMode ? Icons.close : Icons.select_all),
            onPressed: () {
              setState(() {
                _selectionMode = !_selectionMode;
                if (!_selectionMode) {
                  _selectedIds.clear();
                }
              });
            },
            tooltip: _selectionMode ? 'Cancel selection' : 'Multi-select',
          ),
        ],
      ),
      body: portfolioAsync.when(
        data: (portfolio) {
          return Column(
            children: [
              // Portfolio header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.blueGrey,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
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
                                portfolio.name,
                                style: Ts.semiBold24(Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                portfolio.investmentType.name,
                                style: Ts.regular14(Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ID: ${portfolio.id}',
                            style: Ts.regular12(Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (portfolio.description != null && portfolio.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          portfolio.description!,
                          style: Ts.regular14(Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
              
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
                  data: (transactions) {
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
                              'No transactions yet',
                              style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTransactionView(
                                      portfolioId: widget.portfolioId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Add Your First Transaction'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionCard(
                          transaction: transaction,
                          selectionMode: _selectionMode,
                          selected: transaction.id != null && _selectedIds.contains(transaction.id),
                          onSelectedChanged: (checked) {
                            final id = transaction.id;
                            if (id == null) return;
                            setState(() {
                              if (checked == true) {
                                _selectedIds.add(id);
                              } else {
                                _selectedIds.remove(id);
                              }
                            });
                          },
                          onTap: () {
                            final id = transaction.id;
                            if (_selectionMode && id != null) {
                              setState(() {
                                if (_selectedIds.contains(id)) {
                                  _selectedIds.remove(id);
                                } else {
                                  _selectedIds.add(id);
                                }
                              });
                            } else {
                              // TODO: Show transaction details
                            }
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
                          'Error loading transactions',
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
                            ref.read(transactionListProvider(widget.portfolioId).notifier).loadTransactions();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
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
                'Error loading portfolio',
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        ref.read(transactionListProvider(widget.portfolioId).notifier).filterTransactionsByType(value);
      },
      backgroundColor: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey[200],
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool?>? onSelectedChanged;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectedChanged,
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
              // Transaction type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTransactionTypeColor(transaction.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTransactionTypeIcon(transaction.type),
                  color: _getTransactionTypeColor(transaction.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Transaction info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type.displayName,
                      style: Ts.semiBold16(AppColors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${transaction.quantity.toStringAsFixed(2)}',
                      style: Ts.regular14(AppColors.grey),
                    ),
                    const SizedBox(height: 2),
                    Consumer(
                      builder: (context, ref, _) {
                        final settings = ref.watch(settingsProvider);
                        final base = settings.value?.baseCurrency ?? Currency.inr;
                        final converter = CurrencyConversionService();
                        return Text(
                          'Price: ${converter.format(base, transaction.price)}',
                          style: Ts.regular14(AppColors.grey),
                        );
                      },
                    ),
                    if (transaction.notes != null && transaction.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          transaction.notes!,
                          style: Ts.regular12(AppColors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Amount and date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final settings = ref.watch(settingsProvider);
                      final base = settings.value?.baseCurrency ?? Currency.inr;
                      final converter = CurrencyConversionService();
                      return Text(
                        converter.format(base, transaction.amount),
                        style: Ts.semiBold16(
                          transaction.type.isPositive ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(transaction.date),
                    style: Ts.regular12(AppColors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              selectionMode
                  ? Checkbox(
                      value: selected,
                      onChanged: onSelectedChanged,
                    )
                  : Consumer(
                      builder: (context, ref, _) {
                        return PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final id = transaction.id;
                              if (id != null) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTransactionView(
                                      portfolioId: transaction.portfolioId,
                                      transactionId: id,
                                    ),
                                  ),
                                );
                              }
                            } else if (value == 'delete') {
                              final id = transaction.id;
                              if (id != null) {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete transaction'),
                                    content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    await ref.read(transactionListProvider(transaction.portfolioId).notifier).deleteTransaction(id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Transaction deleted'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error deleting transaction: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Colors.green;
      case TransactionType.sell:
        return Colors.red;
      case TransactionType.dividend:
        return Colors.blue;
      case TransactionType.deposit:
        return Colors.purple;
      case TransactionType.withdrawal:
        return Colors.orange;
      case TransactionType.split:
        return Colors.teal;
      case TransactionType.bonus:
        return Colors.indigo;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.add_shopping_cart;
      case TransactionType.sell:
        return Icons.sell;
      case TransactionType.dividend:
        return Icons.attach_money;
      case TransactionType.deposit:
        return Icons.account_balance_wallet;
      case TransactionType.withdrawal:
        return Icons.money_off;
      case TransactionType.split:
        return Icons.call_split;
      case TransactionType.bonus:
        return Icons.card_giftcard;
    }
  }
}