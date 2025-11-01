import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

enum TagType {
  platform,
  sector,
  custom,
}

extension TagTypeExtension on TagType {
  String get displayName {
    switch (this) {
      case TagType.platform:
        return 'Platform';
      case TagType.sector:
        return 'Sector';
      case TagType.custom:
        return 'Custom';
    }
  }
}

@JsonSerializable()
class Tag extends Equatable {
  final int? id;
  final String name;
  final TagType type;

  const Tag({
    this.id,
    required this.name,
    required this.type,
  });

  Tag copyWith({
    int? id,
    String? name,
    TagType? type,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      type: TagType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TagType.custom,
      ),
    );
  }

  @override
  List<Object?> get props => [id, name, type];

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, type: $type)';
  }
}