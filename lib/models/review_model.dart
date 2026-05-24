import 'package:nusantara_trail/models/user_review_model.dart';

class ReviewModel {
  final double avgRating;
  final int totalReviews;
  final List<UserReview> reviews;

  ReviewModel({
    required this.avgRating,
    required this.totalReviews,
    required this.reviews,
  });
}
