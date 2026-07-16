import 'package:flutter/material.dart';
import 'package:portfolio_plus/modules/calculators/models/calculator_type.dart';
import 'package:portfolio_plus/modules/calculators/universal_calculator_screen.dart';

class SipCalculatorScreen extends StatelessWidget {
  const SipCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UniversalCalculatorScreen(
      title: 'SIP Calculator',
      calculatorType: CalculatorType.sip,
    );
  }
}
