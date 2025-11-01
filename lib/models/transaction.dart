import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portfolio_plus/utils/enums/transaction.dart';

part 'transaction.g.dart';

@JsonSerializable()
class TransactionModel extends Equatable {
  final int? id;
  final int portfolioId;
  final int? assetId;
  final TransactionType type;
  final double quantity;
  final double price;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const TransactionModel({
    this.id,
    required this.portfolioId,
    this.assetId,
    required this.type,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  TransactionModel copyWith({
    int? id,
    int? portfolioId,
    int? assetId,
    TransactionType? type,
    double? quantity,
    double? price,
    double? amount,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      assetId: assetId ?? this.assetId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'portfolioId': portfolioId,
      'assetId': assetId,
      'type': type.name,
      'quantity': quantity,
      'price': price,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toInt(),
      portfolioId: map['portfolioId']?.toInt() ?? 0,
      assetId: map['assetId']?.toInt(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.buy,
      ),
      quantity: map['quantity']?.toDouble() ?? 0.0,
      price: map['price']?.toDouble() ?? 0.0,
      amount: map['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        portfolioId,
        assetId,
        type,
        quantity,
        price,
        amount,
        date,
        notes,
        createdAt,
      ];

  @override
  String toString() {
    return 'TransactionModel(id: $id, portfolioId: $portfolioId, type: $type, amount: $amount)';
  }
}