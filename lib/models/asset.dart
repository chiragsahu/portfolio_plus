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
  final String assetClass;
  final String? providerSymbol;
  final String? isin;
  final double? faceValue;
  final String? series;

  const Asset({
    this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.lastUpdated,
    required this.assetClass,
    this.providerSymbol,
    this.isin,
    this.faceValue,
    this.series,
  });

  Asset copyWith({
    int? id,
    String? symbol,
    String? name,
    double? currentPrice,
    DateTime? lastUpdated,
    String? assetClass,
    String? providerSymbol,
    String? isin,
    double? faceValue,
    String? series,
  }) {
    return Asset(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      assetClass: assetClass ?? this.assetClass,
      providerSymbol: providerSymbol ?? this.providerSymbol,
      isin: isin ?? this.isin,
      faceValue: faceValue ?? this.faceValue,
      series: series ?? this.series,
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
      'assetClass': assetClass,
      'providerSymbol': providerSymbol,
      'isin': isin,
      'faceValue': faceValue,
      'series': series,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id']?.toInt(),
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      currentPrice: map['currentPrice']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(map['lastUpdated']),
      assetClass: map['assetClass'] ?? '',
      providerSymbol: map['providerSymbol'],
      isin: map['isin'],
      faceValue: map['faceValue']?.toDouble(),
      series: map['series'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        currentPrice,
        lastUpdated,
        assetClass,
        providerSymbol,
        isin,
        faceValue,
        series,
      ];

  @override
  String toString() {
    return 'Asset(id: $id, symbol: $symbol, name: $name, currentPrice: $currentPrice, assetClass: $assetClass, providerSymbol: $providerSymbol, isin: $isin, faceValue: $faceValue, series: $series)';
  }
}