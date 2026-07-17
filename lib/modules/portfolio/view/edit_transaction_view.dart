import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/transaction.dart';
import 'package:portfolio_plus/models/asset.dart';
import 'package:portfolio_plus/modules/portfolio/provider/transaction_provider.dart';
import 'package:portfolio_plus/modules/portfolio/view/widgets/searchable_ticker_dropdown.dart';
import 'package:portfolio_plus/services/asset_repository.dart';
import 'package:portfolio_plus/services/ticker_loader_service.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';
import 'package:portfolio_plus/utils/enums/transaction.dart';

class EditTransactionView extends ConsumerStatefulWidget {
  final int portfolioId;
  final int transactionId;

  const EditTransactionView({
    super.key,
    required this.portfolioId,
    required this.transactionId,
  });

  @override
  ConsumerState<EditTransactionView> createState() =>
      _EditTransactionViewState();
}

class _EditTransactionViewState extends ConsumerState<EditTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _tickerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController();
  final _notesController = TextEditingController();
  TransactionType _selectedType = TransactionType.buy;
  DateTime _selectedDate = DateTime.now();
  bool _initialized = false;
  IndianEquityTicker? _selectedTicker;

  @override
  void dispose() {
    _tickerController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadAssetTicker(int assetId) async {
    final asset = await AssetRepository().getAssetById(assetId);
    if (asset != null && mounted) {
      setState(() {
        _tickerController.text = asset.symbol;
      });
      // Load corresponding ticker from sheet
      final tickers = await TickerLoaderService().loadTickers();
      final matched = tickers.firstWhere(
        (t) => t.symbol.toUpperCase() == asset.symbol.toUpperCase(),
        orElse: () => IndianEquityTicker(
          symbol: asset.symbol,
          name: asset.name,
          series: asset.series ?? '',
          dateOfListing: '',
          paidUpValue: 0,
          marketLot: 1,
          isin: asset.isin ?? '',
          faceValue: asset.faceValue ?? 10,
        ),
      );
      if (mounted) {
        setState(() {
          _selectedTicker = matched;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionAsync = ref.watch(
      transactionProvider(widget.transactionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: transactionAsync.when(
        data: (transaction) {
          if (!_initialized) {
            _selectedType = transaction.type;
            _selectedDate = transaction.date;
            _quantityController.text = transaction.quantity.toString();
            _priceController.text = transaction.price.toString();
            _feeController.text = transaction.fee?.toString() ?? '';
            _notesController.text = transaction.notes ?? '';
            if (transaction.assetId != null) {
              _loadAssetTicker(transaction.assetId!);
            }
            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Type',
                    style: Ts.semiBold16(AppColors.black),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TransactionType>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: TransactionType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _getTransactionTypeIcon(type),
                              color: _getTransactionTypeColor(type),
                              size: 20,
                        ),
                            const SizedBox(width: 12),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Ticker Symbol Dropdown
                  SearchableTickerDropdown(
                    initialValue: _selectedTicker?.symbol ?? _tickerController.text,
                    onSelected: (ticker) {
                      setState(() {
                        _selectedTicker = ticker;
                        _tickerController.text = ticker.symbol;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  CustomInputField(
                    label: 'Quantity',
                    controller: _quantityController,
                    hint: 'Enter quantity',
                    keyboardType: TextInputType.number,
                    fillColor: Colors.grey[100],
                    borderRadius: 12,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a quantity';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if ((double.tryParse(value) ?? 0) <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  CustomInputField(
                    label: 'Price',
                    controller: _priceController,
                    hint: 'Enter price',
                    keyboardType: TextInputType.number,
                    fillColor: Colors.grey[100],
                    borderRadius: 12,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      child: Text('₹', style: Ts.semiBold16(AppColors.black)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if ((double.tryParse(value) ?? 0) <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // Fee
                  CustomInputField(
                    label: 'Fee (%) (Optional)',
                    controller: _feeController,
                    hint: 'Enter transaction fee percentage',
                    keyboardType: TextInputType.number,
                    fillColor: Colors.grey[100],
                    borderRadius: 12,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      child: Text('%', style: Ts.semiBold16(AppColors.black)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  Text('Amount', style: Ts.semiBold16(AppColors.black)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Text('₹', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _calculateAmount().toStringAsFixed(2),
                            style: Ts.semiBold18(AppColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Date', style: Ts.semiBold16(AppColors.black)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatDate(_selectedDate),
                              style: Ts.regular16(AppColors.black),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Notes (Optional)',
                    style: Ts.semiBold16(AppColors.black),
                  ),
                  const SizedBox(height: 8),
                  CustomInputField(
                    label: 'Notes (Optional)',
                    controller: _notesController,
                    hint: 'Enter transaction notes',
                    maxLines: 3,
                    fillColor: Colors.grey[100],
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateTransaction(transaction),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getTransactionTypeColor(
                          _selectedType,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Update Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Error loading transaction',
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

  double _calculateAmount() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return quantity * price;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateTransaction(TransactionModel original) async {
    if (_formKey.currentState!.validate()) {
      int? assetId = original.assetId;
      final ticker = _tickerController.text.trim().toUpperCase();
      if (ticker.isNotEmpty) {
        final assetRepo = AssetRepository();
        var asset = await assetRepo.getAssetBySymbol(ticker);
        if (asset == null) {
          final newAsset = Asset(
            symbol: ticker,
            name: _selectedTicker?.name ?? ticker,
            isin: _selectedTicker?.isin,
            faceValue: _selectedTicker?.faceValue,
            series: _selectedTicker?.series,
            currentPrice: double.tryParse(_priceController.text) ?? 0.0,
            lastUpdated: DateTime.now(),
            assetClass: 'stock',
          );
          assetId = await assetRepo.createAsset(newAsset);
        } else {
          assetId = asset.id;
          if (asset.isin == null || asset.faceValue == null || asset.series == null) {
            final updatedAsset = asset.copyWith(
              isin: asset.isin ?? _selectedTicker?.isin,
              faceValue: asset.faceValue ?? _selectedTicker?.faceValue,
              series: asset.series ?? _selectedTicker?.series,
            );
            await assetRepo.updateAsset(updatedAsset);
          }
          final price = double.tryParse(_priceController.text);
          if (price != null && assetId != null) {
            await assetRepo.updateAssetPrice(assetId, price);
          }
        }
      }

      final updated = original.copyWith(
        type: _selectedType,
        assetId: assetId,
        quantity: double.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        amount: _calculateAmount(),
        fee: _feeController.text.trim().isEmpty
            ? null
            : double.tryParse(_feeController.text),
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      try {
        await ref
            .read(transactionListProvider(widget.portfolioId).notifier)
            .updateTransaction(updated);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
