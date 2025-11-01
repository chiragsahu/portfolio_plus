import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/calculators/advance_sip_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/sip_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/trade_calculators.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildCalculatorCard(
            context,
            'Trade Calculator',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TradeCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
            'SIP Calculator',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SipCalculatorScreen(),
              ),
            ),
          ),
          _buildCalculatorCard(
            context,
            'Advance SIP Calculator',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdvanceSipCalculatorScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard(
      BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }
}
