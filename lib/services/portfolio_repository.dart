import 'package:portfolio_plus/models/portfolio.dart';
import 'package:portfolio_plus/models/tag.dart';
import 'package:portfolio_plus/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PortfolioRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new portfolio
  Future<int> createPortfolio(Portfolio portfolio) async {
    final db = await _databaseService.database;
    return await db.insert('portfolios', portfolio.toMap());
  }

  // Get all portfolios
  Future<List<Portfolio>> getAllPortfolios() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'portfolios',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) {
      return Portfolio.fromMap(maps[i]);
    });
  }

  // Get portfolio by ID
  Future<Portfolio?> getPortfolioById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'portfolios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Portfolio.fromMap(maps.first);
    }
    return null;
  }

  // Update portfolio
  Future<int> updatePortfolio(Portfolio portfolio) async {
    final db = await _databaseService.database;
    return await db.update(
      'portfolios',
      portfolio.toMap(),
      where: 'id = ?',
      whereArgs: [portfolio.id],
    );
  }

  // Delete portfolio
  Future<int> deletePortfolio(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'portfolios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get portfolios by investment type
  Future<List<Portfolio>> getPortfoliosByInvestmentType(String investmentType) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'portfolios',
      where: 'investmentType = ?',
      whereArgs: [investmentType],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) {
      return Portfolio.fromMap(maps[i]);
    });
  }

  // Add tag to portfolio
  Future<void> addTagToPortfolio(int portfolioId, int tagId) async {
    final db = await _databaseService.database;
    await db.insert(
      'portfolio_tags',
      {
        'portfolioId': portfolioId,
        'tagId': tagId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Remove tag from portfolio
  Future<void> removeTagFromPortfolio(int portfolioId, int tagId) async {
    final db = await _databaseService.database;
    await db.delete(
      'portfolio_tags',
      where: 'portfolioId = ? AND tagId = ?',
      whereArgs: [portfolioId, tagId],
    );
  }

  // Get tags for a portfolio
  Future<List<Tag>> getTagsForPortfolio(int portfolioId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM tags t
      INNER JOIN portfolio_tags pt ON t.id = pt.tagId
      WHERE pt.portfolioId = ?
    ''', [portfolioId]);
    
    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  // Search portfolios by name
  Future<List<Portfolio>> searchPortfolios(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'portfolios',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) {
      return Portfolio.fromMap(maps[i]);
    });
  }

  // Get portfolio statistics
  Future<Map<String, dynamic>> getPortfolioStatistics() async {
    final db = await _databaseService.database;
    
    // Total portfolios count
    final portfolioCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM portfolios')
    ) ?? 0;
    
    // Portfolios by investment type
    final List<Map<String, dynamic>> typeMaps = await db.rawQuery('''
      SELECT investmentType, COUNT(*) as count 
      FROM portfolios 
      GROUP BY investmentType
    ''');
    
    Map<String, int> portfoliosByType = {};
    for (var map in typeMaps) {
      portfoliosByType[map['investmentType']] = map['count'];
    }
    
    return {
      'totalPortfolios': portfolioCount,
      'portfoliosByType': portfoliosByType,
    };
  }

  // Delete all portfolios
  Future<void> deleteAllPortfolios() async {
    final db = await _databaseService.database;
    await db.delete('portfolios');
  }
}