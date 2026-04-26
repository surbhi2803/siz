class Todo {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TodoStatus status;
  final String priority;
  final String roomId;
  final String assignedToId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.createdBy,
    required this.createdAt,
    required this.roomId,
    required this.assignedToId,
    this.dueDate,
    this.status = TodoStatus.pending,
    this.priority = 'medium',
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? createdBy,
    DateTime? createdAt,
    DateTime? dueDate,
    TodoStatus? status,
    String? priority,
    String? roomId,
    String? assignedToId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      roomId: roomId ?? this.roomId,
      assignedToId: assignedToId ?? this.assignedToId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.name,
      'priority': priority,
      'roomId': roomId,
      'assignedToId': assignedToId,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assignedTo: json['assignedTo'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: TodoStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TodoStatus.pending,
      ),
      priority: json['priority'] ?? 'medium',
      roomId: json['roomId'],
      assignedToId: json['assignedToId'],
    );
  }
}

enum TodoStatus {
  pending,
  inProgress,
  completed,
}

extension TodoStatusExtension on TodoStatus {
  String get displayName {
    switch (this) {
      case TodoStatus.pending:
        return 'Pending';
      case TodoStatus.inProgress:
        return 'In Progress';
      case TodoStatus.completed:
        return 'Completed';
    }
  }

}
