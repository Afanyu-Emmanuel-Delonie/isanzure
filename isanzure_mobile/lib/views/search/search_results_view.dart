import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../../core/constants/app_theme.dart';
import '../../models/mock-trip-model.dart';
import '../bookings/bookings_details.dart';
import '../home/widgets/search_card.dart';

// ── Mock trips pool ───────────────────────────────────────────────────────────
const _allTrips = [
  TripSummary(from: 'Kigali', to: 'Butare', date: '14 Jul 2026', takeoffTime: '06:00 AM', amount: 2500, spotsAvailable: 8, agency: 'Volcano Express', plateNumber: 'RAC 412 B'),
  TripSummary(from: 'Kigali', to: 'Butare', date: '14 Jul 2026', takeoffTime: '08:30 AM', amount: 2500, spotsAvailable: 3, agency: 'Virunga Express', plateNumber: 'RAB 887 C'),
  TripSummary(from: 'Kigali', to: 'Butare', date: '14 Jul 2026', takeoffTime: '10:00 AM', amount: 2800, spotsAvailable: 12, agency: 'Stella Express', plateNumber: 'RAD 203 A'),
  TripSummary(from: 'Kigali', to: 'Butare', date: '14 Jul 2026', takeoffTime: '01:00 PM', amount: 2500, spotsAvailable: 1, agency: 'Horizon Express', plateNumber: 'RAE 556 D'),
  TripSummary(from: 'Kigali', to: 'Butare', date: '14 Jul 2026', takeoffTime: '03:30 PM', amount: 2200, spotsAvailable: 6, agency: 'Volcano Express', plateNumber: 'RAC 100 A'),
  TripSummary(from: 'Kigali', to: 'Butare', date: '14 Jul 2026', takeoffTime: '06:00 PM', amount: 2500, spotsAvailable: 9, agency: 'Virunga Express', plateNumber: 'RAB 321 D'),
  TripSummary(from: 'Kigali', to: 'Gisenyi', date: '14 Jul 2026', takeoffTime: '07:00 AM', amount: 3000, spotsAvailable: 5, agency: 'Virunga Express', plateNumber: 'RAB 887 C'),
  TripSummary(from: 'Kigali', to: 'Musanze', date: '14 Jul 2026', takeoffTime: '06:30 AM', amount: 1800, spotsAvailable: 10, agency: 'Stella Express', plateNumber: 'RAD 203 A'),
  TripSummary(from: 'Butare', to: 'Kigali', date: '14 Jul 2026', takeoffTime: '07:00 AM', amount: 2500, spotsAvailable: 7, agency: 'Volcano Express', plateNumber: 'RAC 412 B'),
  TripSummary(from: 'Butare', to: 'Kigali', date: '14 Jul 2026', takeoffTime: '09:00 AM', amount: 2200, spotsAvailable: 4, agency: 'Stella Express', plateNumber: 'RAD 203 A'),
];

enum _SortBy { earliest, cheapest, mostSeats }

// ── View ──────────────────────────────────────────────────────────────────────
class SearchResultsView extends StatefulWidget {
  const SearchResultsView({
    super.key,
    required this.from,
    required this.to,
    this.date,
    this.period,
  });

  final String from;
  final String to;
  final DateTime? date;
  final TimePeriod? period;

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  _SortBy _sortBy = _SortBy.earliest;
  final Set<String> _agencyFilter = {};
  int? _maxPrice;
  bool _availableOnly = false;

  Set<String> get _allAgencies => _allTrips.map((t) => t.agency).toSet();

