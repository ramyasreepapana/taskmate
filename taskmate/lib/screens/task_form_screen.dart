import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? taskToEdit;
  const TaskFormScreen({super.key, this.taskToEdit});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedSubject;
  late String _selectedPriority;
  late DateTime _selectedDueDate;
  bool _isSaving = false;

  final List<String> _subjects = ['Flutter', 'Java', 'DSA', 'Machine Learning', 'Database', 'Other'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _selectedSubject = (task != null && _subjects.contains(task.subject)) ? task.subject : 'Flutter';
    _selectedPriority = (task != null && _priorities.contains(task.priority)) ? task.priority : 'Medium';
    if (task != null) {
      try {
        _selectedDueDate = DateTime.parse(task.dueDate);
      } catch (_) {
        _selectedDueDate = DateTime.now();
      }
    } else {
      _selectedDueDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.indigo, onPrimary: Colors.white, onSurface: Colors.black87),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final formattedDate = _formatDate(_selectedDueDate);
      final isEditing = widget.taskToEdit != null;
      if (isEditing) {
        final updated = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          subject: _selectedSubject,
          priority: _selectedPriority,
          dueDate: formattedDate,
        );
        await DatabaseHelper.instance.updateTask(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated successfully!'), backgroundColor: Colors.indigo));
          Navigator.pop(context, true);
        }
      } else {
        final newTask = Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          subject: _selectedSubject,
          priority: _selectedPriority,
          dueDate: formattedDate,
          isCompleted: 0,
          createdAt: DateTime.now().toIso8601String(),
        );
        await DatabaseHelper.instance.insertTask(newTask);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added successfully!'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving task: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Add New Task'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title *', hintText: 'e.g. Implement SQLite DatabaseHelper', prefixIcon: const Icon(Icons.title, color: Colors.indigo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a task title';
                  if (val.trim().length < 3) return 'Title must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description (Optional)', hintText: 'Add details or links...', alignLabelWithHint: true, prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.description_outlined, color: Colors.indigo)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(labelText: 'Subject', prefixIcon: const Icon(Icons.school_outlined, color: Colors.indigo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) { if (val != null) setState(() => _selectedSubject = val); },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(labelText: 'Priority', prefixIcon: const Icon(Icons.flag_outlined, color: Colors.indigo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) { if (val != null) setState(() => _selectedPriority = val); },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Due Date', prefixIcon: const Icon(Icons.calendar_month, color: Colors.indigo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(_selectedDueDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const Text('Change', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveTask,
                icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : (isEditing ? 'Update Task' : 'Save Task'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
