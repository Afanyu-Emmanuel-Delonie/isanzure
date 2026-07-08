import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isanzure_mobile/views/bookings/bookings_details.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../../../core/constants/app_theme.dart';
import '../../../models/mock-trip-model.dart';



const _mockTrips = [
  TripSummary(
    from: 'Butare',
    to: 'Kigali ',
    date: '12 Jul 2025',
    takeoffTime: '06:30 AM',
    amount: 2500,
    spotsAvailable: 8,
    agency: 'Volcano Express',
    plateNumber: 'RAC 412 B',
  ),
  TripSummary(
    from: 'Kigali',
    to: 'Gisenyi ',
    date: '12 Jul 2025',
    takeoffTime: '07:00 AM',
    amount: 3000,
    spotsAvailable: 3,
    agency: 'Virunga Express',
    plateNumber: 'RAB 887 C',
  ),
  TripSummary(
    from: 'Kigali',
    to: 'Mombasa',
    date: '13 Jul 2025',
    takeoffTime: '08:15 AM',
    amount: 1800,
    spotsAvailable: 12,
    agency: 'Stella Express',
    plateNumber: 'RAD 203 A',
  ),
  TripSummary(
    from: 'Rubavu',
    to: 'Kigali',
    date: '14 Jul 2025',
    takeoffTime: '05:45 AM',
    amount: 4000,
    spotsAvailable: 1,
    agency: 'Horizon Express',
    plateNumber: 'RAE 556 D',
  ),
];

// ── Popular Trips section ─────────────────────────────────────────────────────
class PopularTrips extends StatelessWidget {
  const PopularTrips({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popular Trips',
                style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
            Text('See all',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent)),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _mockTrips.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AnimatedTripTicket(trip: _mockTrips[i], index: i),
          ),
        ),
      ],
    );
  }
}

// ── Animated wrapper — staggered fade+slide per card index ──────────────────
class _AnimatedTripTicket extends StatefulWidget {
  const _AnimatedTripTicket({required this.trip, required this.index});
  final TripSummary trip;
  final int index;

  @override
  State<_AnimatedTripTicket> createState() => _AnimatedTripTicketState();
}

class _AnimatedTripTicketState extends State<_AnimatedTripTicket>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger: each card delays by 100ms × index
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: _TripTicket(trip: widget.trip),
        ),
      );
}

// ── Single ticket card ────────────────────────────────────────────────────────
class _TripTicket extends StatelessWidget {
  const _TripTicket({required this.trip});
  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40; // parent already has h:20 padding each side
    final isLow = trip.spotsAvailable <= 3;

    return TicketWidget(
      width: width,
      height: 178,
      isCornerRounded: true,
      color: Colors.white,
      shadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        children: [
          // ── Top section ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                children: [
                  // Route row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip.from,
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            const SizedBox(height: 2),
                            Text(trip.date,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.bodyTextSecondary)),
                          ],
                        ),
                      ),
                      // Bus icon with dashed lines
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _DashedLine()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.directions_bus_rounded,
                                    size: 14,
                                    color: AppColors.primary),
                              ),
                            ),
                            Expanded(child: _DashedLine()),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(trip.to,
                                textAlign: TextAlign.end,
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary)),
                            const SizedBox(height: 2),
                            Text(trip.takeoffTime,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.bodyTextSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Agency + plate row
                  Row(
                    children: [
                      const Icon(Icons.business_outlined,
                          size: 13, color: AppColors.bodyTextSecondary),
                      const SizedBox(width: 4),
                      Text(trip.agency,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.bodyText)),
                      const Spacer(),
                      const Icon(Icons.directions_car_outlined,
                          size: 13, color: AppColors.bodyTextSecondary),
                      const SizedBox(width: 4),
                      Text(trip.plateNumber,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.bodyText)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tear line ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _DashedLine(color: const Color(0xFFE0E3EE)),
          ),

          // ── Bottom section ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.bodyTextSecondary)),
                    Text('RWF ${trip.amount}',
                        style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
                // Seats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Seats left',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.bodyTextSecondary)),
                    Row(
                      children: [
                        Icon(Icons.event_seat_outlined,
                            size: 13,
                            color:
                                isLow ? Colors.redAccent : AppColors.accent),
                        const SizedBox(width: 4),
                        Text('${trip.spotsAvailable}',
                            style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isLow
                                    ? Colors.redAccent
                                    : AppColors.accent)),
                      ],
                    ),
                  ],
                ),
                // Book button
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingsDetails(trip: trip),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Book Now',
                      style: GoogleFonts.sora(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed line ───────────────────────────────────────────────────────────────
class _DashedLine extends StatelessWidget {
  const _DashedLine({this.color = const Color(0xFFCDD0DC)});
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedLinePainter(color),
        child: const SizedBox(height: 1),
      );
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
