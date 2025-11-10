import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scope.g.dart';

@JsonSerializable()
class ScopeModel extends Equatable {
  final int? id;
  final String name;
  final String filters; // JSON string containing filter criteria
  final String? baseCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScopeModel({
    this.id,
    required this.name,
    required this.filters,
    this.baseCurrency,
    required this.createdAt,
    required this.updatedAt,
  });

  ScopeModel copyWith({
    int? id,
    String? name,
    String? filters,
    String? baseCurrency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScopeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      filters: filters ?? this.filters,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ScopeModel.fromJson(Map<String, dynamic> json) =>
      _$ScopeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScopeModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'filters': filters,
      'baseCurrency': baseCurrency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ScopeModel.fromMap(Map<String, dynamic> map) {
    return ScopeModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      filters: map['filters'] ?? '{}',
      baseCurrency: map['baseCurrency'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        filters,
        baseCurrency,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ScopeModel(id: $id, name: $name, baseCurrency: $baseCurrency)';
  }
}