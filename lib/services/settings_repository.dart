// SettingsRepository to persist base currency and FX rates using sqflite

import 'package:portfolio_plus/services/database_service.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepository {
  final DatabaseService _databaseService = DatabaseService();

  static const String baseCurrencyKey = 'baseCurrency';

  Future<Currency> getBaseCurrency() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [baseCurrencyKey],
      limit: 1,
    );
    if (rows.isNotEmpty && rows.first['value'] is String) {
      return Currency.fromCode(rows.first['value'] as String);
    }
    // default to INR
    await setBaseCurrency(Currency.inr);
    return Currency.inr;
  }

  Future<void> setBaseCurrency(Currency currency) async {
    final db = await _databaseService.database;
    await db.insert(
      'app_settings',
      {'key': baseCurrencyKey, 'value': currency.code},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['value'] as String?;
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _databaseService.database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setFxRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    DateTime? date,
  }) async {
    final db = await _databaseService.database;
    final DateTime now = DateTime.now();
    final String dateStr = (date ?? DateTime(now.year, now.month, now.day)).toIso8601String().split('T').first;
    await db.insert('fx_rates', {
      'fromCurrency': fromCurrency.toUpperCase(),
      'toCurrency': toCurrency.toUpperCase(),
      'rate': rate,
      'date': dateStr,
      'createdAt': now.toIso8601String(),
    });
  }

  Future<double?> getLatestFxRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> rows = await db.query(
      'fx_rates',
      columns: ['rate', 'date', 'createdAt'],
      where: 'fromCurrency = ? AND toCurrency = ?',
      whereArgs: [fromCurrency.toUpperCase(), toCurrency.toUpperCase()],
      orderBy: 'date DESC, createdAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final num? r = rows.first['rate'] as num?;
    return r?.toDouble();
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> rows = await db.query('app_settings');
    final Map<String, String> map = {};
    for (final row in rows) {
      final key = row['key']?.toString();
      final value = row['value']?.toString();
      if (key != null && value != null) {
        map[key] = value;
      }
    }
    return map;
  }
}