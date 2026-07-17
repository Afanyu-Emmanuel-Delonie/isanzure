import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../../../core/constants/app_theme.dart';
import '../../../models/booking_model.dart';
import '../../bookings/bookings_details.dart';

class RecentBookings extends StatelessWidget {
  const RecentBookings({super.key, required this.bookings});

  final List<BookingModel> bookings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Bookings',
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
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.none,
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _RecentTicket(booking: bookings[i]),
          ),
        ),
      ],
    );
  }
}

class _RecentTicket extends StatelessWidget {
  const _RecentTicket({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.82;

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
          // ── Top section ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.origin,
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            const SizedBox(height: 2),
                            Text(booking.departureTime.split('T').first,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.bodyTextSecondary)),
                          ],
                        ),
                      ),
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
                                child: const Icon(Icons.directions_bus_rounded,
                                    size: 14, color: AppColors.primary),
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
                            Text(booking.destination.trim(),
                                textAlign: TextAlign.end,
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary)),
                            const SizedBox(height: 2),
                            Text(booking.departureTime.split('T').length > 1 ? booking.departureTime.split('T')[1].substring(0, 5) : '',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.bodyTextSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Agency + ref row
                  Row(
                    children: [
                      const Icon(Icons.business_outlined,
                          size: 13, color: AppColors.bodyTextSecondary),
                      const SizedBox(width: 4),
                      Text(booking.agencyName,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.bodyText)),
                      const Spacer(),
                      const Icon(Icons.confirmation_number_outlined,
                          size: 13, color: AppColors.bodyTextSecondary),
                      const SizedBox(width: 4),
                      Text(booking.paymentReference ?? 'N/A',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bodyText,
                              letterSpacing: 0.6)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tear line ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _DashedLine(color: const Color(0xFFE0E3EE)),
          ),

          // ── Bottom section ─────────────────────────────────────────────
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
                    Text('RWF ${booking.price.toInt()}',
                        style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
                // Seat
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Seat',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.bodyTextSecondary)),
                    Row(
                      children: [
                        const Icon(Icons.event_seat_outlined,
                            size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('${booking.seatNumber}',
                            style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent)),
                      ],
                    ),
                  ],
                ),
                // Rebook button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh_rounded, size: 13),
                  label: Text('Rebook',
                      style: GoogleFonts.sora(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
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
