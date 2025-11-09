import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_plus/modules/calculators/advance_sip_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/loan_calculator_screen.dart';
import 'package:portfolio_plus/modules/calculators/sip_calculator_screen.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';

class Trade {
  final String type; // Buy or Sell
  final double amount;
  final int quantity;
  final DateTime date;

  Trade({required this.type, required this.amount, required this.quantity, required this.date});
}

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculators'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Calculators',
              style: Ts.semiBold24(AppColors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a calculator to help with your financial planning',
              style: Ts.regular16(Colors.grey[600] ?? Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Calculator Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildCalculatorCard(
                    context,
                    'SIP Calculator',
                    'Calculate Systematic Investment Plan returns',
                    Icons.trending_up,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SipCalculatorScreen(),
                      ),
                    ),
                  ),
                  _buildCalculatorCard(
                    context,
                    'Advanced SIP',
                    'SIP with step-up and inflation adjustment',
                    Icons.show_chart,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvanceSipCalculatorScreen(),
                      ),
                    ),
                  ),
                  _buildCalculatorCard(
                    context,
                    'Loan Calculator',
                    'Calculate EMI and amortization schedule',
                    Icons.account_balance,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoanCalculatorScreen(),
                      ),
                    ),
                  ),
                  _buildCalculatorCard(
                    context,
                    'Trade Calculator',
                    'Track trades and calculate profits',
                    Icons.currency_exchange,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TradeCalculatorScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Ts.semiBold16(AppColors.black),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: Ts.regular12(Colors.grey[600] ?? Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TradeCalculatorScreen extends StatefulWidget {
  const TradeCalculatorScreen({super.key});

  @override
  State<TradeCalculatorScreen> createState() => _TradeCalculatorScreenState();
}

class _TradeCalculatorScreenState extends State<TradeCalculatorScreen> {
  final List<Trade> _trades = [];
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _marketPriceController = TextEditingController();
  String _selectedType = 'Buy';
  DateTime _selectedDate = DateTime.now();

  double realizedProfit = 0;
  double unrealizedProfit = 0;
  double averageBuyPrice = 0;
  int totalHoldings = 0;

  void _addTrade() {
    if (_amountController.text.isEmpty || _quantityController.text.isEmpty) return;

    final trade = Trade(
      type: _selectedType,
      amount: double.parse(_amountController.text),
      quantity: int.parse(_quantityController.text),
      date: _selectedDate,
    );

    setState(() {
      _trades.add(trade);
      _calculateSummary();
    });

    _amountController.clear();
    _quantityController.clear();
  }

  void _calculateSummary() {
    double totalBuyAmount = 0;
    int totalBuyQty = 0;
    double totalSellAmount = 0;
    int totalSellQty = 0;

    for (var trade in _trades) {
      if (trade.type == 'Buy') {
        totalBuyAmount += trade.amount;
        totalBuyQty += trade.quantity;
      } else {
        totalSellAmount += trade.amount;
        totalSellQty += trade.quantity;
      }
    }

    totalHoldings = totalBuyQty - totalSellQty;
    averageBuyPrice = totalBuyQty > 0 ? totalBuyAmount / totalBuyQty : 0;

    final currentMarketPrice = double.tryParse(_marketPriceController.text) ?? 0;

    realizedProfit = totalSellAmount - (averageBuyPrice * totalSellQty);
    unrealizedProfit = totalHoldings * (currentMarketPrice - averageBuyPrice);
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Calculator'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Input Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: _selectedType,
                      items: ['Buy', 'Sell'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                    CustomInputField(
                      label: 'Amount',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      hint: 'Amount',
                      borderRadius: 12,
                    ),
                    CustomInputField(
                      label: 'Quantity',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      hint: 'Quantity',
                      borderRadius: 12,
                    ),
                    Row(
                      children: [
                        Text("Date: ${DateFormat.yMd().format(_selectedDate)}"),
                        TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
                      ],
                    ),
                    CustomInputField(
                      label: 'Current Market Price',
                      controller: _marketPriceController,
                      keyboardType: TextInputType.number,
                      hint: 'Current Market Price',
                      borderRadius: 12,
                      onChanged: (_) => setState(_calculateSummary),
                    ),
                    ElevatedButton(onPressed: _addTrade, child: const Text('Add Trade')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Trade List
            Expanded(
              child: ListView.builder(
                itemCount: _trades.length,
                itemBuilder: (ctx, i) {
                  final trade = _trades[i];
                  return Card(
                    color: trade.type == 'Buy' ? Colors.green[50] : Colors.red[50],
                    child: ListTile(
                      title: Text("${trade.type} - ${trade.quantity} units"),
                      subtitle: Text("Amount: ${currencyFormat.format(trade.amount)} | Date: ${DateFormat.yMd().format(trade.date)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _trades.removeAt(i);
                            _calculateSummary();
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text("Total Holdings: $totalHoldings units"),
                    Text("Average Buy Price: ${currencyFormat.format(averageBuyPrice)}"),
                    Text("Realized Profit: ${currencyFormat.format(realizedProfit)}"),
                    Text("Unrealized Profit: ${currencyFormat.format(unrealizedProfit)}"),
                    SizedBox(height: 150, child: _buildPieChart()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final totalProfit = (realizedProfit + unrealizedProfit).abs();
    if (totalProfit == 0) {
      return const Center(child: Text("No data for chart"));
    }
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: realizedProfit.abs(),
            color: realizedProfit >= 0 ? Colors.green : Colors.red,
            title: 'Realized',
          ),
          PieChartSectionData(
            value: unrealizedProfit.abs(),
            color: unrealizedProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
            title: 'Unrealized',
          ),
        ],
        centerSpaceRadius: 30,
        sectionsSpace: 4,
      ),
    );
  }
}
