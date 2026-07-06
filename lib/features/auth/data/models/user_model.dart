import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.avatarUrl,
    super.reviewsCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatarUrl: json['avatarUrl'],
      reviewsCount: json['reviewsCount'] is String
          ? int.tryParse(json['reviewsCount']) ?? 0
          : (json['reviewsCount'] as num?)?.toInt() ?? 0,
    );
  }
}
