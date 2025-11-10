// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num?)?.toInt(),
      portfolioId: (json['portfolioId'] as num).toInt(),
      accountId: (json['accountId'] as num?)?.toInt(),
      assetId: (json['assetId'] as num?)?.toInt(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble(),
      feeCurrency: $enumDecodeNullable(_$CurrencyEnumMap, json['feeCurrency']),
      quoteCurrency:
          $enumDecodeNullable(_$CurrencyEnumMap, json['quoteCurrency']),
      tradeId: json['tradeId'] as String?,
      realizedPnLPerTx: (json['realizedPnLPerTx'] as num?)?.toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'portfolioId': instance.portfolioId,
      'accountId': instance.accountId,
      'assetId': instance.assetId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'quantity': instance.quantity,
      'price': instance.price,
      'amount': instance.amount,
      'fee': instance.fee,
      'feeCurrency': _$CurrencyEnumMap[instance.feeCurrency],
      'quoteCurrency': _$CurrencyEnumMap[instance.quoteCurrency],
      'tradeId': instance.tradeId,
      'realizedPnLPerTx': instance.realizedPnLPerTx,
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

const _$CurrencyEnumMap = {
  Currency.inr: 'inr',
  Currency.usd: 'usd',
};
