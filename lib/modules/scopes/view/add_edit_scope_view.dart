import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/scope.dart';
import 'package:portfolio_plus/modules/scopes/provider/scope_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';

class AddEditScopeView extends ConsumerStatefulWidget {
  final ScopeModel? scope;

  const AddEditScopeView({super.key, this.scope});

  @override
  ConsumerState<AddEditScopeView> createState() => _AddEditScopeViewState();
}

class _AddEditScopeViewState extends ConsumerState<AddEditScopeView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _filtersController = TextEditingController();
  Currency? _selectedCurrency;
  bool _isLoading = false;

  // Filter options
  List<String> _selectedProviders = [];
  List<String> _selectedAccounts = [];
  List<String> _selectedAssets = [];
  List<String> _selectedTags = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.scope != null) {
      _nameController.text = widget.scope!.name;
      _selectedCurrency = widget.scope!.baseCurrency != null
          ? Currency.values.firstWhere(
              (c) => c.name == widget.scope!.baseCurrency,
              orElse: () => Currency.usd,
            )
          : null;

      // Parse filters JSON
      try {
        final filters = json.decode(widget.scope!.filters);
        _selectedProviders = List<String>.from(filters['providers'] ?? []);
        _selectedAccounts = List<String>.from(filters['accounts'] ?? []);
        _selectedAssets = List<String>.from(filters['assets'] ?? []);
        _selectedTags = List<String>.from(filters['tags'] ?? []);
        if (filters['startDate'] != null) {
          _startDate = DateTime.parse(filters['startDate']);
        }
        if (filters['endDate'] != null) {
          _endDate = DateTime.parse(filters['endDate']);
        }
      } catch (e) {
        // Ignore invalid JSON
      }
      _updateFiltersText();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _filtersController.dispose();
    super.dispose();
  }

  void _updateFiltersText() {
    final filters = {
      'providers': _selectedProviders,
      'accounts': _selectedAccounts,
      'assets': _selectedAssets,
      'tags': _selectedTags,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
    };
    _filtersController.text = const JsonEncoder.withIndent('  ').convert(filters);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.scope != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Basket' : 'Add Basket'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteScope,
              tooltip: 'Delete Basket',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomInputField(
              controller: _nameController,
              hint: 'Basket Name',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a basket name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Base Currency Dropdown
            DropdownButtonFormField<Currency>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Base Currency (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: Currency.values.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Filters Section
            Text(
              'Filters',
              style: Ts.semiBold16(AppColors.black),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _filtersController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'JSON filter configuration',
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
                style: Ts.regular14(AppColors.black),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use JSON format to define filters. Example: {"providers": ["broker1"], "accounts": ["acc1"], "startDate": "2023-01-01T00:00:00.000Z"}',
              style: Ts.regular12(Colors.grey[600]!),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveScope,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEditing ? 'Update Basket' : 'Create Basket'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveScope() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final scope = ScopeModel(
        id: widget.scope?.id,
        name: _nameController.text.trim(),
        filters: _filtersController.text.trim(),
        baseCurrency: _selectedCurrency?.name,
        createdAt: widget.scope?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.scope != null) {
        await ref.read(scopeListProvider.notifier).updateScope(scope);
      } else {
        await ref.read(scopeListProvider.notifier).addScope(scope);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving basket: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteScope() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Basket'),
        content: Text('Are you sure you want to delete "${widget.scope!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(scopeListProvider.notifier).deleteScope(widget.scope!.id!);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting basket: $e')),
          );
        }
      }
    }
  }
}