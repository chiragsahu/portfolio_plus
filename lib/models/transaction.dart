import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';
import 'package:portfolio_plus/utils/enums/transaction.dart';

part 'transaction.g.dart';

@JsonSerializable()
class TransactionModel extends Equatable {
  final int? id;
  final int portfolioId;
  final int? accountId;
  final int? assetId;
  final TransactionType type;
  final double quantity;
  final double price;
  final double amount;
  final double? fee;
  final Currency? feeCurrency;
  final Currency? quoteCurrency;
  final String? tradeId;
  final double? realizedPnLPerTx;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const TransactionModel({
    this.id,
    required this.portfolioId,
    this.accountId,
    this.assetId,
    required this.type,
    required this.quantity,
    required this.price,
    required this.amount,
    this.fee,
    this.feeCurrency,
    this.quoteCurrency,
    this.tradeId,
    this.realizedPnLPerTx,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  TransactionModel copyWith({
    int? id,
    int? portfolioId,
    int? accountId,
    int? assetId,
    TransactionType? type,
    double? quantity,
    double? price,
    double? amount,
    double? fee,
    Currency? feeCurrency,
    Currency? quoteCurrency,
    String? tradeId,
    double? realizedPnLPerTx,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      accountId: accountId ?? this.accountId,
      assetId: assetId ?? this.assetId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      feeCurrency: feeCurrency ?? this.feeCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      tradeId: tradeId ?? this.tradeId,
      realizedPnLPerTx: realizedPnLPerTx ?? this.realizedPnLPerTx,
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
      'accountId': accountId,
      'assetId': assetId,
      'type': type.name,
      'quantity': quantity,
      'price': price,
      'amount': amount,
      'fee': fee,
      'feeCurrency': feeCurrency?.name,
      'quoteCurrency': quoteCurrency?.name,
      'tradeId': tradeId,
      'realizedPnLPerTx': realizedPnLPerTx,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final String? feeCurrencyCode = map['feeCurrency'] as String?;
    final Currency? feeCurrency =
        feeCurrencyCode != null && feeCurrencyCode.isNotEmpty ? Currency.fromCode(feeCurrencyCode) : null;

    final String? quoteCurrencyCode = map['quoteCurrency'] as String?;
    final Currency? quoteCurrency =
        quoteCurrencyCode != null && quoteCurrencyCode.isNotEmpty ? Currency.fromCode(quoteCurrencyCode) : null;

    return TransactionModel(
      id: map['id']?.toInt(),
      portfolioId: map['portfolioId']?.toInt() ?? 0,
      accountId: map['accountId']?.toInt(),
      assetId: map['assetId']?.toInt(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.buy,
      ),
      quantity: map['quantity']?.toDouble() ?? 0.0,
      price: map['price']?.toDouble() ?? 0.0,
      amount: map['amount']?.toDouble() ?? 0.0,
      fee: map['fee']?.toDouble(),
      feeCurrency: feeCurrency,
      quoteCurrency: quoteCurrency,
      tradeId: map['tradeId'],
      realizedPnLPerTx: map['realizedPnLPerTx']?.toDouble(),
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        portfolioId,
        accountId,
        assetId,
        type,
        quantity,
        price,
        amount,
        fee,
        feeCurrency,
        quoteCurrency,
        tradeId,
        realizedPnLPerTx,
        date,
        notes,
        createdAt,
      ];

  @override
  String toString() {
    return 'TransactionModel(id: $id, portfolioId: $portfolioId, accountId: $accountId, type: $type, amount: $amount, fee: $fee)';
  }
}