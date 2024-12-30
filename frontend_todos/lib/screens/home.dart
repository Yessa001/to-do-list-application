import 'package:flutter/material.dart';
import '../services/tasks.dart';
import 'add_task.dart';
import 'edit_task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    _tasksFuture = fetchTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _fetchTasks();
    });
  }

  Future<void> _deleteTask(int taskId) async {
    try {
      await deleteTask(taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task berhasil dihapus!'),
        backgroundColor: Colors.green,
        ),
      );
      _refreshTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus task: $e'),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(  // Handle future response for tasks
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Deskripsi: ${task['description'] ?? '-'}\n'
                    'Tanggal: ${task['due_date']}\n'
                    'Status: ${task['status']}',
                    style: const TextStyle(fontSize: 14),
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
                _deleteTask(taskId); // Panggil fungsi hapus task
              },
              child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cukup menutup dialog
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }
}
