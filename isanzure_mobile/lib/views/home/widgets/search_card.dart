import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_theme.dart';


// ── Rwanda cities ─────────────────────────────────────────────────────────────
const _rwandaCities = [
  'Kigali', 'Butare (Huye)', 'Gitarama (Muhanga)', 'Ruhengeri (Musanze)',
  'Gisenyi (Rubavu)', 'Byumba (Gicumbi)', 'Cyangugu (Rusizi)',
  'Kibungo (Ngoma)', 'Kibuye (Karongi)', 'Nyagatare', 'Rwamagana',
  'Kayonza', 'Kirehe', 'Bugesera', 'Rulindo', 'Gakenke', 'Burera',
  'Nyabihu', 'Ngororero', 'Karongi', 'Rutsiro', 'Nyamasheke',
  'Nyanza', 'Gisagara', 'Nyaruguru', 'Ruhango', 'Kamonyi',
  'Gasabo', 'Kicukiro', 'Nyarugenge',
];

// ── Time period enum ──────────────────────────────────────────────────────────
enum TimePeriod {
  morning('Morning', '05:00 – 11:59', Icons.wb_twilight_outlined, Color(0xFFFFF3E0)),
  midday('Midday', '12:00 – 13:59', Icons.wb_sunny_outlined, Color(0xFFFFFDE7)),
  afternoon('Afternoon', '14:00 – 17:59', Icons.wb_cloudy_outlined, Color(0xFFE3F2FD)),
  evening('Evening', '18:00 – 23:59', Icons.nights_stay_outlined, Color(0xFFEDE7F6));

  const TimePeriod(this.label, this.range, this.icon, this.bgColor);
  final String label;
  final String range;
  final IconData icon;
  final Color bgColor;
}

// ── Search Card ───────────────────────────────────────────────────────────────
class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mountCtrl;
  late final Animation<double> _mountFade;
  late final Animation<double> _mountScale;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  String? _from;
  String? _to;
  TimePeriod? _period;

  @override
  void initState() {
    super.initState();
    _mountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _mountFade =
        CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut);
    _mountScale = Tween<double>(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut));
    _mountCtrl.forward();
  }

  @override
  void dispose() {
    _mountCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  void _pickDate() {
    DateTime focused = _focusedDay;
    DateTime? selected = _selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DragHandle(),
              const SizedBox(height: 16),
              Text('Select Date',
                  style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: focused,
                selectedDayPredicate: (d) => isSameDay(d, selected),
                onDaySelected: (sel, foc) =>
                    setModal(() { selected = sel; focused = foc; }),
                onPageChanged: (foc) => setModal(() => focused = foc),
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.sora(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary),
                  leftChevronIcon: const Icon(Icons.chevron_left,
                      color: AppColors.primary),
                  rightChevronIcon: const Icon(Icons.chevron_right,
                      color: AppColors.primary),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyTextSecondary),
                  weekendStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: GoogleFonts.inter(
                      color: AppColors.accent, fontWeight: FontWeight.w700),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  weekendTextStyle:
                      GoogleFonts.inter(color: AppColors.secondary),
                  defaultTextStyle:
                      GoogleFonts.inter(color: AppColors.bodyText),
                  outsideTextStyle: GoogleFonts.inter(
                      color: AppColors.bodyTextSecondary.withOpacity(0.4)),
                  disabledTextStyle: GoogleFonts.inter(
                      color: AppColors.bodyTextSecondary.withOpacity(0.3)),
                ),
              ),
              const SizedBox(height: 12),
              _ConfirmButton(
                label: 'Confirm Date',
                enabled: selected != null,
                onPressed: () {
                  setState(() {
                    _selectedDate = selected;
                    _focusedDay = focused;
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Time period picker ────────────────────────────────────────────────────
  void _pickTime() {
    TimePeriod? temp = _period;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('When do you want to travel?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text('Choose a time of day',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.bodyTextSecondary)),
                const SizedBox(height: 20),
                // 2×2 period grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: TimePeriod.values.map((p) {
                    final isSelected = temp == p;
                    return GestureDetector(
                      onTap: () => setModal(() => temp = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE5E7F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.18)
                                    : p.bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(p.icon,
                                  size: 22,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            Text(p.label,
                                style: GoogleFonts.sora(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.bodyText)),
                            const SizedBox(height: 3),
                            Text(p.range,
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.bodyTextSecondary)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Cancel',
                            style: GoogleFonts.sora(
                                color: AppColors.bodyTextSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ConfirmButton(
                        label: 'Confirm',
                        enabled: temp != null,
                        onPressed: () {
                          setState(() => _period = temp);
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── City picker ───────────────────────────────────────────────────────────
  void _pickCity({required bool isFrom}) {
    final controller = TextEditingController();
    List<String> filtered = List.from(_rwandaCities);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DragHandle(),
                const SizedBox(height: 16),
                Text(isFrom ? 'Departure City' : 'Destination City',
                    style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.bodyText),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: GoogleFonts.inter(
                        color: AppColors.bodyTextSecondary, fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.primary, size: 20),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setModal(() {
                    filtered = _rwandaCities
                        .where((c) =>
                            c.toLowerCase().contains(v.toLowerCase()))
                        .toList();
                  }),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.38,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF0F0F5)),
                    itemBuilder: (_, i) => ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      leading: Icon(
                        isFrom
                            ? Icons.directions_bus_rounded
                            : Icons.location_on_rounded,
                        color: isFrom
                            ? AppColors.primary
                            : AppColors.secondary,
                        size: 20,
                      ),
                      title: Text(filtered[i],
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.bodyText)),
                      onTap: () {
                        setState(() {
                          if (isFrom) {
                            _from = filtered[i];
                          } else {
                            _to = filtered[i];
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _mountFade,
      child: ScaleTransition(
        scale: _mountScale,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Book A trip',
              style: GoogleFonts.sora(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          // ── From / To connector ──
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.primary),
                    ),
                    Expanded(
                        child: Container(
                            width: 2, color: const Color(0xFFE5E7F0))),
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.secondary, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      CityField(
                        value: _from,
                        hint: 'From — departure city',
                        icon: Icons.directions_bus_rounded,
                        iconColor: AppColors.primary,
                        onTap: () => _pickCity(isFrom: true),
                      ),
                      const SizedBox(height: 10),
                      CityField(
                        value: _to,
                        hint: 'To — destination city',
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.secondary,
                        onTap: () => _pickCity(isFrom: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF0F0F5), height: 1),
          const SizedBox(height: 14),

          // ── Date & Time ──
          Row(
            children: [
              Expanded(
                child: TappableField(
                  icon: Icons.calendar_today_outlined,
                  label: _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Date',
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TappableField(
                  icon: _period?.icon ?? Icons.access_time_outlined,
                  label: _period?.label ?? 'Time of day',
                  onTap: _pickTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                  'Search Trips',
                  style: GoogleFonts.sora(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// ── Reusable small widgets ────────────────────────────────────────────────────

class CityField extends StatelessWidget {
  const CityField({
    super.key,
    required this.value,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String? value;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? AppColors.primary.withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: GoogleFonts.inter(
                  color: hasValue
                      ? AppColors.bodyText
                      : AppColors.bodyTextSecondary,
                  fontSize: 13,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: hasValue
                    ? AppColors.primary
                    : AppColors.bodyTextSecondary),
          ],
        ),
      ),
    );
  }
}

class TappableField extends StatelessWidget {
  const TappableField({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      color: AppColors.bodyTextSecondary, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(label,
              style: GoogleFonts.sora(
                  fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
        ),
      );
}
