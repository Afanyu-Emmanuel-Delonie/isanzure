class RouteModel {
  final String id;
  final String origin;
  final String destination;
  final double price;

  const RouteModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
  });

  factory RouteModel.fromJson(Map<String, dynamic> j) => RouteModel(
        id: j['id'],
        origin: j['origin'],
        destination: j['destination'],
        price: (j['price'] as num).toDouble(),
      );
}
