class BreakdownData {
  final int periodIndex;
  final DateTime date;
  final double monthlyInvestment;
  final double investment;
  final double value;
  final double gain;
  final double inflationAdjustedValue;
  final double inflationAdjustedGain;
  final bool isYearly;

  BreakdownData({
    required this.periodIndex,
    required this.date,
    required this.monthlyInvestment,
    required this.investment,
    required this.value,
    required this.gain,
    required this.inflationAdjustedValue,
    required this.inflationAdjustedGain,
    this.isYearly = false,
  });
}
