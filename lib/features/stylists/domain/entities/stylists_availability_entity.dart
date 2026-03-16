class StylistsAvailability {
  final int id;
  final String stylistsId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  StylistsAvailability({
    required this.id,
    required this.stylistsId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,

  });
}