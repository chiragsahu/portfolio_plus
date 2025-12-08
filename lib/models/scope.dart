import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scope.g.dart';

/// Represents a Basket (user-facing saved view) with filters for providers, accounts, assets, etc.
/// Internally called ScopeModel to minimize churn.
@JsonSerializable()
class ScopeModel extends Equatable {
  final int? id;
  final String name;
  final String filters; // JSON string containing Basket filter criteria
  final String? baseCurrency; // Optional override for base currency display
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

  /// Parses the filters JSON string into a Map for easy access.
  Map<String, dynamic> get parsedFilters {
    try {
      return jsonDecode(filters);
    } catch (e) {
      return {};
    }
  }

  /// Builds a filters JSON string from a Map.
  static String buildFilters({
    List<int>? providerIds,
    List<int>? accountIds,
    bool? includeChildAccounts,
    List<int>? assetIds,
    List<String>? assetClasses,
    List<String>? tags,
    String? dateFrom, // ISO 8601 string, inclusive
    String? dateTo, // ISO 8601 string, inclusive
    String? costBasisMethod, // e.g., 'fifo', 'lifo', 'average'
  }) {
    return jsonEncode({
      'providerIds': providerIds ?? [],
      'accountIds': accountIds ?? [],
      'includeChildAccounts': includeChildAccounts ?? false,
      'assetIds': assetIds ?? [],
      'assetClasses': assetClasses ?? [],
      'tags': tags ?? [],
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'costBasisMethod': costBasisMethod ?? 'fifo',
    });
  }

  /// Convenience getters for common filter fields.
  List<int> get providerIds => parsedFilters['providerIds']?.cast<int>() ?? [];
  List<int> get accountIds => parsedFilters['accountIds']?.cast<int>() ?? [];
  bool get includeChildAccounts => parsedFilters['includeChildAccounts'] ?? false;
  List<int> get assetIds => parsedFilters['assetIds']?.cast<int>() ?? [];
  List<String> get assetClasses => parsedFilters['assetClasses']?.cast<String>() ?? [];
  List<String> get tags => parsedFilters['tags']?.cast<String>() ?? [];
  String? get dateFrom => parsedFilters['dateFrom'];
  String? get dateTo => parsedFilters['dateTo'];
  String get costBasisMethod => parsedFilters['costBasisMethod'] ?? 'fifo';

  @override
  String toString() {
    return 'ScopeModel(id: $id, name: $name, baseCurrency: $baseCurrency, filters: $filters)';
  }
}