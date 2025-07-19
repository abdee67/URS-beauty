import 'package:urs_beauty/features/service-listing/domain/models/category_model.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int durationMinutes;
  final double rating;
  final CategoryModel category;
  final bool isFavorite;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.durationMinutes,
    required this.rating,
    required this.category,
    required this.isFavorite,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['provider_services']['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] ?? 0,
      rating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      category: CategoryModel.fromJson(json['service_categories']),
      isFavorite: (json['favorites'] as List?)?.isNotEmpty ?? false,
    );
  }
    ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    int? durationMinutes,
    double? rating,
    CategoryModel? category,
    bool? isFavorite,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}