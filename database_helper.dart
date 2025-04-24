import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grades.db');
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        course_name TEXT,
        semester_no TEXT,
        credit_hours TEXT,
        marks TEXT,
        grade TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertGrade(Map<String, dynamic> grade) async {
    final db = await instance.database;
    return await db.insert('grades', grade);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedGrades() async {
    final db = await instance.database;
    return await db.query(
      'grades',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getAllGrades() async {
    final db = await instance.database;
    return await db.query('grades');
  }

  Future<int> updateGradeSyncStatus(int id) async {
    final db = await instance.database;
    return await db.update(
      'grades',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGrade(int id) async {
    final db = await instance.database;
    return await db.delete(
      'grades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}