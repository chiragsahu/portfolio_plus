import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/portfolio.dart';
import 'package:portfolio_plus/services/portfolio_repository.dart';
import 'package:portfolio_plus/services/tag_repository.dart';

// Portfolio repository provider
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository();
});

// Tag repository provider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository();
});

// Portfolio list provider
final portfolioListProvider = StateNotifierProvider<PortfolioListNotifier, AsyncValue<List<Portfolio>>>((ref) {
  return PortfolioListNotifier(ref.read(portfolioRepositoryProvider));
});

class PortfolioListNotifier extends StateNotifier<AsyncValue<List<Portfolio>>> {
  final PortfolioRepository _repository;

  PortfolioListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPortfolios();
  }

  Future<void> loadPortfolios() async {
    state = const AsyncValue.loading();
    try {
      final portfolios = await _repository.getAllPortfolios();
      state = AsyncValue.data(portfolios);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addPortfolio(Portfolio portfolio) async {
    try {
      await _repository.createPortfolio(portfolio);
      await loadPortfolios();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePortfolio(Portfolio portfolio) async {
    try {
      await _repository.updatePortfolio(portfolio);
      await loadPortfolios();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deletePortfolio(int id) async {
    try {
      await _repository.deletePortfolio(id);
      await loadPortfolios();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> searchPortfolios(String query) async {
    try {
      if (query.isEmpty) {
        await loadPortfolios();
      } else {
        final portfolios = await _repository.searchPortfolios(query);
        state = AsyncValue.data(portfolios);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAllPortfolios() async {
    try {
      await _repository.deleteAllPortfolios();
      await loadPortfolios();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Individual portfolio provider
final portfolioProvider = StateNotifierProvider.family<PortfolioNotifier, AsyncValue<Portfolio>, int>((ref, id) {
  return PortfolioNotifier(ref.read(portfolioRepositoryProvider), id);
});

class PortfolioNotifier extends StateNotifier<AsyncValue<Portfolio>> {
  final PortfolioRepository _repository;
  final int _portfolioId;

  PortfolioNotifier(this._repository, this._portfolioId) : super(const AsyncValue.loading()) {
    loadPortfolio();
  }

  Future<void> loadPortfolio() async {
    state = const AsyncValue.loading();
    try {
      final portfolio = await _repository.getPortfolioById(_portfolioId);
      if (portfolio != null) {
        state = AsyncValue.data(portfolio);
      } else {
        state = AsyncValue.error('Portfolio not found', StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePortfolio(Portfolio portfolio) async {
    try {
      final updatedPortfolio = await _repository.updatePortfolio(portfolio);
      if (updatedPortfolio > 0) {
        state = AsyncValue.data(portfolio.copyWith(updatedAt: DateTime.now()));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Portfolio statistics provider
final portfolioStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(portfolioRepositoryProvider);
  return await repository.getPortfolioStatistics();
});

// Portfolios by investment type provider
final portfoliosByTypeProvider = FutureProvider.family<List<Portfolio>, String>((ref, investmentType) async {
  final repository = ref.read(portfolioRepositoryProvider);
  return await repository.getPortfoliosByInvestmentType(investmentType);
});