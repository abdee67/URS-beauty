import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';

class StylistsAvailabilityModel extends  StylistsAvailability {

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
      id: json['id'],
      stylistsId: json['stylists_Id'],
      dayOfWeek: json['day_of_Week'],
      startTime: (json['start_time']),
      endTime: (json['end_time']),
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stylists_Id': stylistsId,
      'day_of_Week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'isAvailable': isAvailable,
    };
  }
}