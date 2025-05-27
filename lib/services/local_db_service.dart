import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sms_phish_detective.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sms_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            address TEXT,
            body TEXT,
            date INTEGER,
            isAnalyzed INTEGER,
            isPhishing INTEGER,
            phishingScore REAL
          )
        ''');
      },
    );
  }

  static Future<int> insertSmsLog(Map<String, dynamic> msgMap) async {
    final db = await database;
    final sms = msgMap['sms'];
    return await db.insert('sms_logs', {
      'address': sms.address,
      'body': sms.body,
      'date': sms.date,
      'isAnalyzed': (msgMap['isAnalyzed'] ?? false) ? 1 : 0,
      'isPhishing': (msgMap['isPhishing'] ?? false) ? 1 : 0,
      'phishingScore': msgMap['phishingScore'],
    });
  }

  static Future<List<Map<String, dynamic>>> getAllSmsLogs() async {
    final db = await database;
    return await db.query('sms_logs', orderBy: 'date DESC');
  }

  static Future<void> clearAllLogs() async {
    final db = await database;
    await db.delete('sms_logs');
  }
}
