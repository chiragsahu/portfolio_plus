import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portfolio_plus/utils/enums/investment_type.dart';

part 'portfolio.g.dart';

@JsonSerializable()
class Portfolio extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final InvestmentType investmentType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  const Portfolio({
    this.id,
    required this.name,
    this.description,
    required this.investmentType,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  Portfolio copyWith({
    int? id,
    String? name,
    String? description,
    InvestmentType? investmentType,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Portfolio(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      investmentType: investmentType ?? this.investmentType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  factory Portfolio.fromJson(Map<String, dynamic> json) =>
      _$PortfolioFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'investmentType': investmentType.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags.join(','),
    };
  }

  factory Portfolio.fromMap(Map<String, dynamic> map) {
    return Portfolio(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      investmentType: InvestmentType.values.firstWhere(
        (e) => e.name == map['investmentType'],
        orElse: () => InvestmentType.custom,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? map['tags'].split(',')
          : [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        investmentType,
        createdAt,
        updatedAt,
        tags,
      ];

  @override
  String toString() {
    return 'Portfolio(id: $id, name: $name, investmentType: $investmentType)';
  }
}