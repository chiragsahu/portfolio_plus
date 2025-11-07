import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/calculators/universal_calculator_screen.dart';

class EpfCalculatorScreen extends StatelessWidget {
  const EpfCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UniversalCalculatorScreen(
      title: 'EPF Calculator',
      calculatorType: CalculatorType.epf,
    );
  }
}
