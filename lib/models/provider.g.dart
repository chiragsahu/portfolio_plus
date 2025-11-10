// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderModel _$ProviderModelFromJson(Map<String, dynamic> json) =>
    ProviderModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      type: $enumDecode(_$ProviderKindEnumMap, json['type']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProviderModelToJson(ProviderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ProviderKindEnumMap[instance.type]!,
      'metadata': instance.metadata,
    };

const _$ProviderKindEnumMap = {
  ProviderKind.broker: 'broker',
  ProviderKind.exchange: 'exchange',
  ProviderKind.bank: 'bank',
  ProviderKind.wallet: 'wallet',
  ProviderKind.platform: 'platform',
  ProviderKind.other: 'other',
};
