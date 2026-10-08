import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:urs_beauty/features/payments/presentation/screens/payment_success_screen.dart';
import 'package:urs_beauty/features/payments/presentation/widgets/cash_verification_widgets.dart';
import 'package:urs_beauty/features/payments/presentation/widgets/payment_hero_card.dart';
import 'package:urs_beauty/features/payments/presentation/widgets/payment_method_tile.dart';
import 'package:urs_beauty/features/payments/presentation/widgets/payment_summary_widgets.dart';
import 'package:urs_beauty/features/payments/presentation/widgets/wallet_checkout_sheet.dart';
import 'package:urs_beauty/config/app_config.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({
    super.key,
    this.booking,
    this.serviceName = '',
    this.stylistName = '',
  });

  final BookingEntity? booking;
  final String serviceName;
  final String stylistName;

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isPresentingSheet = false;

  @override
  void initState() {
    super.initState();
    _listenForStripeRedirects();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Stripe deep-link listener
  // ---------------------------------------------------------------------------

  Future<void> _listenForStripeRedirects() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      await Stripe.instance.handleURLCallback(initialLink.toString());
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await Stripe.instance.handleURLCallback(uri.toString());

      if (!mounted || uri.host != 'stripe-redirect') return;

      final payment = context.read<PaymentBloc>().state.activePayment;
      if (payment != null) {
        context.read<PaymentBloc>().add(ConfirmCardPaymentEvent(payment.id));
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    if (booking == null) {
      return _buildScaffold(
        context,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Choose a booking first, then come here to complete payment.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (booking.status != BookingStatus.completed) {
      return _buildScaffold(
        context,
        child: PaymentUnavailableState(
          icon: Icons.event_available_rounded,
          title: 'Payment opens after service',
          message:
              'You will be able to pay once your stylist marks this '
              'appointment as completed.',
          actionLabel: 'Back to bookings',
          onAction: () => Navigator.of(context).pop(false),
        ),
      );
    }

    if (booking.isPaid) {
      return _buildScaffold(
        context,
        child: PaymentUnavailableState(
          icon: Icons.check_circle_rounded,
          title: 'Already paid',
          message:
              'This booking is already paid. You can now leave a review.',
          actionLabel: 'Back to bookings',
          onAction: () => Navigator.of(context).pop(true),
        ),
      );
    }

    if (booking.isPaymentAwaitingVerification) {
      return _buildScaffold(
        context,
        child: PaymentUnavailableState(
          icon: Icons.hourglass_top_rounded,
          title: 'Payment is being verified',
          message:
              'Confirming this payment. Return to bookings and refresh shortly.',
          actionLabel: 'Back to bookings',
          onAction: () => Navigator.of(context).pop(true),
        ),
      );
    }

    final localizations = MaterialLocalizations.of(context);
    final serviceLabel = widget.serviceName.isNotEmpty
        ? widget.serviceName
        : booking.serviceName;
    final stylistLabel = widget.stylistName.isNotEmpty
        ? widget.stylistName
        : booking.stylistName;
    final displayService =
        serviceLabel.isEmpty ? 'Beauty service' : serviceLabel;
    final amountLabel =
        '${booking.currency ?? 'ETB'} ${booking.totalAmount.toStringAsFixed(2)}';

    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) async {
        // Card sheet
        if (state.status == PaymentBlocStatus.paymentSheetReady &&
            state.activePayment != null &&
            !_isPresentingSheet &&
            state.selectedMethod == PaymentMethod.card) {
          await _presentPaymentSheet(state.activePayment!);
          return;
        }

        // Wallet sheet
        if (state.status == PaymentBlocStatus.paymentSheetReady &&
            state.activePayment != null &&
            !_isPresentingSheet &&
            state.selectedMethod == PaymentMethod.wallet) {
          await _handleWalletPayment(state.activePayment!);
          return;
        }

        // Error snackbar
        if (state.status == PaymentBlocStatus.failure &&
            state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }

        // Cancelled / webhook snackbar
        if ((state.status == PaymentBlocStatus.cancelled ||
                state.status == PaymentBlocStatus.awaitingWebhook) &&
            (state.message?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }

        // Success → navigate to receipt screen
        if (state.status == PaymentBlocStatus.success &&
            state.activePayment != null) {
          final didFinish = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => PaymentSuccessScreen(
                booking: booking,
                payment: state.activePayment!,
                serviceName: displayService,
                stylistName: stylistLabel,
              ),
            ),
          );

          if (!context.mounted) return;
          Navigator.of(context).pop(didFinish ?? true);
        }
      },
      builder: (context, state) {
        final selectedMethod = state.selectedMethod;
        final activePayment = state.activePayment;
        final isAwaitingWebhook =
            state.status == PaymentBlocStatus.awaitingWebhook &&
            activePayment != null;

        return _buildScaffold(
          context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero banner
                PaymentHeroCard(
                  serviceName: displayService,
                  stylistName: stylistLabel,
                  amountLabel: amountLabel,
                ),
                const SizedBox(height: 18),

                // Booking summary
                PaymentSummaryCard(
                  title: displayService,
                  stylistName: stylistLabel,
                  dateLabel: localizations.formatMediumDate(
                    booking.scheduledAt,
                  ),
                  timeLabel: localizations.formatTimeOfDay(
                    TimeOfDay.fromDateTime(booking.scheduledAt),
                  ),
                  amountLabel: amountLabel,
                ),
                const SizedBox(height: 18),

                // Payment method selector
                PaymentSectionCard(
                  title: 'Payment method',
                  subtitle:
                      'This payment is collected after the service is '
                      'completed. Card payments are verified securely before '
                      'the booking is marked paid.',
                  child: Column(
                    children: [
                      PaymentMethodTile(
                        title: 'Card Payment',
                        subtitle:
                            'Pay now with Stripe after service completion',
                        isSelected: selectedMethod == PaymentMethod.card,
                        enabled: true,
                        onTap: () => context.read<PaymentBloc>().add(
                          const SelectPaymentMethodEvent(PaymentMethod.card),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PaymentMethodTile(
                        title: 'Wallet',
                        subtitle:
                            'Pay now with Telebirr, CBE Birr, eBirr or '
                            'M-Pesa after service completion',
                        isSelected: selectedMethod == PaymentMethod.wallet,
                        enabled: true,
                        onTap: () => context.read<PaymentBloc>().add(
                          const SelectPaymentMethodEvent(PaymentMethod.wallet),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PaymentMethodTile(
                        title: 'Bank Transfer',
                        subtitle: 'Manual verification coming soon',
                        isSelected:
                            selectedMethod == PaymentMethod.bankTransfer,
                        enabled: false,
                        onTap: () => context.read<PaymentBloc>().add(
                          const SelectPaymentMethodEvent(
                            PaymentMethod.bankTransfer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PaymentMethodTile(
                        title: 'Cash Payment',
                        subtitle:
                            'Confirm with QR or OTP after handing cash to '
                            'the stylist',
                        isSelected: selectedMethod == PaymentMethod.cash,
                        enabled: true,
                        onTap: () => context.read<PaymentBloc>().add(
                          const SelectPaymentMethodEvent(PaymentMethod.cash),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Safety checks
                const PaymentSectionCard(
                  title: 'Safety checks',
                  subtitle:
                      'This post-service flow is guarded to keep the payment '
                      'accurate and traceable.',
                  child: Column(
                    children: [
                      PaymentChecklistItem(
                        'Only completed unpaid bookings can be charged',
                      ),
                      PaymentChecklistItem(
                        'Amount is validated on the server',
                      ),
                      PaymentChecklistItem(
                        'Duplicate payment attempts are blocked',
                      ),
                      PaymentChecklistItem(
                        'Payment confirmation is re-checked before success',
                      ),
                      PaymentChecklistItem(
                        'Receipts and booking status stay in sync after payment',
                      ),
                    ],
                  ),
                ),

                // Webhook pending card
                if (isAwaitingWebhook) ...[
                  const SizedBox(height: 18),
                  PaymentSectionCard(
                    title: 'Waiting for payment confirmation',
                    subtitle:
                        'Your payment step is done. We are waiting for the '
                        'secure webhook to finish syncing the booking record.',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<PaymentBloc>().add(
                          RefreshPaymentStatusEvent(
                            paymentId: activePayment.id,
                            bookingId: booking.id,
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Check payment status'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7A4A39),
                          side: const BorderSide(color: Color(0xFFD9B7A9)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),

                // Primary action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isBusy
                        ? null
                        : selectedMethod == PaymentMethod.card
                        ? () => context
                              .read<PaymentBloc>()
                              .add(CreateCardPaymentEvent(booking))
                        : selectedMethod == PaymentMethod.wallet
                        ? () => context
                              .read<PaymentBloc>()
                              .add(CreateWalletPaymentEvent(booking))
                        : selectedMethod == PaymentMethod.cash
                        ? () => _showCashVerificationOptions(
                              context,
                              booking,
                              displayService,
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F32),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _primaryActionLabel(state, selectedMethod),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Stripe card sheet
  // ---------------------------------------------------------------------------

  Future<void> _presentPaymentSheet(PaymentEntity payment) async {
    if (_isPresentingSheet) return;

    setState(() => _isPresentingSheet = true);

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'URS Beauty',
          paymentIntentClientSecret: payment.paymentIntentClientSecret,
          style: ThemeMode.light,
          returnURL: 'ursbeauty://stripe-redirect',
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
                name: CollectionMode.always,
                email: CollectionMode.automatic,
                phone: CollectionMode.automatic,
                address: AddressCollectionMode.automatic,
              ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;

      context.read<PaymentBloc>().add(ConfirmCardPaymentEvent(payment.id));
    } on StripeException catch (error) {
      if (!mounted) return;
      context.read<PaymentBloc>().add(
        HandleCardPaymentFailureEvent(
          payment.id,
          failureReason: error.error.localizedMessage ??
              error.error.message ??
              'Payment was cancelled before completion.',
        ),
      );
    } catch (error) {
      if (!mounted) return;
      context.read<PaymentBloc>().add(
        HandleCardPaymentFailureEvent(
          payment.id,
          failureReason: error.toString(),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPresentingSheet = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Chapa wallet sheet
  // ---------------------------------------------------------------------------

  Future<void> _handleWalletPayment(PaymentEntity payment) async {
    if (_isPresentingSheet) return;

    if (payment.amount <= 0) {
      context.read<PaymentBloc>().add(
        HandleWalletPaymentFailureEvent(
          payment.id,
          failureReason: 'Payment amount must be greater than 0.',
        ),
      );
      return;
    }

    final publicKey = AppConfig.chapaPublicKey.trim();
    final txRef = _walletPaymentReference(payment);

    if (publicKey.isEmpty || txRef.isEmpty) {
      context.read<PaymentBloc>().add(
        HandleWalletPaymentFailureEvent(
          payment.id,
          failureReason: publicKey.isEmpty
              ? 'Chapa public key is not configured.'
              : 'Wallet payment reference is missing.',
        ),
      );
      return;
    }

    setState(() => _isPresentingSheet = true);

    final bloc = context.read<PaymentBloc>();
    final result = await showModalBottomSheet<WalletCheckoutResult>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentChapaWalletCheckoutSheet(
        publicKey: publicKey,
        payment: payment,
        txRef: txRef,
        initialPhone: _chapaCustomerValue(payment, 'phone'),
        email: _chapaCustomerValue(payment, 'email'),
        firstName: _chapaCustomerValue(payment, 'first_name'),
        lastName: _chapaCustomerValue(payment, 'last_name'),
      ),
    );

    if (!mounted) return;
    setState(() => _isPresentingSheet = false);

    switch (result?.status) {
      case WalletCheckoutStatus.success:
      case WalletCheckoutStatus.pending:
        bloc.add(ConfirmWalletPaymentEvent(txRef));
      case WalletCheckoutStatus.failed:
      case WalletCheckoutStatus.cancelled:
      case null:
        bloc.add(
          HandleWalletPaymentFailureEvent(
            txRef,
            failureReason: result?.message ??
                'Wallet checkout was closed before completion.',
          ),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Cash verification sheets
  // ---------------------------------------------------------------------------

  Future<void> _showCashVerificationOptions(
    BuildContext context,
    BookingEntity booking,
    String serviceName,
  ) async {
    final method = await showModalBottomSheet<CashVerificationMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PaymentCashVerificationMethodSheet(
        amountLabel:
            '${booking.currency ?? 'ETB'} '
            '${booking.totalAmount.toStringAsFixed(2)}',
      ),
    );

    if (!mounted || method == null) return;

    switch (method) {
      case CashVerificationMethod.qr:
        await _showCashQrSheet(booking, serviceName);
      case CashVerificationMethod.otp:
        await _showCashOtpSheet(booking, serviceName);
    }
  }

  Future<void> _showCashQrSheet(
    BookingEntity booking,
    String serviceName,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PaymentCashQrSheet(
        payload: _cashVerificationPayload(booking, 'qr'),
        serviceName: serviceName,
        amountLabel:
            '${booking.currency ?? 'ETB'} '
            '${booking.totalAmount.toStringAsFixed(2)}',
      ),
    );

    if (!mounted || confirmed != true) return;

    // The stylist's scan already triggered receive-cash-payment (stylist-only
    // function). Here the customer records their own confirmation.
    context.read<PaymentBloc>().add(
      CustomerConfirmCashPaymentEvent(booking.customerId, booking.id),
    );
  }

  Future<void> _showCashOtpSheet(
    BookingEntity booking,
    String serviceName,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PaymentCashOtpSheet(
        otp: _cashOtp(booking),
        serviceName: serviceName,
        amountLabel:
            '${booking.currency ?? 'ETB'} '
            '${booking.totalAmount.toStringAsFixed(2)}',
      ),
    );

    if (!mounted || confirmed != true) return;

    // The stylist entering this OTP already triggered receive-cash-payment
    // (stylist-only function). Here the customer records their own confirmation.
    context.read<PaymentBloc>().add(
      CustomerConfirmCashPaymentEvent(booking.customerId, booking.id),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _walletPaymentReference(PaymentEntity payment) {
    final metadataRef = payment.metaData['chapa_tx_ref']?.toString().trim();
    if (metadataRef?.isNotEmpty == true) return metadataRef!;

    final txRef = payment.transactionReference?.trim();
    if (txRef?.isNotEmpty == true) return txRef!;

    return '';
  }

  String _chapaCustomerValue(PaymentEntity payment, String key) {
    final customer = payment.metaData['chapa_customer'];
    if (customer is Map) return customer[key]?.toString() ?? '';
    return '';
  }

  String _cashVerificationPayload(BookingEntity booking, String mode) {
    return Uri(
      scheme: 'ursbeauty',
      host: 'cash-payment',
      queryParameters: <String, String>{
        'booking_id': booking.id,
        'customer_id': booking.customerId,
        'stylist_id': booking.stylistId,
        'mode': mode,
      },
    ).toString();
  }

  String _cashOtp(BookingEntity booking) {
    final source = '${booking.id}:${booking.customerId}:${booking.stylistId}';
    final hash = source.codeUnits.fold<int>(
      0,
      (value, codeUnit) => (value * 31 + codeUnit) & 0x7fffffff,
    );
    return (100000 + hash % 900000).toString();
  }

  String _primaryActionLabel(
    PaymentState state,
    PaymentMethod? method,
  ) {
    if (method == PaymentMethod.bankTransfer) {
      return 'Bank transfer coming soon';
    }

    if (method == PaymentMethod.cash) {
      return state.status == PaymentBlocStatus.confirming
          ? 'Confirming cash payment...'
          : 'Continue with cash';
    }

    switch (state.status) {
      case PaymentBlocStatus.creatingIntent:
        return 'Preparing secure payment...';
      case PaymentBlocStatus.verifying:
        return 'Verifying payment...';
      case PaymentBlocStatus.confirming:
        return 'Confirming payment...';
      default:
        return 'Pay now';
    }
  }

  Scaffold _buildScaffold(BuildContext context, {required Widget child}) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4EA), Color(0xFFFFE0C7)],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
