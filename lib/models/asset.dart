import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset.g.dart';

@JsonSerializable()
class Asset extends Equatable {
  final int? id;
  final String symbol;
  final String name;
  final double currentPrice;
  final DateTime lastUpdated;

  const Asset({
    this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.lastUpdated,
  });

  Asset copyWith({
    int? id,
    String? symbol,
    String? name,
    double? currentPrice,
    DateTime? lastUpdated,
  }) {
    return Asset(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);

  Map<String, dynamic> toJson() => _$AssetToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id']?.toInt(),
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      currentPrice: map['currentPrice']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  @override
  List<Object?> get props => [id, symbol, name, currentPrice, lastUpdated];

  @override
  String toString() {
    return 'Asset(id: $id, symbol: $symbol, name: $name, currentPrice: $currentPrice)';
  }
}