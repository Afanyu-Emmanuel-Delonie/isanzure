class ScheduleModel {
  final String id;
  final String departureTime;
  final String origin;
  final String destination;
  final double price;
  final String plateNumber;
  final int capacity;
  final String agencyId;
  final String agencyName;
  final List<int> bookedSeats;
  final int? availableSeats;

  const ScheduleModel({
    required this.id,
    required this.departureTime,
    required this.origin,
    required this.destination,
    required this.price,
    required this.plateNumber,
    required this.capacity,
    required this.agencyId,
    required this.agencyName,
    this.bookedSeats = const [],
    this.availableSeats,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> j) => ScheduleModel(
        id: j['id'],
        departureTime: j['departure_time'],
        origin: j['origin'],
        destination: j['destination'],
        price: (j['price'] as num).toDouble(),
        plateNumber: j['plate_number'],
        capacity: j['capacity'],
        agencyId: j['agency_id'] ?? '',
        agencyName: j['agency_name'] ?? '',
        bookedSeats: (j['booked_seats'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        availableSeats: j['available_seats'],
      );
}
