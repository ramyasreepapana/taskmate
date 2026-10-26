import 'dart:async';

import '../models/task.dart';
import 'task_store.dart';
// The compiler picks ONE of these. On Android it takes the sqflite file, so
// sqflite is never compiled into the web bundle - which matters, because the
// plugin has no web implementation at all.
import 'task_store_stub.dart'
    if (dart.library.io) 'task_store_sqflite.dart'
    if (dart.library.js_interop) 'task_store_web.dart';

/// Unchanged public API. Every screen still calls DatabaseHelper.instance and
/// the same seven methods; only what sits behind them changed.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  final TaskStore _store = createStore();

  static const String tableName = 'tasks';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colSubject = 'subject';
  static const String colPriority = 'priority';
  static const String colDueDate = 'due_date';
  static const String colIsCompleted = 'is_completed';
  static const String colCreatedAt = 'created_at';

  Future<int> insertTask(Task task) => _store.insertTask(task);

  Future<List<Task>> getTasks() => _store.getTasks();

  Future<List<Task>> searchTasks(String keyword) => _store.searchTasks(keyword);

  Future<int> updateTask(Task task) => _store.updateTask(task);

  Future<int> setTaskCompletion(int id, bool isCompleted) =>
      _store.setTaskCompletion(id, isCompleted);

  Future<int> deleteTask(int id) => _store.deleteTask(id);

  Future<void> close() => _store.close();
}
