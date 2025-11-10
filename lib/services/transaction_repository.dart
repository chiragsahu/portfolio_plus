import 'package:portfolio_plus/models/transaction.dart';
import 'package:portfolio_plus/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class TransactionRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new transaction
  Future<int> createTransaction(TransactionModel transaction) async {
    final db = await _databaseService.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transactions by portfolio ID
  Future<List<TransactionModel>> getTransactionsByPortfolioId(
    int portfolioId,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'portfolioId = ?',
      whereArgs: [portfolioId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transactions by asset ID
  Future<List<TransactionModel>> getTransactionsByAssetId(int assetId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'assetId = ?',
      whereArgs: [assetId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transactions by account ID
  Future<List<TransactionModel>> getTransactionsByAccountId(
    int accountId,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transactions by account and asset ID
  Future<List<TransactionModel>> getTransactionsByAccountAndAssetId(
    int accountId,
    int assetId,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'accountId = ? AND assetId = ?',
      whereArgs: [accountId, assetId],
      orderBy: 'date ASC', // FIFO order for position calculations
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  // Update transaction
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await _databaseService.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) async {
    final db = await _databaseService.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transactions by portfolio and date range
  Future<List<TransactionModel>> getTransactionsByPortfolioAndDateRange(
    int portfolioId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'portfolioId = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        portfolioId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Get transaction statistics for a portfolio
  Future<Map<String, dynamic>> getTransactionStatistics(int portfolioId) async {
    final db = await _databaseService.database;

    // Total transactions count
    final transactionCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE portfolioId = ?',
            [portfolioId],
          ),
        ) ??
        0;

    // Total invested amount (sum of buy transactions)
    final totalInvested =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(amount) FROM transactions WHERE portfolioId = ? AND type = ?',
            [portfolioId, 'buy'],
          ),
        ) ??
        0;

    // Total sold amount (sum of sell transactions)
    final totalSold =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(amount) FROM transactions WHERE portfolioId = ? AND type = ?',
            [portfolioId, 'sell'],
          ),
        ) ??
        0;

    // Total dividends received
    final totalDividends =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(amount) FROM transactions WHERE portfolioId = ? AND type = ?',
            [portfolioId, 'dividend'],
          ),
        ) ??
        0;

    // Transactions by type
    final List<Map<String, dynamic>> typeMaps = await db.rawQuery(
      '''
      SELECT type, COUNT(*) as count, SUM(amount) as totalAmount
      FROM transactions 
      WHERE portfolioId = ?
      GROUP BY type
    ''',
      [portfolioId],
    );

    Map<String, Map<String, dynamic>> transactionsByType = {};
    for (var map in typeMaps) {
      transactionsByType[map['type']] = {
        'count': map['count'],
        'totalAmount': map['totalAmount'],
      };
    }

    return {
      'totalTransactions': transactionCount,
      'totalInvested': totalInvested,
      'totalSold': totalSold,
      'totalDividends': totalDividends,
      'transactionsByType': transactionsByType,
    };
  }

  // Search transactions by notes
  Future<List<TransactionModel>> searchTransactions(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'notes LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }
}
