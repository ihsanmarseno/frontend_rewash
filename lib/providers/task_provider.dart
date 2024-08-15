import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchTasks();
});

final tasksNotifierProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.read(apiServiceProvider));
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final ApiService _apiService;

  TaskNotifier(this._apiService) : super([]);

  Future<void> loadTasks() async {
    state = await _apiService.fetchTasks();
  }

  Future<void> removeTask(String taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      state = state.where((task) => task.id != taskId).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTask(String title, String description) async {
    try {
      final newTask = await _apiService.createTask(title, description);
      state = [...state, newTask];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(
      String taskId, String title, String description) async {
    try {
      await _apiService.updateTask(taskId, title, description);
      state = state
          .map((task) => task.id == taskId
              ? Task(
                  id: task.id,
                  title: title,
                  description: description,
                  status: task.status,
                )
              : task)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String taskId) async {
    try {
      await _apiService.updateStatus(taskId);
      state = state
          .map((task) => task.id == taskId
              ? Task(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  status: 'completed',
                )
              : task)
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
