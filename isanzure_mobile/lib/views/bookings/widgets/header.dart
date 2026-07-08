import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_header.dart';
import '../../../core/constants/trip_route_indicator.dart';
import '../../../models/mock-trip-model.dart';

class DetailsHeader extends StatelessWidget {
  const DetailsHeader({
    super.key,
    required this.trip,
    this.parallax = 0,
    this.contentOpacity = 1,
  });

  final TripSummary trip;

  /// 0..1 — drives the map background upward as user scrolls
  final double parallax;

  /// 0..1 — fades the text content as user scrolls into the card
  final double contentOpacity;

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      bottomPadding: 30,
      parallax: parallax,
      contentOpacity: contentOpacity,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),

          const SizedBox(width: 20.0),

          Text(
            'Trip Details',
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
      actions: const [
        AppHeaderIconButton(icon: Icons.notifications_none),
      ],
      child: _TripInfoRow(trip: trip),
    );
  }
}

// ── Trip info row: from/to, date, time, seats, plate ────────────────────────
class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({required this.trip});
  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start',
                      style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 2,),
                  Text(trip.from,
                      style: GoogleFonts.sora(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: RouteBusIndicator(
                iconColor: Colors.white,
                lineColor: Colors.white38,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      'End',
                      style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 2,),
                  Text(trip.to,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.sora(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoChip(icon: Icons.business_outlined, label: trip.agency),
            const SizedBox(width: 10),
            _InfoChip(icon: Icons.directions_car_outlined, label: trip.plateNumber),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoChip(
                icon: Icons.calendar_month,
                label: trip.date,
            ),
            _InfoChip(
                icon: Icons.event_seat, label: '${trip.spotsAvailable} seats Left'),
            _InfoChip(
                icon: Icons.access_time, label: trip.takeoffTime),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      );
  }
}