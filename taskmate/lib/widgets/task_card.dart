import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onCheckboxChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onCheckboxChanged,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red.shade700;
      case 'medium': return Colors.orange.shade800;
      case 'low': default: return Colors.green.shade700;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'flutter': return Colors.blue.shade700;
      case 'java': return Colors.deepOrange.shade700;
      case 'dsa': return Colors.purple.shade700;
      case 'machine learning': return Colors.teal.shade700;
      case 'database': return Colors.indigo.shade700;
      default: return Colors.blueGrey.shade700;
    }
  }

  bool get _isOverdue {
    if (task.completed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      final due = DateTime.parse(task.dueDate);
      return due.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);
    final subjectColor = _getSubjectColor(task.subject);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: _isOverdue ? Colors.red.shade300 : Colors.grey.shade200,
          width: _isOverdue ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: task.completed,
                  activeColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: onCheckboxChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                      color: task.completed ? Colors.grey.shade500 : Colors.grey.shade900,
                    ),
                  ),
                  if (task.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: subjectColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.subject,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subjectColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.priority,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: priorityColor),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 13, color: _isOverdue ? Colors.red.shade700 : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            task.dueDate,
                            style: TextStyle(fontSize: 12, fontWeight: _isOverdue ? FontWeight.w700 : FontWeight.w500, color: _isOverdue ? Colors.red.shade700 : Colors.grey.shade700),
                          ),
                          if (_isOverdue) ...[
                            const SizedBox(width: 4),
                            Text('(Overdue)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.indigo.shade600,
                  tooltip: 'Edit Task',
                  onPressed: onEdit,
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red.shade400,
                  tooltip: 'Delete Task',
                  onPressed: onDelete,
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
