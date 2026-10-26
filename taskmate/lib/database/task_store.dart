import '../models/task.dart';

/// The storage contract TaskMate uses.
///
/// Two implementations exist: sqflite on Android/iOS, and browser storage on
/// the web (sqflite has no web support). The screens never see either one -
/// they talk to DatabaseHelper, which forwards to whichever is compiled in.
abstract class TaskStore {
  Future<int> insertTask(Task task);

  Future<List<Task>> getTasks();

  Future<List<Task>> searchTasks(String keyword);

  Future<int> updateTask(Task task);

  Future<int> setTaskCompletion(int id, bool isCompleted);

  Future<int> deleteTask(int id);

  Future<void> close();
}
