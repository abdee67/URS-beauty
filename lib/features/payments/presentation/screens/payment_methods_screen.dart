import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:chapasdk/data/model/initiate_payment.dart';
import 'package:chapasdk/data/model/network_response.dart';
import 'package:chapasdk/data/model/request/direct_charge_request.dart';
import 'package:chapasdk/data/model/request/validate_direct_charge_request.dart';
import 'package:chapasdk/data/model/response/api_error_response.dart';
import 'package:chapasdk/data/model/response/direct_charge_success_response.dart';
import 'package:chapasdk/data/model/response/verify_direct_charge_response.dart';
import 'package:chapasdk/data/services/payment_service.dart';
import 'package:chapasdk/domain/constants/enums.dart' as chapa;
import 'package:chapasdk/domain/constants/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:urs_beauty/config/app_config.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart'
    as payment_domain;
import 'package:urs_beauty/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:urs_beauty/features/payments/presentation/screens/payment_success_screen.dart';

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

  Future<void> _listenForStripeRedirects() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      await Stripe.instance.handleURLCallback(initialLink.toString());
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await Stripe.instance.handleURLCallback(uri.toString());

      if (!mounted || uri.host != 'stripe-redirect') {
        return;
      }

      final payment = context.read<PaymentBloc>().state.activePayment;
      if (payment != null) {
        context.read<PaymentBloc>().add(ConfirmCardPaymentEvent(payment.id));
      }
    });
  }

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
        child: _PaymentUnavailableState(
          icon: Icons.event_available_rounded,
          title: 'Payment opens after service',
          message:
              'You will be able to pay once your stylist marks this appointment as completed.',
          actionLabel: 'Back to bookings',
          onAction: () => Navigator.of(context).pop(false),
        ),
      );
    }

    if (booking.isPaid) {
      return _buildScaffold(
        context,
        child: _PaymentUnavailableState(
          icon: Icons.check_circle_rounded,
          title: 'Already paid',
          message: 'This booking is already paid. You can now leave a review.',
          actionLabel: 'Back to bookings',
          onAction: () => Navigator.of(context).pop(true),
        ),
      );
    }

    if (booking.isPaymentAwaitingVerification) {
      return _buildScaffold(
        context,
        child: _PaymentUnavailableState(
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

    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) async {
        if (state.status == PaymentBlocStatus.paymentSheetReady &&
            state.activePayment != null &&
            !_isPresentingSheet &&
            state.selectedMethod == payment_domain.PaymentMethod.card) {
          await _presentPaymentSheet(state.activePayment!);
          return;
        }
        if (state.status == PaymentBlocStatus.paymentSheetReady &&
            state.activePayment != null &&
            !_isPresentingSheet &&
            state.selectedMethod == payment_domain.PaymentMethod.wallet) {
          await _handleWalletPayment(state.activePayment!);
          return;
        }

        if (state.status == PaymentBlocStatus.failure &&
            state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }

        if ((state.status == PaymentBlocStatus.cancelled ||
                state.status == PaymentBlocStatus.awaitingWebhook) &&
            (state.message?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }

        if (state.status == PaymentBlocStatus.success &&
            state.activePayment != null) {
          final didFinish = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => PaymentSuccessScreen(
                booking: booking,
                payment: state.activePayment!,
                serviceName: serviceLabel.isEmpty
                    ? 'Beauty service'
                    : serviceLabel,
                stylistName: stylistLabel,
              ),
            ),
          );

          if (!context.mounted) {
            return;
          }

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
                _HeroCard(
                  serviceName: serviceLabel.isEmpty
                      ? 'Beauty service'
                      : serviceLabel,
                  stylistName: stylistLabel,
                  amountLabel:
                      '${booking.currency ?? 'ETB'} ${booking.totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 18),
                _SummaryCard(
                  title: serviceLabel.isEmpty ? 'Beauty service' : serviceLabel,
                  stylistName: stylistLabel,
                  dateLabel: localizations.formatMediumDate(
                    booking.scheduledAt,
                  ),
                  timeLabel: localizations.formatTimeOfDay(
                    TimeOfDay.fromDateTime(booking.scheduledAt),
                  ),
                  amountLabel:
                      '${booking.currency ?? 'ETB'} ${booking.totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Payment method',
                  subtitle:
                      'This payment is collected after the service is completed. Card payments are verified securely before the booking is marked paid.',
                  child: Column(
                    children: [
                      _PaymentMethodTile(
                        title: 'Card Payment',
                        subtitle:
                            'Pay now with Stripe after service completion',
                        isSelected:
                            selectedMethod == payment_domain.PaymentMethod.card,
                        enabled: true,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                            const SelectPaymentMethodEvent(
                              payment_domain.PaymentMethod.card,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _PaymentMethodTile(
                        title: 'Wallet',
                        subtitle:
                            'Pay now with Telebirr, CBE Birr, eBirr or M-Pesa after service completion',
                        isSelected:
                            selectedMethod ==
                            payment_domain.PaymentMethod.wallet,
                        enabled: true,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                            const SelectPaymentMethodEvent(
                              payment_domain.PaymentMethod.wallet,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _PaymentMethodTile(
                        title: 'Bank Transfer',
                        subtitle: 'Manual verification coming soon',
                        isSelected:
                            selectedMethod ==
                            payment_domain.PaymentMethod.bankTransfer,
                        enabled: false,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                            const SelectPaymentMethodEvent(
                              payment_domain.PaymentMethod.bankTransfer,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _PaymentMethodTile(
                        title: 'Cash Payment',
                        subtitle:
                            'Confirm with QR or OTP after handing cash to the stylist',
                        isSelected:
                            selectedMethod == payment_domain.PaymentMethod.cash,
                        enabled: true,
                        onTap: () {
                          context.read<PaymentBloc>().add(
                            const SelectPaymentMethodEvent(
                              payment_domain.PaymentMethod.cash,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Safety checks',
                  subtitle:
                      'This post-service flow is guarded to keep the payment accurate and traceable.',
                  child: const Column(
                    children: [
                      _ChecklistItem(
                        'Only completed unpaid bookings can be charged',
                      ),
                      _ChecklistItem('Amount is validated on the server'),
                      _ChecklistItem('Duplicate payment attempts are blocked'),
                      _ChecklistItem(
                        'Payment confirmation is re-checked before success',
                      ),
                      _ChecklistItem(
                        'Receipts and booking status stay in sync after payment',
                      ),
                    ],
                  ),
                ),
                if (isAwaitingWebhook) ...[
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Waiting for payment confirmation',
                    subtitle:
                        'Your payment step is done. We are waiting for the secure webhook to finish syncing the booking record.',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<PaymentBloc>().add(
                            RefreshPaymentStatusEvent(
                              paymentId: activePayment.id,
                              bookingId: booking.id,
                            ),
                          );
                        },
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isBusy
                        ? null
                        : selectedMethod == payment_domain.PaymentMethod.card
                        ? () {
                            context.read<PaymentBloc>().add(
                              CreateCardPaymentEvent(booking),
                            );
                          }
                        : selectedMethod == payment_domain.PaymentMethod.wallet
                        ? () {
                            context.read<PaymentBloc>().add(
                              CreateWalletPaymentEvent(booking),
                            );
                          }
                        : selectedMethod == payment_domain.PaymentMethod.cash
                        ? () => _showCashVerificationOptions(
                            context,
                            booking,
                            serviceLabel.isEmpty
                                ? 'Beauty service'
                                : serviceLabel,
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

  Future<void> _presentPaymentSheet(
    payment_domain.PaymentEntity payment,
  ) async {
    if (_isPresentingSheet) {
      return;
    }

    setState(() {
      _isPresentingSheet = true;
    });

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
      if (!mounted) {
        return;
      }

      context.read<PaymentBloc>().add(ConfirmCardPaymentEvent(payment.id));
    } on StripeException catch (error) {
      if (!mounted) {
        return;
      }

      context.read<PaymentBloc>().add(
        HandleCardPaymentFailureEvent(
          payment.id,
          failureReason:
              error.error.localizedMessage ??
              error.error.message ??
              'Payment was cancelled before completion.',
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.read<PaymentBloc>().add(
        HandleCardPaymentFailureEvent(
          payment.id,
          failureReason: error.toString(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPresentingSheet = false;
        });
      }
    }
  }

  Future<void> _handleWalletPayment(
    payment_domain.PaymentEntity payment,
  ) async {
    if (_isPresentingSheet) {
      return;
    }

    final amount = payment.amount;
    if (amount <= 0) {
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

    setState(() {
      _isPresentingSheet = true;
    });

    final bloc = context.read<PaymentBloc>();
    final result = await showModalBottomSheet<_WalletCheckoutResult>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (checkoutContext) {
        return _ChapaWalletCheckoutSheet(
          publicKey: publicKey,
          payment: payment,
          txRef: txRef,
          initialPhone: _chapaCustomerValue(payment, 'phone'),
          email: _chapaCustomerValue(payment, 'email'),
          firstName: _chapaCustomerValue(payment, 'first_name'),
          lastName: _chapaCustomerValue(payment, 'last_name'),
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isPresentingSheet = false;
    });

    switch (result?.status) {
      case _WalletCheckoutStatus.success:
      case _WalletCheckoutStatus.pending:
        bloc.add(ConfirmWalletPaymentEvent(txRef));
      case _WalletCheckoutStatus.failed:
      case _WalletCheckoutStatus.cancelled:
      case null:
        bloc.add(
          HandleWalletPaymentFailureEvent(
            txRef,
            failureReason:
                result?.message ??
                'Wallet checkout was closed before completion.',
          ),
        );
    }
  }

  String _walletPaymentReference(payment_domain.PaymentEntity payment) {
    final metadataRef = payment.metaData['chapa_tx_ref']?.toString().trim();
    if (metadataRef?.isNotEmpty == true) {
      return metadataRef!;
    }

    final transactionReference = payment.transactionReference?.trim();
    if (transactionReference?.isNotEmpty == true) {
      return transactionReference!;
    }

    return '';
  }

  String _chapaCustomerValue(payment_domain.PaymentEntity payment, String key) {
    final customer = payment.metaData['chapa_customer'];
    if (customer is Map) {
      return customer[key]?.toString() ?? '';
    }

    return '';
  }

  Future<void> _showCashVerificationOptions(
    BuildContext context,
    BookingEntity booking,
    String serviceName,
  ) async {
    final method = await showModalBottomSheet<_CashVerificationMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CashVerificationMethodSheet(
        amountLabel:
            '${booking.currency ?? 'ETB'} ${booking.totalAmount.toStringAsFixed(2)}',
      ),
    );

    if (!mounted || method == null) {
      return;
    }

    switch (method) {
      case _CashVerificationMethod.qr:
        await _showCashQrSheet(booking, serviceName);
        return;
      case _CashVerificationMethod.otp:
        await _showCashOtpSheet(booking, serviceName);
        return;
    }
  }

  Future<void> _showCashQrSheet(
    BookingEntity booking,
    String serviceName,
  ) async {
    final payload = _cashVerificationPayload(booking, 'qr');
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CashQrSheet(
        payload: payload,
        serviceName: serviceName,
        amountLabel:
            '${booking.currency ?? 'ETB'} ${booking.totalAmount.toStringAsFixed(2)}',
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    // context.read<PaymentBloc>().add(ReceiveCashPaymentEvent(booking));
  }

  Future<void> _showCashOtpSheet(
    BookingEntity booking,
    String serviceName,
  ) async {
    final otp = _cashOtp(booking);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CashOtpSheet(
        otp: otp,
        serviceName: serviceName,
        amountLabel:
            '${booking.currency ?? 'ETB'} ${booking.totalAmount.toStringAsFixed(2)}',
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    //context.read<PaymentBloc>().add(ReceiveCashPaymentEvent(booking));
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
    payment_domain.PaymentMethod method,
  ) {
    if (method == payment_domain.PaymentMethod.bankTransfer) {
      return 'Bank transfer coming soon';
    }

    if (method == payment_domain.PaymentMethod.cash) {
      if (state.status == PaymentBlocStatus.confirming) {
        return 'Confirming cash payment...';
      }

      return 'Continue with cash';
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

enum _CashVerificationMethod { qr, otp }

class _CashVerificationMethodSheet extends StatelessWidget {
  const _CashVerificationMethodSheet({required this.amountLabel});

  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return _CashSheetFrame(
      title: 'Cash verification',
      subtitle: amountLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CashMethodButton(
            icon: Icons.qr_code_2_rounded,
            title: 'Show QR code',
            subtitle: 'Stylist scans it to confirm cash receipt',
            onTap: () => Navigator.of(context).pop(_CashVerificationMethod.qr),
          ),
          const SizedBox(height: 12),
          _CashMethodButton(
            icon: Icons.pin_rounded,
            title: 'Generate OTP',
            subtitle: 'Share a short code with your stylist',
            onTap: () => Navigator.of(context).pop(_CashVerificationMethod.otp),
          ),
        ],
      ),
    );
  }
}

class _CashQrSheet extends StatelessWidget {
  const _CashQrSheet({
    required this.payload,
    required this.serviceName,
    required this.amountLabel,
  });

  final String payload;
  final String serviceName;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return _CashSheetFrame(
      title: 'Scan cash QR',
      subtitle: amountLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            serviceName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF43261D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 220,
            height: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8C8B8)),
            ),
            child: QrImageView(
              data: payload,
              version: QrVersions.auto,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 18),
          _CashNotice(
            text:
                'After the stylist scans this code, the server confirms the cash payment and records the commission debit.',
          ),
          const SizedBox(height: 18),
          _CashPrimaryButton(
            label: 'Stylist scanned QR',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

class _CashOtpSheet extends StatefulWidget {
  const _CashOtpSheet({
    required this.otp,
    required this.serviceName,
    required this.amountLabel,
  });

  final String otp;
  final String serviceName;
  final String amountLabel;

  @override
  State<_CashOtpSheet> createState() => _CashOtpSheetState();
}

class _CashOtpSheetState extends State<_CashOtpSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CashSheetFrame(
      title: 'Cash OTP',
      subtitle: widget.amountLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.serviceName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF43261D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8C8B8)),
            ),
            child: Text(
              widget.otp,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF43261D),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _CashNotice(
            text:
                'Share this code with the stylist. When they confirm it, the server records the cash payment and commission debit.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              labelText: 'Enter OTP to confirm',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _CashPrimaryButton(
            label: 'Confirm OTP',
            onPressed: _controller.text.trim() == widget.otp
                ? () => Navigator.of(context).pop(true)
                : null,
          ),
        ],
      ),
    );
  }
}

class _CashSheetFrame extends StatelessWidget {
  const _CashSheetFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBF6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF43261D),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF7B6156),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CashMethodButton extends StatelessWidget {
  const _CashMethodButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFAF5),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1D8CB)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7A4A39), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF43261D),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7B6156),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8B5C49)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashNotice extends StatelessWidget {
  const _CashNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: Color(0xFF8B5C49),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _CashPrimaryButton extends StatelessWidget {
  const _CashPrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B3F32),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

enum _WalletCheckoutStatus { success, pending, failed, cancelled }

class _WalletCheckoutResult {
  const _WalletCheckoutResult({required this.status, required this.message});

  final _WalletCheckoutStatus status;
  final String message;
}

class _ChapaWalletCheckoutSheet extends StatefulWidget {
  const _ChapaWalletCheckoutSheet({
    required this.publicKey,
    required this.payment,
    required this.txRef,
    required this.initialPhone,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  final String publicKey;
  final payment_domain.PaymentEntity payment;
  final String txRef;
  final String initialPhone;
  final String email;
  final String firstName;
  final String lastName;

  @override
  State<_ChapaWalletCheckoutSheet> createState() =>
      _ChapaWalletCheckoutSheetState();
}

class _ChapaWalletCheckoutSheetState extends State<_ChapaWalletCheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _paymentService = PaymentService();
  late final TextEditingController _phoneController;
  chapa.LocalPaymentMethods _selectedMethod =
      chapa.LocalPaymentMethods.telebirr;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate() || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _statusMessage = 'Sending payment request to your wallet...';
    });

    final result = await _chargeWallet();
    if (!mounted) {
      return;
    }

    if (result.status == _WalletCheckoutStatus.failed) {
      setState(() {
        _isProcessing = false;
        _errorMessage = result.message;
        _statusMessage = null;
      });
      return;
    }

    Navigator.of(context).pop(result);
  }

  Future<_WalletCheckoutResult> _chargeWallet() async {
    final phone = _phoneController.text.trim();
    final method = _selectedMethod.value();

    final initiateResponse = await _paymentService.initializeDirectPayment(
      request: DirectChargeRequest(
        mobile: phone,
        firstName: widget.firstName,
        lastName: widget.lastName,
        amount: widget.payment.amount.toStringAsFixed(2),
        currency: widget.payment.currency.toUpperCase(),
        email: widget.email,
        txRef: widget.txRef,
        paymentMethod: method,
      ),
      publicKey: widget.publicKey,
    );

    if (initiateResponse is Success) {
      final body = initiateResponse.body;
      if (body is! DirectChargeSuccessResponse) {
        return const _WalletCheckoutResult(
          status: _WalletCheckoutStatus.failed,
          message: 'Chapa returned an unexpected payment response.',
        );
      }

      final reference = body.data?.meta?.refId?.trim() ?? '';
      if (reference.isEmpty) {
        return _WalletCheckoutResult(
          status: _WalletCheckoutStatus.failed,
          message:
              body.data?.meta?.message ??
              body.message ??
              'Chapa could not start the wallet charge.',
        );
      }

      if (mounted) {
        setState(() {
          _statusMessage = 'Waiting for wallet approval...';
        });
      }

      return _waitForWalletApproval(
        reference: reference,
        phone: phone,
        method: method,
      );
    }

    if (initiateResponse is ApiError) {
      return _WalletCheckoutResult(
        status: _WalletCheckoutStatus.failed,
        message: _apiErrorMessage(initiateResponse.error),
      );
    }

    if (initiateResponse is NetworkError) {
      return const _WalletCheckoutResult(
        status: _WalletCheckoutStatus.failed,
        message: 'Could not reach Chapa. Check your connection and try again.',
      );
    }

    return const _WalletCheckoutResult(
      status: _WalletCheckoutStatus.failed,
      message: 'Unable to start wallet payment. Please try again.',
    );
  }

  Future<_WalletCheckoutResult> _waitForWalletApproval({
    required String reference,
    required String phone,
    required String method,
  }) async {
    for (var attempt = 0; attempt < 8; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }

      final verifyResponse = await _paymentService.verifyPayment(
        body: ValidateDirectChargeRequest(
          reference: reference,
          mobile: phone,
          paymentMethod: method,
        ),
        publicKey: widget.publicKey,
      );

      if (verifyResponse is Success) {
        final body = verifyResponse.body;
        if (body is! ValidateDirectChargeResponse) {
          return const _WalletCheckoutResult(
            status: _WalletCheckoutStatus.pending,
            message: 'Wallet payment is still being confirmed.',
          );
        }

        final status = body.data?.status?.toLowerCase().trim();
        if (status == 'success') {
          return const _WalletCheckoutResult(
            status: _WalletCheckoutStatus.success,
            message: 'Wallet payment approved.',
          );
        }

        if (status == 'pending') {
          if (mounted) {
            setState(() {
              _statusMessage = 'Still waiting for approval on your phone...';
            });
          }
          continue;
        }

        return _WalletCheckoutResult(
          status: _WalletCheckoutStatus.failed,
          message: body.message ?? 'Wallet payment was not completed.',
        );
      }

      if (verifyResponse is ApiError) {
        return _WalletCheckoutResult(
          status: _WalletCheckoutStatus.pending,
          message: _apiErrorMessage(verifyResponse.error),
        );
      }

      if (verifyResponse is NetworkError) {
        return const _WalletCheckoutResult(
          status: _WalletCheckoutStatus.pending,
          message:
              'Wallet payment was sent, but confirmation is still pending.',
        );
      }
    }

    return const _WalletCheckoutResult(
      status: _WalletCheckoutStatus.pending,
      message:
          'Wallet payment is still pending. Approve it on your phone, then check payment status.',
    );
  }

  String _apiErrorMessage(Object? error) {
    if (error is DirectChargeApiError) {
      return error.data?.message ??
          error.message ??
          'Chapa could not process this wallet payment.';
    }

    if (error is ApiErrorResponse) {
      return error.message ?? 'Chapa could not process this wallet payment.';
    }

    final message = error?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Chapa could not process this wallet payment.';
  }

  void _cancel() {
    if (_isProcessing) {
      return;
    }

    Navigator.of(context).pop(
      const _WalletCheckoutResult(
        status: _WalletCheckoutStatus.cancelled,
        message: 'Wallet checkout was cancelled before completion.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    final amountLabel =
        '${widget.payment.currency.toUpperCase()} ${widget.payment.amount.toStringAsFixed(2)}';

    return PopScope(
      canPop: !_isProcessing,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet checkout',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF43261D),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              amountLabel,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFF7B6156),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isProcessing ? null : _cancel,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chapa.LocalPaymentMethods.values.map((method) {
                      return ChoiceChip(
                        label: Text(method.displayName()),
                        selected: _selectedMethod == method,
                        onSelected: _isProcessing
                            ? null
                            : (_) {
                                setState(() {
                                  _selectedMethod = method;
                                });
                              },
                        selectedColor: const Color(0xFFF1D2C0),
                        labelStyle: TextStyle(
                          color: _selectedMethod == method
                              ? const Color(0xFF43261D)
                              : const Color(0xFF7B6156),
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_isProcessing,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Wallet phone number',
                      hintText: '0911121314',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.isEmpty) {
                        return 'Phone number is required.';
                      }

                      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone) ||
                          !RegExp(r'^(09|07|011)').hasMatch(phone)) {
                        return 'Enter a valid Ethiopian wallet phone number.';
                      }

                      return null;
                    },
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF7B6156)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _startPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F32),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _isProcessing ? 'Processing...' : 'Pay with wallet',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.serviceName,
    required this.stylistName,
    required this.amountLabel,
  });

  final String serviceName;
  final String stylistName;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A4A39), Color(0xFFA7684F)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete your service payment',
            style: TextStyle(
              color: Color(0xFFFFE9DC),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            serviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (stylistName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'with $stylistName',
              style: const TextStyle(color: Color(0xFFFFE9DC), fontSize: 15),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Text(
              amountLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentUnavailableState extends StatelessWidget {
  const _PaymentUnavailableState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0D7CB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: const Color(0xFF7A4A39)),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF43261D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7B6156),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.stylistName,
    required this.dateLabel,
    required this.timeLabel,
    required this.amountLabel,
  });

  final String title;
  final String stylistName;
  final String dateLabel;
  final String timeLabel;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Booking summary',
      subtitle:
          'Payment is collected after service completion and only becomes final once payment verification succeeds.',
      child: Column(
        children: [
          _SummaryRow(label: 'Service', value: title),
          _SummaryRow(label: 'Stylist', value: stylistName),
          _SummaryRow(label: 'Date', value: dateLabel),
          _SummaryRow(label: 'Time', value: timeLabel),
          _SummaryRow(label: 'Amount', value: amountLabel, highlight: true),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D7CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7B6156)),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF7E7DA) : const Color(0xFFFFFAF5),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFB67C65)
                  : const Color(0xFFF1D8CB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: enabled
                    ? const Color(0xFF7A4A39)
                    : const Color(0xFFB9A398),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? const Color(0xFF43261D)
                            : const Color(0xFF9B8578),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: enabled
                            ? const Color(0xFF7B6156)
                            : const Color(0xFFAA988D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 18,
            color: Color(0xFF8B5C49),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F463C)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7B6156)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: highlight
                    ? const Color(0xFF6B3F32)
                    : const Color(0xFF43261D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
