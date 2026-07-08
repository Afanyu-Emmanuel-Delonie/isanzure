// ── Mock model ────────────────────────────────────────────────────────────────
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

