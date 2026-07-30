import 'dart:collection';
import 'package:portfolio_plus/services/transaction_repository.dart';
import 'package:portfolio_plus/services/asset_repository.dart';
import 'package:portfolio_plus/models/asset.dart';
import 'package:portfolio_plus/utils/enums/transaction.dart';

/// Represents a single position lot with quantity and total cost
class Position {
  final double quantity;
  final double totalCost;

  Position(this.quantity, this.totalCost);

  double get avgCost => quantity > 0 ? totalCost / quantity : 0;
}

/// FIFO position engine for tracking cost basis and realized PnL per asset
class FifoPositionEngine {
  final Queue<Position> _positions = Queue<Position>();
  double _realizedPnL = 0;

  /// Add a buy transaction (adds to position queue)
  void addBuy(double quantity, double totalCost) {
    _positions.add(Position(quantity, totalCost));
  }

  /// Add a sell transaction (consumes positions FIFO, calculates realized PnL)
  double addSell(double quantity, double totalProceeds) {
    double remainingQuantity = quantity;
    double costBasis = 0;

    while (remainingQuantity > 0 && _positions.isNotEmpty) {
      Position oldestPosition = _positions.first;

      if (oldestPosition.quantity <= remainingQuantity) {
        // Consume entire position
        double consumedQuantity = oldestPosition.quantity;
        costBasis += oldestPosition.totalCost;
        remainingQuantity -= consumedQuantity;
        _positions.removeFirst();
      } else {
        // Consume partial position
        double consumedQuantity = remainingQuantity;
        double consumedCost =
            (consumedQuantity / oldestPosition.quantity) *
            oldestPosition.totalCost;
        costBasis += consumedCost;

        // Update remaining position
        double remainingQty = oldestPosition.quantity - consumedQuantity;
        double remainingCost = oldestPosition.totalCost - consumedCost;
        _positions.removeFirst();
        _positions.addFirst(Position(remainingQty, remainingCost));

        remainingQuantity = 0;
      }
    }

    // Calculate realized PnL for this sell
    double realizedPnL = totalProceeds - costBasis;
    _realizedPnL += realizedPnL;

    return realizedPnL;
  }

  /// Get current position quantity
  double get currentQuantity {
    return _positions.fold(0, (sum, pos) => sum + pos.quantity);
  }

  /// Get current cost basis (total invested in remaining positions)
  double get currentCostBasis {
    return _positions.fold(0, (sum, pos) => sum + pos.totalCost);
  }

  /// Get average cost of remaining positions
  double get avgCost {
    double qty = currentQuantity;
    return qty > 0 ? currentCostBasis / qty : 0;
  }

  /// Get cumulative realized PnL
  double get realizedPnL => _realizedPnL;

  /// Clear all positions and realized PnL
  void clear() {
    _positions.clear();
    _realizedPnL = 0;
  }
}

class PortfolioCalculationsService {
  final TransactionRepository _transactionRepository;
  final AssetRepository _assetRepository;

  PortfolioCalculationsService(this._transactionRepository, this._assetRepository);

  /// Calculate portfolio summary with FIFO-based realized PnL
  Future<Map<String, dynamic>> calculatePortfolioSummary(
    int portfolioId,
  ) async {
    final values = await calculatePortfolioValues(portfolioId);
    return {
      'totalValue': values['totalValue'],
      'investedAmount': values['totalInvested'],
      'totalPnL': values['totalPnL'],
      'totalDividends': values['totalDividends'],
      'totalFees': values['totalFees'],
      'totalPnLPercentage': values['totalReturnPercent'] ?? 0.0,
    };
  }

