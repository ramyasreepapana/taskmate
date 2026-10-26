class Task {
  final int? id;
  final String title;
  final String description;
  final String subject;
  final String priority;
  final String dueDate;
  final int isCompleted;
  final String createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.priority,
    required this.dueDate,
    this.isCompleted = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'subject': subject,
      'priority': priority,
      'due_date': dueDate,
      'is_completed': isCompleted,
      'created_at': createdAt,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      priority: map['priority'] as String,
      dueDate: map['due_date'] as String,
      isCompleted: map['is_completed'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  bool get completed => isCompleted == 1;

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? subject,
    String? priority,
    String? dueDate,
    int? isCompleted,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
