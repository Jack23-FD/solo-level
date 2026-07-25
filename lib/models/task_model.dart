import '../app/constants/app_constants.dart';

class TaskModel {
  final String id;
  final String? planId;
  final String userId;
  final String title;
  final String description;
  final String priority; // 'Low', 'Medium', 'High', 'S-Rank'
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    this.planId,
    required this.userId,
    required this.title,
    required this.description,
    this.priority = AppConstants.priorityMedium,
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get xpReward {
    switch (priority) {
      case AppConstants.priorityStar:
        return AppConstants.xpStarPriority;
      case AppConstants.priorityLow:
        return AppConstants.xpLowPriority;
      case AppConstants.priorityCasual:
        return AppConstants.xpCasualPriority;
      case AppConstants.priorityHigh:
        return AppConstants.xpHighPriority;
      case AppConstants.priorityElite:
        return AppConstants.xpElitePriority;
      case AppConstants.prioritySRank:
        return AppConstants.xpSRankPriority;
      case AppConstants.priorityMedium:
      default:
        return AppConstants.intMediumPriority;
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String?,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? AppConstants.priorityMedium,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? planId,
    String? userId,
    String? title,
    String? description,
    String? priority,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
