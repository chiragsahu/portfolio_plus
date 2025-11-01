import 'package:portfolio_plus/models/transaction.dart';
import 'package:portfolio_plus/services/transaction_repository.dart';
import 'package:portfolio_plus/utils/enums/transaction.dart';

class PortfolioCalculationsService {
  final TransactionRepository _transactionRepository;

  PortfolioCalculationsService(this._transactionRepository);

  /// Calculate portfolio summary including total value, invested amount, P&L, etc.
  Future<Map<String, dynamic>> calculatePortfolioSummary(int portfolioId) async {
    final transactions = await _transactionRepository.getTransactionsByPortfolioId(portfolioId);
    
    if (transactions.isEmpty) {
      return {
        'totalValue': 0.0,
        'investedAmount': 0.0,
        'totalPnL': 0.0,
        'totalPnLPercentage': 0.0,
        'totalQuantity': 0.0,
        'averageBuyPrice': 0.0,
        'totalDividends': 0.0,
        'transactionCount': 0,
        'buyTransactions': 0,
        'sellTransactions': 0,
        'dividendTransactions': 0,
      };
    }

    double totalInvested = 0.0;
    double totalSold = 0.0;
    double totalDividends = 0.0;
    double totalQuantity = 0.0;
    double totalBuyAmount = 0.0;
    int buyCount = 0;
    int sellCount = 0;
    int dividendCount = 0;

    // Group transactions by asset to calculate holdings
    Map<String, List<TransactionModel>> transactionsByAsset = {};
    Map<String, double> holdings = {};
    Map<String, double> averageBuyPrices = {};

    for (final transaction in transactions) {
      final assetKey = transaction.assetId?.toString() ?? 'unknown';
      
      if (!transactionsByAsset.containsKey(assetKey)) {
        transactionsByAsset[assetKey] = [];
        holdings[assetKey] = 0.0;
        averageBuyPrices[assetKey] = 0.0;
      }
      
      transactionsByAsset[assetKey]!.add(transaction);

      switch (transaction.type) {
        case TransactionType.buy:
          totalInvested += transaction.amount;
          totalQuantity += transaction.quantity;
          totalBuyAmount += transaction.amount;
          buyCount++;
          
          // Update holdings and average buy price
          holdings[assetKey] = (holdings[assetKey] ?? 0.0) + transaction.quantity;
          final currentAvgPrice = averageBuyPrices[assetKey] ?? 0.0;
          final totalQuantityForAvg = (holdings[assetKey] ?? 0.0);
          averageBuyPrices[assetKey] = ((currentAvgPrice * (totalQuantityForAvg - transaction.quantity)) + transaction.amount) / totalQuantityForAvg;
          break;
          
        case TransactionType.sell:
          totalSold += transaction.amount;
          totalQuantity -= transaction.quantity;
          sellCount++;
          
          // Update holdings
          holdings[assetKey] = (holdings[assetKey] ?? 0.0) - transaction.quantity;
          break;
          
        case TransactionType.dividend:
          totalDividends += transaction.amount;
          dividendCount++;
          break;
          
        case TransactionType.deposit:
          totalInvested += transaction.amount;
          break;
          
        case TransactionType.withdrawal:
          totalInvested -= transaction.amount;
          break;
          
        case TransactionType.split:
        case TransactionType.bonus:
          // These don't affect monetary calculations directly
          break;
      }
    }

    // Calculate current value (simplified - in real app, this would use current market prices)
    // For now, we'll use the average buy price as current price
    double currentValue = 0.0;
    for (final entry in holdings.entries) {
      final assetKey = entry.key;
      final quantity = entry.value;
      if (quantity > 0) {
        final avgPrice = averageBuyPrices[assetKey] ?? 0.0;
        currentValue += quantity * avgPrice;
      }
    }

    final totalPnL = currentValue + totalDividends - totalInvested;
    final totalPnLPercentage = totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0.0;
    final overallAverageBuyPrice = totalQuantity > 0 ? totalBuyAmount / totalQuantity : 0.0;

    return {
      'totalValue': currentValue,
      'investedAmount': totalInvested,
      'totalPnL': totalPnL,
      'totalPnLPercentage': totalPnLPercentage,
      'totalQuantity': totalQuantity,
      'averageBuyPrice': overallAverageBuyPrice,
      'totalDividends': totalDividends,
      'transactionCount': transactions.length,
      'buyTransactions': buyCount,
      'sellTransactions': sellCount,
      'dividendTransactions': dividendCount,
      'holdings': holdings,
      'averageBuyPrices': averageBuyPrices,
    };
  }

