import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.7:8000';

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> tasksJson = jsonResponse['data'];
      return tasksJson.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/todos/$taskId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<Task> createTask(String title, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'title': title, 'description': description, 'status': 'pending'}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Task.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(
      String taskId, String title, String description) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'title': title, 'description': description, 'status': 'pending'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<void> updateStatus(String taskId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/todos/$taskId/status'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }
}
