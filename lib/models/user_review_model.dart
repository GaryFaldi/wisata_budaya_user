import 'package:nusantara_trail/models/complete_user_mode.dart';

class UserReview {
  final int? id;
  final int locationId;
  final int userId;
  final CompleteUser completeUser;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserReview({
    this.id,
    required this.locationId,
    required this.userId,
    required this.completeUser,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert JSON to UserReview object
  factory UserReview.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserReview(
      id: json['id'],
      locationId: json['locationId'],
      userId: json['userId'],
      completeUser: CompleteUser.fromJson(json['user']),
      rating: json['rating'],
      comment: json['comment'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert Review object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Review(id: $id, locationId: $locationId, userId: $userId, rating: $rating, comment: $comment)';
  }
}
