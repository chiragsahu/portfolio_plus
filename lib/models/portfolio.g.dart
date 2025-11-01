// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Portfolio _$PortfolioFromJson(Map<String, dynamic> json) => Portfolio(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      investmentType:
          $enumDecode(_$InvestmentTypeEnumMap, json['investmentType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$PortfolioToJson(Portfolio instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'investmentType': _$InvestmentTypeEnumMap[instance.investmentType]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
    };

const _$InvestmentTypeEnumMap = {
  InvestmentType.stocks: 'stocks',
  InvestmentType.crypto: 'crypto',
  InvestmentType.mutualFunds: 'mutualFunds',
  InvestmentType.commodities: 'commodities',
  InvestmentType.bonds: 'bonds',
  InvestmentType.realEstate: 'realEstate',
  InvestmentType.custom: 'custom',
};
