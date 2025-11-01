import 'package:flutter/material.dart';

class SipCalculatorScreen extends StatelessWidget {
  const SipCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
      ),
      body: const Center(
        child: Text('SIP Calculator Screen'),
      ),
    );
  }
}
