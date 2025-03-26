import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'auth_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        is_logged_in INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> setLoggedInUser(String email) async {
    Database db = await instance.database;
    await db.transaction((txn) async {
      await txn.update('users', {'is_logged_in': 0});
      await txn.update(
        'users',
        {'is_logged_in': 1},
        where: 'email = ?',
        whereArgs: [email],
      );
    });
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    Database db = await instance.database;
    List<Map> maps = await db.query(
      'users',
      where: 'is_logged_in = 1',
    );
    if (maps.isNotEmpty) {
      return maps.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> logoutUser() async {
    Database db = await instance.database;
    await db.update('users', {'is_logged_in': 0});
  }

  Future<void> close() async {
    Database db = await instance.database;
    await db.close();
  }
}
