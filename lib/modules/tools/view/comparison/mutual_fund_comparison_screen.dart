import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/modules/tools/models/mutual_fund.dart';
import 'package:portfolio_plus/modules/tools/services/mutual_fund_service.dart';
import 'package:portfolio_plus/modules/tools/view/comparison/widgets/fund_comparison_card.dart';
import 'package:portfolio_plus/modules/tools/view/comparison/widgets/comparison_metrics_widget.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/extensions/number_extension.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';

class MutualFundComparisonScreen extends ConsumerStatefulWidget {
  const MutualFundComparisonScreen({super.key});

  @override
  ConsumerState<MutualFundComparisonScreen> createState() =>
      _MutualFundComparisonScreenState();
}

class _MutualFundComparisonScreenState
    extends ConsumerState<MutualFundComparisonScreen> {
  final List<MutualFund> selectedFunds = [];
  final TextEditingController searchController = TextEditingController();
  List<MutualFund> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchResults = MutualFundService.getSampleFunds();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _searchFunds(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = MutualFundService.getSampleFunds();
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    MutualFundService.searchFunds(query).then((results) {
      setState(() {
        searchResults = results;
        isSearching = false;
      });
    });
  }

  void _addFundToComparison(MutualFund fund) {
    if (selectedFunds.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can compare maximum 4 funds at a time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedFunds.any((f) => f.id == fund.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fund already added to comparison'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      selectedFunds.add(fund);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${fund.name} added to comparison'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  void _removeFundFromComparison(MutualFund fund) {
    setState(() {
      selectedFunds.removeWhere((f) => f.id == fund.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual Fund Comparison'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          if (selectedFunds.length >= 2)
            IconButton(
              icon: const Icon(Icons.compare),
              onPressed: _showComparisonResults,
            ),
        ],
      ),
      body: Column(
        children: [
          if (selectedFunds.isNotEmpty) _buildSelectedFundsBar(),
          _buildSearchBar(),
          Expanded(
            child: isSearching
                ? const Center(child: CircularProgressIndicator())
                : _buildFundList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFundsBar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      color: AppColors.blueGrey.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Funds (${selectedFunds.length}/4)',
            style: Ts.semiBold14(AppColors.black),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedFunds.length,
              itemBuilder: (context, index) {
                final fund = selectedFunds[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.blueGrey),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              fund.name,
                              style: Ts.semiBold12(AppColors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              fund.fundHouse,
                              style: Ts.regular10(Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => _removeFundFromComparison(fund),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomInputField(
        controller: searchController,
        hint: 'Search mutual funds...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  _searchFunds('');
                },
              )
            : null,
        borderRadius: 12,
        fillColor: Colors.white,
        onChanged: _searchFunds,
      ),
    );
  }

  Widget _buildFundList() {
    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No funds found',
              style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final fund = searchResults[index];
        final isSelected = selectedFunds.any((f) => f.id == fund.id);
        
        return FundComparisonCard(
          fund: fund,
          isSelected: isSelected,
          onTap: () => _addFundToComparison(fund),
        );
      },
    );
  }

  void _showComparisonResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonResultsScreen(funds: selectedFunds),
      ),
    );
  }
}

class ComparisonResultsScreen extends StatelessWidget {
  final List<MutualFund> funds;

  const ComparisonResultsScreen({super.key, required this.funds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison Results'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFundOverview(),
            const SizedBox(height: 24),
            ComparisonMetricsWidget(funds: funds),
            const SizedBox(height: 24),
            _buildPerformanceComparison(),
            const SizedBox(height: 24),
            _buildRiskAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildFundOverview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fund Overview', style: Ts.semiBold18(AppColors.black)),
            const SizedBox(height: 16),
            _buildOverviewTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTable() {
    return Column(
      children: [
        _buildOverviewRow('Fund Name', funds.map((f) => f.name).toList()),
        _buildOverviewRow('Fund House', funds.map((f) => f.fundHouse).toList()),
        _buildOverviewRow('Category', funds.map((f) => f.category).toList()),
        _buildOverviewRow('Type', funds.map((f) => f.type).toList()),
        _buildOverviewRow('AUM (₹ Cr)', funds.map((f) => f.aum.toStringAsFixed(2)).toList()),
      ],
    );
  }

  Widget _buildOverviewRow(String label, List<String> values) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300] ?? Colors.grey)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Ts.semiBold14(AppColors.black),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: values.map((value) {
                return Expanded(
                  child: Text(
                    value,
                    style: Ts.regular12(AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceComparison() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Comparison', style: Ts.semiBold18(AppColors.black)),
            const SizedBox(height: 16),
            _buildPerformanceTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTable() {
    return Column(
      children: [
        _buildPerformanceRow('Returns', ['1Y', '3Y', '5Y'], isHeader: true),
        ...funds.map((fund) => _buildPerformanceRow(
          fund.name,
          [
            '${fund.returns['1Y']?.toStringAsFixed(2)}%',
            '${fund.returns['3Y']?.toStringAsFixed(2)}%',
            '${fund.returns['5Y']?.toStringAsFixed(2)}%',
          ],
        )),
      ],
    );
  }

  Widget _buildPerformanceRow(String label, List<String> values, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300] ?? Colors.grey)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: isHeader ? Ts.semiBold14(AppColors.black) : Ts.regular14(AppColors.black),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: values.map((value) {
                return Expanded(
                  child: Text(
                    value,
                    style: isHeader ? Ts.semiBold12(AppColors.black) : Ts.regular12(AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAnalysis() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Analysis', style: Ts.semiBold18(AppColors.black)),
            const SizedBox(height: 16),
            _buildRiskTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTable() {
    return Column(
      children: [
        _buildRiskRow('Risk Metrics', ['Risk Rating', 'Expense Ratio'], isHeader: true),
        ...funds.map((fund) => _buildRiskRow(
          fund.name,
          [
            '${fund.riskRating}/5',
            '${fund.expenseRatio.toStringAsFixed(2)}%',
          ],
        )),
      ],
    );
  }

  Widget _buildRiskRow(String label, List<String> values, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300] ?? Colors.grey)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: isHeader ? Ts.semiBold14(AppColors.black) : Ts.regular14(AppColors.black),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: values.map((value) {
                return Expanded(
                  child: Text(
                    value,
                    style: isHeader ? Ts.semiBold12(AppColors.black) : Ts.regular12(AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}