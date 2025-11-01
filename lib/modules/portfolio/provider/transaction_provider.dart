import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/transaction.dart';
import 'package:portfolio_plus/services/transaction_repository.dart';

// Transaction repository provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Transaction list provider for a specific portfolio
final transactionListProvider = StateNotifierProvider.family<TransactionListNotifier, AsyncValue<List<TransactionModel>>, int>((ref, portfolioId) {
  return TransactionListNotifier(ref.read(transactionRepositoryProvider), portfolioId);
});

class TransactionListNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final TransactionRepository _repository;
  final int _portfolioId;

  TransactionListNotifier(this._repository, this._portfolioId) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _repository.getTransactionsByPortfolioId(_portfolioId);
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.createTransaction(transaction);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> filterTransactionsByType(String type) async {
    try {
      if (type == 'all') {
        await loadTransactions();
      } else {
        final transactions = await _repository.getTransactionsByType(type);
        state = AsyncValue.data(transactions);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> filterTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await _repository.getTransactionsByPortfolioAndDateRange(
        _portfolioId,
        startDate,
        endDate,
      );
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Individual transaction provider
final transactionProvider = StateNotifierProvider.family<TransactionNotifier, AsyncValue<TransactionModel>, int>((ref, id) {
  return TransactionNotifier(ref.read(transactionRepositoryProvider), id);
});

class TransactionNotifier extends StateNotifier<AsyncValue<TransactionModel>> {
  final TransactionRepository _repository;
  final int _transactionId;

  TransactionNotifier(this._repository, this._transactionId) : super(const AsyncValue.loading()) {
    loadTransaction();
  }

  Future<void> loadTransaction() async {
    state = const AsyncValue.loading();
    try {
      final transaction = await _repository.getTransactionById(_transactionId);
      if (transaction != null) {
        state = AsyncValue.data(transaction);
      } else {
        state = AsyncValue.error('Transaction not found', StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      state = AsyncValue.data(transaction);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Transaction statistics provider for a portfolio
final transactionStatisticsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, portfolioId) async {
  final repository = ref.read(transactionRepositoryProvider);
  return await repository.getTransactionStatistics(portfolioId);
});

// All transactions provider (for admin view)
final allTransactionsProvider = StateNotifierProvider<AllTransactionsNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  return AllTransactionsNotifier(ref.read(transactionRepositoryProvider));
});

class AllTransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final TransactionRepository _repository;

  AllTransactionsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAllTransactions();
  }

  Future<void> loadAllTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _repository.getAllTransactions();
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> searchTransactions(String query) async {
    try {
      if (query.isEmpty) {
        await loadAllTransactions();
      } else {
        final transactions = await _repository.searchTransactions(query);
        state = AsyncValue.data(transactions);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}