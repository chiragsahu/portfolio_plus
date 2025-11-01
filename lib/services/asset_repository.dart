import 'package:portfolio_plus/models/asset.dart';
import 'package:portfolio_plus/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class AssetRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new asset
  Future<int> createAsset(Asset asset) async {
    final db = await _databaseService.database;
    return await db.insert('assets', asset.toMap());
  }

  // Get all assets
  Future<List<Asset>> getAllAssets() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      orderBy: 'symbol ASC',
    );
    return List.generate(maps.length, (i) {
      return Asset.fromMap(maps[i]);
    });
  }

  // Get asset by ID
  Future<Asset?> getAssetById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Asset.fromMap(maps.first);
    }
    return null;
  }

  // Get asset by symbol
  Future<Asset?> getAssetBySymbol(String symbol) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'symbol = ?',
      whereArgs: [symbol.toUpperCase()],
    );
    if (maps.isNotEmpty) {
      return Asset.fromMap(maps.first);
    }
    return null;
  }

  // Update asset
  Future<int> updateAsset(Asset asset) async {
    final db = await _databaseService.database;
    return await db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  // Update asset price
  Future<int> updateAssetPrice(int id, double newPrice) async {
    final db = await _databaseService.database;
    return await db.update(
      'assets',
      {
        'currentPrice': newPrice,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update asset price by symbol
  Future<int> updateAssetPriceBySymbol(String symbol, double newPrice) async {
    final db = await _databaseService.database;
    return await db.update(
      'assets',
      {
        'currentPrice': newPrice,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'symbol = ?',
      whereArgs: [symbol.toUpperCase()],
    );
  }

  // Delete asset
  Future<int> deleteAsset(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search assets by symbol or name
  Future<List<Asset>> searchAssets(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'symbol LIKE ? OR name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'symbol ASC',
    );
    return List.generate(maps.length, (i) {
      return Asset.fromMap(maps[i]);
    });
  }

  // Get assets that need price updates (older than specified duration)
  Future<List<Asset>> getAssetsNeedingPriceUpdate({Duration maxAge = const Duration(hours: 1)}) async {
    final db = await _databaseService.database;
    final cutoffTime = DateTime.now().subtract(maxAge).toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'lastUpdated < ?',
      whereArgs: [cutoffTime],
      orderBy: 'lastUpdated ASC',
    );
    return List.generate(maps.length, (i) {
      return Asset.fromMap(maps[i]);
    });
  }

  // Get asset statistics
  Future<Map<String, dynamic>> getAssetStatistics() async {
    final db = await _databaseService.database;
    
    // Total assets count
    final assetCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM assets')
    ) ?? 0;
    
    // Assets with recent price updates (last 24 hours)
    final recentPriceUpdates = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM assets WHERE lastUpdated > ?',
        [DateTime.now().subtract(const Duration(days: 1)).toIso8601String()]
      )
    ) ?? 0;
    
    // Assets needing price updates
    final assetsNeedingUpdate = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM assets WHERE lastUpdated < ?',
        [DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()]
      )
    ) ?? 0;
    
    return {
      'totalAssets': assetCount,
      'recentPriceUpdates': recentPriceUpdates,
      'assetsNeedingUpdate': assetsNeedingUpdate,
    };
  }

  // Bulk update asset prices
  Future<void> bulkUpdatePrices(Map<String, double> priceUpdates) async {
    final db = await _databaseService.database;
    final batch = db.batch();
    
    priceUpdates.forEach((symbol, price) {
      batch.update(
        'assets',
        {
          'currentPrice': price,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'symbol = ?',
        whereArgs: [symbol.toUpperCase()],
      );
    });
    
    await batch.commit();
  }

  // Get unique symbols from transactions that don't exist in assets table
  Future<List<String>> getMissingAssetSymbols() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT t.assetId, a.symbol
      FROM transactions t
      LEFT JOIN assets a ON t.assetId = a.id
      WHERE t.assetId IS NOT NULL AND a.id IS NULL
    ''');
    
    return maps.map((map) => map['symbol'] as String).toList();
  }
}