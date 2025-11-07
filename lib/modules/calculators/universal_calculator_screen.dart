import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

enum CalculatorType { sip, nps, rd, epf }

class UniversalCalculatorScreen extends StatefulWidget {
  final String title;
  final CalculatorType calculatorType;

  const UniversalCalculatorScreen({
    super.key,
    required this.title,
    required this.calculatorType,
  });

  @override
  State<UniversalCalculatorScreen> createState() =>
      _UniversalCalculatorScreenState();
}

class _UniversalCalculatorScreenState extends State<UniversalCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyInvestmentController = TextEditingController(text: '10000');
  final _annualReturnController = TextEditingController();
  final _investmentPeriodController = TextEditingController(text: '10');
  final _stepUpPercentController = TextEditingController(text: '10');
  final _stepUpAmountController = TextEditingController(text: '1000');
  final _stepUpFrequencyController = TextEditingController(text: '1');
  final _inflationRateController = TextEditingController(text: '6');

  bool _adjustWithInflation = false;
  bool _showResults = false;
  bool _showAdvanceOptions = false;
  bool _stepUpByPercentage = true; // true for percentage, false for amount

  List<YearlyData> _yearlyData = [];
  double _totalInvestment = 0;
  double _totalValue = 0;
  double _totalGain = 0;
  double _inflationAdjustedValue = 0;
  double _inflationAdjustedGain = 0;

  @override
  void initState() {
    super.initState();
    // Set default interest rate based on calculator type
    switch (widget.calculatorType) {
      case CalculatorType.sip:
        _annualReturnController.text = '12';
        break;
      case CalculatorType.nps:
        _annualReturnController.text = '8.2';
        break;
      case CalculatorType.rd:
        _annualReturnController.text = '8.2';
        break;
      case CalculatorType.epf:
        _annualReturnController.text = '7.2';
        break;
    }
  }

  @override
  void dispose() {
    _monthlyInvestmentController.dispose();
    _annualReturnController.dispose();
    _investmentPeriodController.dispose();
    _stepUpPercentController.dispose();
    _stepUpFrequencyController.dispose();
    _inflationRateController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final monthlyInvestment =
        double.tryParse(_monthlyInvestmentController.text) ?? 0;
    final annualReturn = double.tryParse(_annualReturnController.text) ?? 0;
    final investmentPeriod =
        int.tryParse(_investmentPeriodController.text) ?? 0;
    double stepUpValue = 0;
    if (_showAdvanceOptions) {
      if (_stepUpByPercentage) {
        stepUpValue = double.tryParse(_stepUpPercentController.text) ?? 0;
      } else {
        stepUpValue = double.tryParse(_stepUpAmountController.text) ?? 0;
      }
    }
    final stepUpFrequency = _showAdvanceOptions
        ? (int.tryParse(_stepUpFrequencyController.text) ?? 1)
        : 1;
    final inflationRate = _adjustWithInflation
        ? (double.tryParse(_inflationRateController.text) ?? 0)
        : 0;

    final monthlyReturn = annualReturn / 100 / 12;
    final monthlyInflation = inflationRate / 100 / 12;

    _yearlyData = [];
    _totalInvestment = 0;
    _totalValue = 0;

    double currentMonthlyInvestment = monthlyInvestment;
    double currentValue = 0;

    for (int year = 1; year <= investmentPeriod; year++) {
      double yearlyInvestment = 0;
      double yearStartValue = currentValue;

      // Calculate for each month in the year
      for (int month = 1; month <= 12; month++) {
        yearlyInvestment += currentMonthlyInvestment;
        currentValue =
            (currentValue + currentMonthlyInvestment) * (1 + monthlyReturn);
      }

      // Calculate inflation adjusted value for this year
      double inflationFactor = 1;
      if (_adjustWithInflation) {
        inflationFactor = 1 / (1 + monthlyInflation).pow(year * 12);
      }

      final inflationAdjustedYearValue = currentValue * inflationFactor;
      final yearlyGain = currentValue - yearStartValue - yearlyInvestment;
      final inflationAdjustedYearGain =
          inflationAdjustedYearValue - yearStartValue - yearlyInvestment;

      _yearlyData.add(
        YearlyData(
          year: year,
          investment: yearlyInvestment,
          value: currentValue,
          gain: yearlyGain,
          inflationAdjustedValue: inflationAdjustedYearValue,
          inflationAdjustedGain: inflationAdjustedYearGain,
          monthlyInvestment: currentMonthlyInvestment,
        ),
      );

      _totalInvestment += yearlyInvestment;

      // Step up investment if it's the right frequency year
      if (_showAdvanceOptions && year % stepUpFrequency == 0) {
        if (_stepUpByPercentage) {
          currentMonthlyInvestment *= (1 + stepUpValue / 100);
        } else {
          currentMonthlyInvestment += stepUpValue;
        }
      }
    }

    _totalValue = currentValue;
    _totalGain = _totalValue - _totalInvestment;

    if (_adjustWithInflation) {
      final totalInflationFactor =
          1 / (1 + monthlyInflation).pow(investmentPeriod * 12);
      _inflationAdjustedValue = _totalValue * totalInflationFactor;
      _inflationAdjustedGain = _inflationAdjustedValue - _totalInvestment;
    } else {
      _inflationAdjustedValue = _totalValue;
      _inflationAdjustedGain = _totalGain;
    }

    setState(() {
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                        'Investment Details',
                        style: Ts.semiBold18(AppColors.black),
                      ),
                      const SizedBox(height: 16),

                      // Monthly Investment
                      _buildInputField(
                        'Monthly Investment (₹)',
                        _monthlyInvestmentController,
                        'Enter monthly investment amount',
                        TextInputType.number,
                      ),

                      const SizedBox(height: 16),

                      // Expected Annual Return
                      _buildInputField(
                        'Expected Annual Return (%)',
                        _annualReturnController,
                        'Enter expected annual return',
                        TextInputType.number,
                      ),

                      const SizedBox(height: 16),

                      // Investment Period
                      _buildInputField(
                        'Investment Period (Years)',
                        _investmentPeriodController,
                        'Enter investment period in years',
                        TextInputType.number,
                      ),

                      const SizedBox(height: 24),

                      // Advance Options Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _showAdvanceOptions,
                            onChanged: (value) {
                              setState(() {
                                _showAdvanceOptions = value ?? false;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Show Advance Options',
                              style: Ts.regular16(AppColors.black),
                            ),
                          ),
                        ],
                      ),

                      if (_showAdvanceOptions) ...[
                        const SizedBox(height: 24),

                        Text(
                          'Step-Up Details',
                          style: Ts.semiBold18(AppColors.black),
                        ),
                        const SizedBox(height: 16),

                        // Step Up Type Selection
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text(
                                  'By Percentage',
                                  style: Ts.regular14(AppColors.black),
                                ),
                                value: true,
                                groupValue: _stepUpByPercentage,
                                onChanged: (value) {
                                  setState(() {
                                    _stepUpByPercentage = value!;
                                  });
                                },
                                activeColor: AppColors.primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text(
                                  'By Amount',
                                  style: Ts.regular14(AppColors.black),
                                ),
                                value: false,
                                groupValue: _stepUpByPercentage,
                                onChanged: (value) {
                                  setState(() {
                                    _stepUpByPercentage = value!;
                                  });
                                },
                                activeColor: AppColors.primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Step Up Value (Percentage or Amount)
                        if (_stepUpByPercentage)
                          _buildInputField(
                            'Step Up (%)',
                            _stepUpPercentController,
                            'Enter annual step up percentage',
                            TextInputType.number,
                          )
                        else
                          _buildInputField(
                            'Step Up Amount (₹)',
                            _stepUpAmountController,
                            'Enter annual step up amount',
                            TextInputType.number,
                          ),

                        const SizedBox(height: 16),

                        // Step Up Frequency
                        _buildInputField(
                          'Step Up Frequency (Years)',
                          _stepUpFrequencyController,
                          'Enter step up frequency in years',
                          TextInputType.number,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Inflation Adjustment
                      Row(
                        children: [
                          Checkbox(
                            value: _adjustWithInflation,
                            onChanged: (value) {
                              setState(() {
                                _adjustWithInflation = value ?? false;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Adjust with Inflation (6% default)',
                              style: Ts.regular16(AppColors.black),
                            ),
                          ),
                        ],
                      ),

                      if (_adjustWithInflation) ...[
                        const SizedBox(height: 16),
                        _buildInputField(
                          'Inflation Rate (%)',
                          _inflationRateController,
                          'Enter expected inflation rate',
                          TextInputType.number,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculate,
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

              // Results Section - Always show if calculated, don't hide input fields
              if (_showResults) ...[
                _buildResultsSection(),
                const SizedBox(height: 20),
                _buildPieChartSection(),
                const SizedBox(height: 20),
                _buildLineChartSection(),
                const SizedBox(height: 20),
                _buildYearlyBreakdownSection(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Ts.regular14(AppColors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.tryParse(value)! < 0) {
              return 'Value must be positive';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Results', style: Ts.semiBold18(AppColors.black)),
            const SizedBox(height: 16),

            _buildResultRow(
              'Total Investment',
              '₹${_totalInvestment.toStringAsFixed(2)}',
            ),
            _buildResultRow(
              'Total Value',
              '₹${_totalValue.toStringAsFixed(2)}',
            ),
            _buildResultRow(
              'Total Gain',
              '₹${_totalGain.toStringAsFixed(2)}',
              _totalGain >= 0 ? Colors.green : Colors.red,
            ),

            if (_adjustWithInflation) ...[
              const Divider(height: 24),
              _buildResultRow(
                'Inflation Adjusted Value',
                '₹${_inflationAdjustedValue.toStringAsFixed(2)}',
              ),
              _buildResultRow(
                'Inflation Adjusted Gain',
                '₹${_inflationAdjustedGain.toStringAsFixed(2)}',
                _inflationAdjustedGain >= 0 ? Colors.green : Colors.red,
              ),
              _buildResultRow(
                'Inflation Impact',
                '₹${(_totalGain - _inflationAdjustedGain).toStringAsFixed(2)}',
                Colors.orange,
              ),
            ],
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
            style: Ts.regular12(
              AppColors.black,
            ), // Reduced font size from 16 to 12
          ),
          Text(value, style: Ts.semiBold16(valueColor ?? AppColors.black)),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment vs Returns',
              style: Ts.semiBold18(AppColors.black),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    // Investment section
                    PieChartSectionData(
                      color: Colors.blue,
                      value: _totalInvestment,
                      title:
                          '${(_totalInvestment / _totalValue * 100).toStringAsFixed(1)}%\nInvested',
                      radius: 50,
                      titleStyle: Ts.regular12(Colors.white),
                      titlePositionPercentageOffset: 0.6,
                    ),
                    // Gain section
                    PieChartSectionData(
                      color: _totalGain >= 0 ? Colors.green : Colors.red,
                      value: _totalGain.abs(),
                      title:
                          '${(_totalGain.abs() / _totalValue * 100).toStringAsFixed(1)}%\n${_totalGain >= 0 ? 'Returns' : 'Loss'}',
                      radius: 50,
                      titleStyle: Ts.regular12(Colors.white),
                      titlePositionPercentageOffset: 0.6,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  'Invested (₹${(_totalInvestment / 100000).toStringAsFixed(1)}L)',
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  '${_totalGain >= 0 ? 'Returns' : 'Loss'} (₹${(_totalGain.abs() / 100000).toStringAsFixed(1)}L)',
                  _totalGain >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Growth Chart', style: Ts.semiBold18(AppColors.black)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300], strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${(value / 100000).toStringAsFixed(0)}L',
                            style: Ts.regular10(
                              Colors.grey[600] ?? Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'Y${value.toInt()}',
                            style: Ts.regular10(
                              Colors.grey[600] ?? Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                  ),
                  lineBarsData: [
                    // Investment line
                    LineChartBarData(
                      spots: _yearlyData
                          .map(
                            (data) =>
                                FlSpot(data.year.toDouble(), data.investment),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    // Value line
                    LineChartBarData(
                      spots: _yearlyData
                          .map(
                            (data) => FlSpot(data.year.toDouble(), data.value),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    // Inflation adjusted value line (if applicable)
                    if (_adjustWithInflation)
                      LineChartBarData(
                        spots: _yearlyData
                            .map(
                              (data) => FlSpot(
                                data.year.toDouble(),
                                data.inflationAdjustedValue,
                              ),
                            )
                            .toList(),
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'Year ${spot.x.toInt()}: ₹${spot.y.toStringAsFixed(0)}',
                            Ts.regular12(Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Investment', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('Value', Colors.green),
                if (_adjustWithInflation) ...[
                  const SizedBox(width: 16),
                  _buildLegendItem('Inflation Adjusted', Colors.orange),
                ],
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Ts.regular12(AppColors.black)),
      ],
    );
  }

  Widget _buildYearlyBreakdownSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yearly Breakdown', style: Ts.semiBold18(AppColors.black)),
            const SizedBox(height: 16),

            // Horizontally scrollable table with sticky header
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                horizontalMargin: 12,
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: 60,
                      child: Text(
                        'Year',
                        style: Ts.semiBold12(AppColors.black),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text(
                        'Monthly',
                        style: Ts.semiBold12(AppColors.black),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text(
                        'Investment',
                        style: Ts.semiBold12(AppColors.black),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text(
                        'Value',
                        style: Ts.semiBold12(AppColors.black),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text(
                        'Gain',
                        style: Ts.semiBold12(AppColors.black),
                      ),
                    ),
                  ),
                  if (_adjustWithInflation)
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'Real Gain',
                          style: Ts.semiBold12(AppColors.black),
                        ),
                      ),
                    ),
                ],
                rows: _yearlyData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${data.year}',
                            style: Ts.regular12(AppColors.black),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${data.monthlyInvestment.toStringAsFixed(0)}',
                            style: Ts.regular12(AppColors.black),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${data.investment.toStringAsFixed(0)}',
                            style: Ts.regular12(AppColors.black),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${data.value.toStringAsFixed(0)}',
                            style: Ts.regular12(AppColors.black),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${data.gain.toStringAsFixed(0)}',
                            style: Ts.regular12(
                              data.gain >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      if (_adjustWithInflation)
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              '₹${data.inflationAdjustedGain.toStringAsFixed(0)}',
                              style: Ts.regular12(
                                data.inflationAdjustedGain >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyRow(YearlyData data) {
    return ExpansionTile(
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text('${data.year}', style: Ts.regular12(AppColors.black)),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '₹${data.monthlyInvestment.toStringAsFixed(0)}',
                style: Ts.regular12(AppColors.black),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '₹${data.investment.toStringAsFixed(0)}',
                style: Ts.regular12(AppColors.black),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '₹${data.value.toStringAsFixed(0)}',
                style: Ts.regular12(AppColors.black),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '₹${data.gain.toStringAsFixed(0)}',
                style: Ts.regular12(data.gain >= 0 ? Colors.green : Colors.red),
              ),
            ),
            if (_adjustWithInflation)
              SizedBox(
                width: 100,
                child: Text(
                  '₹${data.inflationAdjustedGain.toStringAsFixed(0)}',
                  style: Ts.regular12(
                    data.inflationAdjustedGain >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Year ${data.year} Details',
                style: Ts.semiBold14(AppColors.black),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Monthly Investment',
                '₹${data.monthlyInvestment.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Total Investment',
                '₹${data.investment.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Year End Value',
                '₹${data.value.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Year Gain',
                '₹${data.gain.toStringAsFixed(2)}',
                data.gain >= 0 ? Colors.green : Colors.red,
              ),
              if (_adjustWithInflation) ...[
                _buildDetailRow(
                  'Inflation Adjusted Value',
                  '₹${data.inflationAdjustedValue.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Inflation Adjusted Gain',
                  '₹${data.inflationAdjustedGain.toStringAsFixed(2)}',
                  data.inflationAdjustedGain >= 0 ? Colors.green : Colors.red,
                ),
                _buildDetailRow(
                  'Inflation Impact',
                  '₹${(data.gain - data.inflationAdjustedGain).toStringAsFixed(2)}',
                  Colors.orange,
                ),
              ],
            ],
          ),
        ),
      ],
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

class YearlyData {
  final int year;
  final double monthlyInvestment;
  final double investment;
  final double value;
  final double gain;
  final double inflationAdjustedValue;
  final double inflationAdjustedGain;

  YearlyData({
    required this.year,
    required this.monthlyInvestment,
    required this.investment,
    required this.value,
    required this.gain,
    required this.inflationAdjustedValue,
    required this.inflationAdjustedGain,
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