  /// Calculate performance metrics
  Future<Map<String, dynamic>> calculatePerformanceMetrics(
    int portfolioId,
  ) async {
    final values = await calculatePortfolioValues(portfolioId);
    final invested = values['totalInvested'] as double;
    final pnl = values['totalPnL'] as double;
    final realizedPnL = values['totalRealizedPnL'] as double;
    final unrealizedPnL = values['totalUnrealizedPnL'] as double;

    return {
      'totalReturnPercentage': invested > 0 ? (pnl / invested) * 100 : 0,
      'realizedPnL': realizedPnL,
      'unrealizedPnL': unrealizedPnL,
      'dividendYield': invested > 0
          ? ((values['totalDividends'] as double) / invested) * 100
          : 0,
      'feeRatio': invested > 0
          ? ((values['totalFees'] as double) / invested) * 100
          : 0,
    };
  }

  /// Calculate current holdings for a portfolio
  Future<List<Map<String, dynamic>>> calculateHoldings(int portfolioId) async {
    final values = await calculatePortfolioValues(portfolioId);
    final engines = values['_engines'] as Map<String, FifoPositionEngine>;
    
    final Map<int, Map<String, dynamic>> holdingsByAsset = {};
    
    for (final entry in engines.entries) {
      final keyParts = entry.key.split('|');
      if (keyParts.length < 2) continue;
      final assetIdStr = keyParts[1];
      if (assetIdStr == 'none' || assetIdStr == 'null') continue;
      
      final assetId = int.tryParse(assetIdStr);
      if (assetId == null) continue;
      
      final engine = entry.value;
      if (engine.currentQuantity <= 0.0001) continue;
      
      if (!holdingsByAsset.containsKey(assetId)) {
        final asset = await _assetRepository.getAssetById(assetId);
        if (asset == null) continue;
        
        holdingsByAsset[assetId] = {
          'asset': asset,
          'quantity': 0.0,
          'costBasis': 0.0,
        };
      }
      
      holdingsByAsset[assetId]!['quantity'] += engine.currentQuantity;
      holdingsByAsset[assetId]!['costBasis'] += engine.currentCostBasis;
    }
    
    final holdings = holdingsByAsset.values.toList();
    for (var holding in holdings) {
      final qty = holding['quantity'] as double;
      final cost = holding['costBasis'] as double;
      final asset = holding['asset'] as Asset;
      
      holding['averageCost'] = qty > 0 ? cost / qty : 0.0;
      holding['currentValue'] = qty * asset.currentPrice;
      holding['unrealizedPnL'] = holding['currentValue'] - cost;
      holding['unrealizedPnLPercent'] = cost > 0 ? (holding['unrealizedPnL'] / cost) * 100 : 0.0;
    }
    
    // Sort by current value descending
    holdings.sort((a, b) => (b['currentValue'] as double).compareTo(a['currentValue'] as double));
    
    return holdings;
  }

  /// Calculate asset allocation (placeholder - needs asset data)
  Future<Map<String, dynamic>> calculateAssetAllocation(int portfolioId) async {
    final transactions = await _transactionRepository.getTransactionsByPortfolioId(portfolioId);
    
    // Group quantities by assetId
    final Map<int, double> assetQuantities = {};
    for (final tx in transactions) {
      if (tx.assetId == null) continue;
      final qty = tx.quantity;
      if (tx.type == TransactionType.buy || tx.type == TransactionType.deposit || tx.type == TransactionType.split || tx.type == TransactionType.bonus) {
        assetQuantities[tx.assetId!] = (assetQuantities[tx.assetId!] ?? 0.0) + qty;
      } else if (tx.type == TransactionType.sell || tx.type == TransactionType.withdrawal) {
        assetQuantities[tx.assetId!] = (assetQuantities[tx.assetId!] ?? 0.0) - qty;
      }
    }

    final Map<String, double> assetValues = {};
    double totalValue = 0.0;

    for (final entry in assetQuantities.entries) {
      final assetId = entry.key;
      final qty = entry.value;
      if (qty <= 0.0001) continue; // ignore zero/negative holdings

      final asset = await _assetRepository.getAssetById(assetId);
      if (asset == null) continue;

      final price = asset.currentPrice > 0 ? asset.currentPrice : 0.0;
      final value = qty * price;
      final key = asset.symbol.isNotEmpty ? asset.symbol : asset.name;
      assetValues[key] = value;
      totalValue += value;
    }

    final Map<String, double> allocation = {};
    if (totalValue > 0) {
      assetValues.forEach((key, value) {
        allocation[key] = (value / totalValue) * 100;
      });
    }

    return {
      'allocation': allocation,
      'assetValues': assetValues,
      'totalValue': totalValue,
      'byAssetClass': <String, double>{},
      'byAccount': <String, double>{},
      'byProvider': <String, double>{},
    };
  }

