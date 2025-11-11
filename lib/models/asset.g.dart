// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Asset _$AssetFromJson(Map<String, dynamic> json) => Asset(
      id: (json['id'] as num?)?.toInt(),
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      assetClass: json['assetClass'] as String,
      providerSymbol: json['providerSymbol'] as String?,
    );

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'currentPrice': instance.currentPrice,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'assetClass': instance.assetClass,
      'providerSymbol': instance.providerSymbol,
    };
