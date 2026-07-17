import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_theme.dart';
import '../../models/schedule_model.dart';
import '../../services/booking_service.dart';
import '../../viewmodels/booking_details_viewmodel.dart';
import '../../views/bookings/booking_success_view.dart';
import 'widgets/booking_text_field.dart';
import 'widgets/header.dart';

class BookingsDetails extends StatelessWidget {
  const BookingsDetails({super.key, required this.schedule});
  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BookingDetailsViewModel(
        schedule: schedule,
        bookingService: ctx.read<BookingService>(),
      ),
      child: const _BookingsDetailsView(),
    );
  }
}

class _BookingsDetailsView extends StatefulWidget {
  const _BookingsDetailsView();

  @override
  State<_BookingsDetailsView> createState() => _BookingsDetailsViewState();
}

class _BookingsDetailsViewState extends State<_BookingsDetailsView> {
  final _scrollCtrl = ScrollController();
  double _headerParallax = 0;
  double _headerOpacity = 1;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;
    final parallax = (offset / 180).clamp(0.0, 1.0);
    final opacity = (1.0 - offset / 120).clamp(0.0, 1.0);
    if (parallax != _headerParallax || opacity != _headerOpacity) {
      setState(() {
        _headerParallax = parallax;
        _headerOpacity = opacity;
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirm(BuildContext context) async {
    final vm = context.read<BookingDetailsViewModel>();
    try {
      final result = await vm.submit(_scrollCtrl);
      if (result == null || !mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => BookingSuccessView(
            schedule: vm.schedule,
            seat: result['seat'] as int,
            passengerName: result['passengerName'] as String,
            passengerId: '',
            paymentMethod: result['paymentMethod'] as PaymentMethod,
            paymentRef: result['ref'] as String,
          ),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.06), end: Offset.zero)
                  .animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingDetailsViewModel>();

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailsHeader(
              schedule: vm.schedule,
              parallax: _headerParallax,
              contentOpacity: _headerOpacity,
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Form(
                key: vm.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passenger Details',
                      style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const FieldLabel(label: 'Full Name'),
                    const SizedBox(height: 8),
                    BookingTextField(
                      controller: vm.nameController,
                      hint: 'e.g. Jean Pierre Habimana',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: vm.validateName,
                    ),

                    const SizedBox(height: 24),

                    const FieldLabel(label: 'Number of Seats'),
                    const SizedBox(height: 8),
                    _SeatsSelector(vm: vm),

                    if (vm.schedule.availableSeats != null && vm.seats >= vm.schedule.availableSeats!)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          'Max ${vm.schedule.availableSeats} seats available',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.orange.shade700),
                        ),
                      ),

                    const SizedBox(height: 24),

                    const FieldLabel(label: 'Payment Method'),
                    const SizedBox(height: 8),
                    _PaymentMethodSelector(vm: vm),

                    if (vm.paymentError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          vm.paymentError!,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.redAccent),
                        ),
                      ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: vm.selectedPayment != null ? 20 : 0),
                          child: _PaymentDetailFields(vm: vm),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _BookingSummaryCard(vm: vm),

                    const SizedBox(height: 24),

                    _ConfirmButton(
                      isSubmitting: vm.isSubmitting,
                      onPressed: () => _onConfirm(context),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SeatsSelector extends StatelessWidget {
  const _SeatsSelector({required this.vm});
  final BookingDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onPressed: () => vm.setSeats(vm.seats - 1),
            icon: const Icon(Icons.remove_circle_outline,
                color: AppColors.primary),
          ),
          Text('${vm.seats}',
              style: GoogleFonts.sora(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          IconButton(
            onPressed: () => vm.setSeats(vm.seats + 1),
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({required this.vm});
  final BookingDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < PaymentMethod.values.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(
            child: Builder(builder: (context) {
              final method = PaymentMethod.values[i];
              final selected = vm.selectedPayment == method;
              final brandColor = vm.paymentBrandColor(method);

              return GestureDetector(
                onTap: () => vm.selectPayment(method),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? brandColor : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? brandColor
                          : (vm.paymentError != null
                              ? Colors.redAccent
                              : const Color(0xFFE5E7F0)),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withOpacity(0.2)
                              : brandColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          method == PaymentMethod.card
                              ? Icons.credit_card_rounded
                              : Icons.phone_android_rounded,
                          size: 16,
                          color: selected ? Colors.white : brandColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _label(method),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  String _label(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.mtn:    return 'MTN MoMo';
      case PaymentMethod.airtel: return 'Airtel Money';
      case PaymentMethod.card:   return 'Credit Card';
    }
  }
}

class _PaymentDetailFields extends StatelessWidget {
  const _PaymentDetailFields({required this.vm});
  final BookingDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.selectedPayment == null) {
      return const SizedBox(key: ValueKey('none'));
    }

    switch (vm.selectedPayment!) {
      case PaymentMethod.mtn:
      case PaymentMethod.airtel:
        final label = vm.selectedPayment == PaymentMethod.mtn
            ? 'MTN MoMo Phone Number'
            : 'Airtel Money Phone Number';
        return Column(
          key: ValueKey(vm.selectedPayment),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label: label),
            const SizedBox(height: 8),
            BookingTextField(
              controller: vm.phoneController,
              hint: 'e.g. 07XX XXX XXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: vm.validatePhone,
            ),
          ],
        );
      case PaymentMethod.card:
        return Column(
          key: const ValueKey(PaymentMethod.card),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel(label: 'Card Number'),
            const SizedBox(height: 8),
            BookingTextField(
              controller: vm.cardNumberController,
              hint: '1234 5678 9012 3456',
              icon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              maxLength: 16,
              validator: vm.validateCardNumber,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(label: 'Expiry'),
                      const SizedBox(height: 8),
                      BookingTextField(
                        controller: vm.cardExpiryController,
                        hint: 'MM/YY',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
                        validator: vm.validateExpiry,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(label: 'CVV'),
                      const SizedBox(height: 8),
                      BookingTextField(
                        controller: vm.cardCvvController,
                        hint: '123',
                        icon: Icons.lock_outline_rounded,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        validator: vm.validateCvv,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({required this.vm});
  final BookingDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Booking Summary',
                  style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Paying to', value: vm.schedule.agencyName),
          const SizedBox(height: 8),
          _SummaryRow(
              label: 'Route',
              value: '${vm.schedule.origin} → ${vm.schedule.destination}'),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Seats', value: '${vm.seats}'),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Payment Method', value: vm.paymentLabel),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.bodyTextSecondary)),
              Text('RWF ${vm.total}',
                  style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton(
      {required this.isSubmitting, required this.onPressed});
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                'Confirm Booking',
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.bodyTextSecondary)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyText)),
      ],
    );
  }
}