  /// Calculate performance metrics for a portfolio
  Future<Map<String, dynamic>> calculatePerformanceMetrics(int portfolioId) async {
    final transactions = await _transactionRepository.getTransactionsByPortfolioId(portfolioId);
    
    if (transactions.isEmpty) {
      return {
        'bestPerformer': null,
        'worstPerformer': null,
        'totalReturn': 0.0,
        'totalReturnPercentage': 0.0,
        'monthlyReturns': <String, double>{},
      };
    }

    // Group transactions by asset
    Map<String, List<TransactionModel>> transactionsByAsset = {};
    for (final transaction in transactions) {
      final assetKey = transaction.assetId?.toString() ?? 'unknown';
      if (!transactionsByAsset.containsKey(assetKey)) {
        transactionsByAsset[assetKey] = [];
      }
      transactionsByAsset[assetKey]!.add(transaction);
    }

    // Calculate returns for each asset
    Map<String, double> assetReturns = {};
    Map<String, double> assetReturnPercentages = {};
    
    for (final entry in transactionsByAsset.entries) {
      final assetTransactions = entry.value;
      double totalBuy = 0.0;
      double totalSell = 0.0;
      double totalQuantity = 0.0;
      double totalBuyAmount = 0.0;
      
      for (final transaction in assetTransactions) {
        switch (transaction.type) {
          case TransactionType.buy:
            totalBuy += transaction.amount;
            totalQuantity += transaction.quantity;
            totalBuyAmount += transaction.amount;
            break;
          case TransactionType.sell:
            totalSell += transaction.amount;
            totalQuantity -= transaction.quantity;
            break;
          case TransactionType.dividend:
          case TransactionType.deposit:
          case TransactionType.withdrawal:
          case TransactionType.split:
          case TransactionType.bonus:
            // These don't affect asset performance calculations
            break;
        }
      }
      
      final avgBuyPrice = totalQuantity > 0 ? totalBuyAmount / totalQuantity : 0.0;
      final currentValue = totalQuantity * avgBuyPrice;
      final returnValue = currentValue + totalSell - totalBuy;
      final returnPercentage = totalBuy > 0 ? (returnValue / totalBuy) * 100 : 0.0;
      
      assetReturns[entry.key] = returnValue;
      assetReturnPercentages[entry.key] = returnPercentage;
    }

    // Find best and worst performers
    String? bestPerformer;
    String? worstPerformer;
    double bestReturn = double.negativeInfinity;
    double worstReturn = double.infinity;
    
    for (final entry in assetReturnPercentages.entries) {
      if (entry.value > bestReturn) {
        bestReturn = entry.value;
        bestPerformer = entry.key;
      }
      if (entry.value < worstReturn) {
        worstReturn = entry.value;
        worstPerformer = entry.key;
      }
    }

    // Calculate total return
    double totalReturn = 0.0;
    double totalInvested = 0.0;
    for (final entry in assetReturns.entries) {
      totalReturn += entry.value;
      // Get total buy amount for this asset
      final assetTransactions = transactionsByAsset[entry.key] ?? [];
      for (final transaction in assetTransactions) {
        if (transaction.type == TransactionType.buy) {
          totalInvested += transaction.amount;
        }
      }
    }
    
    final totalReturnPercentage = totalInvested > 0 ? (totalReturn / totalInvested) * 100 : 0.0;

    return {
      'bestPerformer': bestPerformer,
      'worstPerformer': worstPerformer,
      'bestReturn': bestReturn,
      'worstReturn': worstReturn,
      'totalReturn': totalReturn,
      'totalReturnPercentage': totalReturnPercentage,
      'assetReturns': assetReturns,
      'assetReturnPercentages': assetReturnPercentages,
    };
  }

