import 'dart:collection';
import 'package:portfolio_plus/services/transaction_repository.dart';
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

  PortfolioCalculationsService(this._transactionRepository);

  /// Map of FIFO engines keyed by '${accountId}_${assetId}' for per-account+asset tracking
  final Map<String, FifoPositionEngine> _engines = {};

  /// Get or create a FIFO engine for the given account and asset
  FifoPositionEngine _getEngine(int? accountId, int? assetId) {
    final key = '${accountId ?? 'no_account'}_${assetId ?? 'no_asset'}';
    return _engines[key] ??= FifoPositionEngine();
  }

  /// Clear all engines (for fresh calculations)
  void _clearEngines() {
    _engines.clear();
  }

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

  /// Calculate asset allocation (placeholder - needs asset data)
  Future<Map<String, dynamic>> calculateAssetAllocation(int portfolioId) async {
    return {
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

  Future<Map<String, double>> calculatePortfolioValues(int portfolioId) async {
    _clearEngines();

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
      final engine = _getEngine(transaction.accountId, transaction.assetId);

      switch (transaction.type) {
        case TransactionType.buy:
          engine.addBuy(transaction.quantity, transaction.amount);
          totalInvested += transaction.amount;
          if (transaction.fee != null) totalFees += transaction.fee!;
          break;

        case TransactionType.sell:
          double realizedPnL = engine.addSell(
            transaction.quantity,
            transaction.amount,
          );
          totalSold += transaction.amount;
          totalRealizedPnL += realizedPnL;
          if (transaction.fee != null) totalFees += transaction.fee!;
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
    for (final engine in _engines.values) {
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
          : 0,
    };
  }
}
