import 'package:portfolio_plus/models/tag.dart';
import 'package:portfolio_plus/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class TagRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new tag
  Future<int> createTag(Tag tag) async {
    final db = await _databaseService.database;
    return await db.insert('tags', tag.toMap());
  }

  // Get all tags
  Future<List<Tag>> getAllTags() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      orderBy: 'type ASC, name ASC',
    );
    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  // Get tag by ID
  Future<Tag?> getTagById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Tag.fromMap(maps.first);
    }
    return null;
  }

  // Get tags by type
  Future<List<Tag>> getTagsByType(String type) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  // Update tag
  Future<int> updateTag(Tag tag) async {
    final db = await _databaseService.database;
    return await db.update(
      'tags',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  // Delete tag
  Future<int> deleteTag(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search tags by name
  Future<List<Tag>> searchTags(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'type ASC, name ASC',
    );
    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  // Get or create tag by name and type
  Future<Tag> getOrCreateTag(String name, String type) async {
    final db = await _databaseService.database;
    
    // Try to find existing tag
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
    );
    
    if (maps.isNotEmpty) {
      return Tag.fromMap(maps.first);
    }
    
    // Create new tag if not found
    final newTag = Tag(
      name: name,
      type: TagType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => TagType.custom,
      ),
    );
    
    final id = await db.insert('tags', newTag.toMap());
    return newTag.copyWith(id: id);
  }

  // Get popular tags (most used)
  Future<List<Tag>> getPopularTags({int limit = 10}) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, COUNT(pt.portfolioId) as usageCount
      FROM tags t
      INNER JOIN portfolio_tags pt ON t.id = pt.tagId
      GROUP BY t.id
      ORDER BY usageCount DESC
      LIMIT ?
    ''', [limit]);
    
    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  // Get unused tags
  Future<List<Tag>> getUnusedTags() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM tags t
      LEFT JOIN portfolio_tags pt ON t.id = pt.tagId
      WHERE pt.tagId IS NULL
      ORDER BY t.type ASC, t.name ASC
    ''');
    
    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  // Get tag statistics
  Future<Map<String, dynamic>> getTagStatistics() async {
    final db = await _databaseService.database;
    
    // Total tags count
    final tagCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tags')
    ) ?? 0;
    
    // Tags by type
    final List<Map<String, dynamic>> typeMaps = await db.rawQuery('''
      SELECT type, COUNT(*) as count 
      FROM tags 
      GROUP BY type
    ''');
    
    Map<String, int> tagsByType = {};
    for (var map in typeMaps) {
      tagsByType[map['type']] = map['count'];
    }
    
    // Used tags count
    final usedTagsCount = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(DISTINCT tagId) FROM portfolio_tags
      ''')
    ) ?? 0;
    
    return {
      'totalTags': tagCount,
      'tagsByType': tagsByType,
      'usedTags': usedTagsCount,
      'unusedTags': tagCount - usedTagsCount,
    };
  }

  // Clean up unused tags
  Future<int> cleanupUnusedTags() async {
    final db = await _databaseService.database;
    return await db.rawQuery('''
      DELETE FROM tags 
      WHERE id NOT IN (SELECT DISTINCT tagId FROM portfolio_tags)
    ''').then((value) => value.length);
  }

  // Get tags for portfolio (already in portfolio_repository, but keeping here for completeness)
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
}