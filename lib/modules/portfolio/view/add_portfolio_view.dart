import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/portfolio.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/enums/investment_type.dart';
import 'package:portfolio_plus/utils/ts.dart';

class AddPortfolioView extends ConsumerStatefulWidget {
  const AddPortfolioView({super.key});

  @override
  ConsumerState<AddPortfolioView> createState() => _AddPortfolioViewState();
}

class _AddPortfolioViewState extends ConsumerState<AddPortfolioView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _tags = [];
  InvestmentType _selectedInvestmentType = InvestmentType.stocks;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Portfolio'),
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
              // Portfolio name
              Text(
                'Portfolio Name',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter portfolio name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a portfolio name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Investment type
              Text(
                'Investment Type',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<InvestmentType>(
                value: _selectedInvestmentType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: InvestmentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _getInvestmentTypeIcon(type),
                          color: _getInvestmentTypeColor(type),
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
                    _selectedInvestmentType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                'Description (Optional)',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter portfolio description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),

              // Tags
              Text(
                'Tags (Optional)',
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    labelStyle: Ts.regular12(AppColors.primaryColor),
                  )),
                  ActionChip(
                    label: const Text('Add Tag'),
                    onPressed: _showAddTagDialog,
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createPortfolio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Portfolio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _createPortfolio() async {
    if (_formKey.currentState!.validate()) {
      final portfolio = Portfolio(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        investmentType: _selectedInvestmentType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: _tags,
      );

      try {
        await ref.read(portfolioListProvider.notifier).addPortfolio(portfolio);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Portfolio created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating portfolio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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