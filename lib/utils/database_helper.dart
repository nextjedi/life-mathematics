import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class CalculationHistory {
  final int? id;
  final String type;
  final String name;
  final String label;
  final bool isPinned;
  final DateTime timestamp;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> results;

  CalculationHistory({
    this.id,
    required this.type,
    required this.name,
    required this.label,
    required this.isPinned,
    required this.timestamp,
    required this.inputs,
    required this.results,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'label': label,
      'isPinned': isPinned ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'inputs': jsonEncode(inputs),
      'results': jsonEncode(results),
    };
  }

  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    return CalculationHistory(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      label: map['label'],
      isPinned: map['isPinned'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      inputs: jsonDecode(map['inputs']),
      results: jsonDecode(map['results']),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('life_mathematics.db');
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
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        label TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        timestamp TEXT NOT NULL,
        inputs TEXT NOT NULL,
        results TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertHistory(CalculationHistory history) async {
    final db = await database;
    return await db.insert('history', history.toMap());
  }

  Future<List<CalculationHistory>> getHistory() async {
    final db = await database;
    final result = await db.query(
      'history',
      orderBy: 'isPinned DESC, timestamp DESC',
    );
    return result.map((map) => CalculationHistory.fromMap(map)).toList();
  }

  Future<int> deleteHistory(int id) async {
    final db = await database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateHistoryPin(int id, bool isPinned) async {
    final db = await database;
    return await db.update(
      'history',
      {'isPinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('history');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
