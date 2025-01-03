import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();
const String baseUrl = 'http://192.168.0.110:8002';

// Register Users
Future<void> register(String name, String email, String password, String passwordConfirmation) async {
  final url = Uri.parse('$baseUrl/auth/register');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    }),
  );

  if (response.statusCode == 201) {
    print('Registration successful!');
  } else {
    final error = json.decode(response.body);
    throw Exception('Registration Failed: ${error['message'] ?? 'Server error'}');
  }
}

// Login Users
Future<void> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/auth/login');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Response data: $data'); 

    if (data.containsKey('token')) {
      final accessToken = data['token'];

      await secureStorage.write(key: 'access_token', value: accessToken);
      print('Access token successfully stored!');
    } else {
      throw Exception('Unexpected response format: Missing access token.');
    }
  } else {
    final error = json.decode(response.body);
    throw Exception('Login Failed: ${error['message'] ?? 'Server error'}');
  }
}

// Fetch Data
Future<Map<String, dynamic>> fetchProtectedData() async {
  final url = Uri.parse('$baseUrl/me');
  final accessToken = await secureStorage.read(key: 'access_token');

  if (accessToken == null) {
    throw Exception('No access token found. Please log in first.');
  }

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else if (response.statusCode == 401) {
    throw Exception('Invalid or expired access token. Please log in again.');
  } else {
    final error = json.decode(response.body);
    throw Exception('Error: ${error['message'] ?? 'Server error'}');
  }
}

// Delete Access Token
Future<void> logout() async {
  await secureStorage.delete(key: 'access_token');
  print('Access token successfully deleted.');
}

// Check Token Availability
Future<bool> isTokenAvailable() async {
  final token = await secureStorage.read(key: 'access_token');
  return token != null;
}
