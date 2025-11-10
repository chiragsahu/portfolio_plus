import 'package:portfolio_plus/models/account.dart';
import 'package:portfolio_plus/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class AccountRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new account
  Future<int> createAccount(AccountModel account) async {
    final db = await _databaseService.database;
    return await db.insert('accounts', account.toMap());
  }

  // Get all accounts
  Future<List<AccountModel>> getAllAccounts() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return AccountModel.fromMap(maps[i]);
    });
  }

  // Get account by ID
  Future<AccountModel?> getAccountById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    }
    return null;
  }

  // Update account
  Future<int> updateAccount(AccountModel account) async {
    final db = await _databaseService.database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  // Delete account
  Future<int> deleteAccount(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get accounts by provider ID
  Future<List<AccountModel>> getAccountsByProviderId(int providerId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'providerId = ?',
      whereArgs: [providerId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return AccountModel.fromMap(maps[i]);
    });
  }

  // Get sub-accounts by parent account ID
  Future<List<AccountModel>> getSubAccounts(int parentAccountId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'parentAccountId = ?',
      whereArgs: [parentAccountId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return AccountModel.fromMap(maps[i]);
    });
  }

  // Get top-level accounts (no parent)
  Future<List<AccountModel>> getTopLevelAccounts() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'parentAccountId IS NULL',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return AccountModel.fromMap(maps[i]);
    });
  }

  // Search accounts by name
  Future<List<AccountModel>> searchAccounts(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return AccountModel.fromMap(maps[i]);
    });
  }

  // Get account statistics
  Future<Map<String, dynamic>> getAccountStatistics() async {
    final db = await _databaseService.database;

    // Total accounts count
    final accountCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM accounts')
    ) ?? 0;

    // Accounts by provider
    final List<Map<String, dynamic>> providerMaps = await db.rawQuery('''
      SELECT providerId, COUNT(*) as count
      FROM accounts
      GROUP BY providerId
    ''');

    Map<int, int> accountsByProvider = {};
    for (var map in providerMaps) {
      accountsByProvider[map['providerId']] = map['count'];
    }

    // Sub-accounts count
    final subAccountCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM accounts WHERE parentAccountId IS NOT NULL')
    ) ?? 0;

    return {
      'totalAccounts': accountCount,
      'accountsByProvider': accountsByProvider,
      'subAccountCount': subAccountCount,
    };
  }

  // Get accounts with provider details (join query)
  Future<List<Map<String, dynamic>>> getAccountsWithProviderDetails() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, p.name as providerName, p.type as providerType
      FROM accounts a
      LEFT JOIN providers p ON a.providerId = p.id
      ORDER BY p.name ASC, a.name ASC
    ''');
    return maps;
  }
}