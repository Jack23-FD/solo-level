class UserModel {
  final String id;
  final String username;
  final String avatarUrl;
  final int level;
  final int experience;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.avatarUrl = '',
    this.level = 1,
    this.experience = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get maxExperienceForCurrentLevel => level * 1000;

  double get experienceProgress {
    int maxXP = maxExperienceForCurrentLevel;
    if (maxXP <= 0) return 0.0;
    return (experience / maxXP).clamp(0.0, 1.0);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Shadow Hunter',
      avatarUrl: json['avatar_url'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'level': level,
      'experience': experience,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    int? level,
    int? experience,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
