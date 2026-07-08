import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_theme.dart';
import 'booking_text_field.dart';

enum PaymentMethod { mobileMoney, card, cash }

class StepBookingDetails extends StatefulWidget {
  const StepBookingDetails({
    super.key,
    required this.nameController,
    required this.seatsController,
    required this.maxSeats,
    required this.selectedPayment,
    required this.onPaymentChanged,
  });

  final TextEditingController nameController;
  final TextEditingController seatsController;
  final int maxSeats;
  final PaymentMethod? selectedPayment;
  final ValueChanged<PaymentMethod> onPaymentChanged;

  @override
  State<StepBookingDetails> createState() => _StepBookingDetailsState();
}

class _StepBookingDetailsState extends State<StepBookingDetails> {
  int get _seats => int.tryParse(widget.seatsController.text) ?? 1;

  void _setSeats(int value) {
    final clamped = value.clamp(1, widget.maxSeats);
    setState(() {
      widget.seatsController.text = clamped.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.seatsController.text.isEmpty) {
      widget.seatsController.text = '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(label: 'Full Name'),
          const SizedBox(height: 8),
          BookingTextField(
            controller: widget.nameController,
            hint: 'e.g. Jean Pierre Habimana',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 24),

          const FieldLabel(label: 'Number of Seats'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _setSeats(_seats - 1),
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppColors.primary),
                ),
                Text('$_seats',
                    style: GoogleFonts.sora(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: () => _setSeats(_seats + 1),
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const FieldLabel(label: 'Payment Method'),
          const SizedBox(height: 8),
          Column(
            children: PaymentMethod.values.map((method) {
              final selected = widget.selectedPayment == method;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => widget.onPaymentChanged(method),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.08)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFFE5E7F0),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_paymentIcon(method),
                            size: 18,
                            color: selected
                                ? AppColors.primary
                                : AppColors.bodyTextSecondary),
                        const SizedBox(width: 10),
                        Text(_paymentLabel(method),
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.bodyText)),
                        const Spacer(),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 18,
                          color: selected
                              ? AppColors.primary
                              : AppColors.bodyTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _paymentIcon(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.mobileMoney:
        return Icons.phone_android_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.cash:
        return Icons.payments_outlined;
    }
  }

  String _paymentLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cash:
        return 'Cash at boarding';
    }
  }
}