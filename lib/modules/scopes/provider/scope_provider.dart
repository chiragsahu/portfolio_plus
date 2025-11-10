import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/scope.dart';
import 'package:portfolio_plus/services/scope_repository.dart';

final scopeRepositoryProvider = Provider<ScopeRepository>((ref) {
  return ScopeRepository();
});

final scopeListProvider = StateNotifierProvider<ScopeListNotifier, AsyncValue<List<ScopeModel>>>((ref) {
  final repository = ref.watch(scopeRepositoryProvider);
  return ScopeListNotifier(repository);
});

class ScopeListNotifier extends StateNotifier<AsyncValue<List<ScopeModel>>> {
  final ScopeRepository _repository;

  ScopeListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadScopes();
  }

  Future<void> loadScopes() async {
    state = const AsyncValue.loading();
    try {
      final scopes = await _repository.getAllScopes();
      state = AsyncValue.data(scopes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addScope(ScopeModel scope) async {
    try {
      await _repository.createScope(scope);
      await loadScopes();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateScope(ScopeModel scope) async {
    try {
      await _repository.updateScope(scope);
      await loadScopes();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteScope(int id) async {
    try {
      await _repository.deleteScope(id);
      await loadScopes();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> searchScopes(String query) async {
    if (query.isEmpty) {
      await loadScopes();
      return;
    }
    state = const AsyncValue.loading();
    try {
      final scopes = await _repository.searchScopes(query);
      state = AsyncValue.data(scopes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}