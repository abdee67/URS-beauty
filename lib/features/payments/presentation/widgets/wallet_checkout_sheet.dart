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
import 'package:flutter/services.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// Carries the outcome of a [PaymentChapaWalletCheckoutSheet] session back to
/// the caller via [Navigator.pop].
class WalletCheckoutResult {
  const WalletCheckoutResult({
    required this.status,
    required this.message,
  });

  final WalletCheckoutStatus status;
  final String message;
}

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

/// Modal bottom sheet that drives the full Chapa direct-charge wallet flow:
/// method selection → phone entry → initiate → poll for approval.
///
/// Pops with a [WalletCheckoutResult] on completion or cancellation.
class PaymentChapaWalletCheckoutSheet extends StatefulWidget {
  const PaymentChapaWalletCheckoutSheet({
    super.key,
    required this.publicKey,
    required this.payment,
    required this.txRef,
    required this.initialPhone,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  final String publicKey;
  final PaymentEntity payment;
  final String txRef;
  final String initialPhone;
  final String email;
  final String firstName;
  final String lastName;

  @override
  State<PaymentChapaWalletCheckoutSheet> createState() =>
      _PaymentChapaWalletCheckoutSheetState();
}

class _PaymentChapaWalletCheckoutSheetState
    extends State<PaymentChapaWalletCheckoutSheet> {
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

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate() || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _statusMessage = 'Sending payment request to your wallet...';
    });

    final result = await _chargeWallet();
    if (!mounted) return;

    if (result.status == WalletCheckoutStatus.failed) {
      setState(() {
        _isProcessing = false;
        _errorMessage = result.message;
        _statusMessage = null;
      });
      return;
    }

    Navigator.of(context).pop(result);
  }

  void _cancel() {
    if (_isProcessing) return;
    Navigator.of(context).pop(
      const WalletCheckoutResult(
        status: WalletCheckoutStatus.cancelled,
        message: 'Wallet checkout was cancelled before completion.',
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Chapa direct-charge logic
  // -------------------------------------------------------------------------

  Future<WalletCheckoutResult> _chargeWallet() async {
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
        return const WalletCheckoutResult(
          status: WalletCheckoutStatus.failed,
          message: 'Chapa returned an unexpected payment response.',
        );
      }

      final reference = body.data?.meta?.refId?.trim() ?? '';
      if (reference.isEmpty) {
        return WalletCheckoutResult(
          status: WalletCheckoutStatus.failed,
          message: body.data?.meta?.message ??
              body.message ??
              'Chapa could not start the wallet charge.',
        );
      }

      if (mounted) {
        setState(() => _statusMessage = 'Waiting for wallet approval...');
      }

      return _waitForWalletApproval(
        reference: reference,
        phone: phone,
        method: method,
      );
    }

    if (initiateResponse is ApiError) {
      return WalletCheckoutResult(
        status: WalletCheckoutStatus.failed,
        message: _apiErrorMessage(initiateResponse.error),
      );
    }

    if (initiateResponse is NetworkError) {
      return const WalletCheckoutResult(
        status: WalletCheckoutStatus.failed,
        message: 'Could not reach Chapa. Check your connection and try again.',
      );
    }

    return const WalletCheckoutResult(
      status: WalletCheckoutStatus.failed,
      message: 'Unable to start wallet payment. Please try again.',
    );
  }

  Future<WalletCheckoutResult> _waitForWalletApproval({
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
          return const WalletCheckoutResult(
            status: WalletCheckoutStatus.pending,
            message: 'Wallet payment is still being confirmed.',
          );
        }

        final status = body.data?.status?.toLowerCase().trim();
        if (status == 'success') {
          return const WalletCheckoutResult(
            status: WalletCheckoutStatus.success,
            message: 'Wallet payment approved.',
          );
        }

        if (status == 'pending') {
          if (mounted) {
            setState(
              () => _statusMessage =
                  'Still waiting for approval on your phone...',
            );
          }
          continue;
        }

        return WalletCheckoutResult(
          status: WalletCheckoutStatus.failed,
          message: body.message ?? 'Wallet payment was not completed.',
        );
      }

      if (verifyResponse is ApiError) {
        return WalletCheckoutResult(
          status: WalletCheckoutStatus.pending,
          message: _apiErrorMessage(verifyResponse.error),
        );
      }

      if (verifyResponse is NetworkError) {
        return const WalletCheckoutResult(
          status: WalletCheckoutStatus.pending,
          message:
              'Wallet payment was sent, but confirmation is still pending.',
        );
      }
    }

    return const WalletCheckoutResult(
      status: WalletCheckoutStatus.pending,
      message:
          'Wallet payment is still pending. Approve it on your phone, '
          'then check payment status.',
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
    if (message != null && message.isNotEmpty) return message;
    return 'Chapa could not process this wallet payment.';
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    final amountLabel =
        '${widget.payment.currency.toUpperCase()} '
        '${widget.payment.amount.toStringAsFixed(2)}';

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
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet checkout',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF43261D),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              amountLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
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

                  // Wallet method chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chapa.LocalPaymentMethods.values.map((method) {
                      return ChoiceChip(
                        label: Text(method.displayName()),
                        selected: _selectedMethod == method,
                        onSelected: _isProcessing
                            ? null
                            : (_) => setState(() => _selectedMethod = method),
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

                  // Phone input
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
                      if (phone.isEmpty) return 'Phone number is required.';
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone) ||
                          !RegExp(r'^(09|07|011)').hasMatch(phone)) {
                        return 'Enter a valid Ethiopian wallet phone number.';
                      }
                      return null;
                    },
                  ),

                  // Status message
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color(0xFF7B6156)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Error message
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

                  // Pay button
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
