import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.id,
    required super.bookingId,
    required super.customerId,
    required super.stylistId,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      stylistId: json['stylist_id'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'stylist_id': stylistId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      bookingId: bookingId,
      customerId: customerId,
      stylistId: stylistId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }
}