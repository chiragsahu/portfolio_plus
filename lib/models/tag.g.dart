// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      type: $enumDecode(_$TagTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$TagTypeEnumMap[instance.type]!,
    };

const _$TagTypeEnumMap = {
  TagType.platform: 'platform',
  TagType.sector: 'sector',
  TagType.custom: 'custom',
};
