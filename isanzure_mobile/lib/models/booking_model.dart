class BookingModel {
  final String id;
  final int seatNumber;
  final String createdAt;
  final String userId;
  final String scheduleId;
  final String departureTime;
  final String origin;
  final String destination;
  final double price;
  final String plateNumber;
  final String agencyName;
  final String status;
  final String? paymentReference;
  final String? message;

  const BookingModel({
    required this.id,
    required this.seatNumber,
    required this.createdAt,
    required this.userId,
    required this.scheduleId,
    required this.departureTime,
    required this.origin,
    required this.destination,
    required this.price,
    required this.plateNumber,
    required this.agencyName,
    required this.status,
    this.paymentReference,
    this.message,
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) => BookingModel(
        id: j['id'],
        seatNumber: j['seat_number'],
        createdAt: j['created_at'],
        userId: j['user_id'],
        scheduleId: j['schedule_id'],
        departureTime: j['departure_time'],
        origin: j['origin'],
        destination: j['destination'],
        price: (j['price'] as num).toDouble(),
        plateNumber: j['plate_number'],
        agencyName: j['agency_name'],
        status: j['status'] ?? 'pending',
        paymentReference: j['payment_reference'],
        message: j['message'],
      );
}
