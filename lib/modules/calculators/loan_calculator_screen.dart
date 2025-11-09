import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController(text: '1000000');
  final _interestRateController = TextEditingController(text: '8.5');
  final _loanTenureController = TextEditingController(text: '20');
  
  bool _showResults = false;
  
  List<LoanYearlyData> _yearlyData = [];
  List<LoanMonthlyData> _monthlyData = [];
  double _monthlyEMI = 0;
  double _totalPayment = 0;
  double _totalInterest = 0;

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _loanTenureController.dispose();
    super.dispose();
  }

  void _calculateLoan() {
    if (!_formKey.currentState!.validate()) return;

    final loanAmount = double.tryParse(_loanAmountController.text) ?? 0;
    final annualInterestRate = double.tryParse(_interestRateController.text) ?? 0;
    final loanTenureYears = int.tryParse(_loanTenureController.text) ?? 0;

    final monthlyInterestRate = annualInterestRate / 100 / 12;
    final loanTenureMonths = loanTenureYears * 12;

    // Calculate EMI using the formula: EMI = P * r * (1+r)^n / ((1+r)^n - 1)
    _monthlyEMI = loanAmount * monthlyInterestRate * 
                  (1 + monthlyInterestRate).pow(loanTenureMonths) / 
                  ((1 + monthlyInterestRate).pow(loanTenureMonths) - 1);

    _totalPayment = _monthlyEMI * loanTenureMonths;
    _totalInterest = _totalPayment - loanAmount;

    // Generate monthly amortization schedule
    _monthlyData = [];
    double remainingPrincipal = loanAmount;
    double totalInterestPaid = 0;
    double totalPrincipalPaid = 0;

    for (int month = 1; month <= loanTenureMonths; month++) {
      final interestPayment = remainingPrincipal * monthlyInterestRate;
      final principalPayment = _monthlyEMI - interestPayment;
      
      remainingPrincipal -= principalPayment;
      totalInterestPaid += interestPayment;
      totalPrincipalPaid += principalPayment;

      _monthlyData.add(LoanMonthlyData(
        month: month,
        emi: _monthlyEMI,
        principal: principalPayment,
        interest: interestPayment,
        totalInterestPaid: totalInterestPaid,
        totalPrincipalPaid: totalPrincipalPaid,
        remainingPrincipal: remainingPrincipal > 0 ? remainingPrincipal : 0,
      ));
    }

    // Generate yearly breakdown
    _yearlyData = [];
    for (int year = 1; year <= loanTenureYears; year++) {
      final startMonth = (year - 1) * 12;
      final endMonth = year * 12;
      
      if (startMonth < _monthlyData.length) {
        final yearStartPrincipal = startMonth > 0 ? _monthlyData[startMonth - 1].remainingPrincipal : loanAmount;
        final yearEndPrincipal = endMonth <= _monthlyData.length ? _monthlyData[endMonth - 1].remainingPrincipal : 0;
        
        double yearlyEMI = 0;
        double yearlyPrincipal = 0;
        double yearlyInterest = 0;
        
        for (int i = startMonth; i < endMonth && i < _monthlyData.length; i++) {
          yearlyEMI += _monthlyData[i].emi;
          yearlyPrincipal += _monthlyData[i].principal;
          yearlyInterest += _monthlyData[i].interest;
        }
        
        _yearlyData.add(LoanYearlyData(
          year: year,
          emi: yearlyEMI / 12, // Average monthly EMI
          principal: yearlyPrincipal,
          interest: yearlyInterest,
          totalPayment: yearlyEMI,
          startBalance: yearStartPrincipal,
          endBalance: yearEndPrincipal.toDouble(),
        ));
      }
    }

    setState(() {
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Calculator'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Section
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
                        'Loan Details',
                        style: Ts.semiBold18(AppColors.black),
                      ),
                      const SizedBox(height: 16),
                      
                      // Loan Amount
                      _buildInputField(
                        'Loan Amount (₹)',
                        _loanAmountController,
                        'Enter loan amount',
                        TextInputType.number,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Interest Rate
                      _buildInputField(
                        'Interest Rate (%)',
                        _interestRateController,
                        'Enter annual interest rate',
                        TextInputType.number,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Loan Tenure
                      _buildInputField(
                        'Loan Tenure (Years)',
                        _loanTenureController,
                        'Enter loan tenure in years',
                        TextInputType.number,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateLoan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Calculate',
                            style: Ts.semiBold18(Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Results Section
              if (_showResults) ...[
                _buildResultsSection(),
                const SizedBox(height: 20),
                _buildChartSection(),
                const SizedBox(height: 20),
                _buildYearlyBreakdownSection(),
                const SizedBox(height: 20),
                _buildMonthlyBreakdownSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
    TextInputType keyboardType,
  ) {
    return CustomInputField(
      label: label,
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        if (double.tryParse(value)! <= 0) {
          return 'Value must be positive';
        }
        return null;
      },
    );
  }

  Widget _buildResultsSection() {
    return Card(
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
              'Loan Summary',
              style: Ts.semiBold18(AppColors.black),
            ),
            const SizedBox(height: 16),
            
            _buildResultRow('Monthly EMI', '₹${_monthlyEMI.toStringAsFixed(2)}'),
            _buildResultRow('Total Payment', '₹${_totalPayment.toStringAsFixed(2)}'),
            _buildResultRow('Total Interest', '₹${_totalInterest.toStringAsFixed(2)}', Colors.red),
            _buildResultRow('Interest as % of Principal', '${((_totalInterest / (_totalPayment - _totalInterest)) * 100).toStringAsFixed(1)}%', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Ts.regular16(AppColors.black),
          ),
          Text(
            value,
            style: Ts.semiBold16(valueColor ?? AppColors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Card(
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
              'Payment Breakdown Chart',
              style: Ts.semiBold18(AppColors.black),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  // Pie Chart
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue,
                          value: _totalPayment - _totalInterest,
                          title: 'Principal\n₹${(_totalPayment - _totalInterest).toStringAsFixed(0)}',
                          radius: 50,
                          titleStyle: Ts.semiBold12(Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: _totalInterest,
                          title: 'Interest\n₹${_totalInterest.toStringAsFixed(0)}',
                          radius: 50,
                          titleStyle: Ts.semiBold12(Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Center text
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total',
                            style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                          ),
                          Text(
                            '₹${_totalPayment.toStringAsFixed(0)}',
                            style: Ts.semiBold16(AppColors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Principal', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('Interest', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Ts.regular12(AppColors.black),
        ),
      ],
    );
  }

  Widget _buildYearlyBreakdownSection() {
    return Card(
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
              'Yearly Amortization',
              style: Ts.semiBold18(AppColors.black),
            ),
            const SizedBox(height: 16),
            
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('Year', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('EMI', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('Principal', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('Interest', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('Balance', style: Ts.semiBold12(AppColors.black))),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Table Data
            ..._yearlyData.map((data) => _buildYearlyRow(data)),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyRow(LoanYearlyData data) {
    return ExpansionTile(
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(flex: 1, child: Text('${data.year}', style: Ts.regular12(AppColors.black))),
            Expanded(flex: 2, child: Text('₹${data.emi.toStringAsFixed(0)}', style: Ts.regular12(AppColors.black))),
            Expanded(flex: 2, child: Text('₹${data.principal.toStringAsFixed(0)}', style: Ts.regular12(AppColors.black))),
            Expanded(flex: 2, child: Text('₹${data.interest.toStringAsFixed(0)}', style: Ts.regular12(Colors.red))),
            Expanded(flex: 2, child: Text('₹${data.endBalance.toStringAsFixed(0)}', style: Ts.regular12(AppColors.black))),
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Year ${data.year} Details', style: Ts.semiBold14(AppColors.black)),
              const SizedBox(height: 8),
              _buildDetailRow('Monthly EMI', '₹${data.emi.toStringAsFixed(2)}'),
              _buildDetailRow('Total Principal Paid', '₹${data.principal.toStringAsFixed(2)}'),
              _buildDetailRow('Total Interest Paid', '₹${data.interest.toStringAsFixed(2)}', Colors.red),
              _buildDetailRow('Total Payment', '₹${data.totalPayment.toStringAsFixed(2)}'),
              _buildDetailRow('Opening Balance', '₹${data.startBalance.toStringAsFixed(2)}'),
              _buildDetailRow('Closing Balance', '₹${data.endBalance.toStringAsFixed(2)}'),
              _buildDetailRow('Interest % of Payment', '${(data.interest / data.totalPayment * 100).toStringAsFixed(1)}%', Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdownSection() {
    return Card(
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
              'Monthly Amortization Schedule',
              style: Ts.semiBold18(AppColors.black),
            ),
            const SizedBox(height: 16),
            
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('Month', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('EMI', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('Principal', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('Interest', style: Ts.semiBold12(AppColors.black))),
                  Expanded(flex: 2, child: Text('Balance', style: Ts.semiBold12(AppColors.black))),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Table Data (show first 12 months by default)
            ..._monthlyData.take(12).map((data) => _buildMonthlyRow(data)),
            
            if (_monthlyData.length > 12) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '... and ${_monthlyData.length - 12} more months',
                  style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRow(LoanMonthlyData data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('${data.month}', style: Ts.regular12(AppColors.black))),
          Expanded(flex: 2, child: Text('₹${data.emi.toStringAsFixed(0)}', style: Ts.regular12(AppColors.black))),
          Expanded(flex: 2, child: Text('₹${data.principal.toStringAsFixed(0)}', style: Ts.regular12(AppColors.black))),
          Expanded(flex: 2, child: Text('₹${data.interest.toStringAsFixed(0)}', style: Ts.regular12(Colors.red))),
          Expanded(flex: 2, child: Text('₹${data.remainingPrincipal.toStringAsFixed(0)}', style: Ts.regular12(AppColors.black))),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Ts.regular12(Colors.grey[600] ?? Colors.grey)),
          Text(value, style: Ts.semiBold12(valueColor ?? AppColors.black)),
        ],
      ),
    );
  }
}

class LoanYearlyData {
  final int year;
  final double emi;
  final double principal;
  final double interest;
  final double totalPayment;
  final double startBalance;
  final double endBalance;

  LoanYearlyData({
    required this.year,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.startBalance,
    required this.endBalance,
  });
}

class LoanMonthlyData {
  final int month;
  final double emi;
  final double principal;
  final double interest;
  final double totalInterestPaid;
  final double totalPrincipalPaid;
  final double remainingPrincipal;

  LoanMonthlyData({
    required this.month,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.totalInterestPaid,
    required this.totalPrincipalPaid,
    required this.remainingPrincipal,
  });
}

extension NumExtension on num {
  double pow(int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}