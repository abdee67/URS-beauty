import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';

class StylistAvailabilitySlotModel extends StylistAvailabilitySlotEntity {
  const StylistAvailabilitySlotModel({
    required super.startAt,
    required super.endAt,
    required super.isAvailable,
  });
}
