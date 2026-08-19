import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../app/constants/app_constants.dart';
import '../config/supabase_config.dart';
import '../models/task_model.dart';

class TaskService {
  static const String _localTasksKey = 'solo_level_local_tasks';
  static const String _lastResetTimeKey = 'solo_level_last_reset_timestamp';
  // Check if task reset is needed (Day has changed or forced)
  Future<bool> _shouldResetDaily(bool force) async {
    if (force) return true;
    final prefs = await SharedPreferences.getInstance();
    final lastResetMs = prefs.getInt(_lastResetTimeKey);
    if (lastResetMs == null) return true;
    
    final lastReset = DateTime.fromMillisecondsSinceEpoch(lastResetMs);
    final now = DateTime.now();
    
    // Reset if it's a completely different day
    return lastReset.year != now.year || 
           lastReset.month != now.month || 
           lastReset.day != now.day;
  }

  // Record that reset was performed
  Future<void> _markResetDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt(_lastResetTimeKey, now.millisecondsSinceEpoch);
  }

  // Calculate remaining duration until the next scheduled reset (Midnight tonight)
  Future<Duration> getTimeUntilNextReset() async {
    final now = DateTime.now();
    // Next reset is exactly tomorrow at 00:00:00
    final nextReset = DateTime(now.year, now.month, now.day + 1);
    final diff = nextReset.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  // Check and reset ONLY daily habit tasks (S-Rank & Plan tasks NEVER reset)
  Future<void> checkAndResetDailyTasks(String userId, {bool force = false}) async {
    final bool needsReset = await _shouldResetDaily(force);
    if (!needsReset) return;

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client
            .from('tasks')
            .update({'is_completed': false})
            .eq('user_id', userId)
            .neq('priority', AppConstants.prioritySRank);
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_localTasksKey) ?? [];
    if (tasksJson.isNotEmpty) {
      final updatedList = tasksJson.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        final priority = map['priority'] as String?;
        // Only reset if NOT S-Rank
        if (priority != AppConstants.prioritySRank) {
          map['is_completed'] = false;
        }
        return jsonEncode(map);
      }).toList();
      await prefs.setStringList(_localTasksKey, updatedList);
    }

    await _markResetDoneToday();
  }

  // Get tasks for user (or filtered by plan)
  Future<List<TaskModel>> getTasks(String userId, {String? planId, bool forceReset = false}) async {
    final bool needsReset = await _shouldResetDaily(forceReset);

    List<TaskModel> tasks = [];
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        var query = client.from('tasks').select().eq('user_id', userId);
        if (planId != null) {
          query = query.eq('plan_id', planId);
        }
        final data = await query.order('created_at', ascending: false);
        tasks = (data as List).map((item) => TaskModel.fromJson(item)).toList();
      } catch (_) {}
    }

    if (tasks.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_localTasksKey) ?? [];
      if (tasksJson.isNotEmpty) {
        tasks = tasksJson
            .map((e) => TaskModel.fromJson(jsonDecode(e)))
            .toList();
        if (planId != null) {
          tasks = tasks.where((t) => t.planId == planId).toList();
        }
      } else {
        // Initial sample quests for immediate RPG experience
        final defaultTasks = [
          TaskModel(
            id: const Uuid().v4(),
            userId: userId,
            title: 'Complete Flutter UI Framework',
            description:
                'Build futuristic anime RPG user interface with dark blue theme.',
            priority: AppConstants.prioritySRank,
            isCompleted: false,
          ),
          TaskModel(
            id: const Uuid().v4(),
            userId: userId,
            title: 'Connect Supabase Auth & PostgreSQL',
            description: 'Set up database tables, RLS policies, and triggers.',
            priority: AppConstants.priorityHigh,
            isCompleted: false,
          ),
          TaskModel(
            id: const Uuid().v4(),
            userId: userId,
            title: 'Daily Workout Quest',
            description: '100 Push-ups, 100 Sit-ups, 10km Run.',
            priority: AppConstants.priorityMedium,
            isCompleted: false,
          ),
        ];
        await prefs.setStringList(
          _localTasksKey,
          defaultTasks.map((e) => jsonEncode(e.toJson())).toList(),
        );
        tasks = defaultTasks;
      }
    }

    // GUARANTEE: If reset interval is reached, reset all non-S-Rank tasks to uncompleted!
    if (needsReset) {
      tasks = tasks.map((t) {
        if (t.priority != AppConstants.prioritySRank) {
          return t.copyWith(isCompleted: false);
        }
        return t;
      }).toList();

      // Persist the reset list back to SharedPreferences and Supabase
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _localTasksKey,
        tasks.map((e) => jsonEncode(e.toJson())).toList(),
      );

      // Single batch update instead of N individual queries
      if (client != null) {
        try {
          await client
              .from('tasks')
              .update({'is_completed': false})
              .eq('user_id', userId)
              .neq('priority', AppConstants.prioritySRank);
        } catch (_) {}
      }

      await _markResetDoneToday();
    }

    return tasks;
  }

  // Create task
  Future<TaskModel> createTask(TaskModel task) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      final data = await client
          .from('tasks')
          .insert(task.toJson())
          .select()
          .single();
      return TaskModel.fromJson(data);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_localTasksKey) ?? [];
      tasksJson.insert(0, jsonEncode(task.toJson()));
      await prefs.setStringList(_localTasksKey, tasksJson);
      return task;
    }
  }

  // Update task
  Future<TaskModel> updateTask(TaskModel task) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      final data = await client
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id)
          .select()
          .single();
      return TaskModel.fromJson(data);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_localTasksKey) ?? [];
      final index = tasksJson.indexWhere((item) {
        final map = jsonDecode(item);
        return map['id'] == task.id;
      });
      if (index != -1) {
        tasksJson[index] = jsonEncode(task.toJson());
        await prefs.setStringList(_localTasksKey, tasksJson);
      }
      return task;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      await client.from('tasks').delete().eq('id', taskId);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_localTasksKey) ?? [];
      tasksJson.removeWhere((item) {
        final map = jsonDecode(item);
        return map['id'] == taskId;
      });
      await prefs.setStringList(_localTasksKey, tasksJson);
    }
  }

  // Delete all tasks for a plan
  Future<void> deleteTasksForPlan(String planId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      await client.from('tasks').delete().eq('plan_id', planId);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_localTasksKey) ?? [];
      tasksJson.removeWhere((item) {
        final map = jsonDecode(item);
        return map['plan_id'] == planId;
      });
      await prefs.setStringList(_localTasksKey, tasksJson);
    }
  }

  // Reset all tasks to uncompleted status for user
  Future<void> resetAllTaskCompletions(String userId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client
            .from('tasks')
            .update({'is_completed': false})
            .eq('user_id', userId);
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_localTasksKey) ?? [];
    if (tasksJson.isNotEmpty) {
      final updatedList = tasksJson.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        map['is_completed'] = false;
        return jsonEncode(map);
      }).toList();
      await prefs.setStringList(_localTasksKey, updatedList);
    }
  }
  static const String _taskHistoryKey = 'solo_level_task_history';

  // Check if a task has a completion record on a specific date
  Future<bool> wasTaskCompletedOnDate(String taskId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_taskHistoryKey}_$taskId';
    final history = prefs.getStringList(key) ?? [];
    
    final targetStr = date.toIso8601String().split('T').first;
    for (var dateStr in history) {
      if (dateStr.split('T').first == targetStr) {
        return true;
      }
    }
    return false;
  }

  // Set (add/remove) a completion timestamp for a task on a specific date
  Future<void> setTaskCompletionOnDate(String taskId, DateTime date, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_taskHistoryKey}_$taskId';
    final history = prefs.getStringList(key) ?? [];
    
    final targetStr = date.toIso8601String().split('T').first;
    
    if (isCompleted) {
      // Add if it doesn't exist
      bool exists = history.any((d) => d.split('T').first == targetStr);
      if (!exists) {
        history.add(date.toIso8601String());
      }
    } else {
      // Remove all entries matching that date
      history.removeWhere((d) => d.split('T').first == targetStr);
    }
    
    await prefs.setStringList(key, history);
  }

  // Record a task completion event
  Future<void> recordTaskCompletion(String taskId) async {
    await setTaskCompletionOnDate(taskId, DateTime.now(), true);
  }

  // Get the number of completed days for a task up to a target date
  Future<int> getCompletedCount(String taskId, DateTime targetDate) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_taskHistoryKey}_$taskId';
    final history = prefs.getStringList(key) ?? [];
    
    int count = 0;
    final targetStr = targetDate.toIso8601String().split('T').first;
    
    for (final dateStr in history) {
      final historyDateOnly = dateStr.split('T').first;
      if (historyDateOnly.compareTo(targetStr) <= 0) {
        count++;
      }
    }
    return count;
  }
}
