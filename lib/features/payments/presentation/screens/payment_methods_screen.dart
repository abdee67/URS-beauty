import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
            !_isPresentingSheet) {
          await _presentPaymentSheet(state.activePayment!);
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => PaymentSuccessScreen(
                booking: booking,
                payment: state.activePayment!,
                serviceName:
                    serviceLabel.isEmpty ? 'Beauty service' : serviceLabel,
                stylistName: stylistLabel,
              ),
            ),
          );
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
                  serviceName:
                      serviceLabel.isEmpty ? 'Beauty service' : serviceLabel,
                  stylistName: stylistLabel,
                  amountLabel:
                      '${booking.currency ?? 'ETB'} ${booking.totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 18),
                _SummaryCard(
                  title: serviceLabel.isEmpty ? 'Beauty service' : serviceLabel,
                  stylistName: stylistLabel,
                  dateLabel: localizations.formatMediumDate(booking.scheduledAt),
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
                      'Pay now to secure the appointment. Card payments are verified server-side before we treat the booking as paid.',
                  child: Column(
                    children: [
                      _PaymentMethodTile(
                        title: 'Card Payment',
                        subtitle: 'Instant confirmation with Stripe',
                        isSelected: selectedMethod ==
                            payment_domain.PaymentMethod.card,
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
                        title: 'Bank Transfer',
                        subtitle: 'Manual verification coming soon',
                        isSelected: selectedMethod ==
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
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Safety checks',
                  subtitle:
                      'This flow is guarded to protect both the customer and your business.',
                  child: const Column(
                    children: [
                      _ChecklistItem('Amount is validated on the server'),
                      _ChecklistItem('Duplicate payment attempts are blocked'),
                      _ChecklistItem('Stripe confirmation is re-checked before success'),
                      _ChecklistItem('Pending slot holds are released on cancellation'),
                    ],
                  ),
                ),
                if (isAwaitingWebhook) ...[
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Waiting for Stripe confirmation',
                    subtitle:
                        'Your card step is done. We are waiting for the secure Stripe webhook to finish syncing the booking record.',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<PaymentBloc>().add(
                            RefreshCardPaymentStatusEvent(
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

  Future<void> _presentPaymentSheet(payment_domain.PaymentEntity payment) async {
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

  String _primaryActionLabel(
    PaymentState state,
    payment_domain.PaymentMethod method,
  ) {
    if (method == payment_domain.PaymentMethod.bankTransfer) {
      return 'Bank transfer coming soon';
    }

    switch (state.status) {
      case PaymentBlocStatus.creatingIntent:
        return 'Preparing secure payment...';
      case PaymentBlocStatus.verifying:
        return 'Verifying payment...';
      default:
        return 'Pay now';
    }
  }

  Scaffold _buildScaffold(BuildContext context, {required Widget child}) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(color: Color(0xFF5C2E1F)),
        ),
      ),
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
            'Secure your appointment',
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
              style: const TextStyle(
                color: Color(0xFFFFE9DC),
                fontSize: 15,
              ),
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
          'You will only see the success screen after payment verification.',
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
            ),
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
        onTap: onTap,
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
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5F463C),
              ),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
            ),
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
