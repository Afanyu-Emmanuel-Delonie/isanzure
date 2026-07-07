class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? agencyId;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.agencyId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        phone: j['phone'],
        role: j['role'],
        agencyId: j['agency_id'],
        createdAt: j['created_at'],
      );
}
