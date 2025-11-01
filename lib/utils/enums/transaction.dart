enum TransactionType {
  buy,
  sell,
  dividend,
  deposit,
  withdrawal,
  split,
  bonus,
}

enum PositionType {
  open,
  close,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
      case TransactionType.dividend:
        return 'Dividend';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.split:
        return 'Split';
      case TransactionType.bonus:
        return 'Bonus';
    }
  }

  bool get affectsQuantity {
    switch (this) {
      case TransactionType.buy:
      case TransactionType.sell:
      case TransactionType.split:
      case TransactionType.bonus:
        return true;
      case TransactionType.dividend:
      case TransactionType.deposit:
      case TransactionType.withdrawal:
        return false;
    }
  }

  bool get isPositive {
    switch (this) {
      case TransactionType.buy:
      case TransactionType.dividend:
      case TransactionType.deposit:
      case TransactionType.split:
      case TransactionType.bonus:
        return true;
      case TransactionType.sell:
      case TransactionType.withdrawal:
        return false;
    }
  }
}