import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/services/settings_repository.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';

class SettingsState {
  final Currency baseCurrency;
  final double? usdInrRate;

  const SettingsState({
    required this.baseCurrency,
    this.usdInrRate,
  });

  SettingsState copyWith({
    Currency? baseCurrency,
    double? usdInrRate,
  }) {
    return SettingsState(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      usdInrRate: usdInrRate ?? this.usdInrRate,
    );
  }
}

// Repository provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// Settings provider with AsyncValue to handle loading states
final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<AsyncValue<SettingsState>> {
  final SettingsRepository _repo;

  static const String _fxKeyUsdInr = 'usdInrRate';

  SettingsNotifier(this._repo) : super(const AsyncLoading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final base = await _repo.getBaseCurrency();
      final fxStr = await _repo.getSetting(_fxKeyUsdInr);
      final fx = fxStr != null ? double.tryParse(fxStr) : null;
      state = AsyncValue.data(SettingsState(baseCurrency: base, usdInrRate: fx));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setBaseCurrency(Currency currency) async {
    final current = state.valueOrNull;
    state = const AsyncLoading();
    try {
      await _repo.setBaseCurrency(currency);
      state = AsyncValue.data(
        (current ?? SettingsState(baseCurrency: currency)).copyWith(baseCurrency: currency),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setUsdInrRate(double? rate) async {
    final current = state.valueOrNull;
    state = const AsyncLoading();
    try {
      if (rate == null) {
        // Clear by setting empty string
        await _repo.setSetting(_fxKeyUsdInr, '');
      } else {
        await _repo.setSetting(_fxKeyUsdInr, rate.toString());
        // also persist in fx_rates table for today
        await _repo.setFxRate(fromCurrency: 'USD', toCurrency: 'INR', rate: rate);
      }
      state = AsyncValue.data(
        (current ?? const SettingsState(baseCurrency: Currency.inr)).copyWith(usdInrRate: rate),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}