import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProgressData();
  }

  Future<void> loadProgressData() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await DatabaseHelper.instance.getTasks();
      setState(() { _tasks = tasks; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  double get _completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    final completed = _tasks.where((t) => t.completed).length;
    return (completed / _tasks.length) * 100;
  }

  Map<String, List<Task>> get _tasksBySubject {
    final Map<String, List<Task>> grouped = {};
    for (final task in _tasks) {
      grouped.putIfAbsent(task.subject, () => []).add(task);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.completed).length;
    final pending = total - completed;
    final pct = _completionPercentage;

    return Scaffold(
      appBar: AppBar(title: const Text('Productivity & Progress'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : RefreshIndicator(
              onRefresh: loadProgressData,
              color: Colors.indigo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: CircularProgressIndicator(
                                    value: total == 0 ? 0 : (completed / total),
                                    strokeWidth: 10,
                                    backgroundColor: Colors.grey.shade200,
                                    color: Colors.indigo,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${pct.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                    const Text('Completed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text("$completed", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                    const Text('Done', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                Container(height: 24, width: 1, color: Colors.grey.shade300),
                                Column(
                                  children: [
                                    Text("$pending", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                                    const Text('Remaining', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                Container(height: 24, width: 1, color: Colors.grey.shade300),
                                Column(
                                  children: [
                                    Text("$total", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                    const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Subject-wise Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    if (_tasksBySubject.isEmpty)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No task records available to analyze.', style: TextStyle(color: Colors.grey)))),
                      )
                    else
                      ..._tasksBySubject.entries.map((entry) {
                        final subject = entry.key;
                        final subjectTasks = entry.value;
                        final subTotal = subjectTasks.length;
                        final subCompleted = subjectTasks.where((t) => t.completed).length;
                        final subPct = subTotal == 0 ? 0.0 : (subCompleted / subTotal);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(subject, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    Text("$subCompleted / $subTotal done", style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(value: subPct, minHeight: 8, backgroundColor: Colors.grey.shade200, color: Colors.indigo),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }
}
