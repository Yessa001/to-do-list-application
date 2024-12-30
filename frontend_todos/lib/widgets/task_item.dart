import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(task.title, style: const TextStyle(fontSize: 18)),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Implementasi untuk menghapus task bisa ditambahkan di sini
          },
        ),
      ),
    );
  }
}
