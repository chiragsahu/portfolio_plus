// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num?)?.toInt(),
      portfolioId: (json['portfolioId'] as num).toInt(),
      assetId: (json['assetId'] as num?)?.toInt(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'portfolioId': instance.portfolioId,
      'assetId': instance.assetId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'quantity': instance.quantity,
      'price': instance.price,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.buy: 'buy',
  TransactionType.sell: 'sell',
  TransactionType.dividend: 'dividend',
  TransactionType.deposit: 'deposit',
  TransactionType.withdrawal: 'withdrawal',
  TransactionType.split: 'split',
  TransactionType.bonus: 'bonus',
};