  /// Calculate asset allocation for a portfolio
  Future<Map<String, dynamic>> calculateAssetAllocation(int portfolioId) async {
    final transactions = await _transactionRepository.getTransactionsByPortfolioId(portfolioId);
    
    if (transactions.isEmpty) {
      return {
        'allocation': <String, double>{},
        'totalValue': 0.0,
      };
    }

    // Group transactions by asset and calculate current value
    Map<String, double> holdings = {};
    Map<String, double> averageBuyPrices = {};
    
    for (final transaction in transactions) {
      final assetKey = transaction.assetId?.toString() ?? 'unknown';
      
      if (!holdings.containsKey(assetKey)) {
        holdings[assetKey] = 0.0;
        averageBuyPrices[assetKey] = 0.0;
      }
      
      switch (transaction.type) {
        case TransactionType.buy:
          holdings[assetKey] = (holdings[assetKey] ?? 0.0) + transaction.quantity;
          final currentAvgPrice = averageBuyPrices[assetKey] ?? 0.0;
          final totalQuantityForAvg = (holdings[assetKey] ?? 0.0);
          averageBuyPrices[assetKey] = ((currentAvgPrice * (totalQuantityForAvg - transaction.quantity)) + transaction.amount) / totalQuantityForAvg;
          break;
          
        case TransactionType.sell:
          holdings[assetKey] = (holdings[assetKey] ?? 0.0) - transaction.quantity;
          break;
        case TransactionType.dividend:
        case TransactionType.deposit:
        case TransactionType.withdrawal:
        case TransactionType.split:
        case TransactionType.bonus:
          // These don't affect asset allocation
          break;
      }
    }

    // Calculate current value for each asset
    Map<String, double> assetValues = {};
    double totalValue = 0.0;
    
    for (final entry in holdings.entries) {
      final quantity = entry.value;
      if (quantity > 0) {
        final avgPrice = averageBuyPrices[entry.key] ?? 0.0;
        final value = quantity * avgPrice;
        assetValues[entry.key] = value;
        totalValue += value;
      }
    }

    // Calculate allocation percentages
    Map<String, double> allocationPercentages = {};
    for (final entry in assetValues.entries) {
      final percentage = totalValue > 0 ? (entry.value / totalValue) * 100 : 0.0;
      allocationPercentages[entry.key] = percentage;
    }

    return {
      'allocation': allocationPercentages,
      'assetValues': assetValues,
      'totalValue': totalValue,
      'holdings': holdings,
    };
  }

  /// Calculate historical performance over time
  Future<Map<String, dynamic>> calculateHistoricalPerformance(
    int portfolioId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await _transactionRepository.getTransactionsByPortfolioAndDateRange(
      portfolioId,
      startDate,
      endDate,
    );
    
    if (transactions.isEmpty) {
      return {
        'dailyValues': <DateTime, double>{},
        'totalReturn': 0.0,
        'totalReturnPercentage': 0.0,
      };
    }

    // Group transactions by date
    Map<DateTime, List<TransactionModel>> transactionsByDate = {};
    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (!transactionsByDate.containsKey(date)) {
        transactionsByDate[date] = [];
      }
      transactionsByDate[date]!.add(transaction);
    }

    // Calculate daily portfolio values
    Map<DateTime, double> dailyValues = {};
    DateTime currentDate = startDate;
    double runningInvested = 0.0;
    double runningQuantity = 0.0;
    double runningBuyAmount = 0.0;
    
    while (!currentDate.isAfter(endDate)) {
      // Process transactions for current date
      if (transactionsByDate.containsKey(currentDate)) {
        for (final transaction in transactionsByDate[currentDate]!) {
          switch (transaction.type) {
            case TransactionType.buy:
              runningInvested += transaction.amount;
              runningQuantity += transaction.quantity;
              runningBuyAmount += transaction.amount;
              break;
            case TransactionType.sell:
              runningQuantity -= transaction.quantity;
              break;
            case TransactionType.dividend:
              // Dividends don't affect quantity
              break;
            case TransactionType.deposit:
            case TransactionType.withdrawal:
            case TransactionType.split:
            case TransactionType.bonus:
              // These don't affect historical performance calculations
              break;
          }
        }
      }
      
      // Calculate current value for the day
      final avgBuyPrice = runningQuantity > 0 ? runningBuyAmount / runningQuantity : 0.0;
      final dayValue = runningQuantity * avgBuyPrice;
      dailyValues[currentDate] = dayValue;
      
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Calculate total return for the period
    final firstDayValue = dailyValues[startDate] ?? 0.0;
    final lastDayValue = dailyValues[endDate] ?? 0.0;
    final totalReturn = lastDayValue - firstDayValue;
    final totalReturnPercentage = firstDayValue > 0 ? (totalReturn / firstDayValue) * 100 : 0.0;

    return {
      'dailyValues': dailyValues,
      'totalReturn': totalReturn,
      'totalReturnPercentage': totalReturnPercentage,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}