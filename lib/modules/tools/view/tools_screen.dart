import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/calculators/advance_sip_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/loan_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/sip_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/nps_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/rd_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/epf_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/trade_calculators.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        childAspectRatio: 1.2,
        children: [
          _buildCalculatorCard(
            context,
            'Trade Calculator',
            Icons.calculate,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TradeCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
            'SIP Calculator',
            Icons.trending_up,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SipCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
            'NPS Calculator',
            Icons.account_balance_wallet,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NpsCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
            'RD Calculator',
            Icons.savings,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RdCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
            'EPF Calculator',
            Icons.work,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EpfCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
            'Advance SIP Calculator',
            Icons.show_chart,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdvanceSipCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
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
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blueGrey[700]),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