  List<TripSummary> get _results {
    var list = _allTrips.where((t) {
      if (t.from.toLowerCase() != widget.from.toLowerCase()) return false;
      if (t.to.trim().toLowerCase() != widget.to.trim().toLowerCase()) return false;
      if (_agencyFilter.isNotEmpty && !_agencyFilter.contains(t.agency)) return false;
      if (_maxPrice != null && t.amount > _maxPrice!) return false;
      if (_availableOnly && t.spotsAvailable == 0) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case _SortBy.earliest:
        list.sort((a, b) => a.takeoffTime.compareTo(b.takeoffTime));
      case _SortBy.cheapest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
      case _SortBy.mostSeats:
        list.sort((a, b) => b.spotsAvailable.compareTo(a.spotsAvailable));
    }
    return list;
  }

  bool get _hasActiveFilters =>
      _agencyFilter.isNotEmpty || _maxPrice != null || _availableOnly;

  void _openFilters() {
    _SortBy tempSort = _sortBy;
    final Set<String> tempAgencies = Set.from(_agencyFilter);
    int tempPrice = _maxPrice ?? 5000;
    bool tempAvailable = _availableOnly;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters & Sort',
                          style: GoogleFonts.sora(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      TextButton(
                        onPressed: () => setModal(() {
                          tempSort = _SortBy.earliest;
                          tempAgencies.clear();
                          tempPrice = 5000;
                          tempAvailable = false;
                        }),
                        child: Text('Reset',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort
                  Text('Sort by',
                      style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bodyTextSecondary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Chip(label: 'Earliest', selected: tempSort == _SortBy.earliest, onTap: () => setModal(() => tempSort = _SortBy.earliest)),
                      _Chip(label: 'Cheapest', selected: tempSort == _SortBy.cheapest, onTap: () => setModal(() => tempSort = _SortBy.cheapest)),
                      _Chip(label: 'Most Seats', selected: tempSort == _SortBy.mostSeats, onTap: () => setModal(() => tempSort = _SortBy.mostSeats)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Agency
                  Text('Agency',
                      style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bodyTextSecondary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allAgencies.map((a) {
                      final sel = tempAgencies.contains(a);
                      return _Chip(
                        label: a,
                        selected: sel,
                        onTap: () => setModal(() {
                          if (sel) tempAgencies.remove(a);
                          else tempAgencies.add(a);
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Max price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Price',
                          style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bodyTextSecondary)),
                      Text('RWF $tempPrice',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: tempPrice.toDouble(),
                    min: 1000,
                    max: 5000,
                    divisions: 8,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withOpacity(0.15),
                    onChanged: (v) => setModal(() => tempPrice = v.round()),
                  ),
                  const SizedBox(height: 8),

                  // Available only
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available seats only',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.bodyText)),
                      Switch(
                        value: tempAvailable,
                        onChanged: (v) => setModal(() => tempAvailable = v),
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sortBy = tempSort;
                          _agencyFilter..clear()..addAll(tempAgencies);
                          _maxPrice = tempPrice < 5000 ? tempPrice : null;
                          _availableOnly = tempAvailable;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('Apply Filters',
                          style: GoogleFonts.sora(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        headerSliverBuilder: (_, __) => [
          // ── Collapsing app bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 168,
            collapsedHeight: 60,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 22),
                    onPressed: _openFilters,
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: _SortBar(
              sortBy: _sortBy,
              resultCount: results.length,
              onSort: (s) => setState(() => _sortBy = s),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.fromLTRB(52, 0, 52, 64),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(widget.from,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded,
                            color: Colors.white60, size: 14),
                      ),
                      Flexible(
                        child: Text(widget.to,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  if (widget.date != null)
                    Text(_fmtDate(widget.date!),
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white70)),
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
        body: results.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.07),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_off_rounded,
                          size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('No trips found',
                        style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Text('Try adjusting your filters',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.bodyTextSecondary)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _ResultCard(trip: results[i]),
              ),
      ),
    );
  }
}

// ── Sort bar (PreferredSizeWidget → SliverAppBar.bottom) ──────────────────────
class _SortBar extends StatelessWidget implements PreferredSizeWidget {
  const _SortBar({
    required this.sortBy,
    required this.resultCount,
    required this.onSort,
  });
  final _SortBy sortBy;
  final int resultCount;
  final ValueChanged<_SortBy> onSort;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text('$resultCount trip${resultCount != 1 ? 's' : ''}',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyTextSecondary)),
          const SizedBox(width: 10),
          _Chip(label: 'Earliest', selected: sortBy == _SortBy.earliest, onTap: () => onSort(_SortBy.earliest)),
          const SizedBox(width: 6),
          _Chip(label: 'Cheapest', selected: sortBy == _SortBy.cheapest, onTap: () => onSort(_SortBy.cheapest)),
          const SizedBox(width: 6),
          _Chip(label: 'Most Seats', selected: sortBy == _SortBy.mostSeats, onTap: () => onSort(_SortBy.mostSeats)),
        ],
      ),
    );
  }
}

// ── Result card — identical TicketWidget style as popular trips ───────────────
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.trip});
  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
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
                            Text(trip.to.trim(),
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
                    Text('Price',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.bodyTextSecondary)),
                    Text('RWF ${trip.amount}',
                        style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Seats left',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.bodyTextSecondary)),
                    Row(
                      children: [
                        Icon(Icons.event_seat_outlined,
                            size: 13,
                            color: isLow ? Colors.redAccent : AppColors.accent),
                        const SizedBox(width: 4),
                        Text('${trip.spotsAvailable}',
                            style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isLow ? Colors.redAccent : AppColors.accent)),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingsDetails(trip: trip)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
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

// ── Chip ──────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7F0),
            ),
          ),
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.bodyTextSecondary)),
        ),
      );
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
