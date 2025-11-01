import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:portfolio_plus/modules/portfolio/provider/portfolio_calculations_provider.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class HistoricalPerformanceView extends ConsumerStatefulWidget {
  final int portfolioId;
  final String portfolioName;

  const HistoricalPerformanceView({
    super.key,
    required this.portfolioId,
    required this.portfolioName,
  });

  @override
  ConsumerState<HistoricalPerformanceView> createState() => _HistoricalPerformanceViewState();
}

class _HistoricalPerformanceViewState extends ConsumerState<HistoricalPerformanceView> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.portfolioName} - Historical Performance'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(),
            tooltip: 'Select Date Range',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range selector
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Range',
                  style: Ts.semiBold16(AppColors.black),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        'Start Date',
                        _startDate,
                        (date) => setState(() => _startDate = date),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateCard(
                        'End Date',
                        _endDate,
                        (date) => setState(() => _endDate = date),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loadHistoricalData,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Load Data'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => _setPresetRange('1M'),
                      child: const Text('1M'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _setPresetRange('3M'),
                      child: const Text('3M'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _setPresetRange('6M'),
                      child: const Text('6M'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _setPresetRange('1Y'),
                      child: const Text('1Y'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Performance chart
          Expanded(
            child: _buildPerformanceChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime date, Function(DateTime) onDateChanged) {
    return InkWell(
      onTap: () => _selectDate(date, onDateChanged),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300] ?? Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: Ts.semiBold14(AppColors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Consumer(
      builder: (context, ref, child) {
        final historicalDataAsync = ref.watch(
          portfolioHistoricalPerformanceProvider({
            'portfolioId': widget.portfolioId,
            'startDate': _startDate,
            'endDate': _endDate,
          }),
        );

        return historicalDataAsync.when(
          data: (data) {
            final dailyValues = data['dailyValues'] as Map<DateTime, double>;
            final totalReturn = data['totalReturn'] as double;
            final totalReturnPercentage = data['totalReturnPercentage'] as double;

            if (dailyValues.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No data available for selected period',
                      style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Convert to list of chart points
            final List<FlSpot> spots = [];
            final sortedDates = dailyValues.keys.toList()..sort();
            
            for (final date in sortedDates) {
              final value = dailyValues[date] ?? 0.0;
              spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), value));
            }

            return Column(
              children: [
                // Summary cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Return',
                          '₹${totalReturn.toStringAsFixed(2)}',
                          totalReturn >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Return %',
                          '${totalReturnPercentage.toStringAsFixed(2)}%',
                          totalReturnPercentage >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chart
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
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
                              'Portfolio Value Over Time',
                              style: Ts.semiBold16(AppColors.black),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: _calculateHorizontalInterval(dailyValues),
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[300],
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '₹${value.toInt()}',
                                            style: Ts.regular10(Colors.grey[600] ?? Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 22,
                                        interval: _calculateDateInterval(sortedDates),
                                        getTitlesWidget: (value, meta) {
                                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                          return Text(
                                            '${date.day}/${date.month}',
                                            style: Ts.regular10(Colors.grey[600] ?? Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      color: AppColors.primaryColor,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 3,
                                            color: AppColors.primaryColor,
                                            strokeColor: Colors.white,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((spot) {
                                          final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                                          final value = spot.y;
                                          return LineTooltipItem(
                                            '${date.day}/${date.month}/${date.year}\n₹${value.toStringAsFixed(2)}',
                                            Ts.regular12(Colors.white),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                  minY: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading historical data',
                  style: Ts.regular18(Colors.red[600] ?? Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
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
              title,
              style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Ts.semiBold20(color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(DateTime initialDate, Function(DateTime) onDateChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      onDateChanged(date);
    }
  }

  void _setPresetRange(String preset) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (preset) {
      case '1M':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3M':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6M':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1Y':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return;
    }
      
    setState(() {
      _startDate = startDate;
      _endDate = now;
    });
  }
  
  void _selectDateRange() {
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Date range selection coming soon!'),
      ),
    );
  }
  
  Future<void> _loadHistoricalData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Trigger data refresh
    ref.refresh(
      portfolioHistoricalPerformanceProvider({
        'portfolioId': widget.portfolioId,
        'startDate': _startDate,
        'endDate': _endDate,
      }),
    );
    
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  double _calculateHorizontalInterval(Map<DateTime, double> dailyValues) {
    if (dailyValues.isEmpty) return 1000.0;
    
    final values = dailyValues.values.toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    // Calculate appropriate interval based on max value
    if (maxValue < 1000) return 200.0;
    if (maxValue < 10000) return 1000.0;
    if (maxValue < 100000) return 10000.0;
    return 50000.0;
  }

  double _calculateDateInterval(List<DateTime> dates) {
    if (dates.isEmpty) return 1.0;
    
    final totalDays = dates.length;
    if (totalDays <= 30) return 5.0; // Every 5 days
    if (totalDays <= 90) return 15.0; // Every 15 days
    if (totalDays <= 180) return 30.0; // Every 30 days
    return 60.0; // Every 60 days
  }
}