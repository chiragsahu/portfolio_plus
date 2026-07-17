import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/services/portfolio_calculations_service.dart';
import 'package:portfolio_plus/services/portfolio_repository.dart';
import 'package:portfolio_plus/services/transaction_repository.dart';

import 'package:portfolio_plus/services/asset_repository.dart';

// Provider for transaction repository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Provider for asset repository
final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository();
});

// Provider for portfolio repository
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository();
});

// Provider for the portfolio calculations service
final portfolioCalculationsServiceProvider = Provider<PortfolioCalculationsService>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final assetRepository = ref.watch(assetRepositoryProvider);
  return PortfolioCalculationsService(transactionRepository, assetRepository);
});

// Provider for portfolio summary data
final portfolioSummaryProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, portfolioId) async {
  final calculationsService = ref.watch(portfolioCalculationsServiceProvider);
  return await calculationsService.calculatePortfolioSummary(portfolioId);
});

// Provider for portfolio performance metrics
final portfolioPerformanceProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, portfolioId) async {
  final calculationsService = ref.watch(portfolioCalculationsServiceProvider);
  return await calculationsService.calculatePerformanceMetrics(portfolioId);
});

// Provider for portfolio asset allocation
final portfolioAllocationProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, portfolioId) async {
  final calculationsService = ref.watch(portfolioCalculationsServiceProvider);
  return await calculationsService.calculateAssetAllocation(portfolioId);
});

// Provider for historical performance
final portfolioHistoricalPerformanceProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final calculationsService = ref.watch(portfolioCalculationsServiceProvider);
  final portfolioId = params['portfolioId'] as int;
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;
  return await calculationsService.calculateHistoricalPerformance(portfolioId, startDate, endDate);
});

// Provider for all portfolios summary
final allPortfoliosSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final portfolioRepository = ref.watch(portfolioRepositoryProvider);
  final calculationsService = ref.watch(portfolioCalculationsServiceProvider);
  
  final portfolios = await portfolioRepository.getAllPortfolios();
  
  if (portfolios.isEmpty) {
    return {
      'totalPortfolios': 0,
      'totalValue': 0.0,
      'totalInvested': 0.0,
      'totalPnL': 0.0,
      'totalPnLPercentage': 0.0,
      'portfoliosByType': <String, int>{},
      'topPerformers': <Map<String, dynamic>>[],
    };
  }
  
  double totalValue = 0.0;
  double totalInvested = 0.0;
  double totalPnL = 0.0;
  Map<String, int> portfoliosByType = {};
  List<Map<String, dynamic>> portfolioPerformances = [];
  
  for (final portfolio in portfolios) {
    // Count portfolios by type
    final typeName = portfolio.investmentType.name;
    portfoliosByType[typeName] = (portfoliosByType[typeName] ?? 0) + 1;
    
    // Get portfolio summary
    try {
      final summary = await calculationsService.calculatePortfolioSummary(portfolio.id!);
      final performance = await calculationsService.calculatePerformanceMetrics(portfolio.id!);
      
      totalValue += summary['totalValue'] as double;
      totalInvested += summary['investedAmount'] as double;
      totalPnL += summary['totalPnL'] as double;
      
      portfolioPerformances.add({
        'portfolio': portfolio,
        'summary': summary,
        'performance': performance,
      });
    } catch (e) {
      // Skip portfolios with errors
      continue;
    }
  }
  
  // Sort portfolios by return percentage
  portfolioPerformances.sort((a, b) {
    final aReturn = a['performance']['totalReturnPercentage'] as double;
    final bReturn = b['performance']['totalReturnPercentage'] as double;
    return bReturn.compareTo(aReturn);
  });
  
  final totalPnLPercentage = totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0.0;
  
  return {
    'totalPortfolios': portfolios.length,
    'totalValue': totalValue,
    'totalInvested': totalInvested,
    'totalPnL': totalPnL,
    'totalPnLPercentage': totalPnLPercentage,
    'portfoliosByType': portfoliosByType,
    'topPerformers': portfolioPerformances.take(5).toList(),
  };
});