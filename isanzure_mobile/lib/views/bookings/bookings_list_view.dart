import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../../core/constants/app_theme.dart';
import '../../models/mock-trip-model.dart';
import '../../viewmodels/booking_details_viewmodel.dart';
import '../ticket/ticket_view.dart';
import 'bookings_details.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────
enum _BookingStatus { upcoming, past, cancelled }

class _MockBooking {
  const _MockBooking({
    required this.booking,
    required this.status,
    required this.passengers,
  });
  final RecentBooking booking;
  final _BookingStatus status;
  final int passengers;
}

const _mockBookings = [
  _MockBooking(
    status: _BookingStatus.upcoming,
    passengers: 2,
    booking: RecentBooking(
      ref: 'ISZ7712048', seat: 9, bookedOn: 'Jul 14, 2025',
      trip: TripSummary(from: 'Kigali', to: 'Butare', date: 'Jul 14, 2025', takeoffTime: '08:00 AM', amount: 2500, spotsAvailable: 10, agency: 'Volcano Express', plateNumber: 'RAC 412 B'),
    ),
  ),
  _MockBooking(
    status: _BookingStatus.upcoming,
    passengers: 1,
    booking: RecentBooking(
      ref: 'ISZ7834910', seat: 17, bookedOn: 'Jul 16, 2025',
      trip: TripSummary(from: 'Kigali', to: 'Musanze', date: 'Jul 16, 2025', takeoffTime: '06:00 AM', amount: 1800, spotsAvailable: 6, agency: 'Stella Express', plateNumber: 'RAD 203 A'),
    ),
  ),
  _MockBooking(
    status: _BookingStatus.past,
    passengers: 1,
    booking: RecentBooking(
      ref: 'ISZ4829301', seat: 14, bookedOn: 'Jul 8, 2025',
      trip: TripSummary(from: 'Kigali', to: 'Butare', date: 'Jul 8, 2025', takeoffTime: '07:00 AM', amount: 2500, spotsAvailable: 10, agency: 'Volcano Express', plateNumber: 'RAC 412 B'),
    ),
  ),
  _MockBooking(
    status: _BookingStatus.past,
    passengers: 3,
    booking: RecentBooking(
      ref: 'ISZ5530182', seat: 6, bookedOn: 'Jul 5, 2025',
      trip: TripSummary(from: 'Kigali', to: 'Gisenyi', date: 'Jul 5, 2025', takeoffTime: '06:30 AM', amount: 3000, spotsAvailable: 5, agency: 'Virunga Express', plateNumber: 'RAB 887 C'),
    ),
  ),
  _MockBooking(
    status: _BookingStatus.cancelled,
    passengers: 1,
    booking: RecentBooking(
      ref: 'ISZ6671045', seat: 22, bookedOn: 'Jul 1, 2025',
      trip: TripSummary(from: 'Rubavu', to: 'Kigali', date: 'Jul 1, 2025', takeoffTime: '05:45 AM', amount: 4000, spotsAvailable: 2, agency: 'Horizon Express', plateNumber: 'RAE 556 D'),
    ),
  ),
];

// ── View ──────────────────────────────────────────────────────────────────────
class BookingsListView extends StatefulWidget {
  const BookingsListView({super.key});

  @override
  State<BookingsListView> createState() => _BookingsListViewState();
}

class _BookingsListViewState extends State<BookingsListView> {
  int _tab = 0;
  static const _tabs = ['All', 'Upcoming', 'Past'];

  List<_MockBooking> get _filtered {
    switch (_tab) {
      case 1:
        return _mockBookings.where((b) => b.status == _BookingStatus.upcoming).toList();
      case 2:
        return _mockBookings
            .where((b) => b.status == _BookingStatus.past || b.status == _BookingStatus.cancelled)
            .toList();
      default:
        return _mockBookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 176,
            collapsedHeight: 56,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            bottom: _FilterTabsBar(
              tab: _tab,
              tabs: _tabs,
              onTabChanged: (i) => setState(() => _tab = i),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 72),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Bookings',
                      style: GoogleFonts.sora(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text('Track and manage your trips',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white70)),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.primary),
                  Opacity(
                    opacity: 0.08,
                    child: Image.asset(
                      'assets/img/map-bg.png',
                      fit: BoxFit.cover,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: filtered.isEmpty
            ? _EmptyState(tab: _tabs[_tab])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _BookingCard(item: filtered[i]),
              ),
      ),
    );
  }
}

// ── Filter tabs bar (PreferredSizeWidget → SliverAppBar.bottom) ───────────────
class _FilterTabsBar extends StatelessWidget implements PreferredSizeWidget {
  const _FilterTabsBar({
    required this.tab,
    required this.tabs,
    required this.onTabChanged,
  });
  final int tab;
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = tab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[i],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.bodyTextSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Booking card ──────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.item});
  final _MockBooking item;

  @override
  Widget build(BuildContext context) {
    final trip = item.booking.trip;
    final width = MediaQuery.of(context).size.width - 40;

    return TicketWidget(
      width: width,
      height: 190,
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
                            Text(trip.from,
                                style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            const SizedBox(height: 2),
                            Text(trip.date,
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.bodyTextSecondary)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _DashedLine()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.directions_bus_rounded, size: 14, color: AppColors.primary),
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
                            Text(trip.to.trim(),
                                textAlign: TextAlign.end,
                                style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            const SizedBox(height: 2),
                            Text(trip.takeoffTime,
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.bodyTextSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.business_outlined, size: 13, color: AppColors.bodyTextSecondary),
                      const SizedBox(width: 4),
                      Text(trip.agency,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.bodyText)),
                      const Spacer(),
                      _StatusBadge(status: item.status),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _DashedLine(color: const Color(0xFFE0E3EE)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price', style: GoogleFonts.inter(fontSize: 10, color: AppColors.bodyTextSecondary)),
                    Text('RWF ${trip.amount}',
                        style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Seat', style: GoogleFonts.inter(fontSize: 10, color: AppColors.bodyTextSecondary)),
                    Row(
                      children: [
                        const Icon(Icons.event_seat_outlined, size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('${item.booking.seat}',
                            style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accent)),
                      ],
                    ),
                  ],
                ),
                if (item.status == _BookingStatus.past)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingsDetails(trip: trip))),
                    icon: const Icon(Icons.refresh_rounded, size: 13),
                    label: Text('Rebook', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                else if (item.status == _BookingStatus.upcoming)
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketView(
                          trip: trip,
                          seat: item.booking.seat,
                          passengerName: 'Passenger',
                          paymentMethod: PaymentMethod.mtn,
                          paymentRef: item.booking.ref,
                          total: trip.amount,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_rounded, size: 13),
                    label: Text('View Ticket', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final _BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      _BookingStatus.upcoming  => ('Upcoming',  const Color(0xFFEFF6FF), AppColors.accent),
      _BookingStatus.past      => ('Completed', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
      _BookingStatus.cancelled => ('Cancelled', const Color(0xFFFFF1F2), const Color(0xFFE11D48)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});
  final String tab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.07), shape: BoxShape.circle),
            child: const Icon(Icons.confirmation_number_outlined, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('No $tab bookings',
              style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 6),
          Text('Your trips will appear here',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.bodyTextSecondary)),
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
