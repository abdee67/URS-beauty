import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';

class StylistsAvailabilityModel extends  StylistsAvailability {

  StylistsAvailabilityModel({
    required super.id,
    required super.stylists_id,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
  });

  factory StylistsAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return StylistsAvailabilityModel(
      id: json['id'],
      stylists_id: json['stylists_id'],
      dayOfWeek: json['dayOfWeek'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stylists_id': stylists_id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }
}