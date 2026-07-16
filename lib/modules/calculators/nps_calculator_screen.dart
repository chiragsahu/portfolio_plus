import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/calculators/models/calculator_type.dart';
import 'package:portfolio_plus/modules/calculators/universal_calculator_screen.dart';

class NpsCalculatorScreen extends StatelessWidget {
  const NpsCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UniversalCalculatorScreen(
      title: 'NPS Calculator',
      calculatorType: CalculatorType.nps,
    );
  }
}
