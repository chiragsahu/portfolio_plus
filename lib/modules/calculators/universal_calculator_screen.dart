import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:portfolio_plus/modules/calculators/loan_calculator_screen.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:portfolio_plus/modules/calculators/models/breakdown_data.dart';
import 'package:portfolio_plus/modules/calculators/models/calculator_type.dart';

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
  bool _isYearly = true;
  DateTime _startDate = DateTime.now();

  List<BreakdownData> _breakdownData = [];
  double _totalInvestment = 0;
  double _totalValue = 0;
  double _totalGain = 0;
  double _inflationAdjustedValue = 0;
  double _inflationAdjustedGain = 0;

  int _currentPage = 0;
  final int _rowsPerPage = 10;
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _isExpanded = true;
  bool _isLoading = false;

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
    int investmentPeriod = int.tryParse(_investmentPeriodController.text) ?? 0;

    // Normalize period to months for calculation
    final totalMonths = _isYearly ? investmentPeriod * 12 : investmentPeriod;

    double stepUpValue = 0;
    if (_showAdvanceOptions) {
      if (_stepUpByPercentage) {
        stepUpValue = double.tryParse(_stepUpPercentController.text) ?? 0;
      } else {
        stepUpValue = double.tryParse(_stepUpAmountController.text) ?? 0;
      }
    }
    final stepUpFrequencyYears = _showAdvanceOptions
        ? (int.tryParse(_stepUpFrequencyController.text) ?? 1)
        : 1;
    final inflationRate = _adjustWithInflation
        ? (double.tryParse(_inflationRateController.text) ?? 0)
        : 0;

    final monthlyReturn = annualReturn / 100 / 12;
    final monthlyInflation = inflationRate / 100 / 12;

    _breakdownData = [];
    _totalInvestment = 0;
    _totalValue = 0;

    double currentMonthlyInvestment = monthlyInvestment;
    double currentValue = 0;

    for (int month = 1; month <= totalMonths; month++) {
      _totalInvestment += currentMonthlyInvestment;
      currentValue =
          (currentValue + currentMonthlyInvestment) * (1 + monthlyReturn);

      // Calculate inflation adjusted value for this month
      double inflationFactor = 1;
      if (_adjustWithInflation) {
        inflationFactor = 1 / (1 + monthlyInflation).pow(month);
      }

      final inflationAdjustedValue = currentValue * inflationFactor;

      // We store monthly data regardless, but we can aggregate for yearly view if needed
      final date = DateTime(_startDate.year, _startDate.month + month - 1);

      _breakdownData.add(
        BreakdownData(
          periodIndex: month,
          date: date,
          investment: _totalInvestment,
          value: currentValue,
          gain: currentValue - _totalInvestment,
          inflationAdjustedValue: inflationAdjustedValue,
          inflationAdjustedGain: inflationAdjustedValue - _totalInvestment,
          monthlyInvestment: currentMonthlyInvestment,
          isYearly: false,
        ),
      );

      // Step up investment every N years
      if (_showAdvanceOptions && month % (stepUpFrequencyYears * 12) == 0) {
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
      final totalInflationFactor = 1 / (1 + monthlyInflation).pow(totalMonths);
      _inflationAdjustedValue = _totalValue * totalInflationFactor;
      _inflationAdjustedGain = _inflationAdjustedValue - _totalInvestment;
    } else {
      _inflationAdjustedValue = _totalValue;
      _inflationAdjustedGain = _totalGain;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate calculation/loading time
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showResults = true;
          _currentPage = 0;
          _isExpanded = false;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: AppColors.blueGrey,
          foregroundColor: Colors.white,
          actions: [
            if (_showResults)
              PopupMenuButton<String>(
                onSelected: _onShareSelected,
                icon: const Icon(Icons.share),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'image',
                    child: Text('Share as Image'),
                  ),
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Text('Share as PDF'),
                  ),
                  const PopupMenuItem(
                    value: 'excel',
                    child: Text('Share as Excel'),
                  ),
                ],
              ),
          ],
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
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Investment Details',
                                    style: Ts.semiBold18(AppColors.black),
                                  ),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                              if (!_isExpanded) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Inv: ₹${_monthlyInvestmentController.text} | ${_isYearly ? "Year" : "Month"}: ${_investmentPeriodController.text} | Ret: ${_annualReturnController.text}%'
                                  '${_showAdvanceOptions ? " | Step Up: " + (_stepUpByPercentage ? _stepUpPercentController.text + "%" : "₹" + _stepUpAmountController.text) : ""}'
                                  '${_adjustWithInflation ? " | Inf: " + _inflationRateController.text + "%" : ""}',
                                  style: Ts.regular10(
                                    Colors.grey[600] ?? Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          if (_isExpanded) ...[
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
                            _buildInvestmentPeriodField(),

                            const SizedBox(height: 16),

                            // Start Date Picker
                            _buildStartDatePicker(context),

                            const SizedBox(height: 24),

                            // Advance Options Section
                            _buildAdvancedOptionsSection(),

                            const SizedBox(height: 16),

                            // Inflation Adjustment Section
                            _buildInflationSection(),

                            const SizedBox(height: 24),

                            // Calculate Button
                            _buildCalculateButton(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_showResults) ...[
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
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
    TextInputType keyboardType, {
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return CustomInputField(
      label: label,
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      enabled: enabled,
      validator:
          validator ??
          (value) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Results', style: Ts.semiBold18(AppColors.black)),
                Text('(₹)', style: Ts.regular12(AppColors.blueGrey)),
              ],
            ),
            const SizedBox(height: 16),

            _buildResultRow(
              'Total Investment',
              _totalInvestment.toStringAsFixed(0),
            ),
            _buildResultRow(
              'Total Gain',
              _totalGain.toStringAsFixed(0),
              _totalGain >= 0 ? Colors.green : Colors.red,
            ),
            _buildResultRow(
              'Total Value',
              _totalValue.toStringAsFixed(0),
            ),

            if (_adjustWithInflation) ...[
              const Divider(height: 24),
              _buildResultRow(
                'Real Gain',
                _inflationAdjustedGain.toStringAsFixed(0),
                _inflationAdjustedGain >= 0 ? Colors.green : Colors.red,
              ),
              _buildResultRow(
                'Real Value',
                _inflationAdjustedValue.toStringAsFixed(0),
              ),
              _buildResultRow(
                'Inflation Impact',
                (_totalValue - _inflationAdjustedValue).toStringAsFixed(0),
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
          Text(label, style: Ts.regular12(AppColors.black)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Growth Chart', style: Ts.semiBold18(AppColors.black)),
                Text('(₹)', style: Ts.regular12(AppColors.blueGrey)),
              ],
            ),
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
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) =>
                          AppColors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          // Only show date for the first spot in the list to avoid duplication
                          final isFirst = touchedSpots.indexOf(spot) == 0;
                          
                          final isInv = spot.barIndex == 0;
                          final isVal = spot.barIndex == 1;
                          final isInf = spot.barIndex == 2;
                          String label = isInv
                              ? 'Invested'
                              : (isVal ? 'Value' : 'Real Value');

                          final monthIdx = spot.x.toInt();
                          String dateStr = '';
                          if (isFirst && monthIdx < _breakdownData.length) {
                            dateStr = DateFormat('MMM yyyy').format(_breakdownData[monthIdx].date) + '\n';
                          }

                          return LineTooltipItem(
                            '$dateStr$label: ${(spot.y / 100000).toStringAsFixed(2)}L',
                            Ts.regular12(Colors.white),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 100000).toStringAsFixed(0)}L',
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
                        interval: _breakdownData.length > 24
                            ? (_breakdownData.length / 4).floorToDouble()
                            : 6,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _breakdownData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat(
                                  'MMM yy',
                                ).format(_breakdownData[index].date),
                                style: Ts.regular10(
                                  Colors.grey[600] ?? Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
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
                      spots: _getChartData(type: 'investment'),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    // Value line
                    LineChartBarData(
                      spots: _getChartData(type: 'value'),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    // Inflation adjusted value line
                    if (_adjustWithInflation)
                      LineChartBarData(
                        spots: _getChartData(type: 'inflation'),
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('Investment', Colors.blue),
                _buildLegendItem('Value', Colors.green),
                if (_adjustWithInflation)
                  _buildLegendItem('Inflation Adjusted', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getChartData({required String type}) {
    List<FlSpot> spots = [];
    // Provide all points to allow interactive tooltips everywhere
    for (int i = 0; i < _breakdownData.length; i++) {
      final data = _breakdownData[i];
      double val = 0;
      if (type == 'investment')
        val = data.investment;
      else if (type == 'value')
        val = data.value;
      else if (type == 'inflation')
        val = data.inflationAdjustedValue;
      spots.add(FlSpot(i.toDouble(), val));
    }
    return spots;
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
    final filteredData = _isYearly
        ? _breakdownData.where((d) => d.periodIndex % 12 == 0).toList()
        : _breakdownData;

    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filteredData.length);
    final pagedData = filteredData.sublist(startIndex, endIndex);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Breakdown', style: Ts.semiBold18(AppColors.black)),
                Text(
                  '${_isYearly ? "Yearly" : "Monthly"} (₹)',
                  style: Ts.regular12(AppColors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 12,
                      horizontalMargin: 8,
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey[200],
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            _isYearly ? 'Year' : 'Month',
                            style: Ts.semiBold12(AppColors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date',
                            style: Ts.semiBold12(AppColors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Investment',
                            style: Ts.semiBold12(AppColors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Value',
                            style: Ts.semiBold12(AppColors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Gain',
                            style: Ts.semiBold12(AppColors.black),
                          ),
                        ),
                        if (_adjustWithInflation) ...[
                          DataColumn(
                            label: Text(
                              'Real Value',
                              style: Ts.semiBold12(AppColors.black),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Real Gain',
                              style: Ts.semiBold12(AppColors.black),
                            ),
                          ),
                        ],
                      ],
                      rows: pagedData.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${_isYearly ? data.periodIndex ~/ 12 : data.periodIndex}',
                                style: Ts.regular12(AppColors.black),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat('MMM yyyy').format(data.date),
                                style: Ts.regular12(AppColors.black),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.investment.toStringAsFixed(0),
                                style: Ts.regular12(AppColors.black),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.value.toStringAsFixed(0),
                                style: Ts.regular12(AppColors.black),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.gain.toStringAsFixed(0),
                                style: Ts.regular12(
                                  data.gain >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            if (_adjustWithInflation) ...[
                              DataCell(
                                Text(
                                  data.inflationAdjustedValue.toStringAsFixed(0),
                                  style: Ts.regular12(AppColors.black),
                                ),
                              ),
                              DataCell(
                                Text(
                                  data.inflationAdjustedGain.toStringAsFixed(0),
                                  style: Ts.regular12(
                                    data.inflationAdjustedGain >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            // Pagination Controls
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  'Page ${_currentPage + 1} of ${((filteredData.length - 1) ~/ _rowsPerPage) + 1}',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: (startIndex + _rowsPerPage) < filteredData.length
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onShareSelected(String value) {
    switch (value) {
      case 'image':
        _shareAsImage();
        break;
      case 'pdf':
        _shareAsPDF();
        break;
      case 'excel':
        _shareAsExcel();
        break;
    }
  }

  Future<void> _shareAsImage() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/calculator_result.png',
      ).create();
      await imagePath.writeAsBytes(image);
      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'My ${widget.title} Result');
    }
  }

  Future<void> _shareAsPDF() async {
    final pdf = pw.Document();

    // Capture the growth chart for the PDF
    final chartImage = await _screenshotController.captureFromWidget(
      Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: Ts.bold20(AppColors.black)),
            const SizedBox(height: 20),
            SizedBox(height: 300, width: 500, child: _buildLineChartSection()),
          ],
        ),
      ),
    );

    final filteredData = _isYearly
        ? _breakdownData.where((d) => d.isYearly).toList()
        : _breakdownData;

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '${widget.title} (Rs.)',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Total Investment: ${_totalInvestment.toStringAsFixed(0)}'),
                  pw.Text('Total Gain: ${_totalGain.toStringAsFixed(0)}'),
                  pw.Text('Total Value: ${_totalValue.toStringAsFixed(0)}'),
                ],
              ),
              if (_adjustWithInflation)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Real Gain: ${_inflationAdjustedGain.toStringAsFixed(0)}'),
                    pw.Text('Real Value: ${_inflationAdjustedValue.toStringAsFixed(0)}'),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 30),
          if (chartImage != null)
            pw.Center(child: pw.Image(pw.MemoryImage(chartImage), width: 450)),
          pw.SizedBox(height: 30),
          pw.Text(
            'Breakdown (${_isYearly ? "Yearly" : "Monthly"})',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: [
              _isYearly ? 'Year' : 'Month',
              'Date',
              'Investment',
              'Value',
              'Gain',
              if (_adjustWithInflation) ...['Real Value', 'Real Gain'],
            ],
            data: filteredData
                .map(
                  (d) => [
                    '${_isYearly ? d.periodIndex ~/ 12 : d.periodIndex}',
                    DateFormat('MMM yyyy').format(d.date),
                    d.investment.toStringAsFixed(0),
                    d.value.toStringAsFixed(0),
                    d.gain.toStringAsFixed(0),
                    if (_adjustWithInflation) ...[
                      d.inflationAdjustedValue.toStringAsFixed(0),
                      d.inflationAdjustedGain.toStringAsFixed(0),
                    ],
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/calculator_report.pdf");
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: '${widget.title} Report');
  }

  Future<void> _shareAsExcel() async {
    var excel = excel_pkg.Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.appendRow([
      excel_pkg.TextCellValue('Period'),
      excel_pkg.TextCellValue('Date'),
      excel_pkg.TextCellValue('Investment'),
      excel_pkg.TextCellValue('Value'),
      excel_pkg.TextCellValue('Gain'),
      if (_adjustWithInflation) ...[
        excel_pkg.TextCellValue('Real Value'),
        excel_pkg.TextCellValue('Real Gain'),
      ],
    ]);

    for (var d in _breakdownData) {
      sheet.appendRow([
        excel_pkg.IntCellValue(d.periodIndex),
        excel_pkg.TextCellValue(DateFormat('MMM yyyy').format(d.date)),
        excel_pkg.DoubleCellValue(d.investment),
        excel_pkg.DoubleCellValue(d.value),
        excel_pkg.DoubleCellValue(d.gain),
        if (_adjustWithInflation) ...[
          excel_pkg.DoubleCellValue(d.inflationAdjustedValue),
          excel_pkg.DoubleCellValue(d.inflationAdjustedGain),
        ],
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/calculator_data.xlsx');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: '${widget.title} Data');
    }
  }

  Widget _buildInvestmentPeriodField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildInputField(
            'Investment Period',
            _investmentPeriodController,
            'Enter period',
            TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final val = int.tryParse(value);
              if (val == null) return 'Invalid';
              if (val < 1) return 'Min 1';
              if (_isYearly && val > 50) return 'Max 50 years';
              if (!_isYearly && val > 600) return 'Max 600 months';
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unit', style: Ts.regular12(AppColors.black)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Y'),
                    selected: _isYearly,
                    onSelected: (val) => _updatePeriodUnit(true),
                    selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryColor,
                    labelStyle: Ts.regular12(
                      _isYearly ? AppColors.primaryColor : AppColors.black,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('M'),
                    selected: !_isYearly,
                    onSelected: (val) => _updatePeriodUnit(false),
                    selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryColor,
                    labelStyle: Ts.regular12(
                      !_isYearly ? AppColors.primaryColor : AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updatePeriodUnit(bool yearly) {
    if (yearly == _isYearly) return;
    setState(() {
      final currentVal = int.tryParse(_investmentPeriodController.text) ?? 0;
      if (yearly) {
        _investmentPeriodController.text = (currentVal ~/ 12)
            .clamp(1, 50)
            .toString();
      } else {
        _investmentPeriodController.text = (currentVal * 12)
            .clamp(1, 600)
            .toString();
      }
      _isYearly = yearly;
    });
  }

  Widget _buildStartDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _startDate = picked);
        }
      },
      child: _buildInputField(
        'Start Date',
        TextEditingController(text: DateFormat('MMM yyyy').format(_startDate)),
        '',
        TextInputType.none,
        enabled: false,
        validator: (v) => null,
      ),
    );
  }

  Widget _buildAdvancedOptionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: _showAdvanceOptions
            ? AppColors.primaryColor.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: _showAdvanceOptions
            ? Border.all(color: AppColors.primaryColor.withOpacity(0.1))
            : null,
      ),
      padding: _showAdvanceOptions ? const EdgeInsets.all(12) : EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _showAdvanceOptions,
                onChanged: (value) =>
                    setState(() => _showAdvanceOptions = value ?? false),
                activeColor: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Advanced Options',
                  style: Ts.regular16(AppColors.black),
                ),
              ),
            ],
          ),
          if (_showAdvanceOptions) ...[
            const SizedBox(height: 16),
            Text('Step-Up Details', style: Ts.semiBold16(AppColors.black)),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('By Percentage'),
                  selected: _stepUpByPercentage,
                  onSelected: (val) =>
                      setState(() => _stepUpByPercentage = true),
                  selectedColor: AppColors.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryColor,
                  labelStyle: Ts.regular14(
                    _stepUpByPercentage
                        ? AppColors.primaryColor
                        : AppColors.black,
                  ),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('By Amount'),
                  selected: !_stepUpByPercentage,
                  onSelected: (val) =>
                      setState(() => _stepUpByPercentage = false),
                  selectedColor: AppColors.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryColor,
                  labelStyle: Ts.regular14(
                    !_stepUpByPercentage
                        ? AppColors.primaryColor
                        : AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(
              _stepUpByPercentage ? 'Step Up (%)' : 'Step Up Amount (₹)',
              _stepUpByPercentage
                  ? _stepUpPercentController
                  : _stepUpAmountController,
              'Enter step up',
              TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              'Step Up Frequency (Years)',
              _stepUpFrequencyController,
              'Enter frequency',
              TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInflationSection() {
    return Container(
      decoration: BoxDecoration(
        color: _adjustWithInflation
            ? Colors.orange.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: _adjustWithInflation
            ? Border.all(color: Colors.orange.withOpacity(0.1))
            : null,
      ),
      padding: _adjustWithInflation
          ? const EdgeInsets.all(12)
          : EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _adjustWithInflation,
                onChanged: (value) =>
                    setState(() => _adjustWithInflation = value ?? false),
                activeColor: Colors.orange,
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
            const SizedBox(height: 12),
            _buildInputField(
              'Inflation Rate (%)',
              _inflationRateController,
              'Enter inflation rate',
              TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Calculate', style: Ts.semiBold18(Colors.white)),
      ),
    );
  }
}
