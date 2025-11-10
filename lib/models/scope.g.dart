// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScopeModel _$ScopeModelFromJson(Map<String, dynamic> json) => ScopeModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      filters: json['filters'] as String,
      baseCurrency: json['baseCurrency'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ScopeModelToJson(ScopeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'filters': instance.filters,
      'baseCurrency': instance.baseCurrency,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
