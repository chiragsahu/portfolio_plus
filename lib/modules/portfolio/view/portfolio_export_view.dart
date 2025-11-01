import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_provider.dart';
import 'package:portfolio_plus/modules/portfolio/provider/transaction_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class PortfolioExportView extends ConsumerWidget {
  final int portfolioId;
  final String portfolioName;

  const PortfolioExportView({
    super.key,
    required this.portfolioId,
    required this.portfolioName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider(portfolioId));
    final transactionsAsync = ref.watch(transactionListProvider(portfolioId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$portfolioName - Export'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _exportData(context, ref, []),
            tooltip: 'Share',
          ),
        ],
      ),
      body: portfolioAsync.when(
        data: (portfolio) {
          return transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_download,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions to export',
                        style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Export options
                    Card(
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
                              'Export Options',
                              style: Ts.semiBold16(AppColors.black),
                            ),
                            const SizedBox(height: 16),
                            
                            // Export format
                            Text(
                              'Format',
                              style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormatOption('CSV', 'csv', true),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormatOption('JSON', 'json', false),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Date range
                            Text(
                              'Date Range',
                              style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateRangeOption('All Time'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateRangeOption('Last 30 Days'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateRangeOption('Last 90 Days'),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Include options
                            Text(
                              'Include',
                              style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildIncludeOption('Transactions', true),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildIncludeOption('Summary', true),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Export button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _exportData(context, ref, transactions),
                                icon: const Icon(Icons.file_download),
                                label: const Text('Export Data'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Preview
                    Card(
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
                              'Preview',
                              style: Ts.semiBold16(AppColors.black),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                              ),
                              child: Center(
                                child: Text(
                                  '${transactions.length} transactions will be exported',
                                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                ],
              ),
            ),
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

  Widget _buildFormatOption(String title, String value, bool isSelected) {
    return InkWell(
      onTap: () {
        // TODO: Implement format selection
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300] ?? Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : const SizedBox(),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Ts.regular14(
                isSelected ? AppColors.primaryColor : Colors.grey[700] ?? Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeOption(String title) {
    return InkWell(
      onTap: () {
        // TODO: Implement date range selection
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
        ),
        child: Text(
          title,
          style: Ts.regular14(Colors.grey[700] ?? Colors.grey),
        ),
      ),
    );
  }

  Widget _buildIncludeOption(String title, bool isSelected) {
    return InkWell(
      onTap: () {
        // TODO: Implement include options
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300] ?? Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : const SizedBox(),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Ts.regular14(
                isSelected ? AppColors.primaryColor : Colors.grey[700] ?? Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(
    BuildContext context,
    WidgetRef ref,
    List transactions,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting data...'),
            ],
          ),
        ),
      );

      // Generate CSV data
      final csvData = _generateCsvData(transactions);
      
      // Save to file
      final bytes = const Utf8Encoder().convert(csvData);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_portfolio_export.csv';
      final file = File(path);
      await file.writeAsBytes(bytes);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Share file
      final result = await Share.shareXFiles([XFile(path, name: 'portfolio_export.csv')], text: 'Portfolio Data');

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateCsvData(List transactions) {
    final buffer = StringBuffer();
    
    // CSV header
    buffer.writeln('Date,Type,Asset,Quantity,Price,Amount,Notes');
    
    // CSV data
    for (final transaction in transactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.date);
      final type = transaction.type.name;
      final asset = transaction.assetId?.toString() ?? '';
      final quantity = transaction.quantity.toStringAsFixed(2);
      final price = transaction.price.toStringAsFixed(2);
      final amount = transaction.amount.toStringAsFixed(2);
      final notes = transaction.notes ?? '';
      
      // Escape commas and quotes in fields
      final escapedDate = date.contains(',') ? '"$date"' : date;
      final escapedType = type.contains(',') ? '"$type"' : type;
      final escapedAsset = asset.contains(',') ? '"$asset"' : asset;
      final escapedNotes = notes.contains(',') ? '"$notes"' : notes;
      
      buffer.writeln('$escapedDate,$escapedType,$escapedAsset,$quantity,$price,$amount,$escapedNotes');
    }
    
    return buffer.toString();
  }
}