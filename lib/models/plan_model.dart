class PlanModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String stage; // 'Casual' or 'S-Rank'
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  PlanModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.stage = 'Casual',
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isSRank => stage == 'S-Rank';

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stage: json['stage'] as String? ?? 'Casual',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'stage': stage,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PlanModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? stage,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return PlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      stage: stage ?? this.stage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
