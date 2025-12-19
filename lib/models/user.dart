class User {
  String id;
  String name;
  String email;
  String password;
  String role; // buyer or seller
  String? profilePhotoUrl;
  String? phone;
  String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.profilePhotoUrl,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'profilePhotoUrl': profilePhotoUrl,
        'phone': phone,
        'address': address,
      };

  @override
  String toString() => 'User{id: $id, name: $name, email: $email, role: $role}';
}
