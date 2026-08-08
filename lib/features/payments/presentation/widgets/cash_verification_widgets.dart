import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';

// ---------------------------------------------------------------------------
// Shared primitives
// ---------------------------------------------------------------------------

/// Shared bottom-sheet chrome: rounded top corners, title/subtitle header,
/// close button, and keyboard-inset padding.
class PaymentCashSheetFrame extends StatelessWidget {
  const PaymentCashSheetFrame({
    super.key,
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

/// Tappable option row used inside [PaymentCashVerificationMethodSheet].
class PaymentCashMethodButton extends StatelessWidget {
  const PaymentCashMethodButton({
    super.key,
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
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8B5C49),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Informational notice row with an info icon. Used inside cash sheets.
class PaymentCashNotice extends StatelessWidget {
  const PaymentCashNotice({super.key, required this.text});

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

/// Full-width primary action button shared by all cash bottom sheets.
class PaymentCashPrimaryButton extends StatelessWidget {
  const PaymentCashPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

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

// ---------------------------------------------------------------------------
// Cash verification sheets
// ---------------------------------------------------------------------------

/// First step of the cash flow: lets the customer choose between QR and OTP.
/// Pops with a [CashVerificationMethod] value.
class PaymentCashVerificationMethodSheet extends StatelessWidget {
  const PaymentCashVerificationMethodSheet({
    super.key,
    required this.amountLabel,
  });

  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return PaymentCashSheetFrame(
      title: 'Cash verification',
      subtitle: amountLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaymentCashMethodButton(
            icon: Icons.qr_code_2_rounded,
            title: 'Show QR code',
            subtitle: 'Stylist scans it to confirm cash receipt',
            onTap: () =>
                Navigator.of(context).pop(CashVerificationMethod.qr),
          ),
          const SizedBox(height: 12),
          PaymentCashMethodButton(
            icon: Icons.pin_rounded,
            title: 'Generate OTP',
            subtitle: 'Share a short code with your stylist',
            onTap: () =>
                Navigator.of(context).pop(CashVerificationMethod.otp),
          ),
        ],
      ),
    );
  }
}

/// Shows a QR code the stylist scans to confirm cash receipt.
/// Pops with `true` when the customer taps "Stylist scanned QR".
class PaymentCashQrSheet extends StatelessWidget {
  const PaymentCashQrSheet({
    super.key,
    required this.payload,
    required this.serviceName,
    required this.amountLabel,
  });

  final String payload;
  final String serviceName;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return PaymentCashSheetFrame(
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
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF43261D),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF43261D),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const PaymentCashNotice(
            text:
                'After the stylist scans this code, the server confirms the '
                'cash payment and records the commission debit.',
          ),
          const SizedBox(height: 18),
          PaymentCashPrimaryButton(
            label: 'Stylist scanned QR',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

/// Shows a generated OTP the customer shares with the stylist.
/// The customer must re-enter the OTP to enable the confirm button.
/// Pops with `true` when confirmed.
class PaymentCashOtpSheet extends StatefulWidget {
  const PaymentCashOtpSheet({
    super.key,
    required this.otp,
    required this.serviceName,
    required this.amountLabel,
  });

  final String otp;
  final String serviceName;
  final String amountLabel;

  @override
  State<PaymentCashOtpSheet> createState() => _PaymentCashOtpSheetState();
}

class _PaymentCashOtpSheetState extends State<PaymentCashOtpSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaymentCashSheetFrame(
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
          const PaymentCashNotice(
            text:
                'Share this code with the stylist. When they confirm it, the '
                'server records the cash payment and commission debit.',
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
          PaymentCashPrimaryButton(
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
