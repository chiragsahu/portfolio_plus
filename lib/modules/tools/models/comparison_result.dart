import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/modules/tools/models/mutual_fund.dart';

class ComparisonResult extends Equatable {
  final List<MutualFund> funds;
  final Map<String, dynamic> comparisonMetrics;
  final DateTime createdAt;

  const ComparisonResult({
    required this.funds,
    required this.comparisonMetrics,
    required this.createdAt,
  });

  ComparisonResult copyWith({
    List<MutualFund>? funds,
    Map<String, dynamic>? comparisonMetrics,
    DateTime? createdAt,
  }) {
    return ComparisonResult(
      funds: funds ?? this.funds,
      comparisonMetrics: comparisonMetrics ?? this.comparisonMetrics,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [funds, comparisonMetrics, createdAt];

  @override
  String toString() {
    return 'ComparisonResult(funds: ${funds.length}, createdAt: $createdAt)';
  }
}

class ComparisonMetrics extends Equatable {
  final String metric;
  final Map<String, double> fundValues; // fundId -> value
  final String unit; // %, ₹, rating, etc.
  final bool higherIsBetter;

  const ComparisonMetrics({
    required this.metric,
    required this.fundValues,
    required this.unit,
    this.higherIsBetter = true,
  });

  @override
  List<Object?> get props => [metric, fundValues, unit, higherIsBetter];

  @override
  String toString() {
    return 'ComparisonMetrics(metric: $metric, unit: $unit)';
  }
}