import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();
const String baseUrl =
    'http://192.168.0.110:8002/api'; 

// Fetch all tasks
Future<List<Map<String, dynamic>>> fetchTasks() async {
  final url = Uri.parse('$baseUrl/tasks');
  final accessToken = await secureStorage.read(key: 'access_token');

  if (accessToken == null) {
    throw Exception('No access token found. Please log in first.');
  }

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    final error = json.decode(response.body);
    throw Exception(
        'Error fetching tasks: ${error['message'] ?? 'Server error'}');
  }
}

// Add a new task
Future<void> addTask(
    BuildContext context, Map<String, dynamic> taskData) async {
  final url = Uri.parse('$baseUrl/task');
  final accessToken = await secureStorage.read(key: 'access_token');

  if (accessToken == null) {
    throw Exception('No access token found. Please log in first.');
  }

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(taskData),
    );

    if (response.statusCode == 201) {
      print('Task berhasil ditambahkan');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task berhasil ditambahkan!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token expired or invalid');
    } else {
      final error = json.decode(response.body);
      throw Exception(
          'Error adding task: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menambah task: $e')),
    );
  }
}

// Update an existing task
Future<void> updateTask(int taskId, Map<String, dynamic> taskData) async {
  final url = Uri.parse('$baseUrl/tasks/$taskId');
  final accessToken = await secureStorage.read(key: 'access_token');

  if (accessToken == null) {
    throw Exception('No access token found. Please log in first.');
  }

  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode(taskData),
  );

  if (response.statusCode != 200) {
    final error = json.decode(response.body);
    throw Exception(
        'Error updating task: ${error['message'] ?? 'Server error'}');
  }
}

// Delete a task
Future<void> deleteTask(int taskId) async {
  final url = Uri.parse('$baseUrl/tasks/$taskId');
  final accessToken = await secureStorage.read(key: 'access_token');

  if (accessToken == null) {
    throw Exception('No access token found. Please log in first.');
  }

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    final error = json.decode(response.body);
    throw Exception(
        'Error deleting task: ${error['message'] ?? 'Server error'}');
  }
}

// Fetch task by ID
Future<Map<String, dynamic>> fetchTaskById(int taskId) async {
  final url = Uri.parse('$baseUrl/tasks/$taskId');
  final accessToken = await secureStorage.read(key: 'access_token');

  if (accessToken == null) {
    throw Exception('No access token found. Please log in first.');
  }

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'];
  } else {
    final error = json.decode(response.body);
    throw Exception(
        'Error fetching task: ${error['message'] ?? 'Server error'}');
  }
}


