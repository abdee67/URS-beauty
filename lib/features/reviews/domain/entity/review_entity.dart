 class ReviewEntity{
  final String id;
  final String customerId;
  final String stylistId;
  final String bookingId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  ReviewEntity({
    required this.id,
    required this.customerId,
    required this.stylistId,
    required this.bookingId,
    required this.rating,
     this.comment,
    required this.createdAt,
  });
}