import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/schedule_model.dart';
import '../../../views/home/widgets/popular_trips.dart';

const int kServiceFee = 200;

enum PaymentMethod { mtn, airtel, card }

class StepConfirmPay extends StatefulWidget {
  const StepConfirmPay({
    super.key,
    required this.schedule,
    required this.selectedSeat,
    required this.passengerName,
    required this.passengerId,
    required this.onPaymentMethodChanged,
    required this.phoneController,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.selectedMethod,
    this.readOnly = false,
  });

  final ScheduleModel schedule;
  final int? selectedSeat;
  final String passengerName;
  final String passengerId;
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final TextEditingController phoneController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  /// When true, hides the payment method toggle + fields (summary only)
  final bool readOnly;

  @override
  State<StepConfirmPay> createState() => _StepConfirmPayState();
}

class _StepConfirmPayState extends State<StepConfirmPay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _total => widget.schedule.price.toInt() + kServiceFee;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order Summary ──────────────────────────────────────────
              _SectionTitle(title: 'Order Summary'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFE5E7F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Route
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          _CityChip(
                              city: widget.schedule.origin,
                              color: AppColors.primary),
                          const Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Color(0xFFCDD0DC),
                                        thickness: 1)),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.directions_bus_rounded,
                                      size: 16, color: AppColors.primary),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: Color(0xFFCDD0DC),
                                        thickness: 1)),
                              ],
                            ),
                          ),
                          _CityChip(
                              city: widget.schedule.destination.trim(),
                              color: AppColors.secondary),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F5)),
                    // Details grid
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _DetailRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Date',
                              value: widget.schedule.departureTime.split('T').first),
                          const SizedBox(height: 10),
                          _DetailRow(
                              icon: Icons.access_time_rounded,
                              label: 'Departure',
                              value: widget.schedule.departureTime.split('T').length > 1 ? widget.schedule.departureTime.split('T')[1].substring(0, 5) : ''),
                          const SizedBox(height: 10),
                          _DetailRow(
                              icon: Icons.event_seat_rounded,
                              label: 'Seat',
                              value: widget.selectedSeat != null
                                  ? 'Seat ${widget.selectedSeat}'
                                  : 'Auto-assigned'),
                          const SizedBox(height: 10),
                          _DetailRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Passenger',
                              value: widget.passengerName.isEmpty
                                  ? '—'
                                  : widget.passengerName),
                          const SizedBox(height: 10),
                          _DetailRow(
                              icon: Icons.badge_outlined,
                              label: 'ID / Passport',
                              value: widget.passengerId.isEmpty
                                  ? '—'
                                  : widget.passengerId),
                          const SizedBox(height: 10),
                          _DetailRow(
                              icon: Icons.business_outlined,
                              label: 'Agency',
                              value: widget.schedule.agencyName),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F5)),
                    // Price breakdown
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _PriceRow(
                              label: 'Ticket price',
                              value: 'RWF ${widget.schedule.price.toInt()}'),
                          const SizedBox(height: 8),
                          _PriceRow(
                              label: 'Service fee',
                              value: 'RWF $kServiceFee',
                              valueColor: AppColors.bodyTextSecondary),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: const Color(0xFFE5E7F0),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                  style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                              Text('RWF $_total',
                                  style: GoogleFonts.sora(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!widget.readOnly) ...[  
                const SizedBox(height: 28),
                // ── Payment Method ─────────────────────────────────────────
                _SectionTitle(title: 'Payment Method'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PayMethodTile(
                      label: 'MTN MoMo',
                      color: const Color(0xFFFFCC00),
                      icon: Icons.phone_android_rounded,
                      selected:
                          widget.selectedMethod == PaymentMethod.mtn,
                      onTap: () =>
                          widget.onPaymentMethodChanged(PaymentMethod.mtn),
                    ),
                    const SizedBox(width: 10),
                    _PayMethodTile(
                      label: 'Airtel Money',
                      color: const Color(0xFFE40000),
                      icon: Icons.phone_android_rounded,
                      selected:
                          widget.selectedMethod == PaymentMethod.airtel,
                      onTap: () =>
                          widget.onPaymentMethodChanged(PaymentMethod.airtel),
                    ),
                    const SizedBox(width: 10),
                    _PayMethodTile(
                      label: 'Card',
                      color: AppColors.accent,
                      icon: Icons.credit_card_rounded,
                      selected:
                          widget.selectedMethod == PaymentMethod.card,
                      onTap: () =>
                          widget.onPaymentMethodChanged(PaymentMethod.card),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Payment fields (animated) ──────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.1), end: Offset.zero)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: widget.selectedMethod == PaymentMethod.card
                      ? _CardFields(
                          key: const ValueKey('card'),
                          cardNumberController:
                              widget.cardNumberController,
                          expiryController: widget.expiryController,
                          cvvController: widget.cvvController,
                        )
                      : _MobileMoneyField(
                          key: ValueKey(widget.selectedMethod),
                          controller: widget.phoneController,
                          label: widget.selectedMethod == PaymentMethod.mtn
                              ? 'MTN Mobile Money Number'
                              : 'Airtel Money Number',
                          hint: widget.selectedMethod == PaymentMethod.mtn
                              ? 'e.g. 078 XXX XXXX'
                              : 'e.g. 073 XXX XXXX',
                          accentColor:
                              widget.selectedMethod == PaymentMethod.mtn
                                  ? const Color(0xFFFFCC00)
                                  : const Color(0xFFE40000),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile money field ────────────────────────────────────────────────────────
class _MobileMoneyField extends StatelessWidget {
  const _MobileMoneyField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.accentColor,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style:
              GoogleFonts.inter(fontSize: 14, color: AppColors.bodyText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: AppColors.bodyTextSecondary),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.phone_android_rounded,
                  size: 16, color: accentColor),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Card fields ───────────────────────────────────────────────────────────────
class _CardFields extends StatelessWidget {
  const _CardFields({
    super.key,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
  });

  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Number',
            style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyText)),
        const SizedBox(height: 8),
        TextField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          maxLength: 19,
          style:
              GoogleFonts.inter(fontSize: 14, color: AppColors.bodyText),
          decoration: _cardDeco(
              hint: '0000 0000 0000 0000',
              icon: Icons.credit_card_rounded),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expiry Date',
                      style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bodyText)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpiryFormatter(),
                    ],
                    maxLength: 5,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.bodyText),
                    decoration: _cardDeco(
                        hint: 'MM/YY',
                        icon: Icons.calendar_today_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CVV',
                      style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bodyText)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.bodyText),
                    decoration:
                        _cardDeco(hint: '•••', icon: Icons.lock_outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _cardDeco(
          {required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 13, color: AppColors.bodyTextSecondary),
        prefixIcon: Icon(icon, size: 18, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.surface,
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      );
}

// ── Input formatters ──────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length >= 2) {
      final str = '${digits.substring(0, 2)}/${digits.substring(2)}';
      return next.copyWith(
        text: str,
        selection: TextSelection.collapsed(offset: str.length),
      );
    }
    return next;
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary),
      );
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.city, required this.color});
  final String city;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(city,
            style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 15, color: AppColors.bodyTextSecondary),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.bodyTextSecondary)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText)),
        ],
      );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.label,
      required this.value,
      this.valueColor = AppColors.bodyText});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.bodyTextSecondary)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      );
}

class _PayMethodTile extends StatelessWidget {
  const _PayMethodTile({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.12) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? color : const Color(0xFFE5E7F0),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon,
                    size: 22,
                    color: selected ? color : AppColors.bodyTextSecondary),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? color
                            : AppColors.bodyTextSecondary)),
              ],
            ),
          ),
        ),
      );
}
