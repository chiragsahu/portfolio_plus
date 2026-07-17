// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Asset _$AssetFromJson(Map<String, dynamic> json) {
  // Reconstruct stock metadata from JSON
  final hasStockInfo = json['isin'] != null || json['faceValue'] != null || json['series'] != null;
  final stock = hasStockInfo
      ? StockMetadata(
          isin: json['isin'] as String?,
          faceValue: (json['faceValue'] as num?)?.toDouble(),
          series: json['series'] as String?,
        )
      : null;

  // Reconstruct crypto metadata from JSON
  final hasCryptoInfo = json['cmcId'] != null || json['slug'] != null || json['blockchain'] != null || json['contractAddress'] != null;
  final crypto = hasCryptoInfo
      ? CryptoMetadata(
          cmcId: (json['cmcId'] as num?)?.toInt(),
          slug: json['slug'] as String?,
          blockchain: json['blockchain'] as String?,
          contractAddress: json['contractAddress'] as String?,
        )
      : null;

  return Asset(
    id: (json['id'] as num?)?.toInt(),
    symbol: json['symbol'] as String,
    name: json['name'] as String,
    currentPrice: (json['currentPrice'] as num).toDouble(),
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    assetClass: json['assetClass'] as String,
    providerSymbol: json['providerSymbol'] as String?,
    stock: stock,
    crypto: crypto,
  );
}

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'currentPrice': instance.currentPrice,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'assetClass': instance.assetClass,
      'providerSymbol': instance.providerSymbol,
      'isin': instance.stock?.isin,
      'faceValue': instance.stock?.faceValue,
      'series': instance.stock?.series,
      'cmcId': instance.crypto?.cmcId,
      'slug': instance.crypto?.slug,
      'blockchain': instance.crypto?.blockchain,
      'contractAddress': instance.crypto?.contractAddress,
    };
