import 'package:intl/intl.dart';
import 'package:portfolio_plus/services/settings_repository.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';

class CurrencyConversionService {
  final SettingsRepository _repo;

  CurrencyConversionService({SettingsRepository? repository})
      : _repo = repository ?? SettingsRepository();

  Future<double?> _getUsdInrRate() async {
    // Try fx_rates table first
    final latest = await _repo.getLatestFxRate(fromCurrency: 'USD', toCurrency: 'INR');
    if (latest != null) return latest;
    // Fallback to settings key
    final s = await _repo.getSetting('usdInrRate');
    final r = s != null ? double.tryParse(s) : null;
    return r;
  }

  Future<double> convert(double amount, Currency from, Currency to) async {
    if (from == to) return amount;
    // Only INR and USD supported for now
    final rate = await _getUsdInrRate();
    if (rate == null || rate <= 0) {
      // No rate available; return input unchanged
      return amount;
    }
    if (from == Currency.usd && to == Currency.inr) {
      return amount * rate;
    }
    if (from == Currency.inr && to == Currency.usd) {
      return amount / rate;
    }
    // Unknown pair (future currencies) -> no-op
    return amount;
  }

  Future<double> toBase(double amount, Currency amountCurrency) async {
    final base = await _repo.getBaseCurrency();
    return convert(amount, amountCurrency, base);
  }

  String format(Currency currency, num amount, {int decimals = 2}) {
    final symbol = currency.symbol;
    final locale = currency == Currency.inr ? 'en_IN' : 'en_US';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  Future<String> formatInBase(double amount, Currency amountCurrency, {int decimals = 2}) async {
    final base = await _repo.getBaseCurrency();
    final converted = await convert(amount, amountCurrency, base);
    return format(base, converted, decimals: decimals);
  }
}