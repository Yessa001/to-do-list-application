import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();
const String baseUrl = 'http://192.168.0.110:8002/api';

// Fetch all categories
Future<List<dynamic>> fetchCategories() async {
  final url = Uri.parse('$baseUrl/categories');
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
    throw Exception('Error fetching categories: ${error['message'] ?? 'Server error'}');
  }
}

// Fetch tasks by category
Future<List<Map<String, dynamic>>> fetchTasksByCategory(int categoryId) async {
  final url = Uri.parse('$baseUrl/categories/$categoryId/tasks');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    throw Exception('Failed to load tasks for category $categoryId');
  }
}
