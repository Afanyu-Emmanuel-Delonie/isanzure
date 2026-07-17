import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_theme.dart';
import '../../models/mock-trip-model.dart';
import '../../viewmodels/booking_details_viewmodel.dart';

class TicketView extends StatelessWidget {
  const TicketView({
    super.key,
    required this.trip,
    required this.seat,
    required this.passengerName,
    required this.paymentMethod,
    required this.paymentRef,
    required this.total,
  });

  final TripSummary trip;
  final int seat;
  final String passengerName;
  final PaymentMethod paymentMethod;
  final String paymentRef;
  final int total;

  String get _qrData =>
      'REF:$paymentRef|FROM:${trip.from}|TO:${trip.to}|SEAT:$seat|PAX:$passengerName|DATE:${trip.date}';

  String get _methodLabel {
    switch (paymentMethod) {
      case PaymentMethod.mtn:    return 'MTN Mobile Money';
      case PaymentMethod.airtel: return 'Airtel Money';
      case PaymentMethod.card:   return 'Credit Card';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Your Ticket',
            style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded,
                color: AppColors.primary, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // ── Ticket card ──────────────────────────────────────────────
            _TicketCard(
              trip: trip,
              seat: seat,
              passengerName: passengerName,
              methodLabel: _methodLabel,
              paymentRef: paymentRef,
              total: total,
              qrData: _qrData,
            ),

            const SizedBox(height: 28),

            // ── Download button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text('Download Ticket',
                    style: GoogleFonts.sora(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ticket card with torn divider ─────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.trip,
    required this.seat,
    required this.passengerName,
    required this.methodLabel,
    required this.paymentRef,
    required this.total,
    required this.qrData,
  });

  final TripSummary trip;
  final int seat;
  final String passengerName;
  final String methodLabel;
  final String paymentRef;
  final int total;
  final String qrData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Header banner ────────────────────────────────────────────
            _TicketHeader(trip: trip),

            // ── Details section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Passenger',
                    value: passengerName.isEmpty ? '—' : passengerName,
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.event_seat_rounded,
                    label: 'Seat',
                    value: 'Seat $seat',
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: trip.date,
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Departure',
                    value: trip.takeoffTime,
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.directions_bus_rounded,
                    label: 'Agency',
                    value: trip.agency,
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.payment_rounded,
                    label: 'Payment',
                    value: methodLabel,
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.receipt_rounded,
                    label: 'Total Paid',
                    value: 'RWF $total',
                    valueStyle: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Torn edge divider ────────────────────────────────────────
            CustomPaint(
              size: const Size(double.infinity, 24),
              painter: _TornEdgePainter(),
            ),

            // ── QR + reference ───────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  // QR code
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.10)),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 160,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.primary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text('Booking Reference',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.bodyTextSecondary)),
                  const SizedBox(height: 4),
                  Text(paymentRef,
                      style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 3.0)),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 13, color: Color(0xFF22C55E)),
                        const SizedBox(width: 5),
                        Text('Confirmed',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header banner ─────────────────────────────────────────────────────────────

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.trip});
  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        children: [
          // isanzure branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bus_rounded,
                  color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text('ISANZURE',
                  style: GoogleFonts.sora(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 2.5)),
            ],
          ),

          const SizedBox(height: 20),

          // From → To
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CityBlock(city: trip.from, label: 'FROM'),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white24,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(trip.takeoffTime,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ),
              _CityBlock(city: trip.to.trim(), label: 'TO', alignEnd: true),
            ],
          ),

          const SizedBox(height: 20),

          // Date + plate chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Chip(icon: Icons.calendar_today_rounded, label: trip.date),
              const SizedBox(width: 10),
              _Chip(
                  icon: Icons.confirmation_number_outlined,
                  label: trip.plateNumber),
            ],
          ),
        ],
      ),
    );
  }
}

class _CityBlock extends StatelessWidget {
  const _CityBlock(
      {required this.city, required this.label, this.alignEnd = false});
  final String city;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white54,
                  letterSpacing: 1.5)),
          const SizedBox(height: 2),
          Text(city,
              style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: Colors.white70),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.white70)),
          ],
        ),
      );
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.bodyTextSecondary)),
            const Spacer(),
            Text(value,
                style: valueStyle ??
                    GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bodyText)),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFFF0F0F5));
}

// ── Torn edge painter ─────────────────────────────────────────────────────────

class _TornEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white;
    final bgPaint = Paint()..color = AppColors.surface;

    // Fill top half white, bottom half surface
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), whitePaint);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
        bgPaint);

    // Notch circles on left and right
    const r = 12.0;
    canvas.drawCircle(
        Offset(-r, size.height / 2), r, bgPaint);
    canvas.drawCircle(
        Offset(size.width + r, size.height / 2), r, bgPaint);

    // Dashed line
    final dashPaint = Paint()
      ..color = const Color(0xFFE5E7F0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashGap = 4.0;
    double x = 16;
    final y = size.height / 2;
    while (x < size.width - 16) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), dashPaint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