  /// Calculate historical performance (placeholder)
  Future<Map<String, dynamic>> calculateHistoricalPerformance(
    int portfolioId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return {
      'equityCurve': <DateTime, double>{},
      'monthlyReturns': <DateTime, double>{},
      'yearlyReturns': <int, double>{},
    };
  }

  Future<Map<String, dynamic>> calculatePortfolioValues(int portfolioId) async {
    final Map<String, FifoPositionEngine> engines = {};

    FifoPositionEngine getEngine(int? accountId, int? assetId) {
      final key = '${accountId ?? 'none'}|${assetId ?? 'none'}';
      return engines[key] ??= FifoPositionEngine();
    }

    final transactions = await _transactionRepository
        .getTransactionsByPortfolioId(portfolioId);

    // Sort transactions by date for proper FIFO processing
    transactions.sort((a, b) => a.date.compareTo(b.date));

    double totalInvested = 0;
    double totalSold = 0;
    double totalDividends = 0;
    double totalDeposits = 0;
    double totalWithdrawals = 0;
    double totalFees = 0;
    double totalRealizedPnL = 0;

    for (final transaction in transactions) {
      final engine = getEngine(transaction.accountId, transaction.assetId);
      final double absoluteFee = transaction.fee != null ? transaction.amount * (transaction.fee! / 100) : 0.0;

      switch (transaction.type) {
        case TransactionType.buy:
          engine.addBuy(transaction.quantity, transaction.amount + absoluteFee);
          totalInvested += transaction.amount + absoluteFee;
          totalFees += absoluteFee;
          break;

        case TransactionType.sell:
          double realizedPnL = engine.addSell(
            transaction.quantity,
            transaction.amount - absoluteFee,
          );
          totalSold += transaction.amount - absoluteFee;
          totalRealizedPnL += realizedPnL;
          totalFees += absoluteFee;
          
          if (transaction.realizedPnLPerTx != realizedPnL) {
            await _transactionRepository.updateTransaction(
              transaction.copyWith(realizedPnLPerTx: realizedPnL),
            );
          }
          break;

        case TransactionType.dividend:
          totalDividends += transaction.amount;
          break;

        case TransactionType.deposit:
          totalDeposits += transaction.amount;
          break;

        case TransactionType.withdrawal:
          totalWithdrawals += transaction.amount;
          break;

        case TransactionType.split:
        case TransactionType.bonus:
          // Handle stock splits/bonuses by adjusting positions
          // For now, treat as additional shares at current average cost
          engine.addBuy(transaction.quantity, transaction.amount);
          break;
      }
    }

    // Calculate unrealized PnL from remaining positions
    double totalUnrealizedPnL = 0;
    for (final engine in engines.values) {
      // For unrealized PnL, we'd need current market prices
      // For now, assume current value equals cost basis
      totalUnrealizedPnL += 0; // Placeholder
    }

    // Calculate total PnL
    double totalPnL = totalRealizedPnL + totalDividends + totalUnrealizedPnL;

    return {
      'totalInvested': totalInvested,
      'totalValue':
          totalInvested - totalSold + totalDeposits - totalWithdrawals,
      'totalDividends': totalDividends,
      'totalDeposits': totalDeposits,
      'totalWithdrawals': totalWithdrawals,
      'totalFees': totalFees,
      'totalRealizedPnL': totalRealizedPnL,
      'totalUnrealizedPnL': totalUnrealizedPnL,
      'totalPnL': totalPnL,
      'totalReturnPercent': totalInvested > 0
          ? (totalPnL / totalInvested) * 100
          : 0.0,
      '_engines': engines,
    };
  }
}
