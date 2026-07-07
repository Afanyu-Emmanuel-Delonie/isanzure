class AgencyModel {
  final String id;
  final String name;
  final String contactEmail;
  final String ownerId;
  final String createdAt;

  const AgencyModel({
    required this.id,
    required this.name,
    required this.contactEmail,
    required this.ownerId,
    required this.createdAt,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> j) => AgencyModel(
        id: j['id'],
        name: j['name'],
        contactEmail: j['contact_email'],
        ownerId: j['owner_id'],
        createdAt: j['created_at'],
      );
}
