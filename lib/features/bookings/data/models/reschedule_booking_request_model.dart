import 'package:urs_beauty/features/bookings/domain/entities/reschedule_booking_request.dart';

class RescheduleBookingRequestModel extends RescheduleBookingRequestEntity {
  const RescheduleBookingRequestModel({
    required super.bookingId,
    required super.stylistId,
    required super.scheduledAt,
  });

  Map<String, dynamic> toRpcParams() {
    return <String, dynamic>{
      'p_booking_id': bookingId,
      'p_new_stylist_id': stylistId,
      'p_new_scheduled_at': scheduledAt.toUtc().toIso8601String(),
    };
  }
}
