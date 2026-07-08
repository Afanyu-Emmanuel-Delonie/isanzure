import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../models/mock-trip-model.dart';
import '../../views/bookings/bookings_details.dart';

const int kServiceFee = 200;

class BookingSuccessView extends StatefulWidget {
  const BookingSuccessView({
    super.key,
    required this.trip,
    required this.seat,
    required this.passengerName,
    required this.passengerId,
    required this.paymentMethod,
    required this.paymentRef,
  });

  final TripSummary trip;
  final int seat;
  final String passengerName;
  final String passengerId;
  final PaymentMethod paymentMethod;
  final String paymentRef;

  @override
  State<BookingSuccessView> createState() => _BookingSuccessViewState();
}

class _BookingSuccessViewState extends State<BookingSuccessView>
    with TickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _ringScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _ringScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _checkCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.elasticOut)));

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _checkCtrl,
            curve: const Interval(0.25, 1.0, curve: Curves.elasticOut)));

    _checkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _checkCtrl,
            curve: const Interval(0.25, 0.65, curve: Curves.easeIn)));

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentCtrl,
                curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));
    _contentFade = CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut));

    _buttonsSlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentCtrl,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
    _buttonsFade = CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut));

    _checkCtrl.forward();
    Future.delayed(const Duration(milliseconds: 450),
        () { if (mounted) _contentCtrl.forward(); });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String get _methodLabel {
    switch (widget.paymentMethod) {
      case PaymentMethod.mtn:      return 'MTN Mobile Money';
      case PaymentMethod.airtel:   return 'Airtel Money';
      case PaymentMethod.card:     return 'Credit Card';
    }
  }

  int get _total => widget.trip.amount + kServiceFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // ── Animated checkmark ───────────────────────────────────────
              AnimatedBuilder(
                animation: _checkCtrl,
                builder: (_, __) => SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Transform.scale(
                        scale: _ringScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22C55E).withOpacity(0.12),
                          ),
                        ),
                      ),
                      // Mid ring
                      Transform.scale(
                        scale: _ringScale.value,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22C55E).withOpacity(0.18),
                          ),
                        ),
                      ),
                      // Check circle
                      Transform.scale(
                        scale: _checkScale.value,
                        child: FadeTransition(
                          opacity: _checkFade,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF22C55E),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Title ────────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      Text('Booking Confirmed!',
                          style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                      const SizedBox(height: 6),
                      Text(
                          'Your seat has been reserved.\nHave a great trip! 🚌',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.bodyTextSecondary,
                              height: 1.6)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Ticket card ──────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Route banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TicketCity(
                                  city: widget.trip.from,
                                  sub: widget.trip.date),
                              Column(
                                children: [
                                  const Icon(Icons.directions_bus_rounded,
                                      color: Colors.white70, size: 20),
                                  const SizedBox(height: 2),
                                  Text(widget.trip.takeoffTime,
                                      style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.white60)),
                                ],
                              ),
                              _TicketCity(
                                  city: widget.trip.to.trim(),
                                  sub: widget.trip.agency,
                                  alignEnd: true),
                            ],
                          ),
                        ),

                        // Details
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _TicketRow(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Passenger',
                                  value: widget.passengerName.isEmpty
                                      ? '—'
                                      : widget.passengerName),
                              const SizedBox(height: 10),
                              _TicketRow(
                                  icon: Icons.event_seat_rounded,
                                  label: 'Seat',
                                  value: 'Seat ${widget.seat}'),
                              const SizedBox(height: 10),
                              _TicketRow(
                                  icon: Icons.payment_rounded,
                                  label: 'Payment',
                                  value: _methodLabel),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(
                                    height: 1, color: Color(0xFFF0F0F5)),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Paid',
                                      style: GoogleFonts.sora(
                                          fontSize: 14,
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

                        // Booking ref strip
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8F9FC),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                          ),
                          child: Column(
                            children: [
                              Text('Booking Reference',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.bodyTextSecondary)),
                              const SizedBox(height: 4),
                              Text(widget.paymentRef,
                                  style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: 2.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Buttons ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _buttonsFade,
                child: SlideTransition(
                  position: _buttonsSlide,
                  child: Row(
                    children: [
                      // View Ticket (outlined)
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Frontend only — ticket view coming later
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ticket view coming soon!',
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: const Icon(Icons.confirmation_number_outlined,
                                size: 18),
                            label: Text('View Ticket',
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Back to Home (filled)
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context)
                                .popUntil((r) => r.isFirst),
                            icon: const Icon(Icons.home_rounded, size: 18),
                            label: Text('Home',
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _TicketCity extends StatelessWidget {
  const _TicketCity(
      {required this.city, required this.sub, this.alignEnd = false});
  final String city;
  final String sub;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(city,
              style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(sub,
              style: GoogleFonts.inter(
                  fontSize: 11, color: Colors.white70)),
        ],
      );
}

class _TicketRow extends StatelessWidget {
  const _TicketRow(
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
