// Currency enum and helpers for app-wide currency selection and formatting

enum Currency {
  inr,
  usd;

  static Currency fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'INR':
        return Currency.inr;
      case 'USD':
        return Currency.usd;
      default:
        return Currency.inr;
    }
  }
}

extension CurrencyExtension on Currency {
  String get code {
    switch (this) {
      case Currency.inr:
        return 'INR';
      case Currency.usd:
        return 'USD';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.inr:
        return '₹';
      case Currency.usd:
        return '\$';
    }
  }

  String get displayName {
    switch (this) {
      case Currency.inr:
        return 'INR (₹)';
      case Currency.usd:
        return 'USD (\$)';
    }
  }

}