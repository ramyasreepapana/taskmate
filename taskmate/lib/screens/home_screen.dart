import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToTasks;
  const HomeScreen({super.key, required this.onNavigateToTasks});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await DatabaseHelper.instance.getTasks();
      setState(() { _tasks = tasks; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  int get _totalTasks => _tasks.length;
  int get _completedTasks => _tasks.where((t) => t.completed).length;
  int get _pendingTasks => _tasks.where((t) => !t.completed).length;

  int get _overdueTasks {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _tasks.where((t) {
      if (t.completed) return false;
      try {
        final due = DateTime.parse(t.dueDate);
        return due.isBefore(startOfToday);
      } catch (_) {
        return false;
      }
    }).length;
  }

  List<Task> get _upcomingDeadlines {
    final pending = _tasks.where((t) => !t.completed).toList();
    pending.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return pending.take(5).toList();
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMate'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh Dashboard', onPressed: loadDashboardData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              color: Colors.indigo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.indigo.shade600, Colors.indigo.shade900]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 24, backgroundColor: Colors.white24, child: Icon(Icons.school, color: Colors.white, size: 28)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Welcome, Student!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(_pendingTasks == 0 ? 'All caught up! Excellent work.' : 'You have $_pendingTasks pending tasks.', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Task Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildStatCard('Total Tasks', _totalTasks, Icons.assignment, Colors.indigo),
                              const SizedBox(width: 12),
                              _buildStatCard('Pending', _pendingTasks, Icons.pending_actions, Colors.orange.shade800),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStatCard('Completed', _completedTasks, Icons.check_circle_outline, Colors.green.shade700),
                              const SizedBox(width: 12),
                              _buildStatCard('Overdue', _overdueTasks, Icons.warning_amber_rounded, Colors.red.shade700),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Upcoming Deadlines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          TextButton(onPressed: widget.onNavigateToTasks, child: const Text('View All')),
                        ],
                      ),
                    ),
                    if (_upcomingDeadlines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Center(child: Text('No pending deadlines right now!', style: TextStyle(color: Colors.grey.shade600))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _upcomingDeadlines.length,
                        itemBuilder: (context, index) {
                          final task = _upcomingDeadlines[index];
                          return TaskCard(
                            task: task,
                            onCheckboxChanged: (val) async {
                              if (task.id != null && val != null) {
                                await DatabaseHelper.instance.setTaskCompletion(task.id!, val);
                                loadDashboardData();
                              }
                            },
                            onEdit: () async {
                              final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => TaskFormScreen(taskToEdit: task)));
                              if (res == true) loadDashboardData();
                            },
                            onDelete: () async {
                              if (task.id == null) return;
                              await DatabaseHelper.instance.deleteTask(task.id!);
                              loadDashboardData();
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }
}
