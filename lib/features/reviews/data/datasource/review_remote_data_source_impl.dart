import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/reviews/data/datasource/review_remote_data_source.dart';
import 'package:urs_beauty/features/reviews/data/dto/rating_summary_dto.dart';
import 'package:urs_beauty/features/reviews/data/model/review_model.dart';

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _reviewTable = 'reviews';
  static const String _reviewColumns =
      'id, booking_id, customer_id, stylist_id, rating, comment, created_at';

  @override
  Future<ReviewModel> submitReview(ReviewModel review) {
    return _run(() async {
      _validateReview(review);

      final response = await _client
          .from(_reviewTable)
          .insert(_createReviewPayload(review))
          .select(_reviewColumns)
          .single();

      return _mapReview(response);
    });
  }

  @override
  Future<List<ReviewModel>> getReviewsByStylistId(String stylistId) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from(_reviewTable)
          .select(_reviewColumns)
          .eq('stylist_id', stylistId)
          .order('created_at', ascending: false);

      return _mapReviewList(response);
    });
  }

  @override
  Future<List<ReviewModel>> getReviewsByCustomerId(String customerId) {
    return _run(() async {
      _requireValue(customerId, 'Customer id is required');

      final response = await _client
          .from(_reviewTable)
          .select(_reviewColumns)
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return _mapReviewList(response);
    });
  }

  @override
  Future<ReviewModel> getReviewByBookingId(String bookingId) {
    return _run(() async {
      _requireValue(bookingId, 'Booking id is required');

      final response = await _client
          .from(_reviewTable)
          .select(_reviewColumns)
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) {
        throw Failures(message: 'No review found for booking: $bookingId');
      }

      return _mapReview(response);
    });
  }

  @override
  Future<RatingSummaryDto> getRatingSummary(String stylistId) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from('stylists')
          .select('avg_rating, total_review')
          .eq('id', stylistId)
          .maybeSingle();

      if (response == null) {
        throw Failures(message: 'Stylist not found: $stylistId');
      }

      return RatingSummaryDto.fromJson(Map<String, dynamic>.from(response));
    });
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Failures {
      rethrow;
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  List<ReviewModel> _mapReviewList(dynamic response) {
    return (response as List)
        .map(
          (item) =>
              ReviewModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  ReviewModel _mapReview(dynamic response) {
    return ReviewModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Map<String, dynamic> _createReviewPayload(ReviewModel review) {
    final payload = <String, dynamic>{
      'booking_id': review.bookingId,
      'customer_id': review.customerId,
      'stylist_id': review.stylistId,
      'rating': review.rating,
      'comment': _normalizeComment(review.comment),
      'created_at': review.createdAt.toIso8601String(),
    };

    if (review.id.trim().isNotEmpty) {
      payload['id'] = review.id;
    }

    return payload;
  }

  String? _normalizeComment(String? comment) {
    final normalizedComment = comment?.trim();
    if (normalizedComment == null || normalizedComment.isEmpty) {
      return null;
    }

    return normalizedComment;
  }

  void _validateReview(ReviewModel review) {
    _requireValue(review.bookingId, 'Booking id is required');
    _requireValue(review.customerId, 'Customer id is required');
    _requireValue(review.stylistId, 'Stylist id is required');

    if (review.rating < 0 || review.rating > 5) {
      throw Failures(message: 'Rating must be between 0 and 5');
    }
  }

  void _requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw Failures(message: message);
    }
  }
}
