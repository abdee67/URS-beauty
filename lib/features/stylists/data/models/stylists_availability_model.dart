import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';

class StylistsAvailabilityModel extends StylistsAvailability {
  StylistsAvailabilityModel({
    required super.id,
    required super.stylistsId,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
  });

  factory StylistsAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return StylistsAvailabilityModel(
      id: _asString(json['id']),
      stylistsId: _asString(json['stylists_id']),
      dayOfWeek: _asString(json['day_of_week']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      isAvailable: _asBool(json['is_available']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stylists_id': stylistsId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
    };
  }
  factory StylistsAvailabilityModel.fromEntity(StylistsAvailability entity) {
    return StylistsAvailabilityModel(
      id: entity.id,
      stylistsId: entity.stylistsId,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isAvailable: entity.isAvailable,
    );
  }

  StylistsAvailability toEntity() {
    return StylistsAvailability(
      id: id,
      stylistsId: stylistsId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      isAvailable: isAvailable,
    );
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }
}
