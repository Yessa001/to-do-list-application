import 'package:flutter/material.dart';
import '../services/tasks.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  String _status = 'Pending';
  int _categoryId = 1;
  final int _userId = 1;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Work'},
    {'id': 2, 'name': 'Personal'},
    {'id': 3, 'name': 'Learning'},
  ];

  Future<void> _submitTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final taskData = {
        'user_id': _userId,
        'category_id': _categoryId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'due_date': _dueDateController.text,
        'status': _status,
      };

      try {
        await addTask(context, taskData); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task berhasil ditambahkan!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah task: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Kategori Task'),
                items: _categories
                    .map((category) => DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryId = value ?? 1;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih kategori task';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Task'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Due Date field
              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deadline tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Status dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'In Progress', child: Text('In Progress')),
                  DropdownMenuItem(
                      value: 'Completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value ?? 'Pending';
                  });
                },
              ),
              const SizedBox(height: 20),
              // Submit button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitTask,
                      child: const Text('Tambah Task'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }
}