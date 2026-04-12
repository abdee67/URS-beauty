import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.customerId,
    required this.stylistId,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final String stylistId;
  final String bookingId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  bool get hasComment => comment?.trim().isNotEmpty == true;

  @override
  List<Object?> get props => [
        id,
        customerId,
        stylistId,
        bookingId,
        rating,
        comment,
        createdAt,
      ];
}
