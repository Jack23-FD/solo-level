import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../app/constants/app_constants.dart';
import '../models/plan_model.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'auth_provider.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TaskModel> get todayQuests => _tasks;

  List<TaskModel> getTodayQuests(List<PlanModel> plans) {
    final existingPlanIds = plans.map((p) => p.id).toSet();
    final sRankPlanIds = plans.where((p) => p.isSRank).map((p) => p.id).toSet();
    return _tasks.where((t) {
      if (t.priority == AppConstants.prioritySRank) return false;
      if (t.planId != null && !existingPlanIds.contains(t.planId)) return false;
      if (t.planId != null && sRankPlanIds.contains(t.planId)) return false;
      return true;
    }).toList();
  }

  List<TaskModel> getPlanTasks(String planId) =>
      _tasks.where((t) => t.planId == planId).toList();

  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;

  Future<void> fetchTasks(String userId, {String? planId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _tasks = await _taskService.getTasks(userId);
    } catch (e) {
      _errorMessage = 'Failed to load quests: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskModel?> addTask({
    required String userId,
    String? planId,
    required String title,
    required String description,
    required String priority,
    DateTime? dueDate,
  }) async {
    try {
      final newTask = TaskModel(
        id: const Uuid().v4(),
        userId: userId,
        planId: planId,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
      );
      final created = await _taskService.createTask(newTask);
      _tasks.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = 'Failed to create quest: $e';
      notifyListeners();
      return null;
    }
  }

  final Set<String> _processingTaskIds = {};

  // Toggle completion & trigger XP award
  // Returns true if completing this task triggered a Level Up!
  Future<bool> toggleTaskCompletion(
    TaskModel task,
    AuthProvider authProvider,
  ) async {
    if (_processingTaskIds.contains(task.id)) return false;
    _processingTaskIds.add(task.id);

    try {
      final updatedIsCompleted = !task.isCompleted;
      final updatedTask = task.copyWith(isCompleted: updatedIsCompleted);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }

      bool didLevelUp = false;
      if (updatedIsCompleted) {
        didLevelUp = await authProvider.addXp(task.xpReward);
      } else {
        await authProvider.addXp(-task.xpReward);
      }

      try {
        await _taskService.updateTask(updatedTask);
      } catch (e) {
        _errorMessage = 'Failed to update quest status: $e';
      }
      return didLevelUp;
    } finally {
      _processingTaskIds.remove(task.id);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final updated = await _taskService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update quest: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete quest: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTasksForPlan(String planId) async {
    try {
      await _taskService.deleteTasksForPlan(planId);
      _tasks.removeWhere((t) => t.planId == planId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete plan quests: $e';
      notifyListeners();
    }
  }
}
