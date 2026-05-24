import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/review_model.dart';
import '../models/user_review_model.dart';
import 'auth_service.dart';

class ReviewService {
  /// Ambil semua review berdasarkan locationId
  static Future<ReviewModel> getReviewsByLocation(
    int locationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${AuthService.baseUrl}/api/reviews/$locationId',
      ),
      headers: await AuthService.getHeaders(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == 'success') {
      final data = body['data'];

      final List<UserReview> reviews = (data['reviews'] as List)
          .map(
            (json) => UserReview.fromJson(json),
          )
          .toList();

      return ReviewModel(
        avgRating: (data['avgRating'] as num).toDouble(),
        totalReviews: data['totalReviews'],
        reviews: reviews,
      );
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil review',
    );
  }

  /// Tambah review baru
  static Future<void> createReview({
    required int locationId,
    required int rating,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${AuthService.baseUrl}/api/reviews',
      ),
      headers: await AuthService.getHeaders(),
      body: jsonEncode({
        'locationId': locationId,
        'rating': rating,
        'comment': comment,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        body['message'] ?? 'Gagal menambahkan review',
      );
    }
  }

  /// Update review
  static Future<void> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${AuthService.baseUrl}/api/reviews/$reviewId',
      ),
      headers: await AuthService.getHeaders(),
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body['message'] ?? 'Gagal update review',
      );
    }
  }

  /// Hapus review
  static Future<void> deleteReview(
    int reviewId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '${AuthService.baseUrl}/api/reviews/$reviewId',
      ),
      headers: await AuthService.getHeaders(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body['message'] ?? 'Gagal menghapus review',
      );
    }
  }
}
