// enum AssetClass {
//   stock, bond, mf, etf, nps, gold, silver, cash, fd, realestate, other
// }
//
// enum MutualFundType {
//   equity, debt, hybrid, solution, other
// }

import 'dart:core';

abstract class Investible<T> {
  T get type;
  String get name;
  String? get id;
  int get quantity;

  void display();

  double calculateXIRR();

  double calculateCAGR();

  double calculateROI();

  double calculateIRR();
}

class Stocks extends Investible<double> {

  Stocks({
    required this.type,
    required this.name,
    required this.quantity,
    this.id,
  });

  @override
  void display() {
    print('Stocks');
  }

  @override
  double calculateXIRR() {
    return 0.0;
  }

  @override
  double calculateCAGR() {
    return 0.0;
  }

  @override
  double calculateROI() {
    return 0.0;
  }

  @override
  double calculateIRR() {
    return 0.0;
  }

  @override
  String name;

  @override
  int quantity;

  @override
  double type;

  @override
  String? id;
}
