import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_store.dart';

TaskStore createStore() => WebTaskStore();

/// Browser version of the task store.
///
/// sqflite is an Android/iOS plugin with no web implementation, so on the web
/// the same tasks are kept as JSON in the browser's own storage. Every method
/// matches the SQLite one - including the sort order and the LIKE search - so
/// the screens behave identically on both platforms.
class WebTaskStore implements TaskStore {
  static const String _storageKey = 'taskmate.tasks';

  List<Map<String, dynamic>>? _rows;
  int _nextId = 1;

  Future<void> _load() async {
    if (_rows != null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);

      if (raw == null || raw.isEmpty) {
        _rows = <Map<String, dynamic>>[];
        return;
      }

      final Map<String, dynamic> document =
          jsonDecode(raw) as Map<String, dynamic>;

      _rows = (document['tasks'] as List<dynamic>)
          .map((dynamic row) => Map<String, dynamic>.from(row as Map))
          .toList();
      _nextId = (document['nextId'] as int?) ?? _rows!.length + 1;
    } catch (_) {
      // Corrupt or blocked storage should not stop the app opening.
      _rows = <Map<String, dynamic>>[];
    }
  }

  Future<void> _save() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(<String, dynamic>{'nextId': _nextId, 'tasks': _rows}),
      );
    } catch (_) {
      // Private windows and full storage both throw here. The in-memory list
      // is still correct for this session.
    }
  }

  /// SQLite's "ORDER BY due_date ASC, priority DESC", done in Dart.
  int _compare(Map<String, dynamic> a, Map<String, dynamic> b) {
    final int byDate =
        (a['due_date'] as String).compareTo(b['due_date'] as String);
    if (byDate != 0) return byDate;
    return (b['priority'] as String).compareTo(a['priority'] as String);
  }

  @override
  Future<int> insertTask(Task task) async {
    await _load();

    final Map<String, dynamic> row = task.toMap();
    final int id = (row['id'] as int?) ?? _nextId;

    // Matches ConflictAlgorithm.replace: an existing id overwrites its row.
    _rows!.removeWhere((Map<String, dynamic> existing) => existing['id'] == id);

    row['id'] = id;
    _rows!.add(row);
    if (id >= _nextId) _nextId = id + 1;

    await _save();
    return id;
  }

  @override
  Future<List<Task>> getTasks() async {
    await _load();

    final List<Map<String, dynamic>> sorted =
        List<Map<String, dynamic>>.from(_rows!)..sort(_compare);
    return sorted.map(Task.fromMap).toList();
  }

  @override
  Future<List<Task>> searchTasks(String keyword) async {
    await _load();

    final String term = keyword.toLowerCase();

    final List<Map<String, dynamic>> found = _rows!
        .where((Map<String, dynamic> row) =>
            (row['title'] as String).toLowerCase().contains(term) ||
            (row['description'] as String).toLowerCase().contains(term))
        .toList()
      ..sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
          (a['due_date'] as String).compareTo(b['due_date'] as String));

    return found.map(Task.fromMap).toList();
  }

  @override
  Future<int> updateTask(Task task) async {
    await _load();

    final int index = _rows!
        .indexWhere((Map<String, dynamic> row) => row['id'] == task.id);
    if (index == -1) return 0;

    final Map<String, dynamic> row = task.toMap();
    row['id'] = task.id;
    _rows![index] = row;

    await _save();
    return 1;
  }

  @override
  Future<int> setTaskCompletion(int id, bool isCompleted) async {
    await _load();

    final int index =
        _rows!.indexWhere((Map<String, dynamic> row) => row['id'] == id);
    if (index == -1) return 0;

    _rows![index]['is_completed'] = isCompleted ? 1 : 0;

    await _save();
    return 1;
  }

  @override
  Future<int> deleteTask(int id) async {
    await _load();

    final int before = _rows!.length;
    _rows!.removeWhere((Map<String, dynamic> row) => row['id'] == id);

    await _save();
    return before - _rows!.length;
  }

  @override
  Future<void> close() async {
    await _save();
  }
}
