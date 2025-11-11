import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/account.dart';
import 'package:portfolio_plus/models/transaction.dart';
import 'package:portfolio_plus/modules/portfolio/provider/account_provider.dart';
import 'package:portfolio_plus/modules/portfolio/provider/transaction_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';
import 'package:portfolio_plus/utils/enums/transaction.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/custom_dropdown.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';

class AddTransactionView extends ConsumerStatefulWidget {
  final int portfolioId;

  const AddTransactionView({
    super.key,
    required this.portfolioId,
  });

  @override
  ConsumerState<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends ConsumerState<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController();
  final _tradeIdController = TextEditingController();
  final _notesController = TextEditingController();
  TransactionType _selectedType = TransactionType.buy;
  DateTime _selectedDate = DateTime.now();
  AccountModel? _selectedAccountModel;
  int? _selectedAccountId;
  Currency _selectedFeeCurrency = Currency.inr;
  Currency _selectedQuoteCurrency = Currency.inr;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _tradeIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account selection
              Text(
                'Account (Optional)',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 8),
              accountsAsync.when(
                data: (accounts) => CustomDropdown<AccountModel?>(
                  selectedItem: _selectedAccountModel,
                  items: [
                    null,
                    ...accounts,
                  ],
                  itemToString: (account) => account == null
                      ? 'No account selected'
                      : '${account.name} (${account.baseCurrency?.displayName ?? 'No currency'})',
                  onChanged: (account) {
                    setState(() {
                      _selectedAccountModel = account;
                      _selectedAccountId = account?.id;
                    });
                  },
                  hintText: 'Select account',
                  borderRadius: 12,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error loading accounts: $error'),
              ),
              const SizedBox(height: 20),

              // Transaction type
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

              // Quantity
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

              // Price
              CustomInputField(
                label: 'Price',
                controller: _priceController,
                hint: 'Enter price',
                keyboardType: TextInputType.number,
                fillColor: Colors.grey[100],
                borderRadius: 12,
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                label: 'Fee (Optional)',
                controller: _feeController,
                hint: 'Enter transaction fee',
                keyboardType: TextInputType.number,
                fillColor: Colors.grey[100],
                borderRadius: 12,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Fee Currency
              Text(
                'Fee Currency',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 8),
              CustomDropdown<Currency>(
                selectedItem: _selectedFeeCurrency,
                items: Currency.values,
                itemToString: (currency) => currency.displayName,
                onChanged: (currency) {
                  if (currency != null) {
                    setState(() {
                      _selectedFeeCurrency = currency;
                    });
                  }
                },
                hintText: 'Select fee currency',
                borderRadius: 12,
              ),
              const SizedBox(height: 20),

              // Quote Currency
              Text(
                'Quote Currency',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 8),
              CustomDropdown<Currency>(
                selectedItem: _selectedQuoteCurrency,
                items: Currency.values,
                itemToString: (currency) => currency.displayName,
                onChanged: (currency) {
                  if (currency != null) {
                    setState(() {
                      _selectedQuoteCurrency = currency;
                    });
                  }
                },
                hintText: 'Select quote currency',
                borderRadius: 12,
              ),
              const SizedBox(height: 20),

              // Trade ID
              CustomInputField(
                label: 'Trade ID (Optional)',
                controller: _tradeIdController,
                hint: 'Enter trade ID',
                fillColor: Colors.grey[100],
                borderRadius: 12,
              ),
              const SizedBox(height: 20),

              // Amount (calculated)
              Text(
                'Amount',
                style: Ts.semiBold16(AppColors.black),
              ),
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

              // Date
              Text(
                'Date',
                style: Ts.semiBold16(AppColors.black),
              ),
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

              // Notes
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

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTransactionTypeColor(_selectedType),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add ${_selectedType.displayName}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      final transaction = TransactionModel(
        portfolioId: widget.portfolioId,
        accountId: _selectedAccountId,
        type: _selectedType,
        quantity: double.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        amount: _calculateAmount(),
        fee: _feeController.text.trim().isEmpty
            ? null
            : double.tryParse(_feeController.text),
        feeCurrency: _selectedFeeCurrency,
        quoteCurrency: _selectedQuoteCurrency,
        tradeId: _tradeIdController.text.trim().isEmpty
            ? null
            : _tradeIdController.text,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      try {
        await ref.read(transactionListProvider(widget.portfolioId).notifier).addTransaction(transaction);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding transaction: $e'),
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