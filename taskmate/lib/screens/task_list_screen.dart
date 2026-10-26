import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      List<Task> data;
      if (_searchQuery.trim().isEmpty) {
        data = await DatabaseHelper.instance.getTasks();
      } else {
        data = await DatabaseHelper.instance.searchTasks(_searchQuery.trim());
      }
      setState(() {
        _tasks = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleCompletion(Task task, bool? completed) async {
    if (task.id == null || completed == null) return;
    await DatabaseHelper.instance.setTaskCompletion(task.id!, completed);
    await _loadTasks();
  }

  Future<void> _editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskFormScreen(taskToEdit: task)),
    );
    if (result == true) _loadTasks();
  }

  Future<void> _confirmDelete(Task task) async {
    if (task.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteTask(task.id!);
      _loadTasks();
    }
  }

  List<Task> get _filteredTasks {
    return _tasks.where((t) {
      if (_selectedFilter == 'Pending') return !t.completed;
      if (_selectedFilter == 'Completed') return t.completed;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedTasks = _filteredTasks;
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks by title...',
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); _loadTasks(); }) : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (val) { setState(() => _searchQuery = val); _loadTasks(); },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['All', 'Pending', 'Completed'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: Colors.indigo.shade100,
                    checkmarkColor: Colors.indigo,
                    onSelected: (val) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                : displayedTasks.isEmpty
                    ? Center(child: Text('No tasks found.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)))
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        color: Colors.indigo,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: displayedTasks.length,
                          itemBuilder: (context, index) {
                            final task = displayedTasks[index];
                            return TaskCard(
                              task: task,
                              onCheckboxChanged: (val) => _toggleCompletion(task, val),
                              onEdit: () => _editTask(task),
                              onDelete: () => _confirmDelete(task),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
