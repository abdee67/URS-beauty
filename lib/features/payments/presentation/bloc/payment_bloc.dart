import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart'
    hide PaymentStatus;
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/usecases/cancel_pending_payment.dart';
import 'package:urs_beauty/features/payments/domain/usecases/confirm_payment.dart';
import 'package:urs_beauty/features/payments/domain/usecases/create_payment.dart';
import 'package:urs_beauty/features/payments/domain/usecases/get_payment_status.dart';
import 'package:urs_beauty/features/payments/domain/usecases/handle_payment_faillure.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required this.createCardPayment,
    required this.confirmCardPayment,
    required this.handleCardPaymentFailure,
    required this.getPaymentStatus,
    required this.cancelPendingCardPayment,
    required this.cancelPendingWalletPayment,
    required this.handleWalletPaymentFailure,
    required this.createWalletPayment,
    required this.confirmWalletPayment,
  }) : super(const PaymentState()) {
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<CreateCardPaymentEvent>(_onCreateCardPayment);
    on<ConfirmCardPaymentEvent>(_onConfirmCardPayment);
    on<RefreshPaymentStatusEvent>(_onRefreshPaymentStatus);
    on<HandleCardPaymentFailureEvent>(_onHandleCardPaymentFailure);
    on<CancelPendingCardPaymentEvent>(_onCancelPendingCardPayment);
    on<ClearPaymentMessageEvent>(_onClearPaymentMessage);
    
  }

  final CreateCardPaymentUseCase createCardPayment;
  final ConfirmCardPaymentUseCase confirmCardPayment;
  final HandleCardPaymentFailureUseCase handleCardPaymentFailure;
  final GetPaymentStatusUseCase getPaymentStatus;
  final CancelPendingCardPaymentUseCase cancelPendingCardPayment;
  final CancelPendingWalletPaymentUseCase cancelPendingWalletPayment;
  final HandleWalletPaymentFailureUseCase handleWalletPaymentFailure;
  final CreateWalletPaymentUseCase createWalletPayment;
  final ConfirmWalletPaymentUseCase confirmWalletPayment;
  

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<PaymentState> emit,
  ) {
    emit(
      state.copyWith(
        selectedMethod: event.method,
        message: switch (event.method) {
          PaymentMethod.bankTransfer =>
            'Manual bank transfer verification is coming soon.',
          PaymentMethod.cash => 'Cash payment support is coming soon.',
          PaymentMethod.card => null,
          PaymentMethod.wallet => null,
        },
        clearError: true,
      ),
    );
  }

  Future<void> _onCreateCardPayment(
    CreateCardPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final booking = event.booking;
    if (!booking.canCollectPostServicePayment) {
      final message = booking.status != BookingStatus.completed
          ? 'Card payment is only available after the stylist marks the service as completed.'
          : booking.isPaid
          ? 'This booking has already been paid. There is nothing left to charge.'
          : booking.isPaymentAwaitingVerification
          ? 'This payment is already being verified. Please refresh your bookings shortly.'
          : 'This booking is not ready for card payment yet.';

      emit(state.failure(message));
      return;
    }

    emit(state.creatingIntent());

    final now = DateTime.now();
    final paymentSeed = PaymentEntity(
      id: '',
      bookingId: booking.id,
      customerId: booking.customerId,
      paymentMethod: PaymentMethod.card,
      paymentType: PaymentType.payment,
      status: PaymentStatus.pending,
      amount: booking.totalAmount,
      currency: booking.currency ?? 'ETB',
      createdAt: now,
      updatedAt: now,
    );

    final result = await createCardPayment(booking.id, paymentSeed);
    result.fold((failure) => emit(state.failure(failure.message)), (payment) {
      if (payment.isSuccessful) {
        emit(
          state.copyWith(
            status: PaymentBlocStatus.success,
            activePayment: payment,
            message: 'Payment has already been confirmed.',
            clearError: true,
          ),
        );
        return;
      }

      if ((payment.paymentIntentClientSecret ?? '').trim().isEmpty) {
        emit(
          state.failure(
            'Unable to prepare secure card payment. Please try again.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: PaymentBlocStatus.paymentSheetReady,
          activePayment: payment,
          message: 'Secure card payment is ready.',
          clearError: true,
        ),
      );
    });
  }

  Future<void> _onConfirmCardPayment(
    ConfirmCardPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.verifying());

    final result = await confirmCardPayment(event.paymentReference);
    await result.fold(
      (failure) async => emit(state.failure(failure.message)),
      (payment) async => _resolvePaymentState(payment, emit),
    );
  }

  Future<void> _onRefreshPaymentStatus(
    RefreshPaymentStatusEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.verifying());

    final result = await getPaymentStatus(event.paymentId, event.bookingId);
    await result.fold(
      (failure) async => emit(state.failure(failure.message)),
      (payment) async => _resolvePaymentState(payment, emit),
    );
  }

  Future<void> _onHandleCardPaymentFailure(
    HandleCardPaymentFailureEvent event,
    Emitter<PaymentState> emit,
  ) async {
    if (event.paymentReference.trim().isEmpty) {
      emit(
        state.copyWith(
          status: PaymentBlocStatus.cancelled,
          message:
              event.failureReason ??
              'Payment was cancelled before it could be started.',
          clearError: true,
        ),
      );
      return;
    }

    final result = await handleCardPaymentFailure(event.paymentReference);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (payment) => emit(
        state.copyWith(
          status: PaymentBlocStatus.cancelled,
          activePayment: payment,
          message:
              event.failureReason ??
              payment.failureReason ??
              'Payment was cancelled before it was completed.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCancelPendingCardPayment(
    CancelPendingCardPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final result = await cancelPendingCardPayment(event.paymentId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (payment) => emit(
        state.copyWith(
          status: PaymentBlocStatus.cancelled,
          activePayment: payment,
          message: 'Pending payment was cancelled.',
          clearError: true,
        ),
      ),
    );
  }

  void _onClearPaymentMessage(
    ClearPaymentMessageEvent event,
    Emitter<PaymentState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }

  Future<void> _resolvePaymentState(
    PaymentEntity payment,
    Emitter<PaymentState> emit,
  ) async {
    if (payment.isSuccessful ||
        payment.status == PaymentStatus.refunded ||
        payment.status == PaymentStatus.partiallyRefunded) {
      emit(
        state.copyWith(
          status: PaymentBlocStatus.success,
          activePayment: payment,
          message: 'Payment confirmed successfully.',
          clearError: true,
        ),
      );
      return;
    }

    if (payment.status == PaymentStatus.failed) {
      emit(state.failure(payment.failureReason ?? 'Payment failed.'));
      return;
    }

    if (payment.status == PaymentStatus.cancelled) {
      emit(
        state.copyWith(
          status: PaymentBlocStatus.cancelled,
          activePayment: payment,
          message: payment.failureReason ?? 'Payment was cancelled.',
          clearError: true,
        ),
      );
      return;
    }

    final resolvedPayment = await _pollForPaymentConfirmation(
      payment.id,
      payment.bookingId,
    );

    if (resolvedPayment == null) {
      emit(
        state.copyWith(
          status: PaymentBlocStatus.awaitingWebhook,
          activePayment: payment,
          message:
              'Stripe is still confirming this payment. Use "Check payment '
              'status" if the success screen does not appear shortly.',
          clearError: true,
        ),
      );
      return;
    }

    await _resolvePaymentState(resolvedPayment, emit);
  }

  Future<PaymentEntity?> _pollForPaymentConfirmation(
    String paymentId,
    String bookingId,
  ) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));

      final result = await getPaymentStatus(paymentId, bookingId);
      if (result.isLeft()) {
        continue;
      }

      final payment = result.fold((_) => null, (value) => value);
      if (payment == null) {
        continue;
      }

      if (payment.isSuccessful || payment.status.isTerminal) {
        return payment;
      }
    }

    return null;
  }
}
