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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Portfolios
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
  
    // 2. Assets (with ISIN)
    await db.execute('''
      CREATE TABLE assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        isin TEXT,
        currentPrice REAL NOT NULL,
        lastUpdated TEXT NOT NULL,
        assetClass TEXT NOT NULL,
        providerSymbol TEXT,
        faceValue REAL,
        series TEXT
      )
    ''');
  
    // 3. Providers
    await db.execute('''
      CREATE TABLE providers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        metadata TEXT
      )
    ''');

    // 4. Accounts
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        providerId INTEGER NOT NULL,
        name TEXT NOT NULL,
        parentAccountId INTEGER,
        baseCurrency TEXT,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (providerId) REFERENCES providers (id) ON DELETE CASCADE,
        FOREIGN KEY (parentAccountId) REFERENCES accounts (id) ON DELETE SET NULL
      )
    ''');

    // 5. Holdings (The Snapshot Layer)
    await db.execute('''
      CREATE TABLE holdings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        portfolioId INTEGER NOT NULL,
        accountId INTEGER NOT NULL,
        assetId INTEGER NOT NULL,
        totalQuantity REAL NOT NULL DEFAULT 0,
        averagePrice REAL NOT NULL DEFAULT 0,
        lastUpdated TEXT NOT NULL,
        FOREIGN KEY (portfolioId) REFERENCES portfolios (id) ON DELETE CASCADE,
        FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (assetId) REFERENCES assets (id) ON DELETE CASCADE,
        UNIQUE(portfolioId, accountId, assetId)
      )
    ''');
  
    // 6. Transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        portfolioId INTEGER NOT NULL,
        accountId INTEGER,
        assetId INTEGER,
        holdingId INTEGER,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        amount REAL NOT NULL,
        fee REAL,
        feeCurrency TEXT,
        quoteCurrency TEXT,
        tradeId TEXT,
        realizedPnLPerTx REAL,
        date TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (portfolioId) REFERENCES portfolios (id) ON DELETE CASCADE,
        FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE SET NULL,
        FOREIGN KEY (assetId) REFERENCES assets (id) ON DELETE SET NULL,
        FOREIGN KEY (holdingId) REFERENCES holdings (id) ON DELETE SET NULL
      )
    ''');
  
    // --- TRIGGERS ---

    // Trigger: Sync holdingId on transaction insert if not provided
    await db.execute('''
      CREATE TRIGGER trg_transactions_link_holding
      AFTER INSERT ON transactions
      WHEN NEW.holdingId IS NULL
      BEGIN
        INSERT OR IGNORE INTO holdings (portfolioId, accountId, assetId, lastUpdated)
        VALUES (NEW.portfolioId, NEW.accountId, NEW.assetId, NEW.createdAt);

        UPDATE transactions 
        SET holdingId = (SELECT id FROM holdings WHERE portfolioId = NEW.portfolioId AND accountId = NEW.accountId AND assetId = NEW.assetId)
        WHERE id = NEW.id;
      END;
    ''');

    // Trigger: Update totalQuantity on Insert
    await db.execute('''
      CREATE TRIGGER trg_update_holding_on_insert
      AFTER INSERT ON transactions
      BEGIN
        UPDATE holdings 
        SET totalQuantity = totalQuantity + (
          CASE WHEN NEW.type IN ('buy', 'deposit') THEN NEW.quantity 
               WHEN NEW.type IN ('sell', 'withdrawal') THEN -NEW.quantity 
               ELSE 0 END
        ),
        lastUpdated = NEW.createdAt
        WHERE id = (SELECT holdingId FROM transactions WHERE id = NEW.id);
      END;
    ''');

    // Trigger: Update totalQuantity on Delete
    await db.execute('''
      CREATE TRIGGER trg_update_holding_on_delete
      AFTER DELETE ON transactions
      BEGIN
        UPDATE holdings 
        SET totalQuantity = totalQuantity - (
          CASE WHEN OLD.type IN ('buy', 'deposit') THEN OLD.quantity 
               WHEN OLD.type IN ('sell', 'withdrawal') THEN -OLD.quantity 
               ELSE 0 END
        ),
        lastUpdated = strftime('%Y-%m-%dT%H:%M:%f', 'now')
        WHERE id = OLD.holdingId;
      END;
    ''');

    // --- OTHER TABLES ---

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  
    await db.execute('''
      CREATE TABLE portfolio_tags (
        portfolioId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        PRIMARY KEY (portfolioId, tagId),
        FOREIGN KEY (portfolioId) REFERENCES portfolios (id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
 
    await db.execute('''
      CREATE TABLE fx_rates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromCurrency TEXT NOT NULL,
        toCurrency TEXT NOT NULL,
        rate REAL NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
 
    await db.execute('''
      CREATE TABLE scopes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        filters TEXT NOT NULL,
        baseCurrency TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
 
    await db.execute('''
      CREATE TABLE portfolio_scopes (
        portfolioId INTEGER NOT NULL,
        scopeId INTEGER NOT NULL,
        PRIMARY KEY (portfolioId, scopeId),
        FOREIGN KEY (portfolioId) REFERENCES portfolios (id) ON DELETE CASCADE,
        FOREIGN KEY (scopeId) REFERENCES scopes (id) ON DELETE CASCADE
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX idx_transactions_portfolioId ON transactions(portfolioId)');
    await db.execute('CREATE INDEX idx_transactions_accountId ON transactions(accountId)');
    await db.execute('CREATE INDEX idx_transactions_assetId ON transactions(assetId)');
    await db.execute('CREATE INDEX idx_transactions_holdingId ON transactions(holdingId)');
    await db.execute('CREATE INDEX idx_assets_symbol ON assets(symbol)');
    await db.execute('CREATE UNIQUE INDEX idx_providers_name ON providers(name)');
    await db.execute('CREATE INDEX idx_accounts_providerId ON accounts(providerId)');
    await db.execute('CREATE INDEX idx_fx_rates_pair_date ON fx_rates(fromCurrency, toCurrency, date)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here when needed
    // IMPORTANT: Perform additive migrations; do not drop existing data.
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS fx_rates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fromCurrency TEXT NOT NULL,
          toCurrency TEXT NOT NULL,
          rate REAL NOT NULL,
          date TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_fx_rates_pair_date ON fx_rates(fromCurrency, toCurrency, date)');
    }

    if (oldVersion < 3) {
      // Providers
      await db.execute('''
        CREATE TABLE IF NOT EXISTS providers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          metadata TEXT
        )
      ''');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_providers_name ON providers(name)');

      // Accounts (with self-referencing parentAccountId)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          providerId INTEGER NOT NULL,
          name TEXT NOT NULL,
          parentAccountId INTEGER,
          baseCurrency TEXT,
          metadata TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (providerId) REFERENCES providers (id) ON DELETE CASCADE,
          FOREIGN KEY (parentAccountId) REFERENCES accounts (id) ON DELETE SET NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_accounts_providerId ON accounts(providerId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_accounts_parentAccountId ON accounts(parentAccountId)');

      // Extend transactions table with new fields
      await db.execute('ALTER TABLE transactions ADD COLUMN accountId INTEGER REFERENCES accounts(id)');
      await db.execute('ALTER TABLE transactions ADD COLUMN fee REAL');
      await db.execute('ALTER TABLE transactions ADD COLUMN feeCurrency TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN quoteCurrency TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN tradeId TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN realizedPnLPerTx REAL');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_accountId ON transactions(accountId)');

      // Extend assets table with new fields
      await db.execute('ALTER TABLE assets ADD COLUMN assetClass TEXT NOT NULL DEFAULT \'stock\'');
      await db.execute('ALTER TABLE assets ADD COLUMN providerSymbol TEXT');

      // Scopes (Lenses)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS scopes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          filters TEXT NOT NULL,
          baseCurrency TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      // Portfolio-Scopes join
      await db.execute('''
        CREATE TABLE IF NOT EXISTS portfolio_scopes (
          portfolioId INTEGER NOT NULL,
          scopeId INTEGER NOT NULL,
          PRIMARY KEY (portfolioId, scopeId),
          FOREIGN KEY (portfolioId) REFERENCES portfolios (id) ON DELETE CASCADE,
          FOREIGN KEY (scopeId) REFERENCES scopes (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE assets ADD COLUMN faceValue REAL');
      await db.execute('ALTER TABLE assets ADD COLUMN series TEXT');
    }
  }

  // Reconcile holdings (Self-healing mechanism)
  Future<void> reconcileHoldings() async {
    final db = await database;
    
    await db.transaction((txn) async {
      // 1. Get correct totals from transaction history
      final List<Map<String, dynamic>> results = await txn.rawQuery('''
        SELECT 
          portfolioId, 
          accountId, 
          assetId, 
          SUM(CASE WHEN type IN ('buy', 'deposit') THEN quantity 
                   WHEN type IN ('sell', 'withdrawal') THEN -quantity 
                   ELSE 0 END) as actualQty,
          MAX(createdAt) as lastTxDate
        FROM transactions
        GROUP BY portfolioId, accountId, assetId
      ''');

      // 2. Update holdings table
      for (var row in results) {
        await txn.insert(
          'holdings',
          {
            'portfolioId': row['portfolioId'],
            'accountId': row['accountId'],
            'assetId': row['assetId'],
            'totalQuantity': row['actualQty'],
            'lastUpdated': row['lastTxDate'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 3. Optional: Remove holdings that no longer have transactions
      // (This prevents "ghost" holdings from cluttering the UI)
      await txn.execute('''
        DELETE FROM holdings 
        WHERE NOT EXISTS (
          SELECT 1 FROM transactions t 
          WHERE t.portfolioId = holdings.portfolioId 
          AND t.accountId = holdings.accountId 
          AND t.assetId = holdings.assetId
        )
      ''');
    });
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