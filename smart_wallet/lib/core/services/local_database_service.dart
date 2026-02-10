import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Servicio de base de datos local SQLite para persistir datos dummy
class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;
  static bool _initialized = false;

  /// Inicializar el factory de base de datos para Windows/Desktop
  static Future<void> initializeDatabaseFactory() async {
    if (_initialized) return;
    
    // Para Windows, Linux y macOS usar sqflite_common_ffi
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Inicializar FFI
      sqfliteFfiInit();
      // Establecer el factory para usar FFI
      databaseFactory = databaseFactoryFfi;
      print('✅ DatabaseFactory inicializado para plataforma desktop');
    }
    // Para Android e iOS, sqflite funciona nativamente
    // No necesita inicialización adicional
    
    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Asegurar que el factory esté inicializado
    await initializeDatabaseFactory();
    
    String dbPath;
    
    // Obtener la ruta de la base de datos según la plataforma
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Para desktop, usar path_provider para obtener el directorio de documentos
      final documentsDirectory = await getApplicationDocumentsDirectory();
      dbPath = join(documentsDirectory.path, 'smart_wallet_dummy.db');
    } else {
      // Para móvil, usar getDatabasesPath() de sqflite
      final dbDir = await getDatabasesPath();
      dbPath = join(dbDir, 'smart_wallet_dummy.db');
    }

    print('🗄️ Abriendo base de datos en: $dbPath');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de transacciones
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de metas
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL,
        deadline TEXT NOT NULL,
        description TEXT,
        status TEXT
      )
    ''');

    // Tabla de recordatorios
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        due_date TEXT NOT NULL,
        amount REAL,
        is_recurring INTEGER NOT NULL,
        recurrence_type TEXT,
        reminder_days INTEGER,
        status TEXT
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_transactions_created_at ON transactions(created_at)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_goals_status ON goals(status)');
    await db.execute('CREATE INDEX idx_reminders_due_date ON reminders(due_date)');
  }

  // ==================== TRANSACCIONES ====================

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query(
      'transactions',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getTransaction(String id) async {
    final db = await database;
    final results = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<String> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    await db.insert('transactions', transaction);
    return transaction['id'] as String;
  }

  Future<int> updateTransaction(String id, Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getTransactionsSummary() async {
    final db = await database;
    
    // Calcular ingresos
    final incomeResult = await db.rawQuery('''
      SELECT COALESCE(SUM(CAST(amount AS REAL)), 0) as total
      FROM transactions
      WHERE type = 'income'
    ''');
    final income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Calcular gastos
    final expenseResult = await db.rawQuery('''
      SELECT COALESCE(SUM(CAST(amount AS REAL)), 0) as total
      FROM transactions
      WHERE type = 'expense'
    ''');
    final expenses = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final balance = income - expenses;

    return {
      'balance': balance.toStringAsFixed(2),
      'income': income.toStringAsFixed(2),
      'expenses': expenses.toStringAsFixed(2),
    };
  }

  // ==================== METAS ====================

  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await database;
    return await db.query('goals', orderBy: 'deadline ASC');
  }

  Future<Map<String, dynamic>?> getGoal(String id) async {
    final db = await database;
    final results = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<String> insertGoal(Map<String, dynamic> goal) async {
    final db = await database;
    await db.insert('goals', goal);
    return goal['id'] as String;
  }

  Future<int> updateGoal(String id, Map<String, dynamic> goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGoal(String id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== RECORDATORIOS ====================

  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final db = await database;
    return await db.query('reminders', orderBy: 'due_date ASC');
  }

  Future<Map<String, dynamic>?> getReminder(String id) async {
    final db = await database;
    final results = await db.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<String> insertReminder(Map<String, dynamic> reminder) async {
    final db = await database;
    await db.insert('reminders', reminder);
    return reminder['id'] as String;
  }

  Future<int> updateReminder(String id, Map<String, dynamic> reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReminder(String id) async {
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getUpcomingReminders() async {
    final db = await database;
    final now = DateTime.now().toIso8601String().split('T')[0];
    return await db.query(
      'reminders',
      where: 'due_date >= ? AND status = ?',
      whereArgs: [now, 'pending'],
      orderBy: 'due_date ASC',
    );
  }

  // ==================== UTILIDADES ====================

  /// Limpiar todas las tablas (útil para resetear datos)
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('goals');
    await db.delete('reminders');
  }

  /// Cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Obtener conteo de registros
  Future<Map<String, int>> getCounts() async {
    final db = await database;
    final transactionsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM transactions'),
    ) ?? 0;
    final goalsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM goals'),
    ) ?? 0;
    final remindersCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM reminders'),
    ) ?? 0;

    return {
      'transactions': transactionsCount,
      'goals': goalsCount,
      'reminders': remindersCount,
    };
  }
}
