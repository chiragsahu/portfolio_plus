class CmcUsdQuote {
  final double? price;
  final double? volume24h;
  final double? marketCap;
  final String? lastUpdated;
  final String? timestamp;

  const CmcUsdQuote({
    this.price,
    this.volume24h,
    this.marketCap,
    this.lastUpdated,
    this.timestamp,
  });

  factory CmcUsdQuote.fromJson(Map<String, dynamic> json) {
    return CmcUsdQuote(
      price: json['price']?.toDouble(),
      volume24h: (json['volume_24h'] ?? json['volume_24hr'])?.toDouble(),
      marketCap: json['market_cap']?.toDouble(),
      lastUpdated: json['last_updated'],
      timestamp: json['timestamp'],
    );
  }
}

class CmcHistoricalQuote {
  final String? timestamp;
  final CmcUsdQuote? usdQuote;

  const CmcHistoricalQuote({
    this.timestamp,
    this.usdQuote,
  });

  factory CmcHistoricalQuote.fromJson(Map<String, dynamic> json) {
    final quoteMap = json['quote'] as Map<String, dynamic>?;
    final usdJson = quoteMap != null ? quoteMap['USD'] as Map<String, dynamic>? : null;
    return CmcHistoricalQuote(
      timestamp: json['timestamp'],
      usdQuote: usdJson != null ? CmcUsdQuote.fromJson(usdJson) : null,
    );
  }
}

class CmcCoinData {
  final int id;
  final String name;
  final String symbol;
  final int? isActive;
  final int? isFiat;
  final List<CmcHistoricalQuote> quotes;

  const CmcCoinData({
    required this.id,
    required this.name,
    required this.symbol,
    this.isActive,
    this.isFiat,
    required this.quotes,
  });

  factory CmcCoinData.fromJson(Map<String, dynamic> json) {
    final quotesJson = json['quotes'] as List? ?? [];
    return CmcCoinData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      isActive: json['is_active'],
      isFiat: json['is_fiat'],
      quotes: quotesJson
          .map((q) => CmcHistoricalQuote.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CmcHistoricalResponse {
  final Map<String, CmcCoinData> data;

  const CmcHistoricalResponse({
    required this.data,
  });

  factory CmcHistoricalResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    final mappedData = dataMap.map(
      (key, value) => MapEntry(key, CmcCoinData.fromJson(value as Map<String, dynamic>)),
    );
    return CmcHistoricalResponse(data: mappedData);
  }
}
