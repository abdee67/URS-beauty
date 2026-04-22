part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class SelectPaymentMethodEvent extends PaymentEvent {
  const SelectPaymentMethodEvent(this.method);

  final PaymentMethod method;

  @override
  List<Object?> get props => [method];
}

class CreateCardPaymentEvent extends PaymentEvent {
  const CreateCardPaymentEvent(this.booking);

  final BookingEntity booking;

  @override
  List<Object?> get props => [booking];
}

class ConfirmCardPaymentEvent extends PaymentEvent {
  const ConfirmCardPaymentEvent(this.paymentReference);

  final String paymentReference;

  @override
  List<Object?> get props => [paymentReference];
}

class RefreshCardPaymentStatusEvent extends PaymentEvent {
  const RefreshCardPaymentStatusEvent({
    required this.paymentId,
    required this.bookingId,
  });

  final String paymentId;
  final String bookingId;

  @override
  List<Object?> get props => [paymentId, bookingId];
}

class HandleCardPaymentFailureEvent extends PaymentEvent {
  const HandleCardPaymentFailureEvent(
    this.paymentReference, {
    this.failureReason,
  });

  final String paymentReference;
  final String? failureReason;

  @override
  List<Object?> get props => [paymentReference, failureReason];
}

class CancelPendingCardPaymentEvent extends PaymentEvent {
  const CancelPendingCardPaymentEvent(this.paymentId);

  final String paymentId;

  @override
  List<Object?> get props => [paymentId];
}

class ClearPaymentMessageEvent extends PaymentEvent {
  const ClearPaymentMessageEvent();
}
