part of 'payment_bloc.dart';

enum PaymentBlocStatus {
  initial,
  creatingIntent,
  paymentSheetReady,
  verifying,
  awaitingWebhook,
  success,
  cancelled,
  failure,
}

class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentBlocStatus.initial,
    this.selectedMethod = PaymentMethod.wallet,
    this.activePayment,
    this.message,
    this.errorMessage = '',
  });

  final PaymentBlocStatus status;
  final PaymentMethod selectedMethod;
  final PaymentEntity? activePayment;
  final String? message;
  final String errorMessage;

  bool get isBusy =>
      status == PaymentBlocStatus.creatingIntent ||
      status == PaymentBlocStatus.verifying;

  PaymentState creatingIntent() => copyWith(
    status: PaymentBlocStatus.creatingIntent,
    clearMessage: true,
    clearError: true,
  );

  PaymentState verifying() => copyWith(
    status: PaymentBlocStatus.verifying,
    clearMessage: true,
    clearError: true,
  );

  PaymentState failure(String message) =>
      copyWith(status: PaymentBlocStatus.failure, errorMessage: message);

  PaymentState copyWith({
    PaymentBlocStatus? status,
    PaymentMethod? selectedMethod,
    PaymentEntity? activePayment,
    String? message,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
    bool clearActivePayment = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      activePayment: clearActivePayment
          ? null
          : (activePayment ?? this.activePayment),
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedMethod,
    activePayment,
    message,
    errorMessage,
  ];
}
