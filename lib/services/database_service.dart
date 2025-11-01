import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'portfolio_plus.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create portfolios table
    await db.execute('''
      CREATE TABLE portfolios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        investmentType TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        tags TEXT
      )
    ''');

    // Create assets table
    await db.execute('''
      CREATE TABLE assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        currentPrice REAL NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        portfolioId INTEGER NOT NULL,
        assetId INTEGER,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (portfolioId) REFERENCES portfolios (id) ON DELETE CASCADE,
        FOREIGN KEY (assetId) REFERENCES assets (id) ON DELETE SET NULL
      )
    ''');

    // Create tags table
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Create portfolio_tags junction table
    await db.execute('''
      CREATE TABLE portfolio_tags (
        portfolioId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        PRIMARY KEY (portfolioId, tagId),
        FOREIGN KEY (portfolioId) REFERENCES portfolios (id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_transactions_portfolioId ON transactions(portfolioId)');
    await db.execute('CREATE INDEX idx_transactions_assetId ON transactions(assetId)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_assets_symbol ON assets(symbol)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here when needed
    // For now, we'll recreate tables (this will lose data in production)
    // In a real app, you'd want to migrate data properly
    if (oldVersion < newVersion) {
      // Example of how to handle upgrades:
      // await db.execute('ALTER TABLE portfolios ADD COLUMN newColumn TEXT');
    }
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  // Reset the database (for development/testing)
  Future<void> reset() async {
    final db = await database;
    await db.close();
    _database = null;
    
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'portfolio_plus.db');
    
    await deleteDatabase(path);
    _database = await _initDatabase();
  }
}