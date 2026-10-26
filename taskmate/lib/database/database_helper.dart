import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String _dbName = 'taskmate.db';
  static const int _dbVersion = 1;
  static const String tableName = 'tasks';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colSubject = 'subject';
  static const String colPriority = 'priority';
  static const String colDueDate = 'due_date';
  static const String colIsCompleted = 'is_completed';
  static const String colCreatedAt = 'created_at';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTitle TEXT NOT NULL,
        $colDescription TEXT NOT NULL,
        $colSubject TEXT NOT NULL,
        $colPriority TEXT NOT NULL,
        $colDueDate TEXT NOT NULL,
        $colIsCompleted INTEGER NOT NULL DEFAULT 0,
        $colCreatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query(
      tableName,
      orderBy: '$colDueDate ASC, $colPriority DESC',
    );
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<List<Task>> searchTasks(String keyword) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: '$colTitle LIKE ? OR $colDescription LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: '$colDueDate ASC',
    );
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      tableName,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> setTaskCompletion(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      tableName,
      {colIsCompleted: isCompleted ? 1 : 0},
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
