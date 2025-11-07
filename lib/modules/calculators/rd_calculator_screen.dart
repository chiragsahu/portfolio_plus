import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/calculators/universal_calculator_screen.dart';

class RdCalculatorScreen extends StatelessWidget {
  const RdCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UniversalCalculatorScreen(
      title: 'RD Calculator',
      calculatorType: CalculatorType.rd,
    );
  }
}
