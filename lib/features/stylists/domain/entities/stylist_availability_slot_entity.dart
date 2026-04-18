class StylistAvailabilitySlotEntity {
  const StylistAvailabilitySlotEntity({
    required this.startAt,
    required this.endAt,
    required this.isAvailable,
  });

  final DateTime startAt;
  final DateTime endAt;
  final bool isAvailable;
}
