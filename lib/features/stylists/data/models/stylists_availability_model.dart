import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/core/constants/app_strings.dart';

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
      id: AppStrings.asString(json['id']),
      stylistsId: AppStrings.asString(json['stylists_id']),
      dayOfWeek: AppStrings.asString(json['day_of_week']),
      startTime: AppStrings.asString(json['start_time']),
      endTime: AppStrings.asString(json['end_time']),
      isAvailable: AppStrings.asBool(json['is_available']),
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
}
