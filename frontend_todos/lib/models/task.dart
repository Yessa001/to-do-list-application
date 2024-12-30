class Task {
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;

  Task({
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status,
    };
  }
}
