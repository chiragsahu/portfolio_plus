enum InvestmentType {
  stocks,
  crypto,
  mutualFunds,
  commodities,
  bonds,
  realEstate,
  custom,
}

extension InvestmentTypeExtension on InvestmentType {
  String get displayName {
    switch (this) {
      case InvestmentType.stocks:
        return 'Stocks';
      case InvestmentType.crypto:
        return 'Cryptocurrency';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds';
      case InvestmentType.commodities:
        return 'Commodities';
      case InvestmentType.bonds:
        return 'Bonds';
      case InvestmentType.realEstate:
        return 'Real Estate';
      case InvestmentType.custom:
        return 'Custom';
    }
  }

  String get iconName {
    switch (this) {
      case InvestmentType.stocks:
        return 'trending_up';
      case InvestmentType.crypto:
        return 'currency_bitcoin';
      case InvestmentType.mutualFunds:
        return 'account_balance';
      case InvestmentType.commodities:
        return 'bar_chart';
      case InvestmentType.bonds:
        return 'description';
      case InvestmentType.realEstate:
        return 'home';
      case InvestmentType.custom:
        return 'folder';
    }
  }
}