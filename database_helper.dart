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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentname TEXT,
        fathername TEXT,
        progname TEXT,
        shift TEXT,
        rollno TEXT,
        coursecode TEXT,
        coursetitle TEXT,
        credithours REAL,
        obtainedmarks REAL,
        mysemester TEXT,
        consider_status TEXT,
        UNIQUE(rollno, coursecode) ON CONFLICT REPLACE
      )
    ''');
  }

  Future<int> insertGrade(Map<String, dynamic> grade) async {
    final db = await instance.database;
    return await db.insert('grades', grade);
  }

  Future<List<Map<String, dynamic>>> getAllGrades() async {
    final db = await instance.database;
    return await db.query('grades', orderBy: 'mysemester ASC, coursetitle ASC');
  }

  Future<List<Map<String, dynamic>>> getGradesByStudent(String rollNo) async {
    final db = await instance.database;
    return await db.query(
      'grades',
      where: 'rollno = ?',
      whereArgs: [rollNo],
      orderBy: 'mysemester ASC, coursetitle ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getUniqueStudents() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT DISTINCT 
        studentname, fathername, progname, shift, rollno 
      FROM grades
      ORDER BY studentname ASC
    ''');
  }

  Future<int> deleteGrade(String gradeId) async {
    final db = await instance.database;
    return await db.delete(
      'grades',
      where: 'rollno || coursecode = ?',
      whereArgs: [gradeId],
    );
  }

  Future<int> deleteAllGrades() async {
    final db = await instance.database;
    return await db.delete('grades');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
