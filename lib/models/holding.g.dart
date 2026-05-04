// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Holding _$HoldingFromJson(Map<String, dynamic> json) => Holding(
  id: (json['id'] as num?)?.toInt(),
  accountId: (json['accountId'] as num).toInt(),
  assetId: (json['assetId'] as num).toInt(),
  portfolioId: (json['portfolioId'] as num).toInt(),
  totalQuantity: (json['totalQuantity'] as num).toDouble(),
  averagePrice: (json['averagePrice'] as num).toDouble(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$HoldingToJson(Holding instance) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'assetId': instance.assetId,
  'portfolioId': instance.portfolioId,
  'totalQuantity': instance.totalQuantity,
  'averagePrice': instance.averagePrice,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
