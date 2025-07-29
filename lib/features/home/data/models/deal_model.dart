import 'package:urs_beauty/features/home/domain/entities/deal.dart';

class DealModel {
  final String id;
  final String title;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String serviceName;
  final String serviceCategory;
  final String imageUrl;

  DealModel({
    required this.id,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.serviceName,
    required this.serviceCategory,
    required this.imageUrl,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      originalPrice: json['original_price']?.toDouble() ?? 0.0,
      discountedPrice: json['discounted_price']?.toDouble() ?? 0.0,
      serviceName: json['service']['name'] ?? '',
      serviceCategory: json['service']['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
  Deal toEntity() {
    return Deal(
      id: id,
      title: title,
      description: description,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      serviceName: serviceName,
      serviceCategory: serviceCategory,
      imageUrl: imageUrl,
    );
  }
}