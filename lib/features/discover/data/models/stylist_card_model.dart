import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';

class StylistCardModel extends Stylist {
  StylistCardModel({
    required super.id,
    required super.businessName,
    required super.description,
    required super.serviceRadiusKm,
    required super.averageRating,
    required super.imageUrl,
    super.isVerified = true,
    required super.totalReview,
    required super.latitude,
    required super.longitude,
    required this.distanceKm,
    required this.servicePrice,
    required this.serviceDuration,
  });

  final double distanceKm;
  final double servicePrice;
  final int serviceDuration;

  String get stylistId => id;

  String get distanceDisplay {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  factory StylistCardModel.fromJson(Map<String, dynamic> json) {
    return StylistCardModel(
      id: (json['stylist_id'] ?? '').toString(),
      businessName: (json['business_name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      averageRating: _asDouble(json['avg_rating']),
      totalReview: _asInt(json['total_reviews']),
      serviceRadiusKm: _asDouble(json['service_radius_km']),
      distanceKm: _asDouble(json['distance_km']),
      servicePrice: _asDouble(json['service_price']),
      serviceDuration: _asInt(json['service_duration']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stylist_id': stylistId,
      'business_name': businessName,
      'description': description,
      'image_url': imageUrl,
      'avg_rating': averageRating,
      'total_reviews': totalReview,
      'service_radius_km': serviceRadiusKm,
      'distance_km': distanceKm,
      'service_price': servicePrice,
      'service_duration': serviceDuration,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}
