import 'dart:core';
import 'package:portfolio_plus/utils/enums/transaction.dart';

class AssetPosition {
  AssetPosition({
    required this.positionType,
    required this.assetValue,
    required this.buyUnits,
    required this.sellUnits,
    this.id,
  });

  final PositionType positionType;
  final double assetValue;
  final double buyUnits;
  final double sellUnits;
  final String? id;
}

abstract class Investible<T> {
  T get type;
  String get name;
  String? get id;
  double get quantity;
  int get assetValue;
  String get notes;
  List<AssetPosition> get assetPositions;

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
    required this.assetValue,
    this.id,
    this.notes = '',
    this.assetPositions = const [],
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
  late double quantity = assetPositions.fold(
      0, (previousValue, element) => previousValue + element.buyUnits);

  @override
  double type;

  @override
  String? id;

  @override
  int assetValue;

  @override
  String notes;

  @override
  List<AssetPosition> assetPositions;

  List<AssetPosition> get openPositions {
    return assetPositions
        .where((element) => element.buyUnits > element.sellUnits)
        .toList();
  }

  List<AssetPosition> get closedPositions {
    return assetPositions
        .where((element) => element.buyUnits == element.sellUnits)
        .toList();
  }
}
