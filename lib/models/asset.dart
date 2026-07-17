import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset.g.dart';

class StockMetadata extends Equatable {
  final String? isin;
  final double? faceValue;
  final String? series;

  const StockMetadata({
    this.isin,
    this.faceValue,
    this.series,
  });

  StockMetadata copyWith({
    String? isin,
    double? faceValue,
    String? series,
  }) {
    return StockMetadata(
      isin: isin ?? this.isin,
      faceValue: faceValue ?? this.faceValue,
      series: series ?? this.series,
    );
  }

  @override
  List<Object?> get props => [isin, faceValue, series];

  @override
  String toString() {
    return 'StockMetadata(isin: $isin, faceValue: $faceValue, series: $series)';
  }
}

class CryptoMetadata extends Equatable {
  final int? cmcId;
  final String? slug;
  final String? blockchain;
  final String? contractAddress;

  const CryptoMetadata({
    this.cmcId,
    this.slug,
    this.blockchain,
    this.contractAddress,
  });

  CryptoMetadata copyWith({
    int? cmcId,
    String? slug,
    String? blockchain,
    String? contractAddress,
  }) {
    return CryptoMetadata(
      cmcId: cmcId ?? this.cmcId,
      slug: slug ?? this.slug,
      blockchain: blockchain ?? this.blockchain,
      contractAddress: contractAddress ?? this.contractAddress,
    );
  }

  @override
  List<Object?> get props => [cmcId, slug, blockchain, contractAddress];

  @override
  String toString() {
    return 'CryptoMetadata(cmcId: $cmcId, slug: $slug, blockchain: $blockchain, contractAddress: $contractAddress)';
  }
}

@JsonSerializable()
class Asset extends Equatable {
  final int? id;
  final String symbol;
  final String name;
  final double currentPrice;
  final DateTime lastUpdated;
  final String assetClass;
  final String? providerSymbol;
  
  // Nested Params
  final StockMetadata? stock;
  final CryptoMetadata? crypto;

  const Asset({
    this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.lastUpdated,
    required this.assetClass,
    this.providerSymbol,
    this.stock,
    this.crypto,
  });

  Asset copyWith({
    int? id,
    String? symbol,
    String? name,
    double? currentPrice,
    DateTime? lastUpdated,
    String? assetClass,
    String? providerSymbol,
    StockMetadata? stock,
    CryptoMetadata? crypto,
  }) {
    return Asset(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      assetClass: assetClass ?? this.assetClass,
      providerSymbol: providerSymbol ?? this.providerSymbol,
      stock: stock ?? this.stock,
      crypto: crypto ?? this.crypto,
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
      // Flatten Stock columns
      'isin': stock?.isin,
      'faceValue': stock?.faceValue,
      'series': stock?.series,
      // Flatten Crypto columns
      'cmcId': crypto?.cmcId,
      'slug': crypto?.slug,
      'blockchain': crypto?.blockchain,
      'contractAddress': crypto?.contractAddress,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    // Reconstruct StockMetadata if any stock field is present
    final hasStockInfo = map['isin'] != null || map['faceValue'] != null || map['series'] != null;
    final stock = hasStockInfo
        ? StockMetadata(
            isin: map['isin'],
            faceValue: map['faceValue']?.toDouble(),
            series: map['series'],
          )
        : null;

    // Reconstruct CryptoMetadata if any crypto field is present
    final hasCryptoInfo = map['cmcId'] != null || map['slug'] != null || map['blockchain'] != null || map['contractAddress'] != null;
    final crypto = hasCryptoInfo
        ? CryptoMetadata(
            cmcId: map['cmcId']?.toInt(),
            slug: map['slug'],
            blockchain: map['blockchain'],
            contractAddress: map['contractAddress'],
          )
        : null;

    return Asset(
      id: map['id']?.toInt(),
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      currentPrice: map['currentPrice']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(map['lastUpdated']),
      assetClass: map['assetClass'] ?? '',
      providerSymbol: map['providerSymbol'],
      stock: stock,
      crypto: crypto,
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
        stock,
        crypto,
      ];

  @override
  String toString() {
    return 'Asset(id: $id, symbol: $symbol, name: $name, currentPrice: $currentPrice, assetClass: $assetClass, providerSymbol: $providerSymbol, stock: $stock, crypto: $crypto)';
  }
}