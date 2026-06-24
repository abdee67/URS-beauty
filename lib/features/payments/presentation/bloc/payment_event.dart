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

class RefreshPaymentStatusEvent extends PaymentEvent {
  const RefreshPaymentStatusEvent({
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

class CreateWalletPaymentEvent extends PaymentEvent {
  final BookingEntity booking;

  const CreateWalletPaymentEvent(this.booking);
}

class ConfirmWalletPaymentEvent extends PaymentEvent {
  final String paymentReference;

  const ConfirmWalletPaymentEvent(this.paymentReference);
}

class HandleWalletPaymentFailureEvent extends PaymentEvent {
  const HandleWalletPaymentFailureEvent(
    this.paymentReference, {
    this.failureReason,
  });

  final String paymentReference;
  final String? failureReason;

  @override
  List<Object?> get props => [paymentReference, failureReason];
}

class CancelPendingWalletPaymentEvent extends PaymentEvent {
  const CancelPendingWalletPaymentEvent(this.paymentId);

  final String paymentId;

  @override
  List<Object?> get props => [paymentId];
}
