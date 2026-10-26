import 'task_store.dart';

/// Never reached in a real build. The conditional import in
/// database_helper.dart needs a default, and this is it.
TaskStore createStore() =>
    throw UnsupportedError('No TaskStore implementation for this platform.');
