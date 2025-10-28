import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import 'package:vorka_app2/models/task_model.dart';
import 'package:vorka_app2/services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TaskModel> get myTasks => _tasks.where((task) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return currentUserId != null && task.assigneeIds.contains(currentUserId);
  }).toList();

  List<TaskModel> get highPriorityTasks =>
      _tasks.where((task) => task.priority == TaskPriority.high).toList();

  void watchTasks(String orgId, {String? userId}) {
    _firestoreService
        .watchTasks(orgId, userId: userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> createTask(TaskModel task) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.createTask(task);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _firestoreService.updateTaskStatus(taskId, status);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleSubtask(
    String taskId,
    String subtaskId,
    bool isCompleted,
  ) async {
    try {
      await _firestoreService.toggleSubtask(taskId, subtaskId, isCompleted);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
