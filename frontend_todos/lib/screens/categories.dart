import 'package:flutter/material.dart';
import '../services/tasks.dart'; 
import '../services/categories.dart'; 
import 'add_task.dart';
import 'edit_task.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int? _selectedCategoryId;
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  final Map<int, String> categoryNames = {
    1: 'Work',
    2: 'Personal',
    3: 'Learning',
  };

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = 1;
    _fetchTasksByCategory();
  }

  void _fetchTasksByCategory() {
    _tasksFuture = fetchTasksByCategory(_selectedCategoryId!);  
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _fetchTasksByCategory();
    });
  }

  Future<void> _deleteTask(int taskId) async {
    try {
      await deleteTask(taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        backgroundColor: Colors.indigo[50],
        title: const Text(
          'Daftar Task',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks, 
            color: Colors.indigo,
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.indigo[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: _selectedCategoryId,
                isExpanded: true,
                items: categoryNames.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _fetchTasksByCategory();
                  });
                },
                underline: const SizedBox(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.indigo.shade300,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada task yang ditambahkan.',
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  );
                }

                final tasks = snapshot.data!;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    String categoryName = categoryNames[task['category_id']] ?? 'Unknown';
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          task['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        subtitle: Text(
                          'Deskripsi: ${task['description'] ?? '-'}\n'
                          'Tenggat Waktu: ${task['due_date']}\n'
                          'Kategori: $categoryName\n'
                          'Status: ${task['status']}',
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Edit
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskScreen(task: task),
                                  ),
                                );

                                if (result == true) {
                                  _refreshTasks();  
                                }
                              },
                            ),
                            // Tombol Hapus
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmation(context, task['task_id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );

          if (result == true) {
            _refreshTasks();
          }
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Menampilkan dialog konfirmasi hapus
  void _showDeleteConfirmation(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus task ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTask(taskId);
              },
              child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }
}
