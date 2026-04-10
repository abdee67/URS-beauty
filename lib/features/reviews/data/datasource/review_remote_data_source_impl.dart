import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/reviews/data/datasource/review_remote_data_source.dart';
import 'package:urs_beauty/features/reviews/data/dto/rating_summary_dto.dart';
import 'package:urs_beauty/features/reviews/data/model/review_model.dart';

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _reviewTable = 'reviews';
  static const String _bookingTable = 'bookings';
  static const String _stylistsTable = 'stylists';
  static const String _reviewColumns =
      'id, booking_id, customer_id, stylists_id, rating, comment, created_at';
  static const String _bookingReviewColumns = 'id, customer, stylist, status';

  @override
  Future<ReviewModel> submitReview(ReviewModel review) {
    return _run(() async {
      _validateReview(review);
      final booking = await _getBookingReviewData(review.bookingId);
      _validateBookingForReview(review, booking);

      final existingReview = await _client
          .from(_reviewTable)
          .select(_reviewColumns)
          .eq('booking_id', review.bookingId)
          .maybeSingle();

      if (existingReview != null) {
        throw Failures(
          message:
              'This booking already has a review. Only one review is allowed per booking.',
        );
      }

      final response = await _client
          .from(_reviewTable)
          .insert(_createReviewPayload(review))
          .select(_reviewColumns)
          .single();

      final createdReview = _mapReview(response);

      await _client
          .from(_bookingTable)
          .update({
            'status': BookingStatus.confirmed.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', review.bookingId);

      await _refreshStylistRating(review.stylistId);

      return createdReview;
    });
  }

  @override
  Future<List<ReviewModel>> getReviewsByStylistId(String stylistId) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from(_reviewTable)
          .select(_reviewColumns)
          .eq('stylists_id', stylistId)
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
  Future<ReviewModel?> getReviewByBookingId(String bookingId) {
    return _run(() async {
      _requireValue(bookingId, 'Booking id is required');

      final response = await _client
          .from(_reviewTable)
          .select(_reviewColumns)
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapReview(response);
    });
  }

  @override
  Future<RatingSummaryDto> getRatingSummary(String stylistId) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from(_stylistsTable)
          .select('avg_rating, total_reviews')
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
      'stylists_id': review.stylistId,
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

    if (review.rating < 1 || review.rating > 5) {
      throw Failures(message: 'Rating must be between 1 and 5');
    }
  }

  Future<void> _refreshStylistRating(String stylistId) async {
    final response = await _client
        .from(_reviewTable)
        .select('rating')
        .eq('stylists_id', stylistId);

    final ratings = (response as List)
        .map(
          (item) =>
              (Map<String, dynamic>.from(item as Map)['rating'] as num?)
                  ?.toDouble() ??
              0.0,
        )
        .where((rating) => rating > 0)
        .toList();

    final totalReviews = ratings.length;
    final averageRating = totalReviews == 0
        ? 0.0
        : ratings.reduce((sum, rating) => sum + rating) / totalReviews;

    await _client
        .from(_stylistsTable)
        .update({
          'avg_rating': averageRating,
          'total_reviews': totalReviews,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', stylistId);
  }

  Future<Map<String, dynamic>> _getBookingReviewData(String bookingId) async {
    final response = await _client
        .from(_bookingTable)
        .select(_bookingReviewColumns)
        .eq('id', bookingId)
        .maybeSingle();

    if (response == null) {
      throw Failures(message: 'Booking not found.');
    }

    return Map<String, dynamic>.from(response);
  }

  void _validateBookingForReview(
    ReviewModel review,
    Map<String, dynamic> booking,
  ) {
    final bookingStatus = (booking['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final bookingCustomerId = (booking['customer'] ?? '').toString().trim();
    final bookingStylistId = (booking['stylist'] ?? '').toString().trim();

    if (bookingStatus != 'completed') {
      throw Failures(
        message:
            'You can only review a booking after the service is completed.',
      );
    }

    if (bookingCustomerId != review.customerId.trim()) {
      throw Failures(
        message: 'This review does not match the customer on the booking.',
      );
    }

    if (bookingStylistId != review.stylistId.trim()) {
      throw Failures(
        message: 'This review does not match the stylist on the booking.',
      );
    }
  }

  void _requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw Failures(message: message);
    }
  }
}
