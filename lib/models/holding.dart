import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holding.g.dart';

@JsonSerializable()
class Holding extends Equatable {
  final int? id;
  final int accountId;
  final int assetId;
  final int portfolioId;
  final double totalQuantity;
  final double averagePrice;
  final DateTime lastUpdated;

  const Holding({
    this.id,
    required this.accountId,
    required this.assetId,
    required this.portfolioId,
    required this.totalQuantity,
    required this.averagePrice,
    required this.lastUpdated,
  });

  Holding copyWith({
    int? id,
    int? accountId,
    int? assetId,
    int? portfolioId,
    double? totalQuantity,
    double? averagePrice,
    DateTime? lastUpdated,
  }) {
    return Holding(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      assetId: assetId ?? this.assetId,
      portfolioId: portfolioId ?? this.portfolioId,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      averagePrice: averagePrice ?? this.averagePrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory Holding.fromJson(Map<String, dynamic> json) => _$HoldingFromJson(json);

  Map<String, dynamic> toJson() => _$HoldingToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'assetId': assetId,
      'portfolioId': portfolioId,
      'totalQuantity': totalQuantity,
      'averagePrice': averagePrice,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Holding.fromMap(Map<String, dynamic> map) {
    return Holding(
      id: map['id']?.toInt(),
      accountId: map['accountId']?.toInt() ?? 0,
      assetId: map['assetId']?.toInt() ?? 0,
      portfolioId: map['portfolioId']?.toInt() ?? 0,
      totalQuantity: map['totalQuantity']?.toDouble() ?? 0.0,
      averagePrice: map['averagePrice']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        accountId,
        assetId,
        portfolioId,
        totalQuantity,
        averagePrice,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'Holding(id: $id, accountId: $accountId, assetId: $assetId, portfolioId: $portfolioId, totalQuantity: $totalQuantity, averagePrice: $averagePrice)';
  }
}
