class Service {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int durationMinutes;
  final double rating;
  final ServiceCategory category;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.durationMinutes,
    required this.rating,
    required this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['provider_services']['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] ?? 0,
      rating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      category: ServiceCategory.fromJson(json['service_categories']),
    );
  }
}

class ServiceCategory {
  final String id;
  final String name;
  final String? iconUrl;
  final int sortOrder;

  ServiceCategory({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.sortOrder,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      iconUrl: json['icon_url'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}