import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:portfolio_plus/services/asset_repository.dart';
import 'package:portfolio_plus/models/asset.dart';
import 'package:portfolio_plus/models/coinmarketcap_quote.dart';

class CoinMarketCapService {
  final AssetRepository _assetRepository;
  static const String _baseUrl = 'https://pro-api.coinmarketcap.com/v3/cryptocurrency/quotes/historical';

  CoinMarketCapService({AssetRepository? assetRepository})
      : _assetRepository = assetRepository ?? AssetRepository();

  /// Retrieve the CoinMarketCap API key from the environment variables
  String get _apiKey {
    final envKey = Platform.environment['cmc_api_key'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    return const String.fromEnvironment('cmc_api_key');
  }

  /// Request headers containing authorization
  Map<String, String> get _headers {
    final key = _apiKey;
    return {
      'Accepts': 'application/json',
      if (key.isNotEmpty) 'X-CMC_PRO_API_KEY': key,
    };
  }

  /// Process response model to extract and update crypto prices in the database
  Future<void> _processResponseModel(CmcHistoricalResponse responseModel) async {
    final assets = await _assetRepository.getAllAssets();
    final cryptoAssets = assets.where((a) => a.assetClass.toLowerCase() == 'crypto' || a.crypto != null).toList();

    for (var entry in responseModel.data.entries) {
      final coinData = entry.value;
      final id = coinData.id;
      final symbol = coinData.symbol;

      if (coinData.quotes.isEmpty) continue;

      // Extract the latest historical quote from the list
      final latestQuote = coinData.quotes.last;
      final price = latestQuote.usdQuote?.price;
      if (price == null) continue;

      for (var asset in cryptoAssets) {
        bool isMatch = false;
        if (asset.crypto?.cmcId == id) {
          isMatch = true;
        } else if ((asset.crypto?.cmcId == null || asset.crypto?.cmcId == 0) &&
            asset.symbol.toUpperCase() == symbol.toUpperCase()) {
          isMatch = true;
          // Update the asset metadata with the fetched cmcId
          final updatedCrypto = (asset.crypto ?? const CryptoMetadata()).copyWith(cmcId: id);
          final updatedAsset = asset.copyWith(crypto: updatedCrypto);
          await _assetRepository.updateAsset(updatedAsset);
        }

        if (isMatch && asset.id != null) {
          await _assetRepository.updateAssetPrice(asset.id!, price);
          print('Updated price of ${asset.symbol} ($symbol) to USD $price via historical quotes');
        }
      }
    }
  }

  /// Fetch listings/quotes by querying historical quotes for all existing crypto assets,
  /// or falling back to default top cryptos if none exist yet.
  Future<void> fetchListings() async {
    final assets = await _assetRepository.getAllAssets();
    var ids = assets
        .where((a) => a.crypto?.cmcId != null && a.crypto!.cmcId! > 0)
        .map((a) => a.crypto!.cmcId!)
        .toSet()
        .toList();

    if (ids.isEmpty) {
      // Default top CMC IDs if database is empty: BTC (1), ETH (1027), USDT (825), USDC (3408), XAUt (5176)
      ids = [1, 1027, 825, 3408, 5176];
    }
    await fetchQuotes(ids);
  }

  /// Fetch historical quotes by specific CoinMarketCap IDs and update the database
  Future<void> fetchQuotes(List<int> cmcIds) async {
    if (cmcIds.isEmpty) return;
    try {
      final idsParam = cmcIds.join(',');
      final url = '$_baseUrl?id=$idsParam';
      print('Fetching historical quotes: $url');
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final responseModel = CmcHistoricalResponse.fromJson(decoded);
        await _processResponseModel(responseModel);
      } else {
        print('Error fetching historical quotes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception fetching historical quotes: $e');
    }
  }

  /// Helper to fetch quotes for all registered crypto assets in the database
  Future<void> refreshAllCryptoPrices() async {
    final assets = await _assetRepository.getAllAssets();
    final ids = assets
        .where((a) => a.crypto?.cmcId != null && a.crypto!.cmcId! > 0)
        .map((a) => a.crypto!.cmcId!)
        .toSet()
        .toList();

    if (ids.isNotEmpty) {
      await fetchQuotes(ids);
    } else {
      await fetchListings();
    }
  }
}
