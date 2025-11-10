import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';

part 'account.g.dart';

@JsonSerializable()
class AccountModel extends Equatable {
  final int? id;
  final int providerId;
  final String name;
  final int? parentAccountId;
  final Currency? baseCurrency;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountModel({
    this.id,
    required this.providerId,
    required this.name,
    this.parentAccountId,
    this.baseCurrency,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  AccountModel copyWith({
    int? id,
    int? providerId,
    String? name,
    int? parentAccountId,
    Currency? baseCurrency,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) => _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'name': name,
      'parentAccountId': parentAccountId,
      'baseCurrency': baseCurrency?.name,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    final rawMeta = map['metadata'];
    Map<String, dynamic>? meta;
    if (rawMeta is String && rawMeta.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMeta);
        if (decoded is Map<String, dynamic>) {
          meta = decoded;
        }
      } catch (_) {
        meta = null;
      }
    } else if (rawMeta is Map<String, dynamic>) {
      meta = rawMeta;
    }

    final String? currencyCode = map['baseCurrency'] as String?;
    final Currency? currency =
        currencyCode != null && currencyCode.isNotEmpty ? Currency.fromCode(currencyCode) : null;

    return AccountModel(
      id: map['id']?.toInt(),
      providerId: map['providerId']?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      parentAccountId: map['parentAccountId']?.toInt(),
      baseCurrency: currency,
      metadata: meta,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        providerId,
        name,
        parentAccountId,
        baseCurrency,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'AccountModel(id: $id, providerId: $providerId, name: $name, parentAccountId: $parentAccountId, baseCurrency: ${baseCurrency?.name})';
}