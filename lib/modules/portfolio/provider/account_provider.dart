import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/account.dart';
import 'package:portfolio_plus/services/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

final accountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  final repository = ref.watch(accountRepositoryProvider);
  return await repository.getAllAccounts();
});

final accountProvider = FutureProvider.family<AccountModel?, int>((ref, accountId) async {
  final repository = ref.watch(accountRepositoryProvider);
  return await repository.getAccountById(accountId);
});