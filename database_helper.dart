// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('donors.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//     );
//   }
//
//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE donors (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         email TEXT NOT NULL,
//         phone TEXT NOT NULL,
//         blood_group TEXT NOT NULL,
//         city TEXT,
//         gender TEXT,
//         age INTEGER,
//         is_synced INTEGER DEFAULT 0
//       )
//     ''');
//   }
//
//   Future<int> insertDonor(Map<String, dynamic> donor) async {
//     final db = await instance.database;
//     return await db.insert('donors', donor);
//   }
//
//   Future<List<Map<String, dynamic>>> getUnsyncedDonors() async {
//     final db = await instance.database;
//     return await db.query(
//       'donors',
//       where: 'is_synced = ?',
//       whereArgs: [0],
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getAllDonors() async {
//     final db = await instance.database;
//     return await db.query('donors');
//   }
//
//   Future<int> updateDonorSyncStatus(int id) async {
//     final db = await instance.database;
//     return await db.update(
//       'donors',
//       {'is_synced': 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future<int> deleteDonor(int id) async {
//     final db = await instance.database;
//     return await db.delete(
//       'donors',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }


//
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   // Increment version number to trigger migration
//   static const int _databaseVersion = 2;
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('donors.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: _createDB,
//       onUpgrade: _upgradeDB, // Add migration handler
//     );
//   }
//
//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE donors (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         email TEXT NOT NULL,
//         phone TEXT NOT NULL,
//         blood_group TEXT NOT NULL,
//         city TEXT,
//         gender TEXT,
//         age INTEGER,
//         is_synced INTEGER DEFAULT 0
//       )
//     ''');
//   }
//
//   // Handle database upgrades
//   Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 2) {
//       // Migration from version 1 to 2
//       await db.execute('ALTER TABLE donors ADD COLUMN city TEXT');
//       await db.execute('ALTER TABLE donors ADD COLUMN gender TEXT');
//       await db.execute('ALTER TABLE donors ADD COLUMN age INTEGER');
//     }
//     // Add more migration steps here if you increment version further
//   }
//
//   Future<int> insertDonor(Map<String, dynamic> donor) async {
//     final db = await instance.database;
//     return await db.insert('donors', donor);
//   }
//
//   Future<List<Map<String, dynamic>>> getUnsyncedDonors() async {
//     final db = await instance.database;
//     return await db.query(
//       'donors',
//       where: 'is_synced = ?',
//       whereArgs: [0],
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getAllDonors() async {
//     final db = await instance.database;
//     return await db.query('donors');
//   }
//
//   Future<int> updateDonorSyncStatus(int id) async {
//     final db = await instance.database;
//     return await db.update(
//       'donors',
//       {'is_synced': 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future<int> deleteDonor(int id) async {
//     final db = await instance.database;
//     return await db.delete(
//       'donors',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }





// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   // Incremented version to trigger migration
//   static const int _databaseVersion = 2;
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('donors.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: _createDB,
//       onUpgrade: _upgradeDB,
//     );
//   }
//
//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE donors (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         email TEXT NOT NULL,
//         phone TEXT NOT NULL,
//         blood_group TEXT NOT NULL,
//         city TEXT,
//         gender TEXT,
//         age INTEGER,
//         is_synced INTEGER DEFAULT 0
//       )
//     ''');
//   }
//
//   Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 2) {
//       await db.execute('ALTER TABLE donors ADD COLUMN city TEXT');
//       await db.execute('ALTER TABLE donors ADD COLUMN gender TEXT');
//       await db.execute('ALTER TABLE donors ADD COLUMN age INTEGER');
//     }
//   }
//
//   Future<int> insertDonor(Map<String, dynamic> donor) async {
//     final db = await instance.database;
//     return await db.insert('donors', donor);
//   }
//
//   Future<List<Map<String, dynamic>>> getUnsyncedDonors() async {
//     final db = await instance.database;
//     return await db.query(
//       'donors',
//       where: 'is_synced = ?',
//       whereArgs: [0],
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getAllDonors() async {
//     final db = await instance.database;
//     return await db.query('donors');
//   }
//
//   Future<int> updateDonorSyncStatus(int id) async {
//     final db = await instance.database;
//     return await db.update(
//       'donors',
//       {'is_synced': 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future<int> deleteDonor(int id) async {
//     final db = await instance.database;
//     return await db.delete(
//       'donors',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }



import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const int _databaseVersion = 3; // Incremented version

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
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE donors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        blood_group TEXT NOT NULL,
        city TEXT,
        gender TEXT,
        age INTEGER,
        is_synced INTEGER DEFAULT 0,
        sync_attempts INTEGER DEFAULT 0,
        last_sync_attempt INTEGER
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE donors ADD COLUMN city TEXT');
      await db.execute('ALTER TABLE donors ADD COLUMN gender TEXT');
      await db.execute('ALTER TABLE donors ADD COLUMN age INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE donors ADD COLUMN sync_attempts INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE donors ADD COLUMN last_sync_attempt INTEGER');
    }
  }

  Future<int> insertDonor(Map<String, dynamic> donor) async {
    final db = await instance.database;
    return await db.insert('donors', donor);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedDonors() async {
    final db = await instance.database;
    return await db.query(
      'donors',
      where: 'is_synced = ? AND sync_attempts < 5',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getAllDonors() async {
    final db = await instance.database;
    return await db.query('donors');
  }

  Future<int> updateDonorSyncStatus(int id) async {
    final db = await instance.database;
    return await db.update(
      'donors',
      {
        'is_synced': 1,
        'sync_attempts': 0,
        'last_sync_attempt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> recordSyncAttempt(int id) async {
    final db = await instance.database;
    return await db.rawUpdate('''
      UPDATE donors 
      SET sync_attempts = sync_attempts + 1,
          last_sync_attempt = ?
      WHERE id = ?
    ''', [DateTime.now().millisecondsSinceEpoch, id]);
  }

  Future<int> deleteDonor(int id) async {
    final db = await instance.database;
    return await db.delete(
      'donors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}