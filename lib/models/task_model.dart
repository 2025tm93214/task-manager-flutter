class Task {
  final String? objectId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? createdAt;

  Task({
    this.objectId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.createdAt,
  });

  /// Create a Task from a Parse object (Back4App response)
  factory Task.fromParse(dynamic parseObject) {
    return Task(
      objectId: parseObject.objectId,
      title: parseObject.get<String>('title') ?? '',
      description: parseObject.get<String>('description') ?? '',
      isCompleted: parseObject.get<bool>('isCompleted') ?? false,
      createdAt: parseObject.get<DateTime>('createdAt'),
    );
  }

  /// Convert to a Map for sending to Back4App
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  /// Create a copy with updated fields
  Task copyWith({
    String? objectId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      objectId: objectId ?? this.objectId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Task(objectId: $objectId, title: $title, isCompleted: $isCompleted)';
}