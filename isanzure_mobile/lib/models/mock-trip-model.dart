// ── Recent booking model ─────────────────────────────────────────────────────
class RecentBooking {
  const RecentBooking({
    required this.trip,
    required this.ref,
    required this.seat,
    required this.bookedOn,
  });
  final TripSummary trip;
  final String ref;
  final int seat;
  final String bookedOn;
}

const mockRecentBookings = [
  RecentBooking(
    ref: 'ISZ4829301',
    seat: 14,
    bookedOn: 'Jul 8, 2025',
    trip: TripSummary(
      from: 'Kigali',
      to: 'Butare',
      date: 'Jul 8, 2025',
      takeoffTime: '07:00 AM',
      amount: 2500,
      spotsAvailable: 10,
      agency: 'Volcano Express',
      plateNumber: 'RAC 412 B',
    ),
  ),
  RecentBooking(
    ref: 'ISZ5530182',
    seat: 6,
    bookedOn: 'Jul 5, 2025',
    trip: TripSummary(
      from: 'Kigali',
      to: 'Gisenyi',
      date: 'Jul 5, 2025',
      takeoffTime: '06:30 AM',
      amount: 3000,
      spotsAvailable: 5,
      agency: 'Virunga Express',
      plateNumber: 'RAB 887 C',
    ),
  ),
  RecentBooking(
    ref: 'ISZ6671045',
    seat: 22,
    bookedOn: 'Jul 1, 2025',
    trip: TripSummary(
      from: 'Rubavu',
      to: 'Kigali',
      date: 'Jul 1, 2025',
      takeoffTime: '05:45 AM',
      amount: 4000,
      spotsAvailable: 2,
      agency: 'Horizon Express',
      plateNumber: 'RAE 556 D',
    ),
  ),
];

// ── Trip model ────────────────────────────────────────────────────────────────
class TripSummary {
  const TripSummary({
    required this.from,
    required this.to,
    required this.date,
    required this.takeoffTime,
    required this.amount,
    required this.spotsAvailable,
    required this.agency,
    required this.plateNumber,
  });

  final String from;
  final String to;
  final String date;
  final String takeoffTime;
  final int amount;
  final int spotsAvailable;
  final String agency;
  final String plateNumber;
}

