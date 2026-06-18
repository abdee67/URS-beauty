class RatingSummaryDto {
  const RatingSummaryDto({
    required this.averageRating,
    required this.totalReviews,
  });

  final double averageRating;
  final int totalReviews;

  factory RatingSummaryDto.fromJson(Map<String, dynamic> json) {
    return RatingSummaryDto(
      averageRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews:
          (json['total_reviews'] as num?)?.toInt() ??
          (json['total_review'] as num?)?.toInt() ??
          0,
    );
  }

  ({double averageRating, int totalReviews}) toSummary() {
    return (averageRating: averageRating, totalReviews: totalReviews);
  }
}
