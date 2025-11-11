import 'package:portfolio_plus/models/scope.dart';
import 'package:portfolio_plus/services/database_service.dart';

class ScopeRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new scope
  Future<int> createScope(ScopeModel scope) async {
    final db = await _databaseService.database;
    return await db.insert('scopes', scope.toMap());
  }

  // Get all scopes
  Future<List<ScopeModel>> getAllScopes() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scopes',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return ScopeModel.fromMap(maps[i]);
    });
  }

  // Get scope by ID
  Future<ScopeModel?> getScopeById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scopes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ScopeModel.fromMap(maps.first);
    }
    return null;
  }

  // Update scope
  Future<int> updateScope(ScopeModel scope) async {
    final db = await _databaseService.database;
    return await db.update(
      'scopes',
      scope.toMap(),
      where: 'id = ?',
      whereArgs: [scope.id],
    );
  }

  // Delete scope
  Future<int> deleteScope(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'scopes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search scopes by name
  Future<List<ScopeModel>> searchScopes(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scopes',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return ScopeModel.fromMap(maps[i]);
    });
  }

  // Get scopes associated with a portfolio
  Future<List<ScopeModel>> getScopesByPortfolioId(int portfolioId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.* FROM scopes s
      INNER JOIN portfolio_scopes ps ON s.id = ps.scopeId
      WHERE ps.portfolioId = ?
      ORDER BY s.createdAt DESC
    ''', [portfolioId]);
    return List.generate(maps.length, (i) {
      return ScopeModel.fromMap(maps[i]);
    });
  }

  // Associate a scope with a portfolio
  Future<void> associateScopeWithPortfolio(int scopeId, int portfolioId) async {
    final db = await _databaseService.database;
    await db.insert('portfolio_scopes', {
      'scopeId': scopeId,
      'portfolioId': portfolioId,
    });
  }

  // Remove scope association with a portfolio
  Future<void> removeScopeFromPortfolio(int scopeId, int portfolioId) async {
    final db = await _databaseService.database;
    await db.delete(
      'portfolio_scopes',
      where: 'scopeId = ? AND portfolioId = ?',
      whereArgs: [scopeId, portfolioId],
    );
  }
}