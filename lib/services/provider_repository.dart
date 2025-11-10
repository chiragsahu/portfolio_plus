import 'package:portfolio_plus/models/provider.dart';
import 'package:portfolio_plus/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ProviderRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new provider
  Future<int> createProvider(ProviderModel provider) async {
    final db = await _databaseService.database;
    return await db.insert('providers', provider.toMap());
  }

  // Get all providers
  Future<List<ProviderModel>> getAllProviders() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'providers',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return ProviderModel.fromMap(maps[i]);
    });
  }

  // Get provider by ID
  Future<ProviderModel?> getProviderById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'providers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ProviderModel.fromMap(maps.first);
    }
    return null;
  }

  // Update provider
  Future<int> updateProvider(ProviderModel provider) async {
    final db = await _databaseService.database;
    return await db.update(
      'providers',
      provider.toMap(),
      where: 'id = ?',
      whereArgs: [provider.id],
    );
  }

  // Delete provider
  Future<int> deleteProvider(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'providers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get providers by type
  Future<List<ProviderModel>> getProvidersByType(ProviderKind type) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'providers',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return ProviderModel.fromMap(maps[i]);
    });
  }

  // Search providers by name
  Future<List<ProviderModel>> searchProviders(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'providers',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return ProviderModel.fromMap(maps[i]);
    });
  }

  // Get provider statistics
  Future<Map<String, dynamic>> getProviderStatistics() async {
    final db = await _databaseService.database;

    // Total providers count
    final providerCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM providers')
    ) ?? 0;

    // Providers by type
    final List<Map<String, dynamic>> typeMaps = await db.rawQuery('''
      SELECT type, COUNT(*) as count
      FROM providers
      GROUP BY type
    ''');

    Map<String, int> providersByType = {};
    for (var map in typeMaps) {
      providersByType[map['type']] = map['count'];
    }

    return {
      'totalProviders': providerCount,
      'providersByType': providersByType,
    };
  }
}