extension NumberExtension on double {
  String get getAmount => toIndianCurrencyFormat();

  String toIndianCurrencyFormat() {
    // Handle negative numbers
    bool isNegative = this < 0;
    double absoluteValue = isNegative ? -this : this;
    
    // Convert to string and split into integer and decimal parts
    String numberString = absoluteValue.toStringAsFixed(2);
    List<String> parts = numberString.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';
    
    // Format the integer part in Indian format
    String formattedInteger = _formatIndianNumber(integerPart);
    
    // Combine with negative sign if needed
    String result = isNegative ? '-₹$formattedInteger.$decimalPart' : '₹$formattedInteger.$decimalPart';
    
    return result;
  }
  
  String _formatIndianNumber(String number) {
    if (number.length <= 3) {
      return number;
    }
    
    // For numbers with more than 3 digits
    String lastThreeDigits = number.substring(number.length - 3);
    String remainingDigits = number.substring(0, number.length - 3);
    
    if (remainingDigits.isNotEmpty) {
      // Format remaining digits in groups of 2 from right to left
      List<String> groups = [];
      int i = remainingDigits.length;
      
      while (i > 0) {
        int start = (i - 2) >= 0 ? i - 2 : 0;
        groups.insert(0, remainingDigits.substring(start, i));
        i = start;
      }
      
      return '${groups.join(',')},$lastThreeDigits';
    }
    
    return lastThreeDigits;
  }
}

extension IntNumberExtension on int {
  String get getAmount => toDouble().getAmount;
}