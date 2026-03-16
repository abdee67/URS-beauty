class StylistsAvailability {
  final int id;
  final String stylists_id;
  final String dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  StylistsAvailability({
    required this.id,
    required this.stylists_id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,

  });
}