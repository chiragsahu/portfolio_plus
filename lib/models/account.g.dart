// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
  id: (json['id'] as num?)?.toInt(),
  providerId: (json['providerId'] as num).toInt(),
  name: json['name'] as String,
  parentAccountId: (json['parentAccountId'] as num?)?.toInt(),
  baseCurrency: $enumDecodeNullable(_$CurrencyEnumMap, json['baseCurrency']),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'name': instance.name,
      'parentAccountId': instance.parentAccountId,
      'baseCurrency': _$CurrencyEnumMap[instance.baseCurrency],
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CurrencyEnumMap = {Currency.inr: 'inr', Currency.usd: 'usd'};
