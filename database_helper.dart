import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('donors.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE donors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        password TEXT NOT NULL,
        cnic TEXT NOT NULL,
        blood_group TEXT NOT NULL,
        city TEXT NOT NULL,
        gender TEXT NOT NULL,
        age INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<int> insertDonor(Map<String, dynamic> donor) async {
    final db = await instance.database;
    return await db.insert('donors', donor);
  }

  Future<List<Map<String, dynamic>>> getDonors() async {
    final db = await instance.database;
    return await db.query('donors');
  }

  Future<int> deleteDonor(int id) async {
    final db = await instance.database;
    return await db.delete('donors', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}


