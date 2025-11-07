import 'package:equatable/equatable.dart';

class MutualFund extends Equatable {
  final String id;
  final String name;
  final String code;
  final String fundHouse;
  final String category;
  final String type; // Equity, Debt, Hybrid, etc.
  final double expenseRatio;
  final double aum; // Assets Under Management in crores
  final double riskRating; // 1-5 scale
  final double nav; // Current NAV
  final Map<String, double> returns; // 1Y, 3Y, 5Y returns in percentage
  final DateTime lastUpdated;
  final List<NavData> navHistory;
  final String? description;
  final String? fundManager;
  final DateTime inceptionDate;

  const MutualFund({
    required this.id,
    required this.name,
    required this.code,
    required this.fundHouse,
    required this.category,
    required this.type,
    required this.expenseRatio,
    required this.aum,
    required this.riskRating,
    required this.nav,
    required this.returns,
    required this.lastUpdated,
    required this.navHistory,
    this.description,
    this.fundManager,
    required this.inceptionDate,
  });

  MutualFund copyWith({
    String? id,
    String? name,
    String? code,
    String? fundHouse,
    String? category,
    String? type,
    double? expenseRatio,
    double? aum,
    double? riskRating,
    double? nav,
    Map<String, double>? returns,
    DateTime? lastUpdated,
    List<NavData>? navHistory,
    String? description,
    String? fundManager,
    DateTime? inceptionDate,
  }) {
    return MutualFund(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      fundHouse: fundHouse ?? this.fundHouse,
      category: category ?? this.category,
      type: type ?? this.type,
      expenseRatio: expenseRatio ?? this.expenseRatio,
      aum: aum ?? this.aum,
      riskRating: riskRating ?? this.riskRating,
      nav: nav ?? this.nav,
      returns: returns ?? this.returns,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      navHistory: navHistory ?? this.navHistory,
      description: description ?? this.description,
      fundManager: fundManager ?? this.fundManager,
      inceptionDate: inceptionDate ?? this.inceptionDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        fundHouse,
        category,
        type,
        expenseRatio,
        aum,
        riskRating,
        nav,
        returns,
        lastUpdated,
        navHistory,
        description,
        fundManager,
        inceptionDate,
      ];

  @override
  String toString() {
    return 'MutualFund(id: $id, name: $name, code: $code)';
  }
}

class NavData extends Equatable {
  final DateTime date;
  final double nav;

  const NavData({
    required this.date,
    required this.nav,
  });

  NavData copyWith({
    DateTime? date,
    double? nav,
  }) {
    return NavData(
      date: date ?? this.date,
      nav: nav ?? this.nav,
    );
  }

  @override
  List<Object?> get props => [date, nav];

  @override
  String toString() {
    return 'NavData(date: $date, nav: $nav)';
  }
}