import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/modules/calculators/advance_sip_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/loan_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/sip_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/nps_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/rd_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/epf_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/trade_calculators.dart';
import 'package:portfolio_plus/modules/tools/view/comparison/mutual_fund_comparison_screen.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white70,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(
              icon: Icon(Icons.calculate),
              text: 'Calculators',
            ),
            Tab(
              icon: Icon(Icons.compare),
              text: 'Comparison',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analysis',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalculatorsTab(),
          _buildComparisonTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildCalculatorsTab() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      childAspectRatio: 1.2,
      children: [
        _buildToolCard(
          'Trade Calculator',
          Icons.calculate,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TradeCalculatorScreen(),
            ),
          ),
        ),
        _buildToolCard(
          'SIP Calculator',
          Icons.trending_up,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SipCalculatorScreen(),
            ),
          ),
        ),
        _buildToolCard(
          'NPS Calculator',
          Icons.account_balance_wallet,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NpsCalculatorScreen(),
            ),
          ),
        ),
        _buildToolCard(
          'RD Calculator',
          Icons.savings,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RdCalculatorScreen(),
            ),
          ),
        ),
        _buildToolCard(
          'EPF Calculator',
          Icons.work,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EpfCalculatorScreen(),
            ),
          ),
        ),
        _buildToolCard(
          'Advance SIP Calculator',
          Icons.show_chart,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdvanceSipCalculatorScreen(),
            ),
          ),
        ),
        _buildToolCard(
          'Loan Calculator',
          Icons.account_balance,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoanCalculatorScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparison Tools',
            style: Ts.semiBold20(AppColors.black),
          ),
          const SizedBox(height: 16),
          Text(
            'Compare different financial products to make informed investment decisions',
            style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildToolCard(
                'Mutual Fund Comparison',
                Icons.compare_arrows,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MutualFundComparisonScreen(),
                  ),
                ),
                color: AppColors.blue,
              ),
              _buildToolCard(
                'Stock Comparison',
                Icons.show_chart,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.blueGrey,
                    ),
                  );
                },
                color: Colors.grey,
              ),
              _buildToolCard(
                'Portfolio Comparison',
                Icons.pie_chart,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.blueGrey,
                    ),
                  );
                },
                color: Colors.grey,
              ),
              _buildToolCard(
                'Asset Comparison',
                Icons.account_balance,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.blueGrey,
                    ),
                  );
                },
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Tools',
            style: Ts.semiBold20(AppColors.black),
          ),
          const SizedBox(height: 16),
          Text(
            'Deep dive into your investments with comprehensive analysis tools',
            style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildToolCard(
                'Mutual Fund Analysis',
                Icons.analytics,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.blueGrey,
                    ),
                  );
                },
                color: AppColors.green,
              ),
              _buildToolCard(
                'Portfolio Analysis',
                Icons.pie_chart,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.blueGrey,
                    ),
                  );
                },
                color: Colors.grey,
              ),
              _buildToolCard(
                'Risk Analysis',
                Icons.warning,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.blueGrey,
                    ),
                  );
                },
                color: Colors.grey,
              ),
              _buildToolCard(
                'Market Analysis',
                Icons.trending_up,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.blueGrey,
                    ),
                  );
                },
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color color = AppColors.blueGrey,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Ts.semiBold14(AppColors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
