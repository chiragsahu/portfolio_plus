import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'provider.g.dart';

enum ProviderKind { broker, exchange, bank, wallet, platform, other }

extension ProviderKindX on ProviderKind {
  String get displayName {
    switch (this) {
      case ProviderKind.broker:
        return 'Broker';
      case ProviderKind.exchange:
        return 'Exchange';
      case ProviderKind.bank:
        return 'Bank';
      case ProviderKind.wallet:
        return 'Wallet';
      case ProviderKind.platform:
        return 'Platform';
      case ProviderKind.other:
        return 'Other';
    }
  }
}

@JsonSerializable()
class ProviderModel extends Equatable {
  final int? id;
  final String name;
  final ProviderKind type;
  final Map<String, dynamic>? metadata;

  const ProviderModel({
    this.id,
    required this.name,
    required this.type,
    this.metadata,
  });

  ProviderModel copyWith({
    int? id,
    String? name,
    ProviderKind? type,
    Map<String, dynamic>? metadata,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
    }

  factory ProviderModel.fromJson(Map<String, dynamic> json) => _$ProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory ProviderModel.fromMap(Map<String, dynamic> map) {
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

    return ProviderModel(
      id: map['id']?.toInt(),
      name: map['name'] as String? ?? '',
      type: ProviderKind.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ProviderKind.broker,
      ),
      metadata: meta,
    );
  }

  @override
  List<Object?> get props => [id, name, type, metadata];

  @override
  String toString() => 'ProviderModel(id: $id, name: $name, type: ${type.name})';
}